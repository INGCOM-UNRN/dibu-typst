# dibu

Diagramas educativos para Typst a partir de bloques YAML/JSON: estructuras de datos y
algoritmos, sistemas digitales y de computación, control de procesos, química, señales,
probabilidad y circuitos. Son 71 tipos, y el modo ejercicio deja en blanco lo que se tiene que
completar.

*Educational diagrams (data structures, digital systems, control, chemistry, signals,
probability, circuits) from YAML/JSON blocks, with an exercise mode for exams.*

El motor es [dibu](https://github.com/INGCOM-UNRN/dibu), compilado como plugin WebAssembly:
no hace falta instalar nada más. El [manual de dibu](https://ingcom-unrn.github.io/dibu/)
describe cada tipo de diagrama con todos sus campos.

```typ
#import "@preview/dibu:0.1.0": dibu, dibu-bloques, dibu-config

// Texto YAML o JSON
#dibu("type: stack\nvalues: [3, 7, 1]\ncapacity: 5")

// Un diccionario de Typst, que se puede calcular
#dibu((type: "karnaugh", vars: ("A", "B", "C"), minterms: (1, 3, 5, 7)), width: 60%)

// Los bloques ```estructura, ```statics y ```dibu del documento se dibujan solos
#show: dibu-bloques
```

## Funciones

### `dibu(bloque, theme: auto, width: auto, height: auto, fit: "contain", alt: auto)`

Dibuja uno o varios bloques (una lista YAML se apila verticalmente, como en `dibu sync-md`).

- `bloque`: texto YAML/JSON, un bloque `raw` o un diccionario (o una lista de diccionarios).
- `theme`: `auto` toma el del documento (ver `dibu-config`); `none` es tinta (blanco y negro);
  también un nombre (`"color"`, `"high-contrast"`, `"dark"`, ver `themes`) o un diccionario
  `(extends: "color", colors: (accentPrimary: "#a00"), typography: (scale: 1.1))`.
- `width`, `height`, `fit`: como en `image`.
- `alt`: el texto alternativo; por omisión, el tipo y el título de cada bloque.

Un bloque inválido es un error de compilación con el mensaje de dibu.

### `dibu-bloques(theme: auto, width: auto, align: center, cuerpo)`

Regla `show` que dibuja los bloques raw con lenguaje `estructura`, `statics` o `dibu`. Es la
misma sintaxis de los apuntes en Markdown y de los bancos de alucarD, así que se pueden copiar
sin cambios.

```typ
#show: dibu-bloques.with(theme: "high-contrast", width: 80%)
```

### `dibu-config(theme: none)`

Fija el theme de los diagramas desde ese punto del documento.

### `svg(bloque, theme: none)`

Devuelve el SVG como bytes, para guardarlo o procesarlo.

### `tipos`, `themes`

Los tipos de diagrama y los themes predefinidos que entiende el motor.

## Licencia

GPL-3.0-or-later.
