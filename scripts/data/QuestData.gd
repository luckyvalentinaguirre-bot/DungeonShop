class_name QuestData
extends Resource
## Una misión: objetivos + recompensas. Sirve para tutorial, encargos, metas de
## negocio y narrativa (mismo motor). Ver docs/systems/11_Quests.md.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var objectives: Array = []  # QuestObjective
@export var reward_gold: int = 0
@export var reward_prestige: float = 0.0
