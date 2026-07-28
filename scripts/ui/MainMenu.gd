extends Control
## Menú principal: escena viva de la tienda en pixel art (fondo pintado) con
## animaciones por código —fuego, humo, brasas, polvo en la luz, hojas al viento y
## un cliente que entra de vez en cuando por la puerta— y botones de tablón con
## brillo al pasar el ratón. Ver docs/ArtDirection.md y el brief del menú.

const UI := "res://assets/ui/"
const BG_SIZE := Vector2(480, 270)

var _scale := Vector2.ONE
var _plank: Texture2D
var _plank_hover: Texture2D
var _npc: Sprite2D
var _npc_tex: Texture2D

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vp := get_viewport_rect().size
	_scale = vp / BG_SIZE
	_plank = _tex("menu_plank.png")
	_plank_hover = _tex("menu_plank_hover.png")
	_npc_tex = _tex("menu_npc.png")

	_build_background()
	_build_ambient()
	_build_npc()
	_build_sign()
	_build_menu()

## Traduce coordenadas del fondo (480x270) a pantalla.
func _bg(x: float, y: float) -> Vector2:
	return Vector2(x, y) * _scale

func _tex(name: String) -> Texture2D:
	var p := UI + name
	return load(p) if ResourceLoader.exists(p) else null

# ------------------------------------------------------------------- fondo
func _build_background() -> void:
	var bg := TextureRect.new()
	bg.texture = _tex("menu_bg.png")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

# ------------------------------------------------------------------- ambiente
func _build_ambient() -> void:
	# Fuego de la chimenea (rincón derecho).
	var fire := _particles(_bg(441, 182), 46, 0.7)
	fire.emission_rect_extents = Vector2(10, 5) * _scale.x
	fire.direction = Vector2(0, -1)
	fire.gravity = Vector2(0, -150) * _scale.y
	fire.initial_velocity_min = 20.0 * _scale.y
	fire.initial_velocity_max = 55.0 * _scale.y
	fire.scale_amount_min = 2.0 * _scale.x
	fire.scale_amount_max = 5.0 * _scale.x
	fire.color_ramp = _fire_gradient()
	add_child(fire)

	# Humo que sube de la chimenea.
	var smoke := _particles(_bg(441, 122), 16, 3.0)
	smoke.emission_rect_extents = Vector2(6, 4) * _scale.x
	smoke.gravity = Vector2(6, -30) * _scale.y
	smoke.initial_velocity_min = 4.0 * _scale.y
	smoke.initial_velocity_max = 14.0 * _scale.y
	smoke.scale_amount_min = 3.0 * _scale.x
	smoke.scale_amount_max = 8.0 * _scale.x
	smoke.color = Color(0.5, 0.5, 0.52, 0.22)
	add_child(smoke)

	# Polvo flotando en el haz de luz que cae sobre la balanza (icono central).
	var dust := _particles(_bg(240, 160), 34, 6.0)
	dust.emission_rect_extents = Vector2(28, 60) * _scale.x
	dust.gravity = Vector2(4, -6) * _scale.y
	dust.initial_velocity_min = 2.0
	dust.initial_velocity_max = 8.0
	dust.scale_amount_min = 1.0 * _scale.x
	dust.scale_amount_max = 2.5 * _scale.x
	dust.color = Color(1.0, 0.9, 0.7, 0.10)
	add_child(dust)

	# Hojas al viento cruzando la escena.
	var leaves := _particles(Vector2(-20, get_viewport_rect().size.y * 0.2), 10, 9.0)
	leaves.emission_rect_extents = Vector2(4, get_viewport_rect().size.y * 0.35)
	leaves.direction = Vector2(1, 0.3)
	leaves.gravity = Vector2(30, 24)
	leaves.initial_velocity_min = 40.0
	leaves.initial_velocity_max = 90.0
	leaves.angular_velocity_min = -120.0
	leaves.angular_velocity_max = 120.0
	leaves.scale_amount_min = 2.0 * _scale.x
	leaves.scale_amount_max = 3.5 * _scale.x
	leaves.color = Color(0.55, 0.45, 0.2, 0.7)
	add_child(leaves)

