extends Node
## Estado de la partida en curso: oro, jornada, y los servicios de juego (economía,
## inventario de la tienda, catálogo, clientela). Autoload: es el punto central que
## la UI consulta y modifica. Ver docs/systems/00_Architecture.md §6.
##
## NO declara class_name para no chocar con el nombre del singleton.

signal gold_changed(amount: int)
signal day_changed(day: int)
signal skill_leveled(skill_id: StringName, new_level: int)
signal quest_completed(quest: QuestData)
signal achievement_unlocked(achievement: AchievementData)
signal event_started(event: EventData)

var economy: EconomySystem
var item_db: ItemDatabase
var crafting: CraftingLibrary
var skills: PlayerSkills
var reputation: ReputationSystem
var quests: QuestSystem
var achievements: AchievementSystem
var events: EventEngine
var event_catalog: Array = []
var hero_manager: HeroManager
var layout: ShopLayout
var employees: EmployeeManager
var exploration: ExplorationSystem
var research: ResearchSystem
var clock: WorldClock
var weather: WeatherSystem
## Materiales que se pueden comprar en el mercado (ids del catálogo).
var market_materials: Array = [&"mat_iron", &"mat_steel", &"mat_quicksilver"]
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

	skills = PlayerSkills.new()
	reputation = ReputationSystem.new()
	quests = QuestSystem.new()
	achievements = AchievementSystem.new()
	events = EventEngine.new()
	hero_manager = HeroManager.new()
	layout = ShopLayout.new()
	employees = EmployeeManager.new()
	exploration = ExplorationSystem.new()
	research = ResearchSystem.new()
	clock = WorldClock.new()
	weather = WeatherSystem.new()

	economy = EconomySystem.new()
	economy.name = "EconomySystem"
	add_child(economy)
	economy.setup(_config(), rng.randi())
	for mat_id in market_materials:
		var mat := item_db.get_item(mat_id)
		if mat != null:
			economy.market.track_material(mat)

	player_wallet = WalletComponent.new()
	player_wallet.name = "PlayerWallet"
	player_wallet.balance = 100
	player_wallet.credit_limit = 100
	add_child(player_wallet)
	player_wallet.balance_changed.connect(func(v: int) -> void: gold_changed.emit(v))

	stock = Inventory.new(64)
	_stock_initial()

	customer_pool = _default_pool()
	_seed_progression_content()
	_seed_layout()
	day = 1
	weather.roll_for_day(day, rng)

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
	# Requisito de habilidad: no puedes fabricar lo que aún no sabes hacer.
	if recipe.required_skill_id != &"" and skills.level_of(recipe.required_skill_id) < recipe.required_skill_level:
		var blocked := CraftingResolver.Result.new()
		blocked.reason = "skill_too_low"
		return blocked

	var station := crafting.station(recipe.station_id) if crafting != null else null
	var qbonus := skills.quality_bonus(PlayerSkills.SMITHING)
	var dred := skills.defect_reduction(PlayerSkills.SMITHING)
	var result := CraftingResolver.craft(recipe, materials, station, item_db, rng, qbonus, dred)
	if result.success:
		for m in materials:
			if m != null and m.data != null:
				stock.remove(m.data.id, m.quantity)
		stock.add(result.output)
		_record_progress(&"items_crafted", 1)
		# Aprender haciendo: cada fabricación da experiencia de herrería.
		if skills.add_xp(PlayerSkills.SMITHING, 25):
			skill_leveled.emit(PlayerSkills.SMITHING, skills.level_of(PlayerSkills.SMITHING))
	return result

## Registra el efecto de una venta atendida en la reputación (según la facción del
## cliente y su ánimo). Lo llama la UI tras una venta. Ver docs/systems/04_Reputation.md.
func record_sale_reputation(customer: Customer) -> void:
	if customer != null and customer.data != null and reputation != null:
		reputation.register_sale(customer.data.faction, customer.mood.value)

## Notifica una venta para el progreso de misiones y logros. Lo llama la UI.
func notify_sale(price: int) -> void:
	_record_progress(&"items_sold", 1)
	_record_progress(&"gold_earned", maxi(0, price))

