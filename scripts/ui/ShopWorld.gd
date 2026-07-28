extends Node2D
## Vista CENITAL (top-down) de la tienda. Renderiza la cuadrícula de ShopLayout con
## suelo, paredes, mostrador, estantes (con su producto) y decoración; aplica el
## ciclo día/noche (CanvasModulate), el clima (partículas de lluvia/nieve + niebla),
## partículas ambientales (polvo), antorchas con parpadeo y humo de la forja. El
## jugador coloca muebles y asigna qué producto va en cada estante.
##
## TODO EL ARTE ES PLACEHOLDER (formas de color): para el pixel art HD final se
## sustituyen los dibujos por tiles/sprites. Ver docs/ArtDirection.md.

const TILE := 64

enum Tool { SELECT, SHELF, COUNTER, DECOR, ERASE }

var _tool: int = Tool.SELECT
var _assignable_ids: Array = []
var _time_accum: float = 0.0
var _canvas_modulate: CanvasModulate
var _fog: ColorRect
var _rain: CPUParticles2D
var _snow: CPUParticles2D
var _info_label: Label
var _tool_label: Label
## Clientes que deambulan por la tienda (vida ambiental).
var _wanderers: Array = []
## Tormenta: temporizador y brillo del relámpago.
var _lightning_timer: float = 6.0
var _flash: float = 0.0
## Texturas (sprites SVG). key -> Texture2D.
var _tex: Dictionary = {}
## Luces dinámicas (antorchas, forja).
var _lights: Array = []

func _ready() -> void:
	if GameState.economy == null:
		GameState.new_game()
	_load_textures()
	_assignable_ids = _build_assignable_ids()
	_build_camera()
	_build_lights()
	_build_ambient()
	_build_forge_smoke()
	_build_weather_nodes()
	_build_fog()
	_build_wanderers()
	_build_ui()
	_update_weather_visuals()
	set_process(true)

func _process(delta: float) -> void:
	# Ciclo día/noche.
	GameState.clock.advance(delta)
	_canvas_modulate.color = GameState.clock.light_color()
	_time_accum += delta
	_update_wanderers(delta)
	_update_lightning(delta)
	_update_lights()
	# Parpadeo de antorchas, movimiento de clientes, relámpagos: redibuja cada frame.
	queue_redraw()
	_refresh_info()

## Las luces parpadean y brillan más cuanto más oscuro está (noche).
func _update_lights() -> void:
	var night := 1.0 - GameState.clock.daylight()
	var flicker := 0.85 + 0.15 * sin(_time_accum * 9.0)
	var energy := (0.35 + 1.15 * night) * flicker
	for light in _lights:
		light.energy = energy

# ------------------------------------------------------------------- construcción
func _grid_size() -> Vector2:
	return Vector2(GameState.layout.width * TILE, GameState.layout.height * TILE)

func _build_camera() -> void:
	_canvas_modulate = CanvasModulate.new()
	_canvas_modulate.color = GameState.clock.light_color()
	add_child(_canvas_modulate)

	var cam := Camera2D.new()
	var grid := _grid_size()
	cam.position = grid / 2.0
	var vp := get_viewport_rect().size
	var zoom_factor: float = minf(vp.x / (grid.x + 260.0), vp.y / (grid.y + 260.0))
	cam.zoom = Vector2(zoom_factor, zoom_factor)
	add_child(cam)
	cam.make_current()

func _build_lights() -> void:
	var light_tex := _make_light_texture()
	var grid := _grid_size()
	# Antorchas (esquinas superiores) y forja (mostrador).
	var spots := [
		Vector2(TILE * 0.5, TILE * 0.3),
		Vector2(grid.x - TILE * 0.5, TILE * 0.3),
	]
	var forge := _first_furniture(ShopLayout.Furniture.COUNTER)
	if forge != Vector2(-1, -1):
		spots.append(Vector2(forge.x * TILE + TILE / 2.0, forge.y * TILE + TILE / 2.0))
	for spot in spots:
		var light := PointLight2D.new()
		light.texture = light_tex
		light.color = Color(1.0, 0.78, 0.42)
		light.energy = 0.8
		light.texture_scale = 1.6
		light.position = spot
		add_child(light)
		_lights.append(light)

## Genera por código una textura radial (blanca al centro, transparente al borde)
## para las luces, sin necesidad de un asset.
func _make_light_texture() -> Texture2D:
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 256
	tex.height = 256
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex

