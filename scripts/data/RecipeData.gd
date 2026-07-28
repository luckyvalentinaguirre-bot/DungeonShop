class_name RecipeData
extends Resource
## Una receta de fabricación. Define QUÉ se produce y qué CATEGORÍAS de material
## hacen falta, pero NO qué material concreto: el jugador elige los materiales (con
## sus rasgos), de modo que la misma receta da resultados distintos. Ver
## docs/systems/05_Crafting.md §2 y §10 (recetas con materiales variables en v1.0).

## Identificador estable (p. ej. &"recipe_short_sword").
@export var id: StringName = &""
@export var display_name: String = ""
## Objeto base producido (id en el ItemDatabase).
@export var output_item_id: StringName = &""
## Estación en la que se fabrica (id de CraftingStationData).
@export var station_id: StringName = &""
## Puntuación de calidad de partida antes de rasgos y estación.
@export var base_quality_score: float = 2.0
## Probabilidad base de defecto (0..1) antes de rasgos y estación.
@export var base_defect_chance: float = 0.05

## Ranuras de entrada, como dos arrays paralelos (evita diccionarios en el .tres):
## required_categories[i] = categoría exigida (GameEnums.Category),
## required_quantities[i] = cuántas unidades de esa categoría.
@export var required_categories: Array = []
@export var required_quantities: Array = []
