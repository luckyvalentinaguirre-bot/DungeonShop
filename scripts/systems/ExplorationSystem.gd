class_name ExplorationSystem
extends RefCounted
## Desbloqueo de regiones del mundo. Cada región abre nuevos materiales y recetas.
## Puro y testeable. Ver docs/systems/06_Progression.md.

var _unlocked: Array = []  # RegionData

func is_unlocked(region: RegionData) -> bool:
	return _unlocked.has(region)

func unlocked() -> Array:
	return _unlocked

## Desbloquea una región si hay oro suficiente. Devuelve los materiales que la
## región aporta al mercado (para que quien llame los active), o [] si no se pudo.
func unlock(region: RegionData, available_gold: int) -> Array:
	if region == null or is_unlocked(region) or available_gold < region.unlock_cost:
		return []
	_unlocked.append(region)
	return region.provided_materials.duplicate()

## ¿Se puede pagar el desbloqueo?
func can_unlock(region: RegionData, available_gold: int) -> bool:
	return region != null and not is_unlocked(region) and available_gold >= region.unlock_cost
