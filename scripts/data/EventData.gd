class_name EventData
extends Resource
## Un evento del reino (festival, guerra, escasez, feria, jefe que altera el mercado…).
## Contenido data-driven: un evento nuevo es un .tres, sin tocar el motor. Ver
## docs/systems/07_Events.md §2.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
## Jornadas que dura el evento.
@export var duration_days: int = 3
## Probabilidad semanal de que se dispare (0..1).
@export_range(0.0, 1.0) var weekly_chance: float = 0.25
## Efectos que aplica mientras está activo (Array[EventEffect]).
@export var effects: Array = []
