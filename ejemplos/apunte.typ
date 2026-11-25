// Ejemplo: un apunte con diagramas de dibu.
//   typst compile --root . ejemplos/apunte.typ
// Fuera de este repositorio, importar el paquete instalado:
//   #import "@local/dibu:0.1.0": dibu, dibu-bloques     (o "@preview/dibu:0.1.0")
#import "../paquete/lib.typ": dibu, dibu-bloques, dibu-config

#set page(paper: "a4", margin: 2cm)
#set text(lang: "es", size: 11pt)
#set heading(numbering: "1.")
#show: dibu-bloques.with(width: 75%)

#align(center, text(16pt, weight: "bold")[Apunte: estructuras y sistemas digitales])

= Pilas

Una pila admite apilar y desapilar sólo por el tope. Después de `push(3)`, `push(7)`,
`push(1)`, `pop()` y `push(9)`, en un arreglo de 5 enteros:

```estructura
type: stack
title: Pila en un arreglo
values: [3, 7, 9]
capacity: 5
showAddresses: true
```

= Mapas de Karnaugh

Los bloques también se pueden escribir como diccionarios de Typst, lo que permite calcularlos:

#let minterminos = range(16).filter(i => calc.rem(i, 3) == 0)
#figure(
  dibu((type: "karnaugh", vars: ("A", "B", "C", "D"), minterms: minterminos), width: 55%),
  caption: [Múltiplos de 3: $m(#minterminos.map(str).join(", "))$],
)

= Control

#figure(
  dibu("
type: bode
system: {k: 200, poles: [-1, -10]}
margins: true
asymptotes: true
", width: 80%),
  caption: [Diagrama de Bode con asíntotas y márgenes.],
)

= Theme del documento

Desde acá, todos los diagramas usan el theme `color`:

#dibu-config(theme: "color")

```estructura
type: linked_list
title: Lista enlazada
values: [4, 8, 15]
```
