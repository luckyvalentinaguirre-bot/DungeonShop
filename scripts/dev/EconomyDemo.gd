extends Node
## Escena de prueba de la Fase 3 (sin UI): ejecuta un escenario económico completo
## y lo imprime por consola, para VER funcionar la economía sin interfaz todavía.
## Es la escena principal temporal del proyecto (se abre con F5 en Godot).
## Ver docs/Roadmap.md (Fase 3). Se retirará al llegar a la Fase 7 (interfaz).

func _ready() -> void:
	run_demo()

func run_demo() -> void:
	var config: EconomyConfig = _get_config()
	var economy := EconomySystem.new()
	economy.name = "EconomySystem"
	add_child(economy)
	economy.setup(config, 12345)

	# Carteras: el jugador (tendero) y un cliente.
	var player := WalletComponent.new()
	player.name = "PlayerWallet"
	player.balance = 100
	add_child(player)
	var customer := WalletComponent.new()
	customer.name = "CustomerWallet"
	customer.balance = 500
	add_child(customer)

	# Un material (para comprar) y un objeto vendible (para vender).
	var iron := _make_item(&"mat_iron", "Hierro", GameEnums.Category.MATERIAL, 8)
	var sword := _make_item(&"weapon_short_sword", "Espada corta", GameEnums.Category.WEAPON, 40)

	print("=== Demo económica — Dungeon Shop (Fase 3) ===")

	# 1) Precio de material fluctuante por semana.
	economy.market.track_material(iron)
	print("Material Hierro, semana %d: %d coronas" % [economy.market.current_week(), economy.market.material_price(iron)])

	# 2) Precio sugerido de un objeto según su calidad y la demanda.
	var sword_inst := ItemInstance.new(sword, 3, 1)  # calidad 3
	print("Espada corta (calidad 3), precio sugerido: %d coronas" % economy.suggested_price(sword_inst))

	# 3) Venta: mueve oro y actualiza la demanda.
	var price: int = economy.suggested_price(sword_inst)
	print("Oro antes -> tendero: %d | cliente: %d" % [player.balance, customer.balance])
	var result := economy.sell(sword_inst, price, customer, player)
	print("Venta: éxito=%s por %d coronas (motivo: '%s')" % [str(result.success), result.price, result.reason])
	print("Oro después -> tendero: %d | cliente: %d" % [player.balance, customer.balance])

	# 4) La venta satura la demanda de armas; una jornada la revierte.
	print("Demanda de armas tras vender: %.3f" % economy.demand.get_multiplier(GameEnums.Category.WEAPON))
	economy.demand.advance_day()
	print("Demanda de armas tras un día:  %.3f" % economy.demand.get_multiplier(GameEnums.Category.WEAPON))

	# 5) Avanza una semana: los precios de material cambian.
	economy.market.advance_week()
	print("Material Hierro, semana %d: %d coronas" % [economy.market.current_week(), economy.market.material_price(iron)])

	print("=== Fin de la demo ===")

func _get_config() -> EconomyConfig:
	var cfg := get_node_or_null("/root/GameConfig")
	if cfg != null:
		# Acceso por nombre (get) para no acoplar el tipo estático al autoload.
		var eco = cfg.get("economy")
		if eco != null:
			return eco
	return EconomyConfig.new()

func _make_item(id: StringName, item_name: String, category: GameEnums.Category, base_value: int) -> ItemData:
	var it := ItemData.new()
	it.id = id
	it.display_name = item_name
	it.category = category
	it.base_value = base_value
	return it
