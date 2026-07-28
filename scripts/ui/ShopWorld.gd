extends Control
## Vista de la tienda (HÍBRIDA): usa la ILUSTRACIÓN top-down del diseñador como
## fondo (assets/ui/shop_topdown_art.png) y coloca ZONAS CLICABLES invisibles sobre
## las estanterías/mesas. Al tocar una zona se abre un selector para asignar qué
## producto se expone ahí; la asignación persiste en ShopLayout (se guarda con la
## partida). El día/noche tiñe la ilustración para dar ambiente.
##
## Así se combina tu arte con la mecánica de "elegir qué va en cada estante". Las
## zonas están en fracciones de pantalla; se pueden reubicar sin tocar la lógica.

const ART := "res://assets/ui/shop_topdown_art.png"

## Zonas de estantería sobre la ilustración (fracción de pantalla: x, y, ancho, alto).
const SHELF_ZONES := [
	Rect2(0.615, 0.04, 0.31, 0.34),   # estantería alta de pociones (arriba-derecha)
	Rect2(0.135, 0.02, 0.21, 0.22),   # estantería izquierda (arriba)
	Rect2(0.145, 0.30, 0.22, 0.20),   # mesa de ingredientes (izquierda)
	Rect2(0.135, 0.62, 0.22, 0.21),   # mesa inferior (izquierda)
	Rect2(0.815, 0.55, 0.17, 0.32),   # cajones/cesta (abajo-derecha)
	Rect2(0.695, 0.34, 0.12, 0.19),   # barril/mesa (derecha)
]

var _vp: Vector2
var _bg: TextureRect
var _ui: CanvasLayer
var _assignable_ids: Array = []
var _shelf_cells: Array = []       # [{x, y}] mapeada a cada zona
var _zone_icons: Array = []        # TextureRect del icono expuesto por zona
var _tex: Dictionary = {}          # iconos de categoría
var _active_pop: Panel             # popup de selección abierto

func _ready() -> void:
	if GameState.economy == null:
		GameState.new_game()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vp = get_viewport_rect().size
	_load_icons()
	_assignable_ids = _build_assignable_ids()
	_ensure_shelf_cells(SHELF_ZONES.size())
	_build_bg()
	_build_zones()
	_build_ui()
	set_process(true)

func _process(_delta: float) -> void:
	GameState.clock.advance(_delta)
	# Teñir la ilustración según la hora, sin oscurecerla del todo.
	_bg.modulate = GameState.clock.light_color().lerp(Color.WHITE, 0.35)

# ------------------------------------------------------------------- fondo
func _build_bg() -> void:
	_bg = TextureRect.new()
	_bg.texture = load(ART)
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

# ------------------------------------------------------------------- zonas
func _build_zones() -> void:
	_ui = CanvasLayer.new()
	add_child(_ui)
	for i in SHELF_ZONES.size():
		var r := _to_px(SHELF_ZONES[i])
		var btn := Button.new()
		btn.position = r.position
		btn.size = r.size
		btn.flat = true
		btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		btn.add_theme_stylebox_override("hover", _hover_style())
		btn.add_theme_stylebox_override("pressed", _hover_style())
		btn.pressed.connect(_open_picker.bind(i))
		_ui.add_child(btn)

		# Icono del producto expuesto (centrado en la zona).
		var icon := TextureRect.new()
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(48, 48)
		icon.size = Vector2(48, 48)
		icon.position = r.get_center() - Vector2(24, 24)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ui.add_child(icon)
		_zone_icons.append(icon)
		_refresh_zone_icon(i)

func _refresh_zone_icon(i: int) -> void:
	var cell: Dictionary = _shelf_cells[i]
	var item_id: StringName = GameState.layout.assigned_item(cell.x, cell.y)
	var icon: TextureRect = _zone_icons[i]
	if item_id == &"":
		icon.texture = null
		return
	var item := GameState.item_db.get_item(item_id)
	icon.texture = _category_icon(item.category) if item != null else null

# ------------------------------------------------------------------- selector
func _open_picker(zone: int) -> void:
	var pop := _parch(Vector2(360, 420))
	pop.position = _vp * 0.5 - Vector2(180, 210)
	_ui.add_child(pop)
	var col := UiFactory.vbox(6)
	col.position = Vector2(14, 12)
	pop.add_child(col)
	col.add_child(_ink("¿Qué exponés aquí?", 18))

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(332, 320)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var list := UiFactory.vbox(4)
	scroll.add_child(list)

	for item_id in _assignable_ids:
		var item := GameState.item_db.get_item(item_id)
		if item == null:
			continue
		var b := _wood_btn(item.display_name, 320, 32, _assign_to.bind(zone, item_id))
		list.add_child(b)

	var row := UiFactory.hbox(8)
	col.add_child(row)
	row.add_child(_wood_btn("Vaciar", 150, 30, _clear_zone.bind(zone)))
	row.add_child(_wood_btn("Cerrar", 150, 30, func() -> void: pop.queue_free()))
	_active_pop = pop

