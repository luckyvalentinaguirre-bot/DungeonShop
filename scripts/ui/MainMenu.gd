extends Control
## Menú principal: usa la ilustración del diseñador TAL CUAL (assets/ui/menu_art.png)
## a pantalla completa, con zonas clicables invisibles colocadas justo encima de los
## botones dibujados (Nueva Partida, Cargar Partida, Opciones, Salir). No altera el
## aspecto de la imagen; solo la hace funcional.

const ART := "res://assets/ui/menu_art.png"

# Rectángulos de los botones como fracción de la pantalla (medidos sobre la imagen).
const R_NUEVA := Rect2(0.105, 0.748, 0.180, 0.080)
const R_CARGAR := Rect2(0.322, 0.748, 0.186, 0.080)
const R_OPCIONES := Rect2(0.535, 0.748, 0.150, 0.080)
const R_SALIR := Rect2(0.752, 0.748, 0.178, 0.080)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_background()
	_build_hotspots()

func _build_background() -> void:
	var bg := TextureRect.new()
	if ResourceLoader.exists(ART):
		bg.texture = load(ART)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	# Arte ilustrado (no pixel art): filtrado suave al escalar.
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func _build_hotspots() -> void:
	_hotspot(R_NUEVA, _on_new_game)
	_hotspot(R_CARGAR, _on_load)
	_hotspot(R_OPCIONES, _on_options)
	_hotspot(R_SALIR, _on_quit)

## Crea un botón transparente sobre un botón dibujado; solo muestra un brillo suave
## al pasar el ratón, sin cambiar el arte.
func _hotspot(frac: Rect2, cb: Callable) -> void:
	var vp := get_viewport_rect().size
	var b := Button.new()
	b.position = Vector2(frac.position.x * vp.x, frac.position.y * vp.y)
	b.size = Vector2(frac.size.x * vp.x, frac.size.y * vp.y)
	b.custom_minimum_size = b.size
	b.focus_mode = Control.FOCUS_NONE
	var empty := StyleBoxEmpty.new()
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("focus", empty)
	b.add_theme_stylebox_override("disabled", empty)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 0.92, 0.6, 0.16)
	hover.set_corner_radius_all(10)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.pressed.connect(cb)
	# Pequeña animación de escala al pasar el ratón.
	b.mouse_entered.connect(func() -> void: _pop(b, 1.03))
	b.mouse_exited.connect(func() -> void: _pop(b, 1.0))
	add_child(b)

func _pop(b: Button, target: float) -> void:
	b.pivot_offset = b.size * 0.5
	create_tween().tween_property(b, "scale", Vector2(target, target), 0.08)

# ------------------------------------------------------------------- acciones
func _on_new_game() -> void:
	GameState.new_game()
	SceneRouter.goto_counter()

func _on_load() -> void:
	if SaveManager.has_save(1) and SaveManager.load_game(1):
		SceneRouter.goto_counter()
	else:
		# Sin partida guardada: por ahora empieza una nueva.
		GameState.new_game()
		SceneRouter.goto_counter()

func _on_options() -> void:
	pass

func _on_quit() -> void:
	get_tree().quit()
