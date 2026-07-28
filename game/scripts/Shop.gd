extends Control
## TIENDA — vista POV DETRÁS DEL MOSTRADOR. El "lugar" es una ILUSTRACIÓN generada en
## el estilo del diseñador (game/art/bg_shop.png): manos del tendero, mostrador,
## estanterías y puerta al pueblo. Encima va la VIDA (faroles titilando) y los PUNTOS
## DE COLOCACIÓN sobre el mostrador (espacio para exponer objetos, Etapa 3).
##
## Cada lugar del juego se arma igual: fondo ilustrado + capas de interacción/animación.
## Reemplazar el fondo = cambiar el .png en la misma ruta.

const BG := "res://game/art/bg_shop.png"

## Puntos de colocación sobre el mostrador (fracción de pantalla). Aquí se posarán los
## sprites de los objetos que ofrecés al cliente (Etapa 3).
const COUNTER_SLOTS := [Vector2(0.40, 0.82), Vector2(0.50, 0.80), Vector2(0.60, 0.82)]

## Faroles colgantes para el titileo cálido (posición en fracción).
const LANTERNS := [Vector2(0.305, 0.16), Vector2(0.665, 0.16)]

var _vp: Vector2
var _glow_tex: Texture2D
var _flickers: Array = []          # {node, base_a, phase}
var _t := 0.0
var _slot_markers: Array = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vp = get_viewport_rect().size
	_glow_tex = _make_glow_texture()
	_build_bg()
	_build_lantern_glow()
	_build_slots()
	_build_hud()
	set_process(true)

func _process(delta: float) -> void:
	_t += delta
	for f in _flickers:
		var n: Sprite2D = f["node"]
		var wave: float = 0.6 + 0.4 * sin(_t * 3.0 + f["phase"])
		var noise: float = (randf() - 0.5) * 0.12
		n.modulate.a = clampf(f["base_a"] * wave + noise, 0.0, 1.0)

func _p(f: Vector2) -> Vector2:
	return Vector2(f.x * _vp.x, f.y * _vp.y)

# ------------------------------------------------------------------- fondo
func _build_bg() -> void:
	var bg := TextureRect.new()
	bg.texture = load(BG)
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

# --------------------------------------------------------------- vida (faroles)
func _build_lantern_glow() -> void:
	for pos in LANTERNS:
		var g := Sprite2D.new()
		g.texture = _glow_tex
		g.position = _p(pos)
		g.scale = Vector2(0.7, 0.7) * (_vp.x / 1920.0)
		g.modulate = Color(1.0, 0.78, 0.42, 0.5)
		add_child(g)
		_flickers.append({"node": g, "base_a": 0.5, "phase": randf() * TAU})

# ------------------------------------------------------- puntos de colocación
func _build_slots() -> void:
	for pos in COUNTER_SLOTS:
		var m := _make_marker(_p(pos), 60.0 * (_vp.x / 1920.0))
		add_child(m)
		_slot_markers.append(m)

func _make_marker(center: Vector2, s: float) -> Node2D:
	var n := Node2D.new()
	n.position = center
	var half := s * 0.5
	var fill := Polygon2D.new()
	fill.polygon = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	fill.color = Color(1.0, 0.9, 0.6, 0.10)
	n.add_child(fill)
	var border := Line2D.new()
	border.points = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half),
		Vector2(-half, half), Vector2(-half, -half)])
	border.width = 2.0
	border.default_color = Color(1.0, 0.85, 0.5, 0.30)
	n.add_child(border)
	return n

# ------------------------------------------------------------------- HUD
func _build_hud() -> void:
	var hint := Label.new()
	hint.text = "Esc: menú"
	hint.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8, 0.7))
	hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	hint.add_theme_constant_override("shadow_offset_x", 2)
	hint.add_theme_constant_override("shadow_offset_y", 2)
	hint.add_theme_font_size_override("font_size", int(_vp.y * 0.024))
	hint.position = Vector2(_vp.x * 0.02, _vp.y * 0.02)
	add_child(hint)

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://game/scenes/Menu.tscn")

# ------------------------------------------------------------------- helpers
## Textura radial suave para el brillo de los faroles.
func _make_glow_texture() -> Texture2D:
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1))
	grad.set_color(1, Color(1, 1, 1, 0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.width = 256
	gt.height = 256
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	return gt
