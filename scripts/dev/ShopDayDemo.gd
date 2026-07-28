extends Node
## Escena de prueba de la Fase 4 (sin UI): simula una jornada de tienda con el modelo
## híbrido —clientes de mostrador (COUNTER, con regateo) y clientes de estantería
## (SHELF, autoservicio)— y lo imprime por consola. Escena principal temporal.
## Ver docs/Roadmap.md (Fase 4). Se retira al llegar a la Fase 7 (interfaz).

func _ready() -> void:
	run_demo()

func run_demo() -> void:
	var config: EconomyConfig = _get_config()
	var economy := EconomySystem.new()
	economy.name = "EconomySystem"
	add_child(economy)
	economy.setup(config, 2024)

	var player := WalletComponent.new()
	player.name = "PlayerWallet"
	player.balance = 50
	add_child(player)

	var pool := _make_pool()
	var rng := RandomNumberGenerator.new()
	rng.seed = 777

	var customers := CustomerSpawner.spawn_day(pool, 6, rng)
	print("=== Jornada de tienda — Dungeon Shop (Fase 4) ===")
	print("Llegan %d clientes." % customers.size())

	# Reparte según la vía elegida (modelo híbrido).
	var queue := ShopQueue.new()
	var shelf_shoppers: Array[Customer] = []
	for c in customers:
		if c.need.intent == CustomerNeed.Intent.COUNTER:
			queue.enqueue(CustomerController.new(c))
		else:
			shelf_shoppers.append(c)

	_serve_counter(queue, economy, player)
	_serve_shelf(shelf_shoppers, economy, player)

	print("Caja del tendero al cerrar: %d coronas" % player.balance)
	print("=== Fin de la jornada ===")

## Atiende la cola del mostrador: por cada cliente, el tendero (auto) ofrece un
## objeto que cumple su necesidad al precio sugerido y se resuelve el regateo.
func _serve_counter(queue: ShopQueue, economy: EconomySystem, player: WalletComponent) -> void:
	print("\n-- Mostrador (%d en cola) --" % queue.size())
	while not queue.is_empty():
		var controller := queue.current()
		var need := controller.present_need()
		var item := _make_item_for(need)
		var price := economy.suggested_price(item)
		var result := controller.receive_offer(item, price, economy, player)
		print("  %s quiere %s (cal>=%d, presup %d) -> ofrezco %d: %s (ánimo %.2f)" % [
			controller.customer.display_name(),
			_cat_name(need.category), need.min_quality, need.budget,
			price, result.reason, result.mood_after,
		])
		queue.decay_patience(0.02)
		queue.advance()

## Atiende a los clientes de estantería: compran solos del stock expuesto.
func _serve_shelf(shoppers: Array[Customer], economy: EconomySystem, player: WalletComponent) -> void:
	print("\n-- Estantería (%d clientes de autoservicio) --" % shoppers.size())
	var display := _make_display(economy)
	for c in shoppers:
		var result := ShelfPurchaseResolver.resolve(c.need, display, c.wallet, player, economy.demand)
		if result.bought:
			print("  %s compró %s por %d coronas" % [c.display_name(), result.item.data.display_name, result.price])
		else:
			print("  %s se fue sin comprar (%s: quería %s)" % [c.display_name(), result.reason, _cat_name(c.need.category)])

func _make_display(economy: EconomySystem) -> Array:
	# Stock expuesto en la estantería (en Fase 5 vendrá del inventario real).
	var display: Array = []
	var samples := [
		_named_item(&"potion_heal", "Poción de curación", GameEnums.Category.POTION, 15, 2),
		_named_item(&"weapon_short_sword", "Espada corta", GameEnums.Category.WEAPON, 40, 3),
		_named_item(&"tool_torch", "Antorcha", GameEnums.Category.TOOL, 6, 1),
		_named_item(&"armor_leather", "Jubón de cuero", GameEnums.Category.ARMOR, 35, 2),
	]
	for inst in samples:
		display.append({"item": inst, "price": economy.suggested_price(inst)})
	return display

func _make_item_for(need: CustomerNeed) -> ItemInstance:
	# El tendero fabrica/ofrece justo lo que piden (calidad un punto por encima).
	var it := ItemData.new()
	it.id = &"made_to_order"
	it.display_name = "Objeto a medida"
	it.category = need.category
	it.base_value = maxi(10, need.budget / 2)
	return ItemInstance.new(it, mini(5, need.min_quality + 1), 1)

func _named_item(id: StringName, item_name: String, category: GameEnums.Category, base_value: int, quality: int) -> ItemInstance:
	var it := ItemData.new()
	it.id = id
	it.display_name = item_name
	it.category = category
	it.base_value = base_value
	return ItemInstance.new(it, quality, 1)

func _make_pool() -> Array[CustomerData]:
	var pool: Array[CustomerData] = []
	pool.append(_customer(&"npc_mabel", "Doña Mabel", GameEnums.Faction.COMMONERS, [GameEnums.Category.POTION], 10, 30, 0.7, 0.6))
	pool.append(_customer(&"npc_cobos", "Alguacil Cobos", GameEnums.Faction.CROWN, [GameEnums.Category.TOOL, GameEnums.Category.ARMOR], 20, 60, 0.4, 0.3))
	pool.append(_customer(&"archetype_adventurer", "Aventurero", GameEnums.Faction.GUILD, [GameEnums.Category.WEAPON, GameEnums.Category.POTION], 25, 80, 0.5, 0.5))
	return pool

func _customer(id: StringName, cname: String, faction: GameEnums.Faction, cats: Array, bmin: int, bmax: int, mood: float, shelf: float) -> CustomerData:
	var d := CustomerData.new()
	d.id = id
	d.display_name = cname
	d.faction = faction
	d.preferred_categories = cats
	d.budget_min = bmin
	d.budget_max = bmax
	d.base_mood = mood
	d.shelf_preference = shelf
	return d

func _get_config() -> EconomyConfig:
	var cfg := get_node_or_null("/root/GameConfig")
	if cfg != null:
		var eco = cfg.get("economy")
		if eco != null:
			return eco
	return EconomyConfig.new()

func _cat_name(category: int) -> String:
	match category:
		GameEnums.Category.WEAPON: return "arma"
		GameEnums.Category.ARMOR: return "armadura"
		GameEnums.Category.POTION: return "poción"
		GameEnums.Category.TOOL: return "herramienta"
		GameEnums.Category.MAGIC: return "objeto mágico"
		GameEnums.Category.MATERIAL: return "material"
		_: return "objeto"
