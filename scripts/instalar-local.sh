#!/usr/bin/env bash
# Instala el paquete como @local/dibu:<versión>, para usarlo desde cualquier documento:
#   #import "@local/dibu:0.1.0": dibu
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f paquete/dibu.wasm ] || scripts/construir.sh
version=$(sed -n 's/^version *= *"\(.*\)"/\1/p' paquete/typst.toml)
case "$(uname -s)" in
  Darwin) datos="$HOME/Library/Application Support" ;;
  MINGW*|MSYS*|CYGWIN*) datos="$APPDATA" ;;
  *) datos="${XDG_DATA_HOME:-$HOME/.local/share}" ;;
esac
destino="$datos/typst/packages/local/dibu/$version"
rm -rf "$destino"
mkdir -p "$destino"
cp -r paquete/. "$destino/"
echo "✓ @local/dibu:$version en $destino"
