//! Plugin de Typst con el motor de dibu.
//!
//! Implementa el protocolo de plugins de Typst (wasm-minimal-protocol): cada función exportada
//! recibe las longitudes de sus argumentos (bytes), los pide al host con
//! `wasm_minimal_protocol_write_args_to_buffer` y devuelve el resultado con
//! `wasm_minimal_protocol_send_result_to_host`. El código de retorno es 0 si salió bien y 1 si
//! el resultado es un mensaje de error, que Typst muestra como error de compilación.

use dibu_wasm::Theme;
use serde_json::{json, Value};

#[cfg(target_arch = "wasm32")]
#[link(wasm_import_module = "typst_env")]
extern "C" {
    fn wasm_minimal_protocol_send_result_to_host(ptr: *const u8, len: usize);
    fn wasm_minimal_protocol_write_args_to_buffer(ptr: *mut u8);
}

/// Lee los argumentos, de las longitudes dadas, desde el host.
#[cfg(target_arch = "wasm32")]
fn argumentos(longitudes: &[usize]) -> Vec<Vec<u8>> {
    let total = longitudes.iter().sum();
    let mut buffer = vec![0u8; total];
    unsafe { wasm_minimal_protocol_write_args_to_buffer(buffer.as_mut_ptr()) };
    let mut salida = Vec::with_capacity(longitudes.len());
    let mut desde = 0;
    for &n in longitudes {
        salida.push(buffer[desde..desde + n].to_vec());
        desde += n;
    }
    salida
}

/// Envía el resultado al host y devuelve el código de retorno del protocolo.
#[cfg(target_arch = "wasm32")]
fn responder(r: Result<Vec<u8>, String>) -> i32 {
    let (bytes, codigo) = match r {
        Ok(b) => (b, 0),
        Err(e) => (e.into_bytes(), 1),
    };
    unsafe { wasm_minimal_protocol_send_result_to_host(bytes.as_ptr(), bytes.len()) };
    codigo
}

fn texto(bytes: &[u8], que: &str) -> Result<String, String> {
    String::from_utf8(bytes.to_vec()).map_err(|_| format!("dibu: {que} no es UTF-8 válido"))
}

/// El theme: JSON `null`, un nombre (`"dark"`) o `{extends, colors, typography}`.
fn tema(bytes: &[u8]) -> Result<Theme, String> {
    let t = texto(bytes, "el theme")?;
    let v: Value = if t.trim().is_empty() {
        Value::Null
    } else {
        serde_json::from_str(&t).map_err(|e| format!("dibu: theme inválido: {e}"))?
    };
    dibu_wasm::leer_tema(Some(&v)).map_err(|e| format!("dibu: {e}"))
}

/// Dibuja el texto YAML/JSON (uno o varios bloques, apilados como en `dibu sync-md`) y
/// devuelve el SVG.
pub fn render(fuente: &[u8], theme: &[u8]) -> Result<Vec<u8>, String> {
    let cuerpo = texto(fuente, "el bloque")?;
    if cuerpo.trim().is_empty() {
        return Err("dibu: el bloque está vacío".into());
    }
    let v = dibu_wasm::render_md(&cuerpo, &tema(theme)?);
    match (v.get("svg").and_then(Value::as_str), v.get("error").and_then(Value::as_str)) {
        (Some(svg), _) => Ok(svg.as_bytes().to_vec()),
        (_, Some(e)) => Err(format!("dibu: {e}")),
        _ => Err("dibu: respuesta inesperada del motor".into()),
    }
}

/// Los tipos y títulos de los bloques (para el texto alternativo): `{"types": […], "titles": […]}`.
pub fn info(fuente: &[u8]) -> Result<Vec<u8>, String> {
    let cuerpo = texto(fuente, "el bloque")?;
    let v = dibu_wasm::render_md(&cuerpo, &Theme::para_tinta(true));
    let r = json!({ "name": v["name"], "types": v["types"], "titles": v["titles"] });
    Ok(r.to_string().into_bytes())
}

#[cfg(target_arch = "wasm32")]
mod exportadas {
    use super::*;

    #[no_mangle]
    pub extern "C" fn render(fuente: usize, theme: usize) -> i32 {
        let a = argumentos(&[fuente, theme]);
        responder(super::render(&a[0], &a[1]))
    }

    #[no_mangle]
    pub extern "C" fn info(fuente: usize) -> i32 {
        let a = argumentos(&[fuente]);
        responder(super::info(&a[0]))
    }

    #[no_mangle]
    pub extern "C" fn types() -> i32 {
        responder(Ok(dibu_wasm::tipos().to_string().into_bytes()))
    }

    #[no_mangle]
    pub extern "C" fn themes() -> i32 {
        responder(Ok(dibu_wasm::themes().to_string().into_bytes()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn dibuja_y_reporta_errores() {
        let svg = render(b"type: stack\nvalues: [3, 7]\n", b"null").unwrap();
        assert!(svg.starts_with(b"<svg"));
        assert!(render(b"type: stack\nvalues: [1]\n", b"\"dark\"").is_ok());
        assert!(render(b"type: stack\nvalues: [1]\n", b"\"no-existe\"").is_err());
        assert!(render(b"type: no_existe\n", b"null").unwrap_err().starts_with("dibu:"));
        assert!(render(b"  \n", b"null").is_err());
        let i: Value = serde_json::from_slice(&info(b"type: stack\ntitle: Pila\n").unwrap()).unwrap();
        assert_eq!(i["types"][0], "stack");
        assert_eq!(i["titles"][0], "Pila");
    }
}
