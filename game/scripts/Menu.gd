extends Control
## Menú principal (base nueva). Simple y funcional: título + botones de madera sobre
## un fondo cálido. "Nueva partida" entra a la tienda. El arte final del menú se
## puede poner luego como fondo sin tocar la lógica.

const INTRO := "res://game/scenes/Intro.tscn"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vp := get_viewport_rect().size
	_build_background(vp)
	_build_title(vp)
	_build_buttons(vp)

func _build_background(vp: Vector2) -> void:
	var bg := ColorRect.new()
	bg.color = Color("241812")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# Viñeta cálida central.
	var glow := ColorRect.new()
	glow.color = Color(0.5, 0.32, 0.16, 0.18)
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)

func _build_title(vp: Vector2) -> void:
	var title := Label.new()
	title.text = "DUNGEON SHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", int(vp.y * 0.10))
	title.add_theme_color_override("font_color", Color("e8c07a"))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 3)
	title.position = Vector2(0, vp.y * 0.16)
	title.size = Vector2(vp.x, vp.y * 0.14)
	add_child(title)

	var sub := Label.new()
	sub.text = "La tienda de la abuela"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", int(vp.y * 0.03))
	sub.add_theme_color_override("font_color", Color("b79b6e"))
	sub.position = Vector2(0, vp.y * 0.30)
	sub.size = Vector2(vp.x, vp.y * 0.06)
	add_child(sub)

func _build_buttons(vp: Vector2) -> void:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	col.position = Vector2(vp.x * 0.5 - 150, vp.y * 0.46)
	col.custom_minimum_size = Vector2(300, 0)
	add_child(col)
	col.add_child(_button("Nueva partida", _on_new_game))
	col.add_child(_button("Salir", func() -> void: get_tree().quit()))

func _on_new_game() -> void:
	get_tree().change_scene_to_file(INTRO)

func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 56)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_color_override("font_color", Color("f4e7d2"))
	b.add_theme_color_override("font_hover_color", Color("ffedcf"))
	b.add_theme_stylebox_override("normal", _wood(Color("6b4526")))
	b.add_theme_stylebox_override("hover", _wood(Color("845735")))
	b.add_theme_stylebox_override("pressed", _wood(Color("543619")))
	b.pressed.connect(cb)
	return b

func _wood(c: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.border_color = Color("3a2414")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(10)
	return sb
