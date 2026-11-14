use rquickjs::{Coerced, Context, FromJs, Function, Promise, Runtime, Value as JsValue};
use serde_json::{json, Value};
use std::{
    io::Read,
    time::{Duration, Instant},
};

pub fn sanitize(name: &str) -> String {
    let s: String = name
        .chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || c == '_' || c == '-' {
                c
            } else {
                '_'
            }
        })
        .take(64)
        .collect();
    if s.is_empty() {
        "tool".into()
    } else {
        s
    }
}
pub async fn run(code: String, args: Value) -> Value {
    match tokio::task::spawn_blocking(move || execute(&code, &args, Duration::from_secs(10))).await
    {
        Ok(v) => v,
        Err(e) => json!({"result":e.to_string(),"logs":[],"is_error":true,"duration_ms":0}),
    }
}
fn execute(code: &str, args: &Value, limit: Duration) -> Value {
    let start = Instant::now();
    let mut logs = vec![];
    let result = (|| -> anyhow::Result<String> {
        let rt = Runtime::new()?;
        rt.set_memory_limit(64 * 1024 * 1024);
        rt.set_max_stack_size(1024 * 1024);
        rt.set_interrupt_handler(Some(Box::new(move || start.elapsed() >= limit)));
        let ctx = Context::full(&rt)?;
        ctx.with(|ctx|->anyhow::Result<String>{
            let http=Function::new(ctx.clone(),move|method:String,url:String,body:String,headers:String|->String{
                let result=(||->anyhow::Result<Value>{
                    let remaining=limit.saturating_sub(start.elapsed());if remaining.is_zero(){anyhow::bail!("execution timed out");}
                    let client=reqwest::blocking::Client::builder().timeout(remaining.min(Duration::from_secs(15))).build()?;
                    let mut request=client.request(reqwest::Method::from_bytes(method.as_bytes())?,url);
                    if !body.is_empty(){request=request.body(body);}
                    let headers:Value=serde_json::from_str(&headers)?;if let Some(h)=headers.as_object(){for (k,v) in h{if let Some(v)=v.as_str(){request=request.header(k,v);}}}
                    let response=request.send()?;let status=response.status().as_u16();let mut bytes=vec![];response.take(1024*1024+1).read_to_end(&mut bytes)?;if bytes.len()>1024*1024{anyhow::bail!("HTTP response exceeds 1MB");}
                    Ok(json!({"status":status,"body":String::from_utf8_lossy(&bytes)}))
                })();match result{Ok(v)=>v.to_string(),Err(e)=>json!({"error":e.to_string()}).to_string()}
            })?;
            ctx.globals().set("__http",http)?;
            ctx.eval::<(),_>(r#"globalThis.__logs=[]; globalThis.console={}; for(const level of ['log','info','warn','error']) console[level]=(...args)=>__logs.push(args.map(x=>typeof x==='string'?x:JSON.stringify(x)).join(' ')); globalThis.http=(method,url,body,headers)=>{const r=JSON.parse(__http(String(method),String(url),body===undefined?'':typeof body==='string'?body:JSON.stringify(body),JSON.stringify(headers||{})));if(r.error)throw Error(r.error);return r;};"#)?;
            let eval=(||->rquickjs::Result<String>{
                ctx.eval::<(),_>(code)?;
                let main:JsValue=ctx.globals().get("main")?;if !main.is_function(){return Err(rquickjs::Error::new_from_js_message("undefined","function","main(args) is required"));}
                ctx.globals().set("__args",ctx.json_parse(args.to_string())?)?;
                let promise:Promise=ctx.eval("Promise.resolve(main(__args)).then(v => typeof v === 'string' ? v : v === undefined ? 'undefined' : JSON.stringify(v))")?;
                promise.finish::<String>()
            })();
            let log_json:String=ctx.eval("JSON.stringify(__logs)").unwrap_or_else(|_|"[]".into());logs=serde_json::from_str::<Vec<String>>(&log_json).unwrap_or_default();
            match eval{Ok(v)=>Ok(v),Err(e)=>{let exception=Coerced::<String>::from_js(&ctx,ctx.catch()).map(|s|s.0).unwrap_or_default();if start.elapsed()>=limit{anyhow::bail!("execution timed out");}anyhow::bail!("JavaScript error: {e}: {exception}");}}
        })
    })();
    let is_error = result.is_err();
    let mut output = result.unwrap_or_else(|e| e.to_string());
    if !logs.is_empty() {
        output.push_str("\n\n[console]\n");
        output.push_str(&logs.join("\n"));
    }
    json!({"result":output,"logs":logs,"is_error":is_error,"duration_ms":start.elapsed().as_millis() as i64})
}
#[cfg(test)]
mod tests {
    use super::*;
    #[tokio::test]
    async fn sync_async_and_console() {
        let v = run(
            "function main(a){console.log('hello',a.n);return {n:a.n+1}}".into(),
            json!({"n":2}),
        )
        .await;
        assert_eq!(v["is_error"], false);
        assert!(v["result"].as_str().unwrap().contains("{\"n\":3}"));
        assert_eq!(v["logs"][0], "hello 2");
        let v = run(
            "async function main(){await Promise.resolve();return 'ok'}".into(),
            json!({}),
        )
        .await;
        assert_eq!(v["result"], "ok");
        assert_eq!(
            run("function main(){}".into(), json!({})).await["result"],
            "undefined"
        );
    }
    #[tokio::test]
    async fn missing_and_unresolved() {
        assert_eq!(run("const x=1".into(), json!({})).await["is_error"], true);
        assert_eq!(
            run(
                "function main(){return new Promise(()=>{})}".into(),
                json!({})
            )
            .await["is_error"],
            true
        );
    }
    #[test]
    fn timeout() {
        let v = execute(
            "function main(){while(true){}}",
            &json!({}),
            Duration::from_millis(25),
        );
        assert_eq!(v["is_error"], true);
        assert!(v["result"].as_str().unwrap().contains("timed out"));
    }
}
