class_name MarketSystem
extends Node
## Precios de compra de materiales con fluctuación semanal determinista.
## El precio de cada material varía por semana con un RNG sembrado, de modo que
## el mismo (seed + semana) produce siempre los mismos precios (testeable y
## reproducible entre partidas guardadas). Ver docs/systems/01_Economy.md §5.

var _config: EconomyConfig
var _week: int = 0
var _seed: int = 0
## item_id(StringName) -> multiplicador de precio de esta semana (float).
var _price_mult: Dictionary = {}

## Inicializa el mercado con la configuración y una semilla de partida.
func setup(config: EconomyConfig, rng_seed: int = 0) -> void:
	_config = config
	_seed = rng_seed
	_week = 0
	_price_mult.clear()

## Empieza a seguir un material (fija su multiplicador para la semana actual).
func track_material(item: ItemData) -> void:
	if item != null and not _price_mult.has(item.id):
		_price_mult[item.id] = _roll_mult(item.id)

## Precio de compra actual de un material (>= 1).
func material_price(item: ItemData) -> int:
	if item == null or _config == null:
		return 0
	var mult: float = _price_mult.get(item.id, 1.0)
	return maxi(1, int(round(float(item.base_value) * mult)))

## Avanza una semana: todos los materiales seguidos recalculan su precio.
func advance_week() -> void:
	_week += 1
	for item_id in _price_mult.keys():
		_price_mult[item_id] = _roll_mult(item_id)

func current_week() -> int:
	return _week

func _roll_mult(item_id: StringName) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(item_id)) ^ (_seed + _week * 7919)
	var v: float = rng.randf_range(1.0 - _config.market_weekly_volatility, 1.0 + _config.market_weekly_volatility)
	return clampf(v, _config.market_price_min_mult, _config.market_price_max_mult)
