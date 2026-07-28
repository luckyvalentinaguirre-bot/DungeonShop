extends Control
## Menú principal: usa la ilustración del diseñador TAL CUAL (assets/ui/menu_art.png)
## a pantalla completa y le añade VIDA con capas animadas por código encima, sin
## modificar la imagen: fuego y brillo de la chimenea, velas parpadeando, hojas que
## entran por la puerta, polvo en la luz de las ventanas, vapor de la taza, destellos
## en el arma legendaria y en las gemas, farol titilando y algún transeúnte fuera.
## Los botones dibujados se hacen funcionales con zonas clicables invisibles.

const ART := "res://assets/ui/menu_art.png"

const R_NUEVA := Rect2(0.105, 0.748, 0.180, 0.080)
const R_CARGAR := Rect2(0.322, 0.748, 0.186, 0.080)
const R_OPCIONES := Rect2(0.535, 0.748, 0.150, 0.080)
const R_SALIR := Rect2(0.752, 0.748, 0.178, 0.080)

var _vp: Vector2
var _s: Vector2                 # escala respecto a 1920x1080
var _glow_tex: Texture2D
var _t: float = 0.0
## Brillos con parpadeo: {node, base_a, amp, speed, phase}
var _flickers: Array = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vp = get_viewport_rect().size
	_s = _vp / Vector2(1920, 1080)
	_glow_tex = _make_glow_texture()
	_build_background()
	_build_animations()
	_build_hotspots()
	set_process(true)

func _process(delta: float) -> void:
	_t += delta
	for f in _flickers:
		var n: Node2D = f["node"]
		var wave: float = 0.5 + 0.5 * sin(_t * f["speed"] + f["phase"])
		var noise: float = (randf() - 0.5) * 0.12
		n.modulate.a = clampf(f["base_a"] * (1.0 - f["amp"] + f["amp"] * wave) + noise, 0.0, 1.0)

# posición fracción -> pantalla
func _p(fx: float, fy: float) -> Vector2:
	return Vector2(fx * _vp.x, fy * _vp.y)

# ------------------------------------------------------------------- fondo
func _build_background() -> void:
	var bg := TextureRect.new()
	if ResourceLoader.exists(ART):
		bg.texture = load(ART)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

# ------------------------------------------------------------------- animaciones
func _build_animations() -> void:
	# Chimenea: fuego + brillo cálido titilante.
	_fire(_p(0.268, 0.455))
	_flicker_glow(_p(0.268, 0.445), 150.0, Color(1.0, 0.55, 0.2), 0.55, 0.45, 7.0)
	# Velas: repisa de la chimenea y mesa derecha.
	_candle(_p(0.252, 0.328))
	_candle(_p(0.663, 0.452))
	_candle(_p(0.815, 0.315))
	# Farol junto a la puerta.
	_flicker_glow(_p(0.553, 0.292), 90.0, Color(1.0, 0.78, 0.4), 0.35, 0.35, 3.2)
	# Hojas entrando por la puerta.
	_leaves(_p(0.49, 0.24))
	# Polvo flotando en la luz de las ventanas.
	_dust(_p(0.315, 0.34), Vector2(70, 90))
	_dust(_p(0.60, 0.30), Vector2(60, 80))
	# Vapor de la taza (mostrador).
	_steam(_p(0.723, 0.79))
	# Destellos: arma legendaria y gemas del estante.
	_twinkle(_p(0.51, 0.40), Vector2(30, 60))
	_twinkle(_p(0.052, 0.47), Vector2(40, 40))
	# Transeúnte que pasa por la calle (a través de la puerta).
	_spawn_walker(2.5)

func _fire(pos: Vector2) -> void:
	var p := _cpu(pos, 42, 0.7)
	p.emission_rect_extents = Vector2(11, 5) * _s.x
	p.direction = Vector2(0, -1)
	p.gravity = Vector2(0, -150) * _s.y
	p.initial_velocity_min = 20.0 * _s.y
	p.initial_velocity_max = 55.0 * _s.y
	p.scale_amount_min = 2.0 * _s.x
	p.scale_amount_max = 5.0 * _s.x
	p.color_ramp = _fire_gradient()
	add_child(p)

func _candle(pos: Vector2) -> void:
	var p := _cpu(pos, 10, 0.5)
	p.emission_rect_extents = Vector2(2, 2) * _s.x
	p.gravity = Vector2(0, -70) * _s.y
	p.initial_velocity_min = 6.0 * _s.y
	p.initial_velocity_max = 14.0 * _s.y
	p.scale_amount_min = 1.2 * _s.x
	p.scale_amount_max = 2.4 * _s.x
	p.color_ramp = _fire_gradient()
	add_child(p)
	_flicker_glow(pos, 34.0, Color(1.0, 0.8, 0.45), 0.6, 0.4, 9.0)

func _leaves(pos: Vector2) -> void:
	var p := _cpu(pos, 9, 5.0)
	p.emission_rect_extents = Vector2(40, 8) * _s.x
	p.direction = Vector2(-0.6, 1)
	p.gravity = Vector2(-24, 40) * _s.y
	p.initial_velocity_min = 30.0 * _s.y
	p.initial_velocity_max = 70.0 * _s.y
	p.angular_velocity_min = -140.0
	p.angular_velocity_max = 140.0
	p.scale_amount_min = 2.0 * _s.x
	p.scale_amount_max = 3.4 * _s.x
	p.color = Color(0.42, 0.55, 0.22, 0.85)
	add_child(p)

