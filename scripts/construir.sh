#!/usr/bin/env bash
# Compila el plugin y lo deja en paquete/dibu.wasm (optimizado con wasm-opt si está instalado).
#   DIBU_DIR: ruta al repositorio dibu (por omisión ../dibu, como lo espera Cargo.toml).
set -euo pipefail
cd "$(dirname "$0")/.."
cargo build --release --target wasm32-unknown-unknown
crudo=target/wasm32-unknown-unknown/release/dibu_typst_plugin.wasm
if command -v wasm-opt > /dev/null; then
  wasm-opt -Os --enable-bulk-memory --enable-nontrapping-float-to-int --enable-sign-ext \
    --enable-mutable-globals --enable-multivalue --enable-reference-types \
    "$crudo" -o paquete/dibu.wasm
  echo "· wasm-opt aplicado"
else
  cp "$crudo" paquete/dibu.wasm
fi
echo "✓ paquete/dibu.wasm ($(du -h paquete/dibu.wasm | cut -f1))"
