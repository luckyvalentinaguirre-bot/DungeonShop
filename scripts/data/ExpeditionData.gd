class_name ExpeditionData
extends Resource
## Un reto/mazmorra objetivo y su dificultad. Ver docs/systems/03_Heroes.md.

@export var id: StringName = &""
@export var display_name: String = ""
## Dificultad del reto (se compara con el poder del equipo del héroe).
@export var difficulty: float = 5.0