func _dust(pos: Vector2, extents: Vector2) -> void:
	var p := _cpu(pos, 30, 6.0)
	p.emission_rect_extents = extents * _s.x
	p.gravity = Vector2(4, -5) * _s.y
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 7.0
	p.scale_amount_min = 1.0 * _s.x
	p.scale_amount_max = 2.4 * _s.x
	p.color = Color(1.0, 0.94, 0.78, 0.14)
	add_child(p)

func _steam(pos: Vector2) -> void:
	var p := _cpu(pos, 12, 2.2)
	p.emission_rect_extents = Vector2(5, 2) * _s.x
	p.gravity = Vector2(3, -34) * _s.y
	p.initial_velocity_min = 6.0 * _s.y
	p.initial_velocity_max = 16.0 * _s.y
	p.scale_amount_min = 2.5 * _s.x
	p.scale_amount_max = 6.0 * _s.x
	p.color = Color(0.92, 0.92, 0.92, 0.22)
	add_child(p)

func _twinkle(pos: Vector2, extents: Vector2) -> void:
	var p := _cpu(pos, 8, 1.4)
	p.emission_rect_extents = extents * _s.x
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 0.0
	p.initial_velocity_max = 2.0
	p.scale_amount_min = 1.0 * _s.x
	p.scale_amount_max = 2.6 * _s.x
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 0))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.5, Color(1.0, 0.98, 0.8, 0.95))
	p.color_ramp = g
	add_child(p)

func _cpu(pos: Vector2, amount: int, lifetime: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = pos
	p.amount = amount
	p.lifetime = lifetime
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emitting = true
	return p

func _fire_gradient() -> Gradient:
	var g := Gradient.new()
	g.set_color(0, Color(1.0, 0.95, 0.6, 1.0))
	g.set_color(1, Color(0.85, 0.25, 0.08, 0.0))
	g.add_point(0.5, Color(1.0, 0.55, 0.15, 0.9))
	return g

# --- brillos con parpadeo (sprite radial + control de alfa en _process) ---
func _flicker_glow(pos: Vector2, radius: float, color: Color, base_a: float, amp: float, speed: float) -> void:
	var s := Sprite2D.new()
	s.texture = _glow_tex
	s.position = pos
	s.modulate = Color(color.r, color.g, color.b, base_a)
	var scl := (radius * 2.0 * _s.x) / 256.0
	s.scale = Vector2(scl, scl)
	add_child(s)
	_flickers.append({"node": s, "base_a": base_a, "amp": amp, "speed": speed, "phase": randf() * TAU})

func _make_glow_texture() -> Texture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 256
	t.height = 256
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	return t

# --- transeúnte que cruza la calle por la puerta ---
func _spawn_walker(delay: float) -> void:
	get_tree().create_timer(delay).timeout.connect(_walker_go)

func _walker_go() -> void:
	var w := Node2D.new()
	var body := ColorRect.new()
	body.color = Color(0.22, 0.22, 0.30, 0.55)
	body.size = Vector2(7, 15) * _s
	body.position = Vector2(-3.5, -8) * _s
	w.add_child(body)
	var head := ColorRect.new()
	head.color = Color(0.28, 0.26, 0.28, 0.55)
	head.size = Vector2(5, 5) * _s
	head.position = Vector2(-2.5, -13) * _s
	w.add_child(head)
	add_child(w)
	var right := randf() < 0.5
	var y := 0.43
	var x0 := 0.455 if right else 0.545
	var x1 := 0.545 if right else 0.455
	w.position = _p(x0, y)
	w.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(w, "modulate:a", 1.0, 0.5)
	tw.parallel().tween_property(w, "position", _p(x1, y), 5.0)
	tw.tween_property(w, "modulate:a", 0.0, 0.5)
	tw.tween_callback(w.queue_free)
	tw.tween_callback(func() -> void: _spawn_walker(randf_range(6.0, 12.0)))

# ------------------------------------------------------------------- botones
func _build_hotspots() -> void:
	_hotspot(R_NUEVA, _on_new_game)
	_hotspot(R_CARGAR, _on_load)
	_hotspot(R_OPCIONES, _on_options)
	_hotspot(R_SALIR, _on_quit)

func _hotspot(frac: Rect2, cb: Callable) -> void:
	var b := Button.new()
	b.position = Vector2(frac.position.x * _vp.x, frac.position.y * _vp.y)
	b.size = Vector2(frac.size.x * _vp.x, frac.size.y * _vp.y)
	b.custom_minimum_size = b.size
	b.focus_mode = Control.FOCUS_NONE
	var empty := StyleBoxEmpty.new()
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("focus", empty)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 0.92, 0.6, 0.16)
	hover.set_corner_radius_all(10)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.pressed.connect(cb)
	b.mouse_entered.connect(func() -> void: _pop(b, 1.03))
	b.mouse_exited.connect(func() -> void: _pop(b, 1.0))
	add_child(b)

func _pop(b: Button, target: float) -> void:
	b.pivot_offset = b.size * 0.5
	create_tween().tween_property(b, "scale", Vector2(target, target), 0.08)

# ------------------------------------------------------------------- acciones
func _on_new_game() -> void:
	# La partida nueva se crea al terminar la cinematica de introduccion.
	SceneRouter.goto_intro()

func _on_load() -> void:
	if SaveManager.has_save(1) and SaveManager.load_game(1):
		SceneRouter.goto_counter()
	else:
		GameState.new_game()
		SceneRouter.goto_counter()

func _on_options() -> void:
	pass

func _on_quit() -> void:
	get_tree().quit()
