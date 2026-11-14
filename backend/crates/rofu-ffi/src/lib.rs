use rofu_core::{start_server, Config, RunningServer};
use serde::Deserialize;
use serde_json::json;
use std::{
    ffi::{CStr, CString},
    os::raw::c_char,
    sync::{Mutex, OnceLock},
};
use tokio::runtime::Runtime;
struct Embedded {
    runtime: Runtime,
    server: Option<RunningServer>,
}
static INSTANCE: OnceLock<Mutex<Embedded>> = OnceLock::new();
fn instance() -> Result<&'static Mutex<Embedded>, String> {
    if let Some(v) = INSTANCE.get() {
        return Ok(v);
    }
    let rt = tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .map_err(|e| e.to_string())?;
    let _ = INSTANCE.set(Mutex::new(Embedded {
        runtime: rt,
        server: None,
    }));
    Ok(INSTANCE.get().unwrap())
}
#[derive(Deserialize)]
struct Input {
    data_dir: String,
    root_password: String,
    #[serde(default = "listen")]
    listen: String,
}
fn listen() -> String {
    "127.0.0.1:0".into()
}
fn start(input: &str) -> Result<u16, String> {
    let mut embedded = instance()?.lock().map_err(|e| e.to_string())?;
    if let Some(ref server) = embedded.server {
        return Ok(server.address.port());
    }
    let cfg: Input = serde_json::from_str(input).map_err(|e| e.to_string())?;
    std::fs::create_dir_all(&cfg.data_dir).map_err(|e| e.to_string())?;
    let path = std::path::Path::new(&cfg.data_dir).join("rofuchat.db");
    let server = embedded
        .runtime
        .block_on(start_server(Config {
            database: format!("sqlite://{}?mode=rwc", path.display()),
            listen: cfg.listen,
            root_password: Some(cfg.root_password),
            embedded: true,
            ..Config::default()
        }))
        .map_err(|e| e.to_string())?;
    let port = server.address.port();
    embedded.server = Some(server);
    Ok(port)
}
/// Start the embedded server. The returned string must be freed by rofu_free_string.
///
/// # Safety
/// config_json must point to a valid NUL-terminated UTF-8 string for the duration of the call.
#[no_mangle]
pub unsafe extern "C" fn rofu_start(config_json: *const c_char) -> *mut c_char {
    let outcome = std::panic::catch_unwind(|| {
        if config_json.is_null() {
            return Err("config_json is null".into());
        }
        let input = unsafe { CStr::from_ptr(config_json) }
            .to_str()
            .map_err(|e| e.to_string())?;
        start(input)
    });
    let result = match outcome {
        Ok(Ok(port)) => json!({"ok":true,"port":port}),
        Ok(Err(e)) => json!({"ok":false,"error":e}),
        Err(_) => json!({"ok":false,"error":"backend panic"}),
    };
    CString::new(result.to_string()).unwrap().into_raw()
}
#[no_mangle]
pub extern "C" fn rofu_stop() -> i32 {
    let result = std::panic::catch_unwind(|| -> Result<(), String> {
        if let Some(instance) = INSTANCE.get() {
            let mut embedded = instance.lock().map_err(|e| e.to_string())?;
            if let Some(server) = embedded.server.take() {
                embedded
                    .runtime
                    .block_on(server.stop())
                    .map_err(|e| e.to_string())?;
            }
        }
        Ok(())
    });
    if matches!(result, Ok(Ok(()))) {
        0
    } else {
        -1
    }
}
/// Release a string returned by rofu_start. NULL is accepted.
///
/// # Safety
/// s must be NULL or an unfreed pointer returned by rofu_start.
#[no_mangle]
pub unsafe extern "C" fn rofu_free_string(s: *mut c_char) {
    if !s.is_null() {
        drop(unsafe { CString::from_raw(s) });
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn start_health_stop() {
        let dir = tempfile::tempdir().unwrap();
        let config =
            CString::new(json!({"data_dir":dir.path(),"root_password":"test-secret"}).to_string())
                .unwrap();
        let ptr = unsafe { rofu_start(config.as_ptr()) };
        let value: serde_json::Value =
            serde_json::from_str(unsafe { CStr::from_ptr(ptr) }.to_str().unwrap()).unwrap();
        unsafe { rofu_free_string(ptr) };
        assert_eq!(value["ok"], true, "{value}");
        let health: serde_json::Value = reqwest::blocking::Client::builder()
            .no_proxy()
            .build()
            .unwrap()
            .get(format!("http://127.0.0.1:{}/api/health", value["port"]))
            .send()
            .unwrap()
            .json()
            .unwrap();
        assert_eq!(health["embedded"], true);
        let again = unsafe { rofu_start(config.as_ptr()) };
        let repeated: serde_json::Value =
            serde_json::from_str(unsafe { CStr::from_ptr(again) }.to_str().unwrap()).unwrap();
        unsafe { rofu_free_string(again) };
        assert_eq!(repeated["port"], value["port"]);
        assert_eq!(rofu_stop(), 0);
    }
}