func _build_ambient() -> void:
	# Polvo cálido flotando suavemente sobre la tienda.
	var dust := CPUParticles2D.new()
	var grid := _grid_size()
	dust.position = grid / 2.0
	dust.amount = 40
	dust.lifetime = 6.0
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = grid / 2.0
	dust.gravity = Vector2(0, -6)
	dust.initial_velocity_min = 2.0
	dust.initial_velocity_max = 8.0
	dust.scale_amount_min = 1.0
	dust.scale_amount_max = 2.5
	dust.color = Color(1.0, 0.9, 0.7, 0.10)
	add_child(dust)

func _build_forge_smoke() -> void:
	# Humo gris que sube desde la forja (primer mostrador que se encuentre).
	var spot := _first_furniture(ShopLayout.Furniture.COUNTER)
	if spot == Vector2(-1, -1):
		return
	var smoke := CPUParticles2D.new()
	smoke.position = Vector2(spot.x * TILE + TILE / 2.0, spot.y * TILE + 6)
	smoke.amount = 22
	smoke.lifetime = 2.4
	smoke.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	smoke.emission_rect_extents = Vector2(8, 4)
	smoke.gravity = Vector2(4, -34)
	smoke.initial_velocity_min = 6.0
	smoke.initial_velocity_max = 16.0
	smoke.scale_amount_min = 2.0
	smoke.scale_amount_max = 5.0
	smoke.color = Color(0.5, 0.5, 0.52, 0.28)
	add_child(smoke)

func _build_wanderers() -> void:
	var texes := ["shopper1", "shopper2", "shopper3"]
	var colors := [Color(0.8, 0.5, 0.4), Color(0.5, 0.6, 0.8), Color(0.6, 0.75, 0.55)]
	for i in 3:
		_wanderers.append({
			"pos": _random_walk_point(),
			"target": _random_walk_point(),
			"tex": texes[i % texes.size()],
			"color": colors[i % colors.size()],
			"phase": randf() * TAU,
			"speed": randf_range(28.0, 46.0),
		})

func _random_walk_point() -> Vector2:
	var gx := randi() % GameState.layout.width
	var gy := randi() % GameState.layout.height
	return Vector2(gx * TILE + TILE / 2.0, gy * TILE + TILE / 2.0)

func _update_wanderers(delta: float) -> void:
	for w in _wanderers:
		var pos: Vector2 = w["pos"]
		var target: Vector2 = w["target"]
		var to_target := target - pos
		if to_target.length() < 4.0:
			w["target"] = _random_walk_point()
		else:
			w["pos"] = pos + to_target.normalized() * w["speed"] * delta
		w["phase"] = float(w["phase"]) + delta * 6.0

func _update_lightning(delta: float) -> void:
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 4.0)
	if GameState.weather.weather == WeatherSystem.Weather.STORM:
		_lightning_timer -= delta
		if _lightning_timer <= 0.0:
			_flash = 0.6
			_lightning_timer = randf_range(4.0, 11.0)

func _first_furniture(kind: int) -> Vector2:
	for y in GameState.layout.height:
		for x in GameState.layout.width:
			if GameState.layout.furniture_at(x, y) == kind:
				return Vector2(x, y)
	return Vector2(-1, -1)

func _build_weather_nodes() -> void:
	var grid := _grid_size()
	_rain = CPUParticles2D.new()
	_rain.position = Vector2(grid.x / 2.0, -40)
	_rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_rain.emission_rect_extents = Vector2(grid.x / 2.0 + 160.0, 6)
	_rain.amount = 240
	_rain.lifetime = 0.9
	_rain.gravity = Vector2(60, 1000)
	_rain.initial_velocity_min = 500.0
	_rain.initial_velocity_max = 700.0
	_rain.scale_amount_min = 1.0
	_rain.scale_amount_max = 1.6
	_rain.color = Color(0.6, 0.72, 0.92, 0.65)
	_rain.emitting = false
	add_child(_rain)

	_snow = CPUParticles2D.new()
	_snow.position = Vector2(grid.x / 2.0, -40)
	_snow.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_snow.emission_rect_extents = Vector2(grid.x / 2.0 + 160.0, 6)
	_snow.amount = 140
	_snow.lifetime = 5.0
	_snow.gravity = Vector2(10, 70)
	_snow.initial_velocity_min = 20.0
	_snow.initial_velocity_max = 45.0
	_snow.scale_amount_min = 1.5
	_snow.scale_amount_max = 3.0
	_snow.color = Color(1.0, 1.0, 1.0, 0.85)
	_snow.emitting = false
	add_child(_snow)

