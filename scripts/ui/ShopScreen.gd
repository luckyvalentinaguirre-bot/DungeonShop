extends Control
## Pantalla de tienda: primera versión JUGABLE del bucle central. Atiende clientes
## (mostrador con regateo + autoservicio de estantería), vende del stock y avanza la
## jornada, todo con el ratón. Construye la UI por código y usa GameState como fuente
## de verdad. Ver docs/Roadmap.md (Fase 7).

var _gold_label: Label
var _day_label: Label
var _customer_label: Label
var _price_label: Label
var _selected_label: Label
var _offer_btn: Button
var _stock_box: VBoxContainer
var _log: RichTextLabel

var _current: Customer
var _controller: CustomerController
var _selected_slot: ItemInstance
var _offer_price: int = 0

func _ready() -> void:
	# Permite abrir esta escena directamente (sin pasar por el menú) en desarrollo.
	if GameState.economy == null:
		GameState.new_game()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiFactory.background(self)
	_build_ui()
	_refresh_hud()
	_refresh_stock()
	GameState.gold_changed.connect(func(_v: int) -> void: _refresh_hud())
	GameState.day_changed.connect(func(_d: int) -> void: _refresh_hud())
	_log_line("[color=#e8b06a]Abres la tienda de la abuela Rilda. ¡A trabajar![/color]")

# ---------------------------------------------------------------- construcción UI
func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var root := UiFactory.vbox(12)
	margin.add_child(root)

	root.add_child(_build_hud())

	var middle := UiFactory.hbox(12)
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(middle)
	middle.add_child(_build_counter_panel())
	middle.add_child(_build_stock_panel())

	root.add_child(_build_log_panel())

func _build_hud() -> Control:
	var panel := UiFactory.panel()
	var row := UiFactory.hbox(20)
	panel.add_child(row)

	_gold_label = UiFactory.label("Oro: 0", 20, UiFactory.COL_ACCENT)
	row.add_child(_gold_label)
	_day_label = UiFactory.label("Jornada: 0", 20)
	row.add_child(_day_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var next_btn := UiFactory.button("Siguiente cliente")
	next_btn.pressed.connect(_on_next_customer)
	row.add_child(next_btn)
	var craft_btn := UiFactory.button("Fabricar")
	craft_btn.pressed.connect(func() -> void: SceneRouter.goto_crafting())
	row.add_child(craft_btn)
	var day_btn := UiFactory.button("Avanzar jornada")
	day_btn.pressed.connect(_on_advance_day)
	row.add_child(day_btn)
	var menu_btn := UiFactory.button("Menú")
	menu_btn.custom_minimum_size = Vector2(80, 40)
	menu_btn.pressed.connect(func() -> void: SceneRouter.goto_main_menu())
	row.add_child(menu_btn)
	return panel

func _build_counter_panel() -> Control:
	var panel := UiFactory.panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := UiFactory.vbox(10)
	panel.add_child(box)

	box.add_child(UiFactory.label("Mostrador", 22, UiFactory.COL_ACCENT))
	_customer_label = UiFactory.label("No hay nadie en el mostrador.\nPulsa «Siguiente cliente».", 16)
	box.add_child(_customer_label)

	box.add_child(_hsep())

	_selected_label = UiFactory.label("Producto seleccionado: (ninguno)", 15)
	box.add_child(_selected_label)

	var price_row := UiFactory.hbox(8)
	box.add_child(price_row)
	var minus := UiFactory.button("-5")
	minus.custom_minimum_size = Vector2(60, 36)
	minus.pressed.connect(_adjust_price.bind(-5))
	price_row.add_child(minus)
	_price_label = UiFactory.label("Precio: 0", 18)
	price_row.add_child(_price_label)
	var plus := UiFactory.button("+5")
	plus.custom_minimum_size = Vector2(60, 36)
	plus.pressed.connect(_adjust_price.bind(5))
	price_row.add_child(plus)

	_offer_btn = UiFactory.button("Ofrecer al cliente")
	_offer_btn.pressed.connect(_on_offer)
	_offer_btn.disabled = true
	box.add_child(_offer_btn)
	return panel

func _build_stock_panel() -> Control:
	var panel := UiFactory.panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := UiFactory.vbox(8)
	panel.add_child(box)
	box.add_child(UiFactory.label("Stock de la tienda", 22, UiFactory.COL_ACCENT))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_stock_box = UiFactory.vbox(6)
	_stock_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_stock_box)
	return panel

func _build_log_panel() -> Control:
	var panel := UiFactory.panel()
	panel.custom_minimum_size = Vector2(0, 150)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.add_theme_color_override("default_color", UiFactory.COL_TEXT)
	panel.add_child(_log)
	return panel

