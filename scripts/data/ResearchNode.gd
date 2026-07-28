class_name ResearchNode
extends Resource
## Un nodo de investigación/tecnología: al completarlo desbloquea recetas o mejoras.
## Puede exigir haber investigado antes otros nodos (prerrequisitos). Ver
## docs/systems/05_Crafting.md §6 y docs/systems/06_Progression.md.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
## Coste de investigación (coronas o puntos, según se decida al calibrar).
@export var cost: int = 100
## Ids de nodos que hay que investigar antes.
@export var prerequisites: Array = []
## Recetas que desbloquea (ids).
@export var unlocks_recipes: Array = []
