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
var _prestige_label: Label      # "Reputación: Nivel N"
var _level_label: Label         # "Nivel Tienda: N"
var _events_box: VBoxContainer  # lista "Eventos & Tareas"
var _need_label: Label
var _selected_label: Label
var _price_label: Label
var _offer_btn: Button
var _stock_box: HBoxContainer
var _serve_panel: Panel         # burbuja de atención (aparece con cliente)
var _atender_btn: Button
var _ui_layer: CanvasLayer       # capa de HUD (para popups por encima)
var _log: RichTextLabel
var _tex: Dictionary = {}

# Paleta pergamino/madera del mockup.
const COL_PARCH := Color("e6d2a6")
const COL_PARCH_EDGE := Color("5b3d22")
const COL_INK := Color("3a2414")
const COL_WOOD := Color("6b4526")
const COL_WOOD_HI := Color("845735")
const COL_GOLD := Color("c8912f")

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
## Reconstruye el HUD según el mockup: pergamino de stats arriba-izquierda,
## "Eventos & Tareas" arriba-derecha, botones laterales (Hablar/Vender/Comprar),
## barra inferior (Inventario/Recetas/Fabricación/Almacén) y el gran ATENDER CLIENTE.
func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_ui_layer = layer

	_build_stats_panel(layer)
	_build_events_panel(layer)
	_build_side_actions(layer)
	_build_bottom_bar(layer)
	_build_serve_panel(layer)
	_build_log(layer)

	_refresh_hud()
	_refresh_events()
	_refresh_stock()

# --- pergamino de stats (arriba-izquierda) ---------------------------------
func _build_stats_panel(layer: CanvasLayer) -> void:
	var w := clampf(_vp.x * 0.24, 300.0, 380.0)
	var p := _parch(Vector2(w, 168))
	p.position = Vector2(16, 16)
	layer.add_child(p)
	var col := UiFactory.vbox(2)
	col.position = Vector2(14, 10)
	col.custom_minimum_size = Vector2(w - 28, 0)
	p.add_child(col)

	var name_row := UiFactory.hbox(6)
	col.add_child(name_row)
	var title := _plabel("El Bazar del Mazmorrero", 22, COL_INK)
	name_row.add_child(title)
	col.add_child(_plabel("(Store Name)", 12, Color("6b4a2b")))
	_gold_label = _plabel("Oro: 0", 18, COL_INK)
	col.add_child(_gold_label)
	_prestige_label = _plabel("Reputación: Nivel 1", 18, COL_INK)
	col.add_child(_prestige_label)
	_day_label = _plabel("Día: 0", 18, COL_INK)
	col.add_child(_day_label)
	_level_label = _plabel("Nivel Tienda: 1", 18, COL_INK)
	col.add_child(_level_label)

	# Botones de pausa/ajustes (esquina superior derecha del pergamino).
	var pause := _icon_btn("॥", _on_save)
	pause.position = Vector2(w - 76, 8)
	p.add_child(pause)
	var gear := _icon_btn("⚙", func() -> void: SceneRouter.goto_main_menu())
	gear.position = Vector2(w - 40, 8)
	p.add_child(gear)

# --- pergamino de eventos & tareas (arriba-derecha) ------------------------
func _build_events_panel(layer: CanvasLayer) -> void:
	var w := clampf(_vp.x * 0.24, 300.0, 380.0)
	var p := _parch(Vector2(w, 168))
	p.position = Vector2(_vp.x - w - 16, 16)
	layer.add_child(p)
	var col := UiFactory.vbox(3)
	col.position = Vector2(14, 10)
	col.custom_minimum_size = Vector2(w - 28, 0)
	p.add_child(col)
	col.add_child(_plabel("Eventos & Tareas", 18, COL_INK))
	_events_box = UiFactory.vbox(2)
	col.add_child(_events_box)

# --- acciones laterales (Hablar / Vender / Comprar) ------------------------
func _build_side_actions(layer: CanvasLayer) -> void:
	var col := UiFactory.vbox(10)
	col.position = Vector2(_vp.x - 172, _vp.y * 0.42)
	layer.add_child(col)
	col.add_child(_wood_btn("💬 Hablar", _on_talk, 150, 44))
	col.add_child(_wood_btn("Vender", _on_open_sell, 150, 44))
	col.add_child(_wood_btn("Comprar", _on_open_buy, 150, 44))

