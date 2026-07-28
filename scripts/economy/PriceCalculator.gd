class_name PriceCalculator
extends RefCounted
## Cálculo puro del precio sugerido de un objeto. Sin estado y sin UI: dado el
## mismo input, siempre el mismo output (testeable en aislamiento).
##
## precio = base * calidad * demanda * reputación * evento
##
## Ver docs/systems/01_Economy.md §3.

## Devuelve el precio sugerido (>= 1) para un objeto dadas las condiciones de
## mercado. Los multiplicadores de demanda/reputación/evento los aporta el que
## llama (EconomySystem), manteniendo esta clase pura.
static func suggested_price(
		item: ItemData,
		quality: int,
		demand_mult: float,
		reputation_mult: float,
		event_mult: float,
		config: EconomyConfig) -> int:
	if item == null or config == null:
		return 0
	var q: float = _quality_multiplier(quality, config)
	var raw: float = float(item.base_value) * q * demand_mult * reputation_mult * event_mult
	return maxi(1, int(round(raw)))

static func _quality_multiplier(quality: int, config: EconomyConfig) -> float:
	var arr: PackedFloat32Array = config.quality_multipliers
	if arr.is_empty():
		return 1.0
	var idx: int = clampi(quality, 0, arr.size() - 1)
	return arr[idx]
