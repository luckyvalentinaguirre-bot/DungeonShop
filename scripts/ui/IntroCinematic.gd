extends Control
## Cinematica de introduccion de Dungeon Shop.
## Reproductor DATA-DRIVEN: cada "viñeta" (BEATS) define su imagen, la narracion
## en español, un efecto animado (brasas, lluvia, polvo, destello), y un
## movimiento de camara Ken Burns (paneo + zoom lento). Entre viñetas hay fundido
## a negro. Barras cinematograficas arriba/abajo. Subtitulo con efecto maquina de
## escribir. Se puede AVANZAR (click / tecla) o SALTAR TODO (Esc).
##
## Las imagenes en res://assets/cinematic/panel_XX.png son recortes del storyboard
## (placeholders con el texto en ingles quemado abajo, que la banda inferior tapa);
## se reemplazan luego por el arte final sin texto en la misma ruta.
##
## Flujo: MainMenu "Nueva partida" -> IntroCinematic -> al terminar arranca la
## partida (GameState.new_game) y entra a la tienda (SceneRouter.goto_counter).

# --- guion: {img, text, fx, dur} -------------------------------------------
const BEATS := [
	{"img": "res://assets/cinematic/panel_01.png", "fx": "embers",
	 "text": "Cuando la gente entra a esta tienda, siempre me pregunta cómo llegué hasta acá."},
	{"img": "res://assets/cinematic/panel_02.png", "fx": "dust",
	 "text": "Algunos creen que fue suerte. Otros, que tuve una gran oportunidad..."},
	{"img": "res://assets/cinematic/panel_03.png", "fx": "sparkle",
	 "text": "Pero todo empezó con esto. Una llave vieja... y nada más."},
	{"img": "res://assets/cinematic/panel_04.png", "fx": "rain",
	 "text": "Sin fortuna. Sin gloria. Solo una casa olvidada al final del camino."},
	{"img": "res://assets/cinematic/panel_05.png", "fx": "rain",
	 "text": "Mi abuela ya no estaba. Ninguna gran herencia... solo un lugar en ruinas."},
	{"img": "res://assets/cinematic/panel_06.png", "fx": "dust",
	 "text": "De niño, ella me enseñó que cada objeto guarda una historia."},
	{"img": "res://assets/cinematic/panel_07.png", "fx": "",
	 "text": "Así que volví. El camino era largo; la casa, más pequeña de lo que recordaba."},
	{"img": "res://assets/cinematic/panel_08.png", "fx": "sparkle", "dur": 3.0,
	 "text": "Metí la llave. La cerradura cedió con un crujido."},
	{"img": "res://assets/cinematic/panel_09.png", "fx": "dust",
	 "text": "Adentro, polvo y silencio. Y una nota: «No busques la tienda más grande... construye una que importe.»"},
	{"img": "res://assets/cinematic/panel_10.png", "fx": "embers",
	 "text": "Así que empecé. Un clavo, una tabla, un día a la vez."},
	{"img": "res://assets/cinematic/panel_11.png", "fx": "sparkle",
	 "text": "Entre los escombros encontré secretos que ella había dejado para mí."},
	{"img": "res://assets/cinematic/panel_12.png", "fx": "embers",
	 "text": "No estaba armando un negocio. Estaba construyendo un legado."},
	{"img": "res://assets/cinematic/panel_13.png", "fx": "dust",
	 "text": "Esta es mi historia. ¿Y la tuya? ¿Qué clase de legado vas a construir?"},
]

var _vp: Vector2
var _panel: TextureRect          # imagen de la viñeta (con overscan para Ken Burns)
var _fader: ColorRect            # capa negra para fundidos
var _label: Label                # subtitulo (maquina de escribir)
var _fx_layer: Node2D            # contenedor de particulas del efecto
var _kb: Tween                   # tween del Ken Burns actual

var _interrupt := false          # true = el jugador pidio avanzar
var _skip_all := false           # true = saltar toda la intro

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vp = get_viewport_rect().size
	_build_ui()
	set_process(false)
	_run()

# --------------------------------------------------------------- construccion
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# La imagen crece mas que la pantalla (overscan) para poder panear sin bordes.
	_panel = TextureRect.new()
	_panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	_fx_layer = Node2D.new()
	add_child(_fx_layer)

	# Barras cinematograficas + banda de subtitulo (tapan el texto quemado abajo).
	var bar_h := _vp.y * 0.11
	var top := ColorRect.new()
	top.color = Color.BLACK
	top.position = Vector2.ZERO
	top.size = Vector2(_vp.x, bar_h)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)
	var bot := ColorRect.new()
	bot.color = Color.BLACK
	bot.position = Vector2(0, _vp.y - bar_h)
	bot.size = Vector2(_vp.x, bar_h)
	bot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bot)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_color_override("font_color", Color(0.94, 0.90, 0.80))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	_label.add_theme_font_size_override("font_size", int(_vp.y * 0.032))
	_label.position = Vector2(_vp.x * 0.12, _vp.y - bar_h * 1.7)
	_label.size = Vector2(_vp.x * 0.76, bar_h * 1.5)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	var hint := Label.new()
	hint.text = "Esc: saltar   ·   Click: continuar"
	hint.add_theme_color_override("font_color", Color(0.8, 0.78, 0.7, 0.5))
	hint.add_theme_font_size_override("font_size", int(_vp.y * 0.018))
	hint.position = Vector2(_vp.x * 0.72, _vp.y * 0.02)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)

	# Capa de fundido: arranca en negro y se abre en la primera viñeta.
	_fader = ColorRect.new()
	_fader.color = Color(0, 0, 0, 1)
	_fader.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fader)

