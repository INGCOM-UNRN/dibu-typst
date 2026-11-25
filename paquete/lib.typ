// dibu para Typst: diagramas educativos a partir de bloques YAML/JSON.
// El motor es el de dibu (https://github.com/INGCOM-UNRN/dibu), compilado como plugin WebAssembly.

#let _motor = plugin("dibu.wasm")

// Theme por omisión del documento: none (tinta), un nombre o un diccionario.
#let _theme = state("dibu-theme", none)

// Los tipos de diagrama y los themes predefinidos que entiende el motor.
#let tipos = json(_motor.types())
#let themes = json(_motor.themes())

// El texto YAML/JSON de un bloque: texto, raw (```estructura …```) o diccionario.
#let _fuente(bloque) = {
  if type(bloque) == str { bloque }
  else if type(bloque) == content and bloque.func() == raw { bloque.text }
  else if type(bloque) == dictionary or type(bloque) == array { json.encode(bloque, pretty: false) }
  else { panic("dibu: se esperaba texto YAML/JSON, un bloque raw o un diccionario, no " + str(type(bloque))) }
}

// El SVG (bytes) de uno o varios bloques, apilados como en `dibu sync-md`.
#let svg(bloque, theme: none) = _motor.render(
  bytes(_fuente(bloque)),
  bytes(json.encode(theme, pretty: false)),
)

// Texto alternativo a partir del tipo y del título de cada bloque.
#let _alt(fuente) = {
  let i = json(_motor.info(bytes(fuente)))
  let partes = i.types.zip(i.titles).map(((t, ti)) => if ti == "" { t } else { t + ": " + ti })
  "Diagrama " + partes.join(", ")
}

// Dibuja un diagrama. `bloque` es texto YAML/JSON, un bloque raw o un diccionario.
// `theme`: auto (el del documento, ver `dibu-config`), none (tinta), un nombre de
// `themes` o un diccionario `(extends: "color", colors: (...), typography: (...))`.
// El resto de los argumentos (`width`, `height`, `fit`, `alt`) pasan a `image`.
#let dibu(bloque, theme: auto, width: auto, height: auto, fit: "contain", alt: auto) = context {
  let fuente = _fuente(bloque)
  let t = if theme == auto { _theme.get() } else { theme }
  image(
    svg(fuente, theme: t),
    format: "svg",
    width: width,
    height: height,
    fit: fit,
    alt: if alt == auto { _alt(fuente) } else { alt },
  )
}

// Fija el theme del resto del documento: `#dibu-config(theme: "dark")`.
#let dibu-config(theme: none) = _theme.update(theme)

// Lenguajes de bloque raw que se dibujan con `dibu-bloques`.
#let lenguajes = ("estructura", "statics", "dibu")

// Regla show: dibuja los bloques ```estructura```, ```statics``` y ```dibu``` del documento.
//   #show: dibu-bloques
//   #show: dibu-bloques.with(theme: "high-contrast", width: 80%)
#let dibu-bloques(theme: auto, width: auto, align: center, cuerpo) = {
  if theme != auto { _theme.update(theme) }
  show raw.where(block: true): it => {
    if it.lang in lenguajes {
      set std.align(align)
      dibu(it, width: width)
    } else { it }
  }
  cuerpo
}
