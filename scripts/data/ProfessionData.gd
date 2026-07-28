class_name ProfessionData
extends Resource
## Clase/profesión de un héroe (guerrero, mago, pícaro…). Define qué equipo le
## conviene (adecuación). Ver docs/systems/03_Heroes.md.

@export var id: StringName = &""
@export var display_name: String = ""
## Etiquetas de equipo que le sientan bien (p. ej. &"ligero" para clases ágiles).
@export var preferred_tags: Array = []
