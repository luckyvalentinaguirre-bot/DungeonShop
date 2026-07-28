extends Control
## Cinematica de introduccion de Dungeon Shop.
## Muestra LA HOJA DE STORYBOARD COMPLETA (una sola imagen) en penumbra y va
## ILUMINANDO cada viñeta EN ORDEN mientras avanza la narracion: la viñeta activa
## se ve a plena luz con un halo cálido, el resto queda oscurecido. El subtitulo
## aparece letra a letra abajo. Se puede AVANZAR (click / tecla) o SALTAR (Esc).
##
## Al terminar arranca la partida (GameState.new_game) y entra a la tienda.

const SHEET := "res://assets/cinematic/storyboard.png"
const SHEET_SIZE := Vector2(1600, 872)

# Cada viñeta: {rect (en pixeles de la hoja), text}. El orden es el de narracion.
const BEATS := [
	{"rect": Rect2(35, 58, 455, 240),
	 "text": "Cuando la gente entra a esta tienda, siempre me pregunta cómo llegué hasta acá."},
	{"rect": Rect2(543, 58, 450, 240),
	 "text": "Algunos creen que fue suerte. Otros, que tuve una gran oportunidad..."},
	{"rect": Rect2(1002, 58, 281, 240),
	 "text": "Pero todo empezó con esto. Una llave vieja... y nada más."},
	{"rect": Rect2(1287, 58, 280, 240),
	 "text": "Sin fortuna. Sin gloria. Solo una casa olvidada al final del camino."},
	{"rect": Rect2(35, 368, 322, 188),
	 "text": "Mi abuela ya no estaba. Ninguna gran herencia... solo un lugar en ruinas."},
	{"rect": Rect2(378, 368, 322, 188),
	 "text": "De niño, ella me enseñó que cada objeto guarda una historia."},
	{"rect": Rect2(705, 368, 253, 188),
	 "text": "Así que volví. El camino era largo; la casa, más pequeña de lo que recordaba."},
	{"rect": Rect2(962, 368, 128, 188), "dur": 3.0,
	 "text": "Metí la llave. La cerradura cedió con un crujido."},
	{"rect": Rect2(1238, 368, 329, 188),
	 "text": "Adentro, polvo y silencio. Y una nota: «No busques la tienda más grande... construye una que importe.»"},
	{"rect": Rect2(35, 650, 322, 188),
	 "text": "Así que empecé. Un clavo, una tabla, un día a la vez."},
	{"rect": Rect2(378, 650, 287, 188),
	 "text": "Entre los escombros encontré secretos que ella había dejado para mí."},
	{"rect": Rect2(675, 650, 283, 188),
	 "text": "No estaba armando un negocio. Estaba construyendo un legado."},
	{"rect": Rect2(972, 650, 286, 188),
	 "text": "Esta es mi historia. ¿Y la tuya? ¿Qué clase de legado vas a construir?"},
]

var _vp: Vector2
var _sheet_tex: Texture2D
var _scale: float                # escala de la hoja al encajar en pantalla
var _offset: Vector2             # margen de centrado (letterbox)
var _dim: ColorRect              # penumbra sobre toda la hoja
var _spot: Control               # halo + recorte iluminado de la viñeta actual
var _label: Label
var _fader: ColorRect

var _interrupt := false
var _skip_all := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vp = get_viewport_rect().size
	_sheet_tex = load(SHEET)
	# Encajar la hoja en pantalla conservando proporcion (KEEP_ASPECT).
	_scale = minf(_vp.x / SHEET_SIZE.x, _vp.y / SHEET_SIZE.y)
	_offset = (_vp - SHEET_SIZE * _scale) * 0.5
	_build_ui()
	_run()

