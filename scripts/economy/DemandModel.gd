class_name DemandModel
extends RefCounted
## Mantiene la demanda por categoría (1.0 = neutra). Puro y testeable.
## La demanda sube cuando los clientes piden una categoría, baja al saturar el
## mercado con ventas, y revierte hacia la media cada jornada. Global por
## categoría en v1.0. Ver docs/systems/01_Economy.md §4.

var _config: EconomyConfig
## Category(int) -> demanda actual (float).
var _demand: Dictionary = {}

func _init(config: EconomyConfig) -> void:
	_config = config

## Multiplicador de demanda actual de una categoría (neutro si no se ha tocado).
func get_multiplier(category: int) -> float:
	return _demand.get(category, _config.demand_neutral)

## Un cliente pide esa categoría: la demanda percibida sube un poco.
func register_request(category: int) -> void:
	_adjust(category, _config.demand_request_step)

## Se vende esa categoría: el mercado se satura y la demanda baja.
func register_sale(category: int, quantity: int = 1) -> void:
	_adjust(category, -_config.demand_sale_step * float(maxi(1, quantity)))

## Sesgo externo (p. ej. un evento del reino). Ver docs/systems/07_Events.md.
func apply_bias(category: int, delta: float) -> void:
	_adjust(category, delta)

## Avanza una jornada: toda la demanda revierte una fracción hacia el neutro.
func advance_day() -> void:
	for category in _demand.keys():
		var current: float = _demand[category]
		_demand[category] = current + (_config.demand_neutral - current) * _config.demand_reversion_rate

func _adjust(category: int, delta: float) -> void:
	var current: float = _demand.get(category, _config.demand_neutral)
	_demand[category] = clampf(current + delta, _config.demand_min, _config.demand_max)

## Serialización (contrato ISaveable, ver docs/systems/08_Save.md).
func capture_state() -> Dictionary:
	return _demand.duplicate()

func restore_state(data: Dictionary) -> void:
	# Las claves de categoría pueden llegar como texto (tras pasar por JSON): se
	# normalizan a int.
	_demand.clear()
	for key in data.keys():
		_demand[int(key)] = float(data[key])