func _assign_to(zone: int, item_id: StringName) -> void:
	var cell: Dictionary = _shelf_cells[zone]
	GameState.layout.assign(cell.x, cell.y, item_id)
	_refresh_zone_icon(zone)
	_close_pop()

func _clear_zone(zone: int) -> void:
	var cell: Dictionary = _shelf_cells[zone]
	GameState.layout.assign(cell.x, cell.y, &"")
	_refresh_zone_icon(zone)
	_close_pop()

func _close_pop() -> void:
	if _active_pop != null:
		_active_pop.queue_free()
		_active_pop = null

# ------------------------------------------------------------------- HUD
func _build_ui() -> void:
	var title := _ink("Tu tienda · tocá una estantería para elegir qué exponer", 20)
	title.position = Vector2(24, 18)
	title.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	_ui.add_child(title)

	var back := _wood_btn("Volver al mostrador", 220, 44,
		func() -> void: SceneRouter.goto_counter())
	back.position = Vector2(24, _vp.y - 62)
	_ui.add_child(back)

# ------------------------------------------------------------------- datos
## Asegura que existan al menos n celdas de estante en el layout y las mapea a zonas.
func _ensure_shelf_cells(n: int) -> void:
	var shelves := GameState.layout.shelves()
	for s in shelves:
		_shelf_cells.append({"x": s.x, "y": s.y})
	# Si faltan estantes para las zonas, se crean en celdas libres.
	var y := 0
	while _shelf_cells.size() < n and y < GameState.layout.height:
		for x in GameState.layout.width:
			if _shelf_cells.size() >= n:
				break
			if GameState.layout.furniture_at(x, y) == ShopLayout.Furniture.NONE:
				if GameState.layout.place(x, y, ShopLayout.Furniture.SHELF):
					_shelf_cells.append({"x": x, "y": y})
		y += 1
	# Recorta por si había de más.
	_shelf_cells = _shelf_cells.slice(0, n)

func _build_assignable_ids() -> Array:
	var ids: Array = []
	for item in GameState.item_db.all():
		ids.append(item.id)
	ids.sort()
	return ids

func _load_icons() -> void:
	_tex = {
		GameEnums.Category.WEAPON: _load_tex("res://assets/items/icon_sword.svg"),
		GameEnums.Category.ARMOR: _load_tex("res://assets/items/icon_armor.svg"),
		GameEnums.Category.POTION: _load_tex("res://assets/items/icon_potion.svg"),
		GameEnums.Category.TOOL: _load_tex("res://assets/items/icon_tool.svg"),
		GameEnums.Category.MAGIC: _load_tex("res://assets/items/icon_magic.svg"),
		GameEnums.Category.MATERIAL: _load_tex("res://assets/items/icon_material.svg"),
	}

func _load_tex(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null

func _category_icon(category: int) -> Texture2D:
	return _tex.get(category)

func _to_px(frac: Rect2) -> Rect2:
	return Rect2(frac.position * _vp, frac.size * _vp)

# ------------------------------------------------------------------- widgets
func _hover_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.82, 0.35, 0.16)
	sb.border_color = Color(1.0, 0.82, 0.4, 0.85)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(6)
	return sb

func _parch(sz: Vector2) -> Panel:
	var p := Panel.new()
	p.size = sz
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("e6d2a6")
	sb.border_color = Color("5b3d22")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(8)
	sb.shadow_color = Color(0, 0, 0, 0.4)
	sb.shadow_size = 8
	p.add_theme_stylebox_override("panel", sb)
	return p

func _ink(text: String, font_size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color("3a2414"))
	return l

func _wood_btn(text: String, w: float, h: float, cb: Callable = Callable()) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(w, h)
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color("f4e7d2"))
	b.add_theme_color_override("font_hover_color", Color("ffedcf"))
	b.add_theme_stylebox_override("normal", _wood_style(Color("6b4526")))
	b.add_theme_stylebox_override("hover", _wood_style(Color("845735")))
	b.add_theme_stylebox_override("pressed", _wood_style(Color("543619")))
	if cb.is_valid():
		b.pressed.connect(cb)
	return b

func _wood_style(c: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.border_color = Color("3a2414")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(5)
	return sb
