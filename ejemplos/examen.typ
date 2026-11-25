// Ejemplo: ejercicios de examen con el modo ejercicio de dibu (campos blank*).
#import "../paquete/lib.typ": dibu

#set page(paper: "a4", margin: 2cm)
#set text(lang: "es", size: 11pt)
#set enum(numbering: "1)")

#align(center, text(14pt, weight: "bold")[Parcial — Programación II])

+ Complete la tabla de Dijkstra desde el nodo A.
  #align(center, dibu("
type: dijkstra
edges: ['A-B:4', 'A-C:1', 'C-B:2', 'B-D:5', 'C-D:8']
source: A
blank: true
", width: 80%))

+ Indique qué valor tiene la variable en cada paso.
  #align(center, dibu("
type: trace_table
title: Prueba de escritorio
columns: [i, suma]
rows: [[0, 0], [1, null]]
rowCount: 5
", width: 50%))