func _build_fog() -> void:
	# Niebla: una capa translúcida gris-azulada sobre el mundo (bajo la UI).
	var fog_layer := CanvasLayer.new()
	fog_layer.layer = 1
	add_child(fog_layer)
	_fog = ColorRect.new()
	_fog.color = Color(0.7, 0.74, 0.8, 0.32)
	_fog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fog.visible = false
	fog_layer.add_child(_fog)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 2
	add_child(layer)

	# Barra superior de información (minimalista).
	var top := PanelContainer.new()
	top.position = Vector2(12, 12)
	layer.add_child(top)
	var row := UiFactory.hbox(16)
	top.add_child(row)
	_info_label = UiFactory.label("", 16)
	row.add_child(_info_label)

	# Barra de herramientas de colocación (abajo).
	var bottom := PanelContainer.new()
	bottom.position = Vector2(12, get_viewport_rect().size.y - 64)
	layer.add_child(bottom)
	var tools := UiFactory.hbox(8)
	bottom.add_child(tools)
	tools.add_child(_tool_button("Seleccionar", Tool.SELECT))
	tools.add_child(_tool_button("Estante", Tool.SHELF))
	tools.add_child(_tool_button("Mostrador", Tool.COUNTER))
	tools.add_child(_tool_button("Decorar", Tool.DECOR))
	tools.add_child(_tool_button("Borrar", Tool.ERASE))
	_tool_label = UiFactory.label("Herramienta: Seleccionar", 14, UiFactory.COL_ARCANE)
	tools.add_child(_tool_label)
	var back := UiFactory.button("Volver")
	back.pressed.connect(func() -> void: SceneRouter.goto_shop())
	tools.add_child(back)

func _tool_button(text: String, tool_id: int) -> Button:
	var b := UiFactory.button(text)
	b.custom_minimum_size = Vector2(110, 34)
	b.pressed.connect(func() -> void: _set_tool(tool_id, text))
	return b

# ----------------------------------------------------------------------- input
func _set_tool(tool_id: int, label: String) -> void:
	_tool = tool_id
	_tool_label.text = "Herramienta: %s" % label

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world := get_global_mouse_position()
		var tx := int(floor(world.x / float(TILE)))
		var ty := int(floor(world.y / float(TILE)))
		if not GameState.layout.in_bounds(tx, ty):
			return
		_apply_tool(tx, ty)
		queue_redraw()

func _apply_tool(tx: int, ty: int) -> void:
	match _tool:
		Tool.SHELF:
			GameState.layout.place(tx, ty, ShopLayout.Furniture.SHELF)
		Tool.COUNTER:
			GameState.layout.place(tx, ty, ShopLayout.Furniture.COUNTER)
		Tool.DECOR:
			GameState.layout.place(tx, ty, ShopLayout.Furniture.DECOR)
		Tool.ERASE:
			GameState.layout.remove(tx, ty)
		_:
			# Seleccionar: si es un estante, cambia el producto que expone.
			if GameState.layout.furniture_at(tx, ty) == ShopLayout.Furniture.SHELF:
				_cycle_shelf_product(tx, ty)

func _cycle_shelf_product(tx: int, ty: int) -> void:
	if _assignable_ids.is_empty():
		return
	var current := GameState.layout.assigned_item(tx, ty)
	var idx := _assignable_ids.find(current)
	var next: StringName = _assignable_ids[(idx + 1) % _assignable_ids.size()]
	GameState.layout.assign(tx, ty, next)

func _build_assignable_ids() -> Array:
	var ids: Array = []
	for item in GameState.item_db.all():
		ids.append(item.id)
	ids.sort()
	return ids

# ------------------------------------------------------------------- texturas
func _load_textures() -> void:
	_tex = {
		"floor": _load_tex("res://assets/tilesets/floor_wood.svg"),
		"wall": _load_tex("res://assets/tilesets/wall_stone.svg"),
		"shelf": _load_tex("res://assets/buildings/shelf.svg"),
		"counter": _load_tex("res://assets/buildings/counter.svg"),
		"plant": _load_tex("res://assets/buildings/plant.svg"),
		"barrel": _load_tex("res://assets/buildings/barrel.svg"),
		"rug": _load_tex("res://assets/buildings/rug.svg"),
		"torch": _load_tex("res://assets/buildings/torch.svg"),
		"anvil": _load_tex("res://assets/buildings/anvil.svg"),
		"potion": _load_tex("res://assets/items/icon_potion.svg"),
		"sword": _load_tex("res://assets/items/icon_sword.svg"),
		"armor": _load_tex("res://assets/items/icon_armor.svg"),
		"tool": _load_tex("res://assets/items/icon_tool.svg"),
		"material": _load_tex("res://assets/items/icon_material.svg"),
		"magic": _load_tex("res://assets/items/icon_magic.svg"),
		"shopper1": _load_tex("res://assets/characters/shopper_top_1.svg"),
		"shopper2": _load_tex("res://assets/characters/shopper_top_2.svg"),
		"shopper3": _load_tex("res://assets/characters/shopper_top_3.svg"),
	}

