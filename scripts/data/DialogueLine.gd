class_name DialogueLine
extends Resource
## Una línea de diálogo: quién habla y qué dice (clave i18n en producción).
## Ver docs/systems/10_Dialogue.md §3.

@export var speaker: String = ""
@export_multiline var text: String = ""
## Emoción/retrato a mostrar (opcional).
@export var emotion: StringName = &"neutral"
