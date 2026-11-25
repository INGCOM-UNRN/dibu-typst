#import "../paquete/lib.typ": dibu, dibu-bloques, dibu-config, svg, tipos, themes

#assert(tipos.len() >= 70, message: "faltan tipos")
#assert("dark" in themes)

= Texto YAML
#dibu("type: stack\ntitle: Pila\nvalues: [3, 7, 1]")

= Diccionario
#dibu((type: "karnaugh", vars: ("A", "B", "C"), minterms: (1, 3, 5, 7)), width: 50%)

= Bloques raw
#show: dibu-bloques
```estructura
type: queue
values: [1, 2, 3]
```

```python
print("esto sigue siendo código")
```

= Themes
#dibu-config(theme: "dark")
#dibu("type: stack\nvalues: [1]")
#dibu("type: stack\nvalues: [1]", theme: (extends: "color", colors: (accentPrimary: "#aa0000")))
#dibu-config(theme: none)

= Varios bloques apilados
#dibu("- type: stack\n  values: [1]\n- type: queue\n  values: [2]")

#assert(str(svg("type: stack\nvalues: [1]")).starts-with("<svg"))
