# 05 — Sistema de Fabricación

> Combinar materiales en estaciones para crear objetos. Es la mecánica *artesanal*
> con más identidad propia del juego, gracias a los **rasgos de material**. Debe
> premiar la experimentación por encima de recetas "óptimas" fijas. Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Fabricar se siente **táctil y creativo**, no un botón de "craftear".
- Los **materiales tienen personalidad** (rasgos) → decisiones significativas.
- **Escalable con datos:** recetas y estaciones nuevas son Resources, no código.
- Extensible sin tocar el motor (principio Abierto/Cerrado, ver [Arquitectura](00_Architecture.md)).

## 2. Piezas del sistema

- **Materiales** (`ItemData` con categoría *material*): tienen **rasgos**.
- **Estaciones** (`CraftingStationData`): yunque, alambique, mesa de encantar, etc.
  Cada una fabrica ciertas categorías y aplica su propio proceso.
- **Recetas** (`RecipeData`): entradas requeridas → salida base + reglas.
- **Rasgos de material** (`MaterialTrait`): propiedades que se transfieren al objeto.

## 3. Rasgos de material — la idea central 🟡

En vez de "hierro = espada de hierro", cada material aporta **rasgos** que modulan
el resultado:

| Ejemplo de rasgo | Efecto en el objeto |
|------------------|---------------------|
| **Filo** | ↑ daño, ↓ durabilidad |
| **Tenacidad** | ↑ durabilidad, ↓ filo |
| **Ligereza** | mejor para clases ágiles (adecuación, ver [Heroes](03_Heroes.md)) |
| **Conductividad arcana** | permite/mejora encantamientos |
| **Volatilidad** | pociones más potentes pero con riesgo de defecto |
| **Pureza** | ↑ calidad base, reduce defectos |

Combinar materiales = combinar rasgos. La misma receta con materiales distintos
produce objetos con **perfiles distintos**, no solo "mejor/peor". Esto mantiene las
decisiones vivas y evita la solución óptima única (riesgo del GDD §11).

## 4. Calidad y defectos 🟡

- Cada objeto fabricado tiene una **calidad** (afecta precio y adecuación).
- La calidad depende de: rasgos de material, nivel de la estación, skill del
  jugador/empleado, y azar acotado.
- **Defectos**: materiales volátiles o mala combinación pueden generar objetos con
  taras (una espada frágil que se rompe en la mazmorra → afecta al héroe). Vender
  defectuosos a sabiendas daña la reputación.

## 5. Proceso de fabricación (flujo)

```
Jugador abre estación → elige receta (o experimenta libre si se desbloquea) →
  selecciona materiales de inventario → CraftingResolver combina rasgos →
  produce ItemInstance con calidad/rasgos/posibles defectos →
  consume materiales → añade resultado al inventario →
  emite EventBus.item_crafted
```

`CraftingResolver` es **puro y testeable**: dados materiales + receta + semilla,
resultado determinista.

## 6. Progresión de fabricación

- Nuevas **estaciones** se desbloquean por reputación/dinero (ver [Progression](06_Progression.md)).
- Nuevas **recetas** por: comprar, aprender de NPCs, encontrar en botín de héroes,
  o completar el cuaderno del antecesor (gancho narrativo, ver [Lore](../Lore.md)).
- Estaciones **mejorables** (nivel) → mayor calidad, menos defectos, más *slots*.

## 7. Encargos (crafting a pedido)

Clientes/héroes piden objetos concretos (ver [Customers](02_Customers.md),
[Quests](11_Quests.md)). El encargo define restricciones (categoría, calidad
mínima, plazo). Cumplirlo da oro + reputación extra; fallarlo, lo contrario.

## 8. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `CraftingStationData` | Resource | Definición de una estación (qué fabrica, nivel) |
| `RecipeData` | Resource | Entradas, salida base, reglas |
| `MaterialTrait` | Resource | Un rasgo y su efecto |
| `CraftingResolver` | system (puro) | Combina materiales+receta → resultado con rasgos/calidad |
| `QualityCalculator` | system (puro) | Deriva calidad y probabilidad de defecto |
| `CraftingStation` | scene/component | Instancia interactiva de estación en la tienda |

## 9. Señales (EventBus)

- `item_crafted(item_instance, station)`
- `crafting_failed(reason)` (materiales insuficientes, etc.)
- `recipe_learned(recipe)`
- `station_unlocked(station)` / `station_upgraded(station, level)`

## 10. Preguntas abiertas

- 🔴 ¿Hay **fabricación libre/experimental** (sin receta) además de recetas, o solo
  recetas con materiales variables? La libre da identidad pero es más difícil de
  balancear. Recomendado: recetas con materiales variables en v1.0, libre como
  desbloqueo avanzado.
- 🔴 ¿La fabricación consume tiempo/jornadas o es instantánea? Afecta al ritmo.
- 🟡 Lista concreta de rasgos y estaciones se cierra en Fase 5–6.
