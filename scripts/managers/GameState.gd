extends Node
## Estado de la partida en curso: oro, jornada, y los servicios de juego (economía,
## inventario de la tienda, catálogo, clientela). Autoload: es el punto central que
## la UI consulta y modifica. Ver docs/systems/00_Architecture.md §6.
##
## NO declara class_name para no chocar con el nombre del singleton.

signal gold_changed(amount: int)
signal day_changed(day: int)

var economy: EconomySystem
var item_db: ItemDatabase
var crafting: CraftingLibrary
var player_wallet: WalletComponent
## Stock de la tienda (almacén + estantería unificados en esta primera versión).
var stock: Inventory
var customer_pool: Array[CustomerData] = []
var rng: RandomNumberGenerator
var day: int = 0

## Comienza una partida nueva desde cero.
func new_game() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()

	item_db = ItemDatabase.new()
	item_db.load_all()

	crafting = CraftingLibrary.new()
	crafting.load_all()

	economy = EconomySystem.new()
	economy.name = "EconomySystem"
	add_child(economy)
	economy.setup(_config(), rng.randi())

	player_wallet = WalletComponent.new()
	player_wallet.name = "PlayerWallet"
	player_wallet.balance = 100
	player_wallet.credit_limit = 100
	add_child(player_wallet)
	player_wallet.balance_changed.connect(func(v: int) -> void: gold_changed.emit(v))

	stock = Inventory.new(64)
	_stock_initial()

	customer_pool = _default_pool()
	day = 1

	day_changed.emit(day)
	gold_changed.emit(player_wallet.balance)

func gold() -> int:
	return player_wallet.balance if player_wallet != null else 0

## Genera un cliente de la clientela con su necesidad del día.
func spawn_customer() -> Customer:
	var arr := CustomerSpawner.spawn_day(customer_pool, 1, rng)
	return arr[0] if not arr.is_empty() else null

## Fabrica un objeto con la receta y los materiales elegidos. Si tiene éxito,
## consume los materiales del stock y añade el resultado. Ver docs/systems/05_Crafting.md.
func craft(recipe: RecipeData, materials: Array) -> CraftingResolver.Result:
	var station := crafting.station(recipe.station_id) if crafting != null else null
	var result := CraftingResolver.craft(recipe, materials, station, item_db, rng)
	if result.success:
		for m in materials:
			if m != null and m.data != null:
				stock.remove(m.data.id, m.quantity)
		stock.add(result.output)
	return result

## Avanza una jornada: la demanda revierte y (cada semana) fluctúa el mercado.
func advance_day() -> void:
	day += 1
	if economy != null:
		economy.demand.advance_day()
		var config := economy.config
		if config != null and config.days_per_week > 0 and day % config.days_per_week == 1:
			economy.market.advance_week()
	day_changed.emit(day)
	var bus := get_node_or_null("/root/EventBus")
	if bus != null:
		bus.emit_signal("day_advanced", day)

func _config() -> EconomyConfig:
	var gc := get_node_or_null("/root/GameConfig")
	if gc != null:
		var e = gc.get("economy")
		if e != null:
			return e
	return EconomyConfig.new()

func _stock_initial() -> void:
	_add_stock(&"potion_heal", 2, 4)
	_add_stock(&"weapon_short_sword", 3, 1)
	_add_stock(&"tool_torch", 1, 3)
	_add_stock(&"armor_leather", 2, 2)
	_add_stock(&"mat_iron", 0, 20)
	_add_stock(&"mat_steel", 0, 10)

func _add_stock(item_id: StringName, quality: int, quantity: int) -> void:
	var data := item_db.get_item(item_id)
	if data != null:
		stock.add(ItemInstance.new(data, quality, quantity))

func _default_pool() -> Array[CustomerData]:
	var pool: Array[CustomerData] = []
	pool.append(_customer(&"npc_mabel", "Doña Mabel", GameEnums.Faction.COMMONERS, [GameEnums.Category.POTION], 12, 35, 0.7, 0.5))
	pool.append(_customer(&"npc_cobos", "Alguacil Cobos", GameEnums.Faction.CROWN, [GameEnums.Category.TOOL, GameEnums.Category.ARMOR], 20, 60, 0.4, 0.4))
	pool.append(_customer(&"archetype_adventurer", "Aventurero", GameEnums.Faction.GUILD, [GameEnums.Category.WEAPON, GameEnums.Category.POTION], 30, 90, 0.5, 0.5))
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
