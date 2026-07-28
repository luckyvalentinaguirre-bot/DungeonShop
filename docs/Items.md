# Catálogo y taxonomía de objetos

> Contenido de objetos del juego. La **mecánica** de objetos/inventario/fabricación
> está en [systems/09_Inventory](systems/09_Inventory.md) y
> [systems/05_Crafting](systems/05_Crafting.md); este documento define **qué objetos
> existen** y cómo se clasifican. Todos serán `ItemData` (`.tres`) en
> `resources/items/`. Valores 🟡 provisionales para calibrar.

---

## 1. `ItemData` vs `ItemInstance`

- **`ItemData`** (plantilla, inmutable): id, nombre (clave i18n), categoría, valor
  base, icono, apilable, rasgos/afinidades. Vive en `resources/items/`.
- **`ItemInstance`** (concreta, con estado): referencia a `ItemData` + calidad,
  rasgos aplicados, durabilidad, defectos, cantidad. Vive en la partida/inventario.

## 2. Categorías (taxonomía)

| Categoría | Descripción | Compran sobre todo |
|-----------|-------------|--------------------|
| **Armas** | Espadas, hachas, arcos, dagas, bastones | Guerreros, pícaros, arqueros |
| **Armaduras** | Ligera / media / pesada, escudos | Según clase del héroe |
| **Pociones** | Curación, fuerza, antídoto, maná | Todos (consumible clave) |
| **Herramientas** | Antorchas, cuerdas, ganzúas, palas, mapas | Exploración de mazmorra |
| **Objetos mágicos** | Amuletos, pergaminos, reliquias, encantamientos | Magos, élite |
| **Materiales** | Metales, maderas, hierbas, esencias, gemas | *(para fabricar, no para héroes)* |
| **Decoración** | Cosméticos para la tienda | *(el jugador, no venta)* |

## 3. Ejes de un objeto

- **Rareza** 🟡: común → infrecuente → raro → épico → legendario (afecta a valor,
  disponibilidad y clientela que lo desea).
- **Calidad** (0–5) 🟡: resultado de la fabricación; multiplica valor y adecuación.
- **Rasgos**: heredados de los materiales (ver [Crafting](systems/05_Crafting.md)):
  filo, tenacidad, ligereza, conductividad arcana, volatilidad, pureza…
- **Durabilidad** 🟡: los objetos usados por héroes se desgastan; reparables.
- **Defectos**: taras de mala fabricación (afectan al héroe en la mazmorra).

## 4. Catálogo semilla (v1.0, provisional 🟡)

Lista inicial de referencia para Fase 5; se ampliará hasta ~80–120 objetos.

**Armas:** Espada corta, Espada larga, Hacha de leñador, Hacha de guerra, Daga,
Arco corto, Bastón de aprendiz.
**Armaduras:** Jubón de cuero, Cota de malla, Coraza de placas, Escudo de madera,
Escudo de hierro, Túnica arcana.
**Pociones:** Poción de curación (menor/mayor), Antídoto, Elixir de fuerza,
Poción de maná, Tónico de vigor.
**Herramientas:** Antorcha, Cuerda, Ganzúas, Pala, Mapa de mazmorra, Piedra de afilar.
**Materiales:** Hierro, Acero, Cobre, Madera de roble, Cuero curtido, Hierba solar,
Esencia arcana, Gema en bruto, Carbón, Hilo de araña.
**Mágicos:** Amuleto menor, Pergamino de fuego, Anillo de protección, Reliquia rúnica.

## 5. Datos por objeto (campos de `ItemData`)

```
id            : StringName único (p. ej. &"weapon_short_sword")
display_name  : clave i18n
category      : enum (Armas/Armaduras/Pociones/Herramientas/Mágicos/Materiales/Decoración)
base_value    : int (coronas) — punto de partida del precio (ver Economy)
rarity        : enum
stackable     : bool
max_stack     : int
icon          : Texture
material_traits : Array[MaterialTrait]  (solo materiales)
tags          : Array[StringName]  (para adecuación con héroes/clientes)
```

## 6. Preguntas abiertas

- 🔴 Nº de niveles de rareza y calidad definitivos (afecta a economía y drops).
- 🔴 ¿Durabilidad/reparación entra en v1.0 o se pospone? Añade profundidad pero también fricción.
- 🟡 Valores base concretos por objeto — se calibran en Fase 3/5.
