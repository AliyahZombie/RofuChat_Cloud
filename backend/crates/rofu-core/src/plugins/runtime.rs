//! Each invocation owns an AsyncRuntime on a bounded blocking worker. Only JSON
//! strings cross the JS/host boundary; host futures never retain a Ctx or Value.
use super::{HOOK_TIMEOUT, INVOCATION_TIMEOUT, MEMORY_LIMIT, STACK_LIMIT};
use anyhow::{anyhow, Result};
use rquickjs::{
    async_with, function::Async, AsyncContext, AsyncRuntime, Coerced, FromJs, Function, Module,
    Promise,
};
use serde_json::{json, Value};
use std::{
    future::Future,
    pin::Pin,
    sync::Arc,
    time::{Duration, Instant},
};
use tokio_util::sync::CancellationToken;

pub type HostFuture = Pin<Box<dyn Future<Output = Result<Value>> + Send>>;
pub type Host = Arc<dyn Fn(String, Value) -> HostFuture + Send + Sync>;

pub async fn compile(code: String) -> Result<()> {
    tokio::task::spawn_blocking(move || {
        let rt = rquickjs::Runtime::new()?;
        rt.set_memory_limit(MEMORY_LIMIT);
        rt.set_max_stack_size(STACK_LIMIT);
        let start = Instant::now();
        rt.set_interrupt_handler(Some(Box::new(move || start.elapsed() >= HOOK_TIMEOUT)));
        let ctx = rquickjs::Context::full(&rt)?;
        ctx.with(|ctx| {
            Module::declare(ctx.clone(), "plugin", code)
                .map(|_| ())
                .map_err(|e| exception(&ctx, e))
        })
    })
    .await?
}
fn exception(ctx: &rquickjs::Ctx<'_>, e: rquickjs::Error) -> anyhow::Error {
    let caught = ctx.catch();
    let code = caught
        .as_object()
        .and_then(|o| o.get::<_, String>("code").ok())
        .filter(|code| {
            matches!(
                code.as_str(),
                "E_VALIDATION"
                    | "E_LIMIT"
                    | "E_PERMISSION"
                    | "E_PHASE"
                    | "E_NOT_FOUND"
                    | "E_CONFLICT"
                    | "E_TIMEOUT"
                    | "E_CANCELLED"
            )
        })
        .unwrap_or_else(|| "E_JS".into());
    let detail = Coerced::<String>::from_js(ctx, caught)
        .map(|s| s.0)
        .unwrap_or_default();
    anyhow!("{code}: {e}: {detail}")
}
pub async fn run(
    code: String,
    handler: String,
    payload: Value,
    invocation: Value,
    host: Host,
    hook: bool,
    cancel: CancellationToken,
) -> Result<Value> {
    let handle = tokio::runtime::Handle::current();
    tokio::task::spawn_blocking(move || {
        handle.block_on(execute(
            code,
            handler,
            payload,
            invocation,
            host,
            if hook {
                HOOK_TIMEOUT
            } else {
                INVOCATION_TIMEOUT
            },
            cancel,
        ))
    })
    .await?
}
#[allow(clippy::too_many_arguments)]
async fn execute(
    code: String,
    handler: String,
    payload: Value,
    invocation: Value,
    host: Host,
    limit: Duration,
    cancel: CancellationToken,
) -> Result<Value> {
    let start = Instant::now();
    let interrupted = cancel.clone();
    let rt = AsyncRuntime::new()?;
    rt.set_memory_limit(MEMORY_LIMIT).await;
    rt.set_max_stack_size(STACK_LIMIT).await;
    rt.set_interrupt_handler(Some(Box::new(move || {
        start.elapsed() >= limit || interrupted.is_cancelled()
    })))
    .await;
    let context = AsyncContext::full(&rt).await?;
    let work = async_with!(context => |ctx| {
        let bridge=Function::new(ctx.clone(),Async(move |method:String,encoded:String| {
            let host=host.clone();
            async move {
                let result=match serde_json::from_str(&encoded){Ok(args)=>host(method,args).await,Err(e)=>Err(e.into())};
                match result {Ok(value)=>json!({"ok":true,"value":value}).to_string(),Err(e)=>json!({"ok":false,"error":e.to_string()}).to_string()}
            }
        })).map_err(|e|exception(&ctx,e))?;
        ctx.globals().set("__host",bridge).map_err(|e|exception(&ctx,e))?;
        ctx.globals().set("__invocation",ctx.json_parse(invocation.to_string()).map_err(|e|exception(&ctx,e))?).map_err(|e|exception(&ctx,e))?;
        ctx.globals().set("__payload",ctx.json_parse(payload.to_string()).map_err(|e|exception(&ctx,e))?).map_err(|e|exception(&ctx,e))?;
        ctx.eval::<(),_>(include_str!("rofu.js")).map_err(|e|exception(&ctx,e))?;
        let (module,ready)=Module::declare(ctx.clone(),"plugin",code).and_then(|m|m.eval()).map_err(|e|exception(&ctx,e))?;
        ready.into_future::<()>().await.map_err(|e|exception(&ctx,e))?;
        let function:Function=module.get(handler.as_str()).map_err(|e|exception(&ctx,e))?;
        ctx.globals().set("__handler",function).map_err(|e|exception(&ctx,e))?;
        let promise:Promise=ctx.eval("Promise.resolve(__handler(__payload, rofu.invocation)).then(v => JSON.stringify(v === undefined ? null : v))").map_err(|e|exception(&ctx,e))?;
        let encoded=promise.into_future::<String>().await.map_err(|e|exception(&ctx,e))?;
        if encoded.len()>1024*1024 { return Err(anyhow!("E_LIMIT: handler result exceeds 1 MiB")); }
        Ok::<Value,anyhow::Error>(serde_json::from_str(&encoded)?)
    });
    let output = tokio::select! {
        _=cancel.cancelled()=>Err(anyhow!("E_CANCELLED: invocation cancelled")),
        result=tokio::time::timeout(limit,work)=>result.map_err(|_|anyhow!("E_TIMEOUT: invocation timed out"))?,
    };
    if start.elapsed() >= limit {
        return Err(anyhow!("E_TIMEOUT: invocation timed out"));
    }
    if cancel.is_cancelled() {
        return Err(anyhow!("E_CANCELLED: invocation cancelled"));
    }
    output
}
