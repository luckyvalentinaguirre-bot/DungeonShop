class_name MaterialTrait
extends Resource
## Un rasgo que un material aporta al objeto fabricado. La combinación de rasgos de
## los materiales de entrada define el PERFIL del resultado (no solo "mejor/peor"):
## es la mecánica de identidad del juego. Ver docs/systems/05_Crafting.md §3.

## Identificador estable (p. ej. &"edge", &"tenacity", &"volatile").
@export var id: StringName = &""
## Nombre visible (clave i18n en producción).
@export var display_name: String = ""
## Aporte a la puntuación de calidad del resultado (puede ser negativo).
@export var quality_bonus: float = 0.0
## Variación de la probabilidad de defecto (volatilidad la sube, pureza la baja).
@export var defect_chance_delta: float = 0.0
## Aporte al perfil de atributos del objeto (p. ej. {"edge": 2, "durability": -1}).
@export var attributes: Dictionary = {}
## Etiquetas que este rasgo añade al objeto (p. ej. &"arcano", &"ligero").
@export var tags_added: Array = []
