extends Control
## GAMEPLAY NORMAL: vista en primera persona DETRÁS DEL MOSTRADOR. Ves toda la tienda
## (pared del fondo con estanterías, puerta, ventana con el cielo según la hora) y
## atiendes a los clientes que se acercan al mostrador. Al "Cerrar tienda" se pasa a
## la vista cenital (top-down) para gestionar la distribución.
##
## El fondo se dibuja por código con sprites SVG; el día/noche tiñe la escena
## (CanvasModulate) sin oscurecer la UI (va en una CanvasLayer aparte).

var _canvas_modulate: CanvasModulate
var _character: CharacterView
var _gold_label: Label
var _day_label: Label
var _prestige_label: Label
var _need_label: Label
var _selected_label: Label
var _price_label: Label
var _offer_btn: Button
var _stock_box: HBoxContainer
var _log: RichTextLabel
var _tex: Dictionary = {}

var _current: Customer
var _controller: CustomerController
var _selected_slot: ItemInstance
var _offer_price: int = 0
var _vp: Vector2

func _ready() -> void:
	if GameState.economy == null:
		GameState.new_game()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vp = get_viewport_rect().size
	_load_textures()
	_build_scene()
	_build_ui()
	_connect_signals()
	set_process(true)
	_log_line("[color=#e8b06a]Abres la tienda de la abuela Rilda. Llega el primer cliente cuando quieras.[/color]")

func _process(delta: float) -> void:
	GameState.clock.advance(delta)
	_canvas_modulate.color = GameState.clock.light_color()
	queue_redraw()

# ------------------------------------------------------------------- escena/fondo
func _load_textures() -> void:
	_tex = {
		"shelf": _load_tex("res://assets/buildings/shelf.svg"),
		"potion": _load_tex("res://assets/items/icon_potion.svg"),
		"sword": _load_tex("res://assets/items/icon_sword.svg"),
		"armor": _load_tex("res://assets/items/icon_armor.svg"),
		"tool": _load_tex("res://assets/items/icon_tool.svg"),
		"material": _load_tex("res://assets/items/icon_material.svg"),
		"magic": _load_tex("res://assets/items/icon_magic.svg"),
	}

func _load_tex(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null

func _build_scene() -> void:
	_canvas_modulate = CanvasModulate.new()
	_canvas_modulate.color = GameState.clock.light_color()
	add_child(_canvas_modulate)

	# Cliente frente al mostrador (queda detrás de la barra del mostrador).
	_character = CharacterView.new()
	_character.custom_minimum_size = Vector2(220, 280)
	_character.position = Vector2(_vp.x * 0.5 - 110, _vp.y * 0.24)
	_character.size = Vector2(220, 280)
	add_child(_character)

	# Mostrador en primer plano (barra de madera abajo).
	var counter := Panel.new()
	counter.position = Vector2(0, _vp.y * 0.60)
	counter.size = Vector2(_vp.x, _vp.y * 0.24)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.45, 0.28, 0.14)
	sb.border_color = Color(0.30, 0.18, 0.08)
	sb.set_border_width_all(0)
	sb.border_width_top = 6
	sb.corner_radius_top_left = 14
	sb.corner_radius_top_right = 14
	counter.add_theme_stylebox_override("panel", sb)
	add_child(counter)
	# Franja pulida del borde del mostrador.
	var edge := ColorRect.new()
	edge.color = Color(0.62, 0.42, 0.22)
	edge.position = Vector2(0, _vp.y * 0.60)
	edge.size = Vector2(_vp.x, 12)
	add_child(edge)

