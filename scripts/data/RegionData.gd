class_name RegionData
extends Resource
## Una región explorable del mundo. Al desbloquearla aporta nuevos materiales,
## recetas, clientes y eventos. Ver docs/systems/06_Progression.md y docs/WorldBible.md.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
## Coste de desbloqueo (coronas / reputación, según se decida).
@export var unlock_cost: int = 100
## Materiales que pasa a ofrecer el mercado (ids del catálogo).
@export var provided_materials: Array = []
## Recetas que desbloquea (ids).
@export var provided_recipes: Array = []
