extends Node
## Carga y expone el tuning del juego desde resources/config/. Autoload: cualquier
## sistema lee de aquí en vez de llevar constantes propias. Si el recurso no
## existe, usa valores por defecto (resiliencia para desarrollo temprano).
## Ver docs/systems/00_Architecture.md §6 y docs/Economy.md.
##
## NO declara class_name para no chocar con el nombre del singleton.

const ECONOMY_CONFIG_PATH := "res://resources/config/EconomyConfig.tres"

var economy: EconomyConfig

func _ready() -> void:
	economy = _load_or_default()

func _load_or_default() -> EconomyConfig:
	if ResourceLoader.exists(ECONOMY_CONFIG_PATH):
		var res: Resource = load(ECONOMY_CONFIG_PATH)
		if res is EconomyConfig:
			return res
	push_warning("EconomyConfig.tres no encontrado; usando valores por defecto.")
	return EconomyConfig.new()