func _draw() -> void:
	var w := size.x
	var h := size.y
	# Pared del fondo (cálida).
	draw_rect(Rect2(0, 0, w, h * 0.62), Color(0.36, 0.26, 0.18), true)
	# Suelo.
	draw_rect(Rect2(0, h * 0.62, w, h * 0.38), Color(0.30, 0.20, 0.11), true)
	# Rodapié.
	draw_rect(Rect2(0, h * 0.60, w, 6), Color(0.22, 0.14, 0.08), true)
	# Ventana (con cielo según la hora).
	var sky := GameState.clock.light_color()
	draw_rect(Rect2(w * 0.06, h * 0.12, w * 0.16, h * 0.22), sky, true)
	draw_rect(Rect2(w * 0.06, h * 0.12, w * 0.16, h * 0.22), Color(0.20, 0.13, 0.07), false, 6.0)
	draw_line(Vector2(w * 0.14, h * 0.12), Vector2(w * 0.14, h * 0.34), Color(0.20, 0.13, 0.07), 4.0)
	draw_line(Vector2(w * 0.06, h * 0.23), Vector2(w * 0.22, h * 0.23), Color(0.20, 0.13, 0.07), 4.0)
	# Estanterías del fondo con producto.
	var shelf: Texture2D = _tex.get("shelf")
	var cats := [GameEnums.Category.POTION, GameEnums.Category.WEAPON, GameEnums.Category.ARMOR, GameEnums.Category.TOOL, GameEnums.Category.MAGIC]
	for i in 5:
		var sx := w * (0.30 + i * 0.13)
		var sy := h * 0.14
		var srect := Rect2(sx, sy, w * 0.11, h * 0.20)
		if shelf != null:
			draw_texture_rect(shelf, srect, false)
		else:
			draw_rect(srect, Color(0.30, 0.20, 0.12), true)
		var icon := _category_icon(cats[i])
		if icon != null:
			var ic := srect.get_center()
			draw_texture_rect(icon, Rect2(ic - Vector2(18, 20), Vector2(36, 36)), false)
	# Puerta a la derecha.
	draw_rect(Rect2(w * 0.86, h * 0.20, w * 0.10, h * 0.40), Color(0.32, 0.20, 0.10), true)
	draw_rect(Rect2(w * 0.86, h * 0.20, w * 0.10, h * 0.40), Color(0.20, 0.13, 0.07), false, 5.0)
	draw_circle(Vector2(w * 0.875, h * 0.40), 4.0, Color(0.85, 0.7, 0.35))
	# Cartel colgante.
	draw_rect(Rect2(w * 0.42, h * 0.03, w * 0.16, h * 0.07), Color(0.5, 0.32, 0.16), true)
	draw_rect(Rect2(w * 0.42, h * 0.03, w * 0.16, h * 0.07), Color(0.85, 0.65, 0.32), false, 3.0)
	var font := ThemeDB.fallback_font
	if font != null:
		draw_string(font, Vector2(w * 0.44, h * 0.08), "YUNQUE", HORIZONTAL_ALIGNMENT_LEFT, w * 0.14, 22, Color(0.95, 0.85, 0.6))

func _category_icon(category: int) -> Texture2D:
	match category:
		GameEnums.Category.WEAPON: return _tex.get("sword")
		GameEnums.Category.ARMOR: return _tex.get("armor")
		GameEnums.Category.POTION: return _tex.get("potion")
		GameEnums.Category.TOOL: return _tex.get("tool")
		GameEnums.Category.MAGIC: return _tex.get("magic")
		GameEnums.Category.MATERIAL: return _tex.get("material")
		_: return null