# --- barra inferior (navegación) + ATENDER CLIENTE -------------------------
func _build_bottom_bar(layer: CanvasLayer) -> void:
	var nav := UiFactory.hbox(10)
	nav.position = Vector2(16, _vp.y - 58)
	layer.add_child(nav)
	nav.add_child(_wood_btn("Inventario", _on_open_sell, 128, 42))
	nav.add_child(_wood_btn("Recetas", func() -> void: SceneRouter.goto_crafting(), 128, 42))
	nav.add_child(_wood_btn("Fabricación", func() -> void: SceneRouter.goto_crafting(), 128, 42))
	nav.add_child(_wood_btn("Almacén", func() -> void: SceneRouter.goto_world(), 128, 42))

	_atender_btn = _wood_btn("ATENDER CLIENTE", _on_next_customer, 320, 56)
	_atender_btn.add_theme_font_size_override("font_size", 22)
	_atender_btn.position = Vector2(_vp.x * 0.5 - 160, _vp.y - 74)
	layer.add_child(_atender_btn)

# --- burbuja de atención (aparece cuando hay cliente) ----------------------
func _build_serve_panel(layer: CanvasLayer) -> void:
	var w := clampf(_vp.x * 0.62, 560.0, 900.0)
	_serve_panel = _parch(Vector2(w, 150))
	_serve_panel.position = Vector2(_vp.x * 0.5 - w * 0.5, _vp.y - 250)
	_serve_panel.visible = false
	layer.add_child(_serve_panel)
	var box := UiFactory.vbox(6)
	box.position = Vector2(16, 12)
	box.custom_minimum_size = Vector2(w - 32, 0)
	_serve_panel.add_child(box)
	_need_label = _plabel("", 16, COL_INK)
	_need_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_need_label.custom_minimum_size = Vector2(w - 32, 0)
	box.add_child(_need_label)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(w - 32, 46)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_stock_box = UiFactory.hbox(6)
	scroll.add_child(_stock_box)

	var offer_row := UiFactory.hbox(8)
	box.add_child(offer_row)
	_selected_label = _plabel("Producto: (ninguno)", 14, COL_INK)
	offer_row.add_child(_selected_label)
	offer_row.add_child(_wood_btn("-5", _adjust_price.bind(-5), 46, 30))
	_price_label = _plabel("Precio: 0", 16, COL_INK)
	offer_row.add_child(_price_label)
	offer_row.add_child(_wood_btn("+5", _adjust_price.bind(5), 46, 30))
	_offer_btn = _wood_btn("Ofrecer", _on_offer, 110, 32)
	_offer_btn.disabled = true
	offer_row.add_child(_offer_btn)

# --- registro compacto (esquina) -------------------------------------------
func _build_log(layer: CanvasLayer) -> void:
	var log_panel := _parch(Vector2(340, 150))
	log_panel.position = Vector2(16, _vp.y * 0.30)
	layer.add_child(log_panel)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.position = Vector2(12, 10)
	_log.custom_minimum_size = Vector2(316, 130)
	_log.size = Vector2(316, 130)
	_log.add_theme_color_override("default_color", COL_INK)
	log_panel.add_child(_log)

# ------------------------------------------------------------------- widgets
## Panel con estilo pergamino (crema, borde marrón, esquinas redondeadas).
func _parch(sz: Vector2) -> Panel:
	var p := Panel.new()
	p.size = sz
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_PARCH
	sb.border_color = COL_PARCH_EDGE
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(8)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 6
	p.add_theme_stylebox_override("panel", sb)
	return p

