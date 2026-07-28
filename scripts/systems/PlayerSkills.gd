class_name PlayerSkills
extends RefCounted
## Habilidades del jugador que mejoran "haciendo" (learn by doing). En esta fase la
## herrería influye en la fabricación: sube la calidad y reduce los defectos, y las
## recetas pueden exigir un nivel mínimo. Ver docs/systems/06_Progression.md §3.

const SMITHING := &"smithing"

## id(StringName) -> nivel actual (empieza en 1)
var _levels: Dictionary = {}
## id(StringName) -> experiencia acumulada hacia el siguiente nivel
var _xp: Dictionary = {}

func level_of(skill_id: StringName) -> int:
	return int(_levels.get(skill_id, 1))

func xp_of(skill_id: StringName) -> int:
	return int(_xp.get(skill_id, 0))

## Experiencia necesaria para pasar del nivel actual al siguiente.
func xp_to_next(skill_id: StringName) -> int:
	return level_of(skill_id) * 100

## Aporte de calidad a la fabricación por nivel de la habilidad.
func quality_bonus(skill_id: StringName) -> float:
	return float(level_of(skill_id) - 1) * 0.15

## Reducción de la probabilidad de defecto por nivel de la habilidad.
func defect_reduction(skill_id: StringName) -> float:
	return float(level_of(skill_id) - 1) * 0.01

## Suma experiencia; devuelve true si ha subido al menos un nivel.
func add_xp(skill_id: StringName, amount: int) -> bool:
	var leveled := false
	var xp: int = xp_of(skill_id) + maxi(0, amount)
	var lvl: int = level_of(skill_id)
	while xp >= lvl * 100:
		xp -= lvl * 100
		lvl += 1
		leveled = true
	_levels[skill_id] = lvl
	_xp[skill_id] = xp
	return leveled

## Serialización (contrato ISaveable, ver docs/systems/08_Save.md).
func capture_state() -> Dictionary:
	return {"levels": _levels.duplicate(), "xp": _xp.duplicate()}

func restore_state(data: Dictionary) -> void:
	# Las claves (ids de habilidad) se normalizan a StringName tras pasar por JSON.
	_levels.clear()
	_xp.clear()
	var lv = data.get("levels", {})
	var xp = data.get("xp", {})
	if lv is Dictionary:
		for key in lv.keys():
			_levels[StringName(key)] = int(lv[key])
	if xp is Dictionary:
		for key in xp.keys():
			_xp[StringName(key)] = int(xp[key])