# ------------------------------------------------------------------- UI (overlay)
func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	# HUD superior.
	var hud := UiFactory.panel()
	hud.position = Vector2(12, 12)
	layer.add_child(hud)
	var hrow := UiFactory.hbox(18)
	hud.add_child(hrow)
	_gold_label = UiFactory.label("Oro: 0", 18, UiFactory.COL_ACCENT)
	hrow.add_child(_gold_label)
	_day_label = UiFactory.label("Jornada: 0", 18)
	hrow.add_child(_day_label)
	_prestige_label = UiFactory.label("Prestigio: 0", 18, UiFactory.COL_ARCANE)
	hrow.add_child(_prestige_label)

	# Botones de acción (arriba a la derecha).
	var actions := UiFactory.hbox(8)
	actions.position = Vector2(_vp.x - 640, 14)
	layer.add_child(actions)
	actions.add_child(_action("Siguiente cliente", _on_next_customer))
	actions.add_child(_action("Fabricar", func() -> void: SceneRouter.goto_crafting()))
	actions.add_child(_action("Cerrar tienda", func() -> void: SceneRouter.goto_world()))
	actions.add_child(_action("Guardar", _on_save))
	actions.add_child(_action("Menú", func() -> void: SceneRouter.goto_main_menu()))

	# Panel de atención (abajo).
	var bottom := UiFactory.panel()
	bottom.position = Vector2(12, _vp.y - 190)
	bottom.size = Vector2(_vp.x - 24, 178)
	layer.add_child(bottom)
	var box := UiFactory.vbox(6)
	bottom.add_child(box)
	_need_label = UiFactory.label("No hay nadie en el mostrador. Pulsa «Siguiente cliente».", 16)
	box.add_child(_need_label)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 44)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_stock_box = UiFactory.hbox(6)
	scroll.add_child(_stock_box)

	var offer_row := UiFactory.hbox(8)
	box.add_child(offer_row)
	_selected_label = UiFactory.label("Producto: (ninguno)", 14)
	offer_row.add_child(_selected_label)
	var minus := _action("-5", _adjust_price.bind(-5))
	minus.custom_minimum_size = Vector2(50, 32)
	offer_row.add_child(minus)
	_price_label = UiFactory.label("Precio: 0", 16)
	offer_row.add_child(_price_label)
	var plus := _action("+5", _adjust_price.bind(5))
	plus.custom_minimum_size = Vector2(50, 32)
	offer_row.add_child(plus)
	_offer_btn = _action("Ofrecer", _on_offer)
	_offer_btn.disabled = true
	offer_row.add_child(_offer_btn)

	# Registro (compacto, esquina).
	var log_panel := UiFactory.panel()
	log_panel.position = Vector2(12, _vp.y * 0.30)
	layer.add_child(log_panel)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.custom_minimum_size = Vector2(360, 150)
	_log.add_theme_color_override("default_color", UiFactory.COL_TEXT)
	log_panel.add_child(_log)

	_refresh_hud()
	_refresh_stock()

func _action(text: String, cb: Callable) -> Button:
	var b := UiFactory.button(text)
	b.custom_minimum_size = Vector2(120, 34)
	b.pressed.connect(cb)
	return b

func _connect_signals() -> void:
	GameState.gold_changed.connect(func(_v: int) -> void: _refresh_hud())
	GameState.day_changed.connect(func(_d: int) -> void: _refresh_hud())
	GameState.quest_completed.connect(func(q: QuestData) -> void: _log_line("[color=#e8b06a]★ Misión: %s (+%d oro)[/color]" % [q.display_name, q.reward_gold]))
	GameState.achievement_unlocked.connect(func(a: AchievementData) -> void: _log_line("[color=#4fd0c8]🏆 %s[/color]" % a.display_name))
	GameState.event_started.connect(func(e: EventData) -> void: _log_line("[color=#d9a86a]※ %s[/color]" % e.display_name))

# ------------------------------------------------------------------- lógica venta
func _on_next_customer() -> void:
	if _current != null:
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
		_character.show_character(_sprite_for(customer))
		_need_label.text = "%s quiere %s (calidad ≥%d) · presupuesto %d · ánimo %.0f%%" % [
			customer.display_name(), _cat_name(customer.need.category),
			customer.need.min_quality, customer.need.budget, customer.mood.value * 100.0,
		]
		_log_line("Llega [b]%s[/b] al mostrador." % customer.display_name())