# ------------------------------------------------------------------- reproduccion
func _run() -> void:
	for b in BEATS:
		if _skip_all:
			break
		await _beat(b)
	await _fade(1.0, 0.6)
	_finish()

func _beat(b: Dictionary) -> void:
	_set_panel(String(b.get("img", "")))
	_spawn_fx(String(b.get("fx", "")))
	_label.text = String(b.get("text", ""))
	_label.visible_ratio = 0.0
	await _fade(0.0, 0.55)           # abrir desde negro
	await _type(_label.text)
	if _skip_all:
		return
	await _sleep(float(b.get("dur", _read_time(_label.text))))
	await _fade(1.0, 0.5)            # cerrar a negro
	_clear_fx()

func _finish() -> void:
	GameState.new_game()
	SceneRouter.goto_counter()

# ------------------------------------------------------------------- camara
func _set_panel(path: String) -> void:
	if _kb != null and _kb.is_valid():
		_kb.kill()
	var tex := load(path) as Texture2D
	_panel.texture = tex
	# Overscan del 14 %: permite paneo y zoom sin descubrir el fondo negro.
	var over := _vp * 0.14
	_panel.size = _vp + over
	var fx := randf()
	var fy := randf()
	var p0 := Vector2(-over.x * fx, -over.y * fy)
	var p1 := Vector2(-over.x * (1.0 - fx), -over.y * (1.0 - fy))
	_panel.position = p0
	var dur := 7.5
	_kb = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_kb.tween_property(_panel, "position", p1, dur)
	_kb.parallel().tween_property(_panel, "size", _vp + over * 1.7, dur)

# ------------------------------------------------------------------- tiempos
func _read_time(t: String) -> float:
	return clampf(1.8 + t.length() * 0.045, 3.2, 6.5)

## Espera t segundos; si el jugador pulsa/hace click, corta la espera (avanzar).
## Usa el reloj del motor (independiente de si el nodo procesa o no).
func _sleep(t: float) -> void:
	var end := Time.get_ticks_msec() + int(t * 1000.0)
	while Time.get_ticks_msec() < end:
		if _interrupt:
			_interrupt = false
			return
		await get_tree().process_frame

## Revela el subtitulo letra a letra. Un toque lo completa de golpe.
func _type(t: String) -> void:
	var dur_ms := int((0.6 + t.length() * 0.028) * 1000.0)
	var start := Time.get_ticks_msec()
	while true:
		if _interrupt:
			_interrupt = false
			break
		var e := Time.get_ticks_msec() - start
		_label.visible_ratio = clampf(float(e) / float(dur_ms), 0.0, 1.0)
		if e >= dur_ms:
			break
		await get_tree().process_frame
	_label.visible_ratio = 1.0

func _fade(target_a: float, t: float) -> void:
	var tw := create_tween()
	tw.tween_property(_fader, "color:a", target_a, t)
	await tw.finished

# ------------------------------------------------------------------- efectos
func _clear_fx() -> void:
	for c in _fx_layer.get_children():
		c.queue_free()

func _spawn_fx(kind: String) -> void:
	_clear_fx()
	match kind:
		"embers":
			_add_embers()
		"rain":
			_add_rain()
		"dust":
			_add_dust()
		"sparkle":
			_add_sparkle()
		_:
			pass

func _add_embers() -> void:
	var p := _cpu(120)
	p.position = Vector2(_vp.x * 0.5, _vp.y * 1.02)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(_vp.x * 0.5, 4)
	p.direction = Vector2(0, -1)
	p.spread = 25.0
	p.gravity = Vector2(0, -30)
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 90.0
	p.scale_amount_min = 1.5
	p.scale_amount_max = 3.5
	p.lifetime = 4.0
	p.color = Color(1.0, 0.55, 0.2, 0.8)
	_fx_layer.add_child(p)

func _add_rain() -> void:
	var p := _cpu(220)
	p.position = Vector2(_vp.x * 0.5, -10)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(_vp.x * 0.6, 4)
	p.direction = Vector2(0.15, 1)
	p.spread = 4.0
	p.gravity = Vector2(60, 900)
	p.initial_velocity_min = 400.0
	p.initial_velocity_max = 520.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 1.5
	p.lifetime = 1.2
	p.color = Color(0.6, 0.68, 0.8, 0.35)
	_fx_layer.add_child(p)

func _add_dust() -> void:
	var p := _cpu(90)
	p.position = _vp * 0.5
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = _vp * 0.5
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(4, -3)
	p.initial_velocity_min = 3.0
	p.initial_velocity_max = 12.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	p.lifetime = 6.0
	p.color = Color(1.0, 0.95, 0.8, 0.22)
	_fx_layer.add_child(p)

func _add_sparkle() -> void:
	var p := _cpu(28)
	p.position = _vp * 0.5
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(_vp.x * 0.18, _vp.y * 0.14)
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 16.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 3.0
	p.lifetime = 1.6
	p.color = Color(1.0, 0.95, 0.7, 0.9)
	_fx_layer.add_child(p)

func _cpu(amount: int) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.preprocess = 2.0
	p.randomness = 0.6
	return p

# ------------------------------------------------------------------- entrada
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode == KEY_ESCAPE:
			_skip_all = true
			_interrupt = true
		else:
			_interrupt = true
	elif e is InputEventMouseButton and e.pressed:
		_interrupt = true