# --------------------------------------------------------------- construccion
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.02)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var sheet := TextureRect.new()
	sheet.texture = _sheet_tex
	sheet.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sheet.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sheet)

	# Penumbra: oscurece toda la hoja; la viñeta activa se dibuja encima a plena luz.
	_dim = ColorRect.new()
	_dim.color = Color(0, 0, 0, 0.74)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)

	# Capa de la viñeta iluminada (encima de la penumbra, debajo del subtitulo).
	_spot = Control.new()
	_spot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_spot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spot.modulate = Color(1, 1, 1, 0)
	add_child(_spot)

	# Banda + subtitulo abajo.
	var band := ColorRect.new()
	band.color = Color(0, 0, 0, 0.55)
	band.position = Vector2(0, _vp.y - _vp.y * 0.14)
	band.size = Vector2(_vp.x, _vp.y * 0.14)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	_label.add_theme_font_size_override("font_size", int(_vp.y * 0.032))
	_label.position = Vector2(_vp.x * 0.12, _vp.y - _vp.y * 0.135)
	_label.size = Vector2(_vp.x * 0.76, _vp.y * 0.12)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)

	var hint := Label.new()
	hint.text = "Esc: saltar   ·   Click: continuar"
	hint.add_theme_color_override("font_color", Color(0.8, 0.78, 0.7, 0.5))
	hint.add_theme_font_size_override("font_size", int(_vp.y * 0.018))
	hint.position = Vector2(_vp.x * 0.72, _vp.y * 0.02)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)

	_fader = ColorRect.new()
	_fader.color = Color(0, 0, 0, 1)
	_fader.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fader)

# ------------------------------------------------------------------- reproduccion
func _run() -> void:
	await _fade(0.0, 0.8)
	for b in BEATS:
		if _skip_all:
			break
		await _beat(b)
	await _fade(1.0, 0.7)
	_finish()

func _beat(b: Dictionary) -> void:
	_show_spot(b["rect"])
	_label.text = String(b.get("text", ""))
	_label.visible_ratio = 0.0
	await _spot_fade(0.0, 1.0, 0.45)   # iluminar la viñeta
	await _type(_label.text)
	if _skip_all:
		return
	await _sleep(float(b.get("dur", _read_time(_label.text))))
	await _spot_fade(1.0, 0.0, 0.4)    # apagar antes de la siguiente

## Rellena la capa iluminada con el recorte (AtlasTexture) + un halo cálido detras.
func _show_spot(img_rect: Rect2) -> void:
	for c in _spot.get_children():
		c.queue_free()
	var screen := _to_screen(img_rect)

	# Halo cálido (marco luminoso).
	var glow := Panel.new()
	var pad := 14.0
	glow.position = screen.position - Vector2(pad, pad)
	glow.size = screen.size + Vector2(pad, pad) * 2.0
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = Color(1.0, 0.82, 0.45, 0.9)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(6)
	sb.shadow_color = Color(1.0, 0.7, 0.3, 0.55)
	sb.shadow_size = 28
	glow.add_theme_stylebox_override("panel", sb)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spot.add_child(glow)

	# Recorte de la viñeta a plena luz (por encima de la penumbra).
	var at := AtlasTexture.new()
	at.atlas = _sheet_tex
	at.region = img_rect
	var cut := TextureRect.new()
	cut.texture = at
	cut.stretch_mode = TextureRect.STRETCH_SCALE
	cut.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	cut.position = screen.position
	cut.size = screen.size
	cut.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spot.add_child(cut)

func _to_screen(r: Rect2) -> Rect2:
	return Rect2(_offset + r.position * _scale, r.size * _scale)

func _finish() -> void:
	GameState.new_game()
	SceneRouter.goto_counter()

# ------------------------------------------------------------------- tiempos
func _read_time(t: String) -> float:
	return clampf(1.8 + t.length() * 0.045, 3.2, 6.5)

func _sleep(t: float) -> void:
	var end := Time.get_ticks_msec() + int(t * 1000.0)
	while Time.get_ticks_msec() < end:
		if _interrupt:
			_interrupt = false
			return
		await get_tree().process_frame

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

func _spot_fade(from_a: float, to_a: float, t: float) -> void:
	if _spot == null:
		return
	_spot.modulate.a = from_a
	var tw := create_tween()
	tw.tween_property(_spot, "modulate:a", to_a, t)
	await tw.finished

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
