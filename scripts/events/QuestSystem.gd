class_name QuestSystem
extends RefCounted
## Rastrea misiones y las completa observando estadísticas acumuladas (que la partida
## alimenta desde las señales del juego: ventas, fabricación…). Desacoplado: los
## sistemas de juego no saben que hay misiones observándolos. Ver docs/systems/11_Quests.md §4.

var _stats: Dictionary = {}
var _active: Array = []      # QuestData en curso
var _completed: Array = []   # QuestData completadas

func add_quest(quest: QuestData) -> void:
	if quest != null and not _active.has(quest) and not _completed.has(quest):
		_active.append(quest)

func stat(stat_name: StringName) -> int:
	return int(_stats.get(stat_name, 0))

func active() -> Array:
	return _active

func completed() -> Array:
	return _completed

## Suma a una estadística y devuelve las misiones que se completan con ello.
func record(stat_name: StringName, amount: int) -> Array:
	_stats[stat_name] = stat(stat_name) + amount
	var newly: Array = []
	var still: Array = []
	for quest in _active:
		if _is_complete(quest):
			_completed.append(quest)
			newly.append(quest)
		else:
			still.append(quest)
	_active = still
	return newly

func progress(quest: QuestData) -> float:
	if quest.objectives.is_empty():
		return 1.0
	var total: float = 0.0
	for obj in quest.objectives:
		total += clampf(float(stat(obj.stat)) / float(maxi(1, obj.target)), 0.0, 1.0)
	return total / float(quest.objectives.size())

func _is_complete(quest: QuestData) -> bool:
	for obj in quest.objectives:
		if stat(obj.stat) < obj.target:
			return false
	return true