## Alimenta una estadística de progreso y aplica misiones/logros que se completen.
func _record_progress(stat_name: StringName, amount: int) -> void:
	var bus := _bus()
	for q in quests.record(stat_name, amount):
		if q.reward_gold > 0:
			player_wallet.receive(q.reward_gold)
		if q.reward_prestige > 0.0:
			reputation.add_prestige(q.reward_prestige)
		quest_completed.emit(q)
		if bus != null:
			bus.emit_signal("quest_completed", q)
	for a in achievements.record(stat_name, amount):
		achievement_unlocked.emit(a)
		if bus != null:
			bus.emit_signal("achievement_unlocked", a)

## Precio de compra actual de un material en el mercado.
func material_price(item_id: StringName) -> int:
	var mat := item_db.get_item(item_id)
	return economy.market.material_price(mat) if mat != null else 0

## Compra 'qty' unidades de un material al mercado: paga y lo añade al stock.
func buy_material(item_id: StringName, qty: int) -> bool:
	var mat := item_db.get_item(item_id)
	if mat == null or qty <= 0:
		return false
	var cost := economy.market.material_price(mat) * qty
	if not player_wallet.can_afford(cost):
		return false
	player_wallet.pay(cost)
	stock.add(ItemInstance.new(mat, 0, qty))
	var bus := _bus()
	if bus != null:
		bus.emit_signal("material_purchased", mat, qty, cost)
	return true

## Avanza una jornada: la demanda revierte y (cada semana) fluctúa el mercado.
func advance_day() -> void:
	day += 1
	if economy != null:
		economy.demand.advance_day()
		# Eventos activos que expiran hoy.
		if events != null:
			events.advance_day(economy.demand)
		var config := economy.config
		if config != null and config.days_per_week > 0 and day % config.days_per_week == 1:
			economy.market.advance_week()
			_maybe_trigger_events()
	if weather != null:
		weather.roll_for_day(day, rng)
	day_changed.emit(day)
	var bus := _bus()
	if bus != null:
		bus.emit_signal("day_advanced", day)

## Al empezar la semana, cada evento del catálogo puede dispararse según su
## probabilidad. Ver docs/systems/07_Events.md.
func _maybe_trigger_events() -> void:
	for event in event_catalog:
		if events.is_active(event):
			continue
		if rng.randf() < event.weekly_chance:
			events.start(event, economy.demand)
			event_started.emit(event)
			var bus := _bus()
			if bus != null:
				bus.emit_signal("event_started", event)

## Devuelve el autoload EventBus, o null si no estamos en el árbol (p. ej. en tests).
func _bus() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/EventBus")

func _config() -> EconomyConfig:
	if is_inside_tree():
		var gc := get_node_or_null("/root/GameConfig")
		if gc != null:
			var e = gc.get("economy")
			if e != null:
				return e
	return EconomyConfig.new()

# ------------------------------------------------------------------- Guardado
const SAVE_VERSION := 1

## Serializa el estado de la partida a un diccionario (JSON-safe).
## Ver docs/systems/08_Save.md.
func capture_state() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"day": day,
		"gold": player_wallet.balance,
		"skills": skills.capture_state(),
		"reputation": reputation.capture_state(),
		"demand": economy.demand.capture_state(),
		"stock": stock.capture_state(),
		"layout": layout.capture_state(),
		"clock": clock.capture_state(),
		"weather": weather.capture_state(),
	}

## Reconstruye la partida desde un diccionario. Requiere que los servicios ya
## existan (llama antes a new_game si hace falta).
func restore_state(data: Dictionary) -> void:
	if economy == null:
		new_game()
	day = int(data.get("day", 1))
	player_wallet.balance = int(data.get("gold", 0))
	skills.restore_state(data.get("skills", {}))
	reputation.restore_state(data.get("reputation", {}))
	economy.demand.restore_state(data.get("demand", {}))
	_restore_stock(data.get("stock", []))
	var layout_data = data.get("layout", {})
	if layout_data is Dictionary and not layout_data.is_empty():
		layout.restore_state(layout_data)
	var clock_data = data.get("clock", {})
	if clock_data is Dictionary and not clock_data.is_empty():
		clock.restore_state(clock_data)
	var weather_data = data.get("weather", {})
	if weather_data is Dictionary and not weather_data.is_empty():
		weather.restore_state(weather_data)
	day_changed.emit(day)
	gold_changed.emit(player_wallet.balance)