# ---------------------------------------------------------------- lógica de juego
func _on_next_customer() -> void:
	if _current != null:
		_log_line("Aún estás atendiendo a %s." % _current.display_name())
		return
	var customer := GameState.spawn_customer()
	if customer == null:
		return
	if customer.need.intent == CustomerNeed.Intent.SHELF:
		_resolve_shelf(customer)
	else:
		_current = customer
		_controller = CustomerController.new(customer)
		_controller.present_need()
		_customer_label.text = "%s (ánimo %.0f%%)\nQuiere: %s de calidad ≥%d\nPresupuesto: %d coronas" % [
			customer.display_name(), customer.mood.value * 100.0,
			_cat_name(customer.need.category), customer.need.min_quality, customer.need.budget,
		]
		_log_line("Llega [b]%s[/b] al mostrador." % customer.display_name())

func _resolve_shelf(customer: Customer) -> void:
	var offers := _offers_from_stock()
	var result := ShelfPurchaseResolver.resolve(customer.need, offers, customer.wallet, GameState.player_wallet, GameState.economy.demand)
	if result.bought:
		GameState.stock.remove(result.item.data.id, 1)
		_log_line("[color=#8fd08a]%s cogió %s de la estantería y pagó %d coronas.[/color]" % [customer.display_name(), result.item.data.display_name, result.price])
		_refresh_stock()
	else:
		_log_line("%s miró la estantería y se fue sin comprar (%s)." % [customer.display_name(), _cat_name(customer.need.category)])

func _offers_from_stock() -> Array:
	var offers: Array = []
	for slot in GameState.stock.get_items():
		var unit := ItemInstance.new(slot.data, slot.quality, 1)
		offers.append({"item": unit, "price": GameState.economy.suggested_price(unit)})
	return offers

func _select_slot(slot: ItemInstance) -> void:
	if _current == null:
		_log_line("No hay cliente al que ofrecer. Pulsa «Siguiente cliente».")
		return
	_selected_slot = slot
	var unit := ItemInstance.new(slot.data, slot.quality, 1)
	_offer_price = GameState.economy.suggested_price(unit)
	_offer_btn.disabled = false
	_update_offer_labels()

func _adjust_price(delta: int) -> void:
	if _selected_slot == null:
		return
	_offer_price = maxi(1, _offer_price + delta)
	_update_offer_labels()

func _on_offer() -> void:
	if _current == null or _selected_slot == null:
		return
	var unit := ItemInstance.new(_selected_slot.data, _selected_slot.quality, 1)
	var result := _controller.receive_offer(unit, _offer_price, GameState.economy, GameState.player_wallet)
	if result.sold:
		GameState.stock.remove(_selected_slot.data.id, 1)
		_log_line("[color=#8fd08a]Vendiste %s a %s por %d coronas.[/color]" % [_selected_slot.data.display_name, _current.display_name(), _offer_price])
		_end_visit()
	elif result.reason == "wrong_item":
		_log_line("A %s no le sirve %s (quería %s)." % [_current.display_name(), _selected_slot.data.display_name, _cat_name(_current.need.category)])
	else:
		_log_line("[color=#d98f6a]%s rechazó la oferta (%s). Se marcha.[/color]" % [_current.display_name(), result.reason])
		_end_visit()

func _end_visit() -> void:
	_current = null
	_controller = null
	_selected_slot = null
	_offer_btn.disabled = true
	_customer_label.text = "No hay nadie en el mostrador.\nPulsa «Siguiente cliente»."
	_selected_label.text = "Producto seleccionado: (ninguno)"
	_price_label.text = "Precio: 0"
	_refresh_stock()

func _on_advance_day() -> void:
	GameState.advance_day()
	_log_line("[color=#e8b06a]— Nueva jornada (%d) —[/color]" % GameState.day)

# ---------------------------------------------------------------- refrescos UI
func _refresh_hud() -> void:
	if _gold_label != null:
		_gold_label.text = "Oro: %d" % GameState.gold()
	if _day_label != null:
		_day_label.text = "Jornada: %d" % GameState.day

func _refresh_stock() -> void:
	for child in _stock_box.get_children():
		child.queue_free()
	for slot in GameState.stock.get_items():
		var unit := ItemInstance.new(slot.data, slot.quality, 1)
		var price := GameState.economy.suggested_price(unit)
		var btn := UiFactory.button("%s  (cal %d) ·x%d· ~%d" % [slot.data.display_name, slot.quality, slot.quantity, price])
		btn.custom_minimum_size = Vector2(0, 34)
		btn.pressed.connect(_select_slot.bind(slot))
		_stock_box.add_child(btn)

func _update_offer_labels() -> void:
	if _selected_slot != null:
		_selected_label.text = "Producto seleccionado: %s (cal %d)" % [_selected_slot.data.display_name, _selected_slot.quality]
	_price_label.text = "Precio: %d" % _offer_price

func _log_line(text: String) -> void:
	if _log != null:
		_log.append_text(text + "\n")

func _hsep() -> Control:
	var s := HSeparator.new()
	return s

func _cat_name(category: int) -> String:
	match category:
		GameEnums.Category.WEAPON: return "un arma"
		GameEnums.Category.ARMOR: return "una armadura"
		GameEnums.Category.POTION: return "una poción"
		GameEnums.Category.TOOL: return "una herramienta"
		GameEnums.Category.MAGIC: return "un objeto mágico"
		GameEnums.Category.MATERIAL: return "un material"
		_: return "algo"