func _load_tex(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null

# ------------------------------------------------------------------- dibujo
func _draw() -> void:
	var layout := GameState.layout
	var polish := _polish()  # 0..1 según prestigio: la tienda mejora de aspecto
	for y in layout.height:
		for x in layout.width:
			_draw_floor(x, y, polish)
	_draw_walls()
	_draw_entrance_rug()
	# Muebles encima del suelo.
	for y in layout.height:
		for x in layout.width:
			match layout.furniture_at(x, y):
				ShopLayout.Furniture.COUNTER:
					_draw_counter(x, y)
				ShopLayout.Furniture.SHELF:
					_draw_shelf(x, y)
				ShopLayout.Furniture.DECOR:
					_draw_decor(x, y)
	_draw_forge_anvil()
	_draw_wanderers()
	_draw_torches()
	# Destello de relámpago (tormenta).
	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, _grid_size()), Color(1, 1, 1, _flash * 0.5), true)

func _tile_rect(x: int, y: int) -> Rect2:
	return Rect2(x * TILE, y * TILE, TILE, TILE)

func _draw_floor(x: int, y: int, polish: float) -> void:
	var rect := _tile_rect(x, y)
	var floor_tex: Texture2D = _tex.get("floor")
	if floor_tex != null:
		# Un poco más luminoso con el prestigio; tablero para dar variedad.
		var tint := Color(0.82, 0.82, 0.82).lerp(Color(1, 1, 1), polish)
		if (x + y) % 2 == 1:
			tint = tint.darkened(0.06)
		draw_texture_rect(floor_tex, rect, false, tint)
	else:
		var warm := Color(0.42, 0.30, 0.18).lerp(Color(0.58, 0.42, 0.26), polish)
		draw_rect(rect, warm.darkened(0.08) if (x + y) % 2 == 0 else warm, true)

func _draw_counter(x: int, y: int) -> void:
	var tex: Texture2D = _tex.get("counter")
	if tex != null:
		draw_texture_rect(tex, _tile_rect(x, y), false)
	else:
		draw_rect(_tile_rect(x, y).grow(-4), Color(0.45, 0.30, 0.16), true)

func _draw_shelf(x: int, y: int) -> void:
	var rect := _tile_rect(x, y)
	var tex: Texture2D = _tex.get("shelf")
	if tex != null:
		draw_texture_rect(tex, rect, false)
	else:
		draw_rect(rect.grow(-4), Color(0.36, 0.24, 0.13), true)
	# Producto expuesto: su icono según categoría.
	var item_id := GameState.layout.assigned_item(x, y)
	if item_id != &"":
		var item := GameState.item_db.get_item(item_id)
		if item != null:
			var c := rect.get_center()
			var icon := _category_icon(item.category)
			if icon != null:
				draw_texture_rect(icon, Rect2(c - Vector2(15, 17), Vector2(30, 30)), false)
			else:
				draw_rect(Rect2(c - Vector2(10, 10), Vector2(20, 20)), _category_color(item.category), true)

func _draw_decor(x: int, y: int) -> void:
	var key := "plant" if (x + y) % 2 == 0 else "barrel"
	var tex: Texture2D = _tex.get(key)
	if tex != null:
		draw_texture_rect(tex, _tile_rect(x, y), false)
	else:
		var c := _tile_rect(x, y).get_center()
		draw_circle(c + Vector2(0, -2), 14, Color(0.3, 0.55, 0.3))

func _draw_wanderers() -> void:
	for w in _wanderers:
		var pos: Vector2 = w["pos"]
		var bob := sin(float(w["phase"])) * 2.0
		draw_circle(pos + Vector2(0, 12), 8.0, Color(0, 0, 0, 0.15))
		var tex: Texture2D = _tex.get(w.get("tex", "shopper1"))
		if tex != null:
			draw_texture_rect(tex, Rect2(pos - Vector2(14, 22 - bob), Vector2(28, 32)), false)
		else:
			var color: Color = w.get("color", Color(0.8, 0.5, 0.4))
			draw_circle(pos + Vector2(0, bob), 9.0, color)

