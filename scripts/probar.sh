#!/usr/bin/env bash
# Pruebas: unitarias del plugin, documentos de prueba, ejemplos, kitchen sink de dibu,
# errores de compilación esperados y el paquete instalado como @local.
#   DIBU_DIR: ruta al repositorio dibu (por omisión ../dibu).
set -euo pipefail
cd "$(dirname "$0")/.."
dibu_dir=$(realpath "${DIBU_DIR:-../dibu}")
salida=salida; mkdir -p "$salida"

cargo test --quiet
[ -f paquete/dibu.wasm ] || scripts/construir.sh

for f in pruebas/basico.typ ejemplos/*.typ; do
  typst compile --root . "$f" "$salida/$(basename "$f" .typ).pdf"
  echo "✓ $f"
done

# Todos los bloques del kitchen sink de dibu, con el theme por omisión y el oscuro.
typst compile --root "$(dirname "$dibu_dir")" --input "dibu=/$(basename "$dibu_dir")" \
  pruebas/kitchen-sink.typ "$salida/kitchen-sink.pdf"
echo "✓ kitchen sink de dibu"

# Un bloque inválido es un error de compilación con el mensaje de dibu.
casos=(
  '#dibu("type: no_existe")'
  '#dibu("type: stack\nvalues: [1]", theme: "no-existe")'
  '#dibu("type: stack\nvalues: [1, 2")'
)
for caso in "${casos[@]}"; do
  printf '#import "../paquete/lib.typ": dibu\n%s\n' "$caso" > "$salida/error.typ"
  if typst compile --root . "$salida/error.typ" "$salida/error.pdf" 2> "$salida/error.log"; then
    echo "✗ se esperaba un error para: $caso"; exit 1
  fi
  grep -q "dibu:" "$salida/error.log" || { cat "$salida/error.log"; exit 1; }
done
echo "✓ errores de dibu como errores de compilación"

# El paquete instalado como @local, en un directorio de datos temporal.
version=$(sed -n 's/^version *= *"\(.*\)"/\1/p' paquete/typst.toml)
export XDG_DATA_HOME="$PWD/$salida/datos"
scripts/instalar-local.sh > /dev/null
printf '#import "@local/dibu:%s": dibu\n#dibu("type: stack\\nvalues: [1, 2]")\n' "$version" > "$salida/local.typ"
typst compile --package-path "$XDG_DATA_HOME/typst/packages" "$salida/local.typ" "$salida/local.pdf"
echo "✓ @local/dibu:$version"
