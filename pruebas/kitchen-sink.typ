// Dibuja todos los bloques del kitchen sink de dibu, para verificar que Typst acepte cada SVG.
//   typst compile --root .. --input dibu=/dibu pruebas/kitchen-sink.typ salida/kitchen-sink.pdf
#import "../paquete/lib.typ": dibu
#let raiz = sys.inputs.at("dibu", default: "/dibu")
#let bloques = yaml(raiz + "/fixtures/kitchen_sink/kitchen_sink.yaml")
#set page(width: 21cm, height: auto, margin: 1cm)
#for (i, b) in bloques.enumerate() [
  #text(size: 8pt)[#(i + 1). #b.type #b.at("title", default: "")]
  #dibu(b, width: 100%, fit: "contain")
  #dibu(b, theme: "dark", width: 40%)
]
#bloques.len() bloques.
