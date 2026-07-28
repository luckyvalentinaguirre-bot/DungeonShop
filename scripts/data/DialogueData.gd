class_name DialogueData
extends Resource
## Un diálogo completo: una secuencia de líneas. Data-driven (motor propio, decisión
## de Fase 7). La ramificación con opciones se añade sobre esta base. Ver
## docs/systems/10_Dialogue.md §2-3.

@export var id: StringName = &""
@export var lines: Array = []  # DialogueLine
