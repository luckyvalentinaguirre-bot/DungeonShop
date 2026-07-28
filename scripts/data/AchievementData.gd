class_name AchievementData
extends Resource
## Un logro coleccionable (mapea a un logro de Steam por su id). Se desbloquea al
## alcanzar 'target' en una estadística. Ver docs/systems/12_Achievements.md.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var stat: StringName = &""
@export var target: int = 1
@export var hidden: bool = false
