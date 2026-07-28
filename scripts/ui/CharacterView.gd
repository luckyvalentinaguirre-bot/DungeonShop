class_name CharacterView
extends Control
## Personaje 2D animado. El arte son placeholders (SVG en assets/characters/) y las
## animaciones son básicas por código (entrar, respirar, alegrarse, enfadarse), para
## dar vida sin frames dibujados. Para poner arte final basta con sustituir las
## texturas. Ver docs/ArtDirection.md.
##
## Nota: se animan escala/rotación/opacidad (con pivote centrado), no la posición,
## para no pelear con el layout del contenedor.

var _sprite: TextureRect
var _idle_tween: Tween

func _ready() -> void:
	custom_minimum_size = Vector2(150, 190)
	_sprite = TextureRect.new()
	_sprite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sprite)
	visible = false

## Muestra un personaje (ruta de textura) y reproduce la animación de entrada.
func show_character(texture_path: String) -> void:
	if ResourceLoader.exists(texture_path):
		_sprite.texture = load(texture_path)
	else:
		_sprite.texture = null
	visible = true
	_play_enter()

func hide_character() -> void:
	_stop_idle()
	visible = false

func play_happy() -> void:
	_stop_idle()
	_center_pivot()
	var t := create_tween()
	t.tween_property(_sprite, "scale", Vector2(1.18, 1.18), 0.12).set_trans(Tween.TRANS_BACK)
	t.tween_property(_sprite, "scale", Vector2.ONE, 0.12)
	t.tween_callback(_start_idle)

func play_sad() -> void:
	_stop_idle()
	_center_pivot()
	var t := create_tween()
	t.tween_property(_sprite, "rotation", -0.12, 0.06)
	t.tween_property(_sprite, "rotation", 0.12, 0.06)
	t.tween_property(_sprite, "rotation", 0.0, 0.06)
	t.tween_callback(_start_idle)

# ---------------------------------------------------------------------- internos
func _play_enter() -> void:
	_stop_idle()
	_center_pivot()
	_sprite.modulate.a = 0.0
	_sprite.scale = Vector2(0.8, 0.8)
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_sprite, "modulate:a", 1.0, 0.3)
	t.tween_property(_sprite, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.chain().tween_callback(_start_idle)

func _start_idle() -> void:
	_stop_idle()
	_center_pivot()
	_idle_tween = create_tween()
	_idle_tween.set_loops()
	_idle_tween.tween_property(_sprite, "scale", Vector2(1.0, 1.05), 1.1).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(_sprite, "scale", Vector2(1.0, 1.0), 1.1).set_trans(Tween.TRANS_SINE)

func _stop_idle() -> void:
	if _idle_tween != null and _idle_tween.is_valid():
		_idle_tween.kill()
	_idle_tween = null
	if _sprite != null:
		_sprite.scale = Vector2.ONE
		_sprite.rotation = 0.0

func _center_pivot() -> void:
	var s := _sprite.size
	if s == Vector2.ZERO:
		s = custom_minimum_size
	_sprite.pivot_offset = s / 2.0