func _draw_entrance_rug() -> void:
	var tex: Texture2D = _tex.get("rug")
	if tex == null:
		return
	var ex := int(GameState.layout.width / 2)
	var ey := GameState.layout.height - 1
	if GameState.layout.furniture_at(ex, ey) == ShopLayout.Furniture.NONE:
		draw_texture_rect(tex, _tile_rect(ex, ey), false)

func _draw_forge_anvil() -> void:
	var tex: Texture2D = _tex.get("anvil")
	if tex == null:
		return
	var forge := _first_furniture(ShopLayout.Furniture.COUNTER)
	if forge == Vector2(-1, -1):
		return
	var c := _tile_rect(int(forge.x), int(forge.y)).get_center()
	draw_texture_rect(tex, Rect2(c - Vector2(20, 22), Vector2(40, 40)), false)

func _draw_walls() -> void:
	var tex: Texture2D = _tex.get("wall")
	var w := GameState.layout.width
	var h := GameState.layout.height
	if tex == null:
		draw_rect(Rect2(Vector2.ZERO, _grid_size()), Color(0.15, 0.10, 0.06), false, 6.0)
		return
	for x in range(-1, w + 1):
		draw_texture_rect(tex, _tile_rect(x, -1), false)
		draw_texture_rect(tex, _tile_rect(x, h), false)
	for y in range(0, h):
		draw_texture_rect(tex, _tile_rect(-1, y), false)
		draw_texture_rect(tex, _tile_rect(w, y), false)

func _draw_torches() -> void:
	# Antorchas en la pared superior con parpadeo; iluminan más de noche.
	var grid := _grid_size()
	var night := 1.0 - GameState.clock.daylight()
	var flicker := 0.75 + 0.25 * sin(_time_accum * 9.0)
	var tex: Texture2D = _tex.get("torch")
	var spots := [Vector2(TILE * 0.5, TILE * 0.15), Vector2(grid.x - TILE * 0.5, TILE * 0.15)]
	for spot in spots:
		if tex != null:
			draw_texture_rect(tex, Rect2(spot - Vector2(12, 6), Vector2(24, 36)), false)
		var flame := spot - Vector2(0, 4)
		draw_circle(flame, 5.0 * flicker, Color(1.0, 0.7, 0.25))
		draw_circle(flame, 3.0 * flicker, Color(1.0, 0.92, 0.6))
		draw_circle(flame, 48.0 * flicker, Color(1.0, 0.75, 0.35, 0.08 + 0.24 * night))

# ------------------------------------------------------------------- clima/estado
func _polish() -> float:
	# La tienda se ve mejor cuanto más prestigio (evoluciona visualmente).
	return clampf(GameState.reputation.prestige() / 100.0, 0.0, 1.0)

func _update_weather_visuals() -> void:
	var w := GameState.weather.weather
	_rain.emitting = (w == WeatherSystem.Weather.RAIN or w == WeatherSystem.Weather.STORM)
	if w == WeatherSystem.Weather.STORM:
		_rain.amount = 360
	else:
		_rain.amount = 240
	_snow.emitting = (w == WeatherSystem.Weather.SNOW)
	if _fog != null:
		_fog.visible = (w == WeatherSystem.Weather.FOG)

func _refresh_info() -> void:
	if _info_label != null:
		_info_label.text = "Jornada %d   ·   %s   ·   %s, %s   ·   Prestigio %d" % [
			GameState.day, GameState.clock.phase_name(),
			GameState.weather.weather_name(), GameState.weather.season_name(),
			int(GameState.reputation.prestige()),
		]

func _category_color(category: int) -> Color:
	match category:
		GameEnums.Category.WEAPON: return Color(0.75, 0.75, 0.8)
		GameEnums.Category.ARMOR: return Color(0.6, 0.65, 0.75)
		GameEnums.Category.POTION: return Color(0.8, 0.3, 0.5)
		GameEnums.Category.TOOL: return Color(0.7, 0.55, 0.3)
		GameEnums.Category.MAGIC: return Color(0.4, 0.8, 0.75)
		GameEnums.Category.MATERIAL: return Color(0.55, 0.45, 0.35)
		_: return Color(0.6, 0.6, 0.6)

func _category_icon(category: int) -> Texture2D:
	match category:
		GameEnums.Category.WEAPON: return _tex.get("sword")
		GameEnums.Category.ARMOR: return _tex.get("armor")
		GameEnums.Category.POTION: return _tex.get("potion")
		GameEnums.Category.TOOL: return _tex.get("tool")
		GameEnums.Category.MAGIC: return _tex.get("magic")
		GameEnums.Category.MATERIAL: return _tex.get("material")
		_: return null