func _restore_stock(entries: Array) -> void:
	stock = Inventory.new(64)
	for entry in entries:
		var data := item_db.get_item(StringName(entry.get("id", "")))
		if data != null:
			stock.add(ItemInstance.new(data, int(entry.get("quality", 0)), int(entry.get("quantity", 1))))

## Contenido inicial de progresión (semilla en código; migrará a resources/ al crecer).
func _seed_progression_content() -> void:
	# Misiones de arranque (tutorial + primera meta de negocio).
	quests.add_quest(_quest(&"q_first_sale", "Primera venta", "Vende tu primer objeto.", &"items_sold", 1, 20, 1.0))
	quests.add_quest(_quest(&"q_first_craft", "Primer forjado", "Fabrica tu primer objeto.", &"items_crafted", 1, 20, 1.0))
	quests.add_quest(_quest(&"q_merchant", "Comerciante en ciernes", "Gana 300 coronas vendiendo.", &"gold_earned", 300, 100, 5.0))
	# Logros semilla.
	achievements.register([
		_achievement(&"ach_first_sale", "Abierto al público", &"items_sold", 1),
		_achievement(&"ach_ten_sales", "Tendero establecido", &"items_sold", 10),
		_achievement(&"ach_smith", "Manos de herrero", &"items_crafted", 10),
		_achievement(&"ach_rich", "Bolsa llena", &"gold_earned", 1000),
	])
	# Catálogo de eventos del reino.
	event_catalog = [
		_war_event(),
		_festival_event(),
	]

func _quest(id: StringName, qname: String, desc: String, stat: StringName, target: int, gold: int, prestige: float) -> QuestData:
	var obj := QuestObjective.new()
	obj.stat = stat
	obj.target = target
	var q := QuestData.new()
	q.id = id
	q.display_name = qname
	q.description = desc
	q.objectives = [obj]
	q.reward_gold = gold
	q.reward_prestige = prestige
	return q

func _achievement(id: StringName, aname: String, stat: StringName, target: int) -> AchievementData:
	var a := AchievementData.new()
	a.id = id
	a.display_name = aname
	a.stat = stat
	a.target = target
	return a

func _war_event() -> EventData:
	var effect := DemandBiasEffect.new()
	effect.category = GameEnums.Category.WEAPON
	effect.delta = 0.5
	var e := EventData.new()
	e.id = &"event_war"
	e.display_name = "Guerra fronteriza"
	e.description = "Los ejércitos necesitan armas: la demanda se dispara."
	e.duration_days = 4
	e.weekly_chance = 0.25
	e.effects = [effect]
	return e

func _festival_event() -> EventData:
	var effect := DemandBiasEffect.new()
	effect.category = GameEnums.Category.POTION
	effect.delta = 0.3
	var e := EventData.new()
	e.id = &"event_festival"
	e.display_name = "Feria de la Fragua"
	e.description = "Llega gente al pueblo: más demanda de pociones y lujo."
	e.duration_days = 3
	e.weekly_chance = 0.3
	e.effects = [effect]
	return e

## Distribución inicial de la tienda (vista cenital): un mostrador y unos estantes
## con productos asignados. El jugador la reorganiza a su gusto. Ver ShopLayout.
func _seed_layout() -> void:
	# Mostrador cerca de la parte inferior-central.
	layout.place(3, 4, ShopLayout.Furniture.COUNTER)
	layout.place(4, 4, ShopLayout.Furniture.COUNTER)
	# Estantes con producto asignado.
	var shelves := [
		[1, 1, &"potion_heal"],
		[2, 1, &"weapon_short_sword"],
		[5, 1, &"armor_leather"],
		[6, 1, &"tool_torch"],
		[1, 2, &"mat_iron"],
	]
	for s in shelves:
		layout.place(s[0], s[1], ShopLayout.Furniture.SHELF)
		layout.assign(s[0], s[1], s[2])
	# Un par de decoraciones.
	layout.place(0, 0, ShopLayout.Furniture.DECOR)
	layout.place(7, 0, ShopLayout.Furniture.DECOR)

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
