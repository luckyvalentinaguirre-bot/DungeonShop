class_name AchievementSystem
extends RefCounted
## Rastrea el progreso de logros (por estadísticas acumuladas) y los desbloquea.
## Hermano de QuestSystem pero meta (sin recompensa de juego, sin caducidad).
## Portable a Steam detrás de una interfaz. Ver docs/systems/12_Achievements.md.

var _stats: Dictionary = {}
var _defs: Array = []       # AchievementData
var _unlocked: Array = []   # AchievementData

func register(defs: Array) -> void:
	_defs = defs

func is_unlocked(achievement: AchievementData) -> bool:
	return _unlocked.has(achievement)

func unlocked() -> Array:
	return _unlocked

## Suma a una estadística y devuelve los logros recién desbloqueados.
func record(stat_name: StringName, amount: int) -> Array:
	_stats[stat_name] = int(_stats.get(stat_name, 0)) + amount
	var newly: Array = []
	for achievement in _defs:
		if not _unlocked.has(achievement) and int(_stats.get(achievement.stat, 0)) >= achievement.target:
			_unlocked.append(achievement)
			newly.append(achievement)
	return newly

func capture_state() -> Dictionary:
	var ids: Array = []
	for a in _unlocked:
		ids.append(a.id)
	return {"stats": _stats.duplicate(), "unlocked": ids}