func _plabel(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

## Botón de madera cálido (con hover más claro), estilo del mockup.
func _wood_btn(text: String, cb: Callable, w: float, h: float) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(w, h)
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_color_override("font_color", Color("f4e7d2"))
	b.add_theme_color_override("font_hover_color", Color("ffedcf"))
	b.add_theme_color_override("font_disabled_color", Color("9a8a72"))
	b.add_theme_stylebox_override("normal", _wood_style(COL_WOOD))
	b.add_theme_stylebox_override("hover", _wood_style(COL_WOOD_HI))
	b.add_theme_stylebox_override("pressed", _wood_style(Color("543619")))
	b.add_theme_stylebox_override("disabled", _wood_style(Color("4a3a2a")))
	b.pressed.connect(cb)
	return b

func _wood_style(c: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.border_color = Color("3a2414")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(6)
	return sb

func _icon_btn(glyph: String, cb: Callable) -> Button:
	var b := _wood_btn(glyph, cb, 32, 28)
	b.add_theme_font_size_override("font_size", 16)
	return b

func _connect_signals() -> void:
	GameState.gold_changed.connect(func(_v: int) -> void: _refresh_hud())
	GameState.day_changed.connect(func(_d: int) -> void: _refresh_hud())
	GameState.quest_completed.connect(func(q: QuestData) -> void:
		_log_line("[color=#e8b06a]★ Misión: %s (+%d oro)[/color]" % [q.display_name, q.reward_gold])
		_refresh_events())
	GameState.achievement_unlocked.connect(func(a: AchievementData) -> void: _log_line("[color=#4fd0c8]🏆 %s[/color]" % a.display_name))
	GameState.event_started.connect(func(e: EventData) -> void:
		_log_line("[color=#d9a86a]※ %s[/color]" % e.display_name)
		_refresh_events())

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
		_show_need()
		_serve_panel.visible = true
		_log_line("Llega [b]%s[/b] al mostrador." % customer.display_name())

## Texto del pedido del cliente actual (estilo diálogo del mockup).
func _show_need() -> void:
	if _current == null:
		return
	_need_label.text = "¡Aventurero! Busco %s (calidad ≥%d). Presupuesto: %d · ánimo %.0f%%" % [
		_cat_name(_current.need.category), _current.need.min_quality,
		_current.need.budget, _current.mood.value * 100.0,
	]

# ------------------------------------------------------------------- acciones laterales
func _on_talk() -> void:
	if _current == null:
		_log_line("No hay ningún cliente en el mostrador. Pulsa «ATENDER CLIENTE».")
		return
	_serve_panel.visible = true
	_show_need()

func _on_open_sell() -> void:
	if _current == null:
		_log_line("Primero atiende a un cliente para venderle algo.")
		return
	_serve_panel.visible = true
	_refresh_stock()

func _on_open_buy() -> void:
	if GameState.market_materials.is_empty():
		return
	var pop := _parch(Vector2(360, 66 + GameState.market_materials.size() * 40))
	pop.position = Vector2(_vp.x * 0.5 - 180, _vp.y * 0.5 - 140)
	_ui_layer.add_child(pop)
	var col := UiFactory.vbox(6)
	col.position = Vector2(14, 12)
	pop.add_child(col)
	col.add_child(_plabel("Comprar materiales", 18, COL_INK))
	for mat_id in GameState.market_materials:
		var price := GameState.material_price(mat_id)
		var mat_name := String(mat_id).replace("mat_", "").capitalize()
		col.add_child(_wood_btn("%s  ·  %d oro" % [mat_name, price], _buy_material.bind(mat_id), 320, 34))
	col.add_child(_wood_btn("Cerrar", func() -> void: pop.queue_free(), 320, 30))

func _buy_material(mat_id: StringName) -> void:
	var mat_name := String(mat_id).replace("mat_", "")
	if GameState.buy_material(mat_id, 1):
		_log_line("[color=#8fd08a]Compraste %s.[/color]" % mat_name)
		_refresh_hud()
	else:
		_log_line("[color=#d98f6a]No te alcanza el oro para %s.[/color]" % mat_name)

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
	_serve_panel.visible = false
	_selected_label.text = "Producto: (ninguno)"
	_price_label.text = "Precio: 0"
	_refresh_stock()

func _on_save() -> void:
	if SaveManager.save_game(1):
		_log_line("[color=#8fd08a]Partida guardada.[/color]")

# ------------------------------------------------------------------- refrescos
func _refresh_hud() -> void:
	var prestige := GameState.reputation.prestige()
	_gold_label.text = "Oro: %d" % GameState.gold()
	_day_label.text = "Día: %d" % GameState.day
	_prestige_label.text = "Reputación: Nivel %d ★" % (1 + int(prestige / 100.0))
	_level_label.text = "Nivel Tienda: %d" % (1 + int(prestige / 250.0))

## Rellena "Eventos & Tareas" con las misiones activas (numeradas).
func _refresh_events() -> void:
	if _events_box == null:
		return
	for c in _events_box.get_children():
		c.queue_free()
	var active: Array = GameState.quests.active()
	if active.is_empty():
		_events_box.add_child(_plabel("· Sin tareas pendientes.", 14, Color("6b4a2b")))
		return
	var i := 1
	for q in active:
		_events_box.add_child(_plabel("%d. %s" % [i, q.display_name], 15, COL_INK))
		i += 1

func _refresh_stock() -> void:
	for c in _stock_box.get_children():
		c.queue_free()
	for slot in GameState.stock.get_items():
		var unit := ItemInstance.new(slot.data, slot.quality, 1)
		var price := GameState.economy.suggested_price(unit)
		var btn := _wood_btn("%s ·x%d· ~%d" % [slot.data.display_name, slot.quantity, price], _select_slot.bind(slot), 150, 32)
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
