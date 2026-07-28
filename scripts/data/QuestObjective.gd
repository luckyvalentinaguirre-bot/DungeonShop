class_name QuestObjective
extends Resource
## Un objetivo medible de una misión: alcanzar 'target' en una estadística acumulada
## (p. ej. &"items_sold", &"gold_earned", &"items_crafted"). El QuestSystem lo evalúa
## contra contadores alimentados por señales. Ver docs/systems/11_Quests.md §4.

@export var stat: StringName = &""
@export var target: int = 1
@export var description: String = ""