func _resolve_shelf(customer: Customer) -> void:
	_character.show_character(_sprite_for(customer))
	var offers := _offers_from_stock()
	var result := ShelfPurchaseResolver.resolve(customer.need, offers, customer.wallet, GameState.player_wallet, GameState.economy.demand)
	if result.bought:
		GameState.stock.remove(result.item.data.id, 1)
		GameState.record_sale_reputation(customer)
		GameState.notify_sale(result.price)
		_log_line("[color=#8fd08a]%s cogió %s de la estantería (%d coronas).[/color]" % [customer.display_name(), result.item.data.display_name, result.price])
		_character.play_happy()
		_refresh_stock()
	else:
		_log_line("%s miró y se fue sin comprar." % customer.display_name())
		_character.play_sad()
	_refresh_hud()

func _offers_from_stock() -> Array:
	var offers: Array = []
	for slot in GameState.stock.get_items():
		var unit := ItemInstance.new(slot.data, slot.quality, 1)
		offers.append({"item": unit, "price": GameState.economy.suggested_price(unit)})
	return offers

func _select_slot(slot: ItemInstance) -> void:
	if _current == null:
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
		GameState.record_sale_reputation(_current)
		GameState.notify_sale(_offer_price)
		_log_line("[color=#8fd08a]Vendiste %s por %d coronas.[/color]" % [_selected_slot.data.display_name, _offer_price])
		_character.play_happy()
		_refresh_hud()
		_end_visit()
	elif result.reason == "wrong_item":
		_log_line("A %s no le sirve eso (quería %s)." % [_current.display_name(), _cat_name(_current.need.category)])
	else:
		_log_line("[color=#d98f6a]%s rechazó la oferta. Se marcha.[/color]" % _current.display_name())
		_character.play_sad()
		_end_visit()

func _end_visit() -> void:
	_current = null
	_controller = null
	_selected_slot = null
	_offer_btn.disabled = true
	_need_label.text = "No hay nadie en el mostrador. Pulsa «Siguiente cliente»."
	_selected_label.text = "Producto: (ninguno)"
	_price_label.text = "Precio: 0"
	_refresh_stock()

func _on_save() -> void:
	if SaveManager.save_game(1):
		_log_line("[color=#8fd08a]Partida guardada.[/color]")

# ------------------------------------------------------------------- refrescos
func _refresh_hud() -> void:
	_gold_label.text = "Oro: %d" % GameState.gold()
	_day_label.text = "Jornada: %d" % GameState.day
	_prestige_label.text = "Prestigio: %d" % int(GameState.reputation.prestige())

func _refresh_stock() -> void:
	for c in _stock_box.get_children():
		c.queue_free()
	for slot in GameState.stock.get_items():
		var unit := ItemInstance.new(slot.data, slot.quality, 1)
		var price := GameState.economy.suggested_price(unit)
		var btn := UiFactory.button("%s ·x%d· ~%d" % [slot.data.display_name, slot.quantity, price])
		btn.custom_minimum_size = Vector2(0, 32)
		btn.pressed.connect(_select_slot.bind(slot))
		_stock_box.add_child(btn)

func _update_offer_labels() -> void:
	if _selected_slot != null:
		_selected_label.text = "Producto: %s (cal %d)" % [_selected_slot.data.display_name, _selected_slot.quality]
	_price_label.text = "Precio: %d" % _offer_price

func _log_line(text: String) -> void:
	if _log != null:
		_log.append_text(text + "\n")

func _sprite_for(customer: Customer) -> String:
	var base := "res://assets/characters/"
	match customer.data.faction:
		GameEnums.Faction.CROWN, GameEnums.Faction.GUILD:
			return base + "customer_knight.svg"
		GameEnums.Faction.ARCANE:
			return base + "customer_mage.svg"
		_:
			return base + "customer_villager.svg"

func _cat_name(category: int) -> String:
	match category:
		GameEnums.Category.WEAPON: return "un arma"
		GameEnums.Category.ARMOR: return "una armadura"
		GameEnums.Category.POTION: return "una poción"
		GameEnums.Category.TOOL: return "una herramienta"
		GameEnums.Category.MAGIC: return "un objeto mágico"
		GameEnums.Category.MATERIAL: return "un material"
		_: return "algo"
