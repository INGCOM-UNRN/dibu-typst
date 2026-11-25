# dibu-typst

Integración de [dibu](https://github.com/INGCOM-UNRN/dibu) con [Typst](https://typst.app): un
paquete de Typst con un plugin WebAssembly que dibuja los diagramas de dibu dentro del
documento, al compilar, sin binarios externos ni SVG pregenerados.

```typ
#import "@local/dibu:0.1.0": dibu, dibu-bloques

#show: dibu-bloques            // los bloques ```estructura se dibujan solos
#dibu("type: stack\nvalues: [3, 7, 1]", theme: "color", width: 50%)
```

La documentación del paquete está en [`paquete/README.md`](paquete/README.md), y hay ejemplos
en [`ejemplos/`](ejemplos/): un apunte y un examen con el modo ejercicio.

## Instalación

Desde un [release](https://github.com/INGCOM-UNRN/dibu-typst/releases): descomprimir
`dibu-typst-X.Y.Z.tar.gz` en el directorio de paquetes locales de Typst
(`~/.local/share/typst/packages/local/` en Linux,
`~/Library/Application Support/typst/packages/local/` en macOS y
`%APPDATA%\typst\packages\local\` en Windows) e importar `@local/dibu:X.Y.Z`.

Desde el código (requiere Rust con el target `wasm32-unknown-unknown` y el repositorio `dibu`
al lado, en `../dibu`):

```bash
scripts/construir.sh        # compila el plugin → paquete/dibu.wasm (usa wasm-opt si está)
scripts/instalar-local.sh   # lo instala como @local/dibu:<versión>
scripts/probar.sh           # pruebas (ver abajo)
```

## Cómo funciona

- `src/lib.rs`: el plugin. Implementa el protocolo de plugins de Typst
  (*wasm-minimal-protocol*) sobre la API pura del crate `dibu-wasm` de dibu: `render` (bloque y
  theme → SVG), `info` (tipos y títulos, para el texto alternativo), `types` y `themes`.
- `paquete/`: el paquete de Typst (`typst.toml`, `lib.typ`, `dibu.wasm` y su README). Typst
  carga el plugin con `plugin("dibu.wasm")` y muestra el SVG con `image(…, format: "svg")`.
- El SVG es el mismo que generan `dibu render`, `dibu sync-md`, dibu-web y dibu-myst.

## Pruebas

`scripts/probar.sh` corre las pruebas unitarias del plugin y compila:

- `pruebas/basico.typ`: texto, diccionarios, bloques raw, themes y bloques apilados;
- los ejemplos;
- `pruebas/kitchen-sink.typ`: todos los bloques del kitchen sink de dibu, con el theme por
  omisión y el oscuro, para verificar que Typst acepte cada SVG;
- documentos con errores, que tienen que fallar con el mensaje de dibu;
- un documento que importa el paquete instalado como `@local`.

## Integración continua y publicación

- `ci.yml`: en cada push y PR, y a mano eligiendo la rama o el tag de dibu. Clona
  `INGCOM-UNRN/dibu` al lado, construye el plugin y corre `scripts/probar.sh` con la versión
  mínima de Typst declarada y con la última. Deja como artefacto el paquete y los PDF.
- `release.yml`: al empujar un tag `vX.Y.Z` igual a la versión de `paquete/typst.toml` y de
  `Cargo.toml`, publica `dibu-typst-X.Y.Z.tar.gz` (el paquete listo para `@local`) con las
  notas y el commit de dibu usado.
- `mantenimiento.yml`: los lunes compila y prueba contra `dibu` `main`.

Para publicarlo en [Typst Universe](https://typst.app/universe) (`@preview/dibu`), se copia el
contenido del tarball a `packages/preview/dibu/X.Y.Z/` en un fork de
[typst/packages](https://github.com/typst/packages) y se abre un pull request.

## Licencia

GPL-3.0-or-later, como dibu.