func _particles(pos: Vector2, amount: int, lifetime: float) -> CPUParticles2D:
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

# ------------------------------------------------------------------- NPC
func _build_npc() -> void:
	if _npc_tex == null:
		return
	_npc = Sprite2D.new()
	_npc.texture = _npc_tex
	_npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_npc.scale = _scale * 0.9
	_npc.modulate.a = 0.0
	add_child(_npc)
	_schedule_npc(3.0)

func _schedule_npc(delay: float) -> void:
	var t := get_tree().create_timer(delay)
	t.timeout.connect(_npc_enter)

func _npc_enter() -> void:
	# Entra por la puerta y camina despacio hacia el mostrador; luego se desvanece.
	var start := _bg(240, 134)
	var mid := _bg(240, 208)
	_npc.position = start
	_npc.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_npc, "modulate:a", 1.0, 0.6)
	tw.parallel().tween_property(_npc, "position", mid, 3.2).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(1.2)
	tw.tween_property(_npc, "modulate:a", 0.0, 0.8)
	tw.tween_callback(func() -> void: _schedule_npc(randf_range(9.0, 16.0)))

# ------------------------------------------------------------------- cartel
func _build_sign() -> void:
	var sign := TextureRect.new()
	sign.texture = _tex("menu_sign.png")
	sign.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sign.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sign.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	var vp := get_viewport_rect().size
	sign.size = Vector2(vp.x * 0.42, vp.y * 0.20)
	sign.position = Vector2(vp.x * 0.29, vp.y * 0.03)
	sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sign)
	# Balanceo muy leve del cartel colgante.
	sign.pivot_offset = Vector2(sign.size.x * 0.5, 0)
	var tw := create_tween().set_loops()
	tw.tween_property(sign, "rotation", 0.012, 2.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sign, "rotation", -0.012, 2.4).set_trans(Tween.TRANS_SINE)

# ------------------------------------------------------------------- menú
func _build_menu() -> void:
	var vp := get_viewport_rect().size
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.position = Vector2(vp.x * 0.09, vp.y * 0.34)
	add_child(box)

	box.add_child(_menu_button("Nueva partida", _on_new_game))
	var cont := _menu_button("Continuar", _on_continue)
	cont.disabled = not SaveManager.has_save(1)
	box.add_child(cont)
	var load_btn := _menu_button("Cargar partida", _on_continue)
	load_btn.disabled = not SaveManager.has_save(1)
	box.add_child(load_btn)
	box.add_child(_menu_button("Opciones", _on_options))
	box.add_child(_menu_button("Créditos", _on_credits))
	box.add_child(_menu_button("Salir", _on_quit))

func _menu_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 60)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_color_override("font_color", Color(0.97, 0.89, 0.68))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.85))
	b.add_theme_color_override("font_disabled_color", Color(0.6, 0.52, 0.42))
	if _plank != null:
		b.add_theme_stylebox_override("normal", _plank_style(_plank))
		b.add_theme_stylebox_override("hover", _plank_style(_plank_hover))
		b.add_theme_stylebox_override("pressed", _plank_style(_plank_hover))
		b.add_theme_stylebox_override("disabled", _plank_style(_plank))
	b.pressed.connect(cb)
	b.mouse_entered.connect(func() -> void: _hover(b, 1.05))
	b.mouse_exited.connect(func() -> void: _hover(b, 1.0))
	return b

func _plank_style(tex: Texture2D) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = 10
	sb.texture_margin_right = 10
	sb.texture_margin_top = 6
	sb.texture_margin_bottom = 6
	return sb

func _hover(b: Button, target: float) -> void:
	b.pivot_offset = b.size * 0.5
	var tw := create_tween()
	tw.tween_property(b, "scale", Vector2(target, target), 0.10).set_trans(Tween.TRANS_SINE)

# ------------------------------------------------------------------- acciones
func _on_new_game() -> void:
	GameState.new_game()
	SceneRouter.goto_counter()

func _on_continue() -> void:
	if SaveManager.load_game(1):
		SceneRouter.goto_counter()

func _on_options() -> void:
	pass

func _on_credits() -> void:
	pass

func _on_quit() -> void:
	get_tree().quit()
