class_name UiFactory
extends RefCounted
## Fábrica de widgets de UI con un estilo cálido y consistente, construidos por
## código (esta primera versión de la interfaz no usa escenas .tscn complejas; se
## pueden convertir en el editor para pulir). Ver docs/ArtDirection.md.

## Paleta base cozy (placeholder; se afina en la fase de arte).
const COL_BG := Color("2a1e16")
const COL_PANEL := Color("3a2a1e")
const COL_ACCENT := Color("e8b06a")
const COL_TEXT := Color("f4e7d2")
const COL_ARCANE := Color("4fd0c8")

static func label(text: String, font_size: int = 16, color: Color = COL_TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

static func title(text: String) -> Label:
	var l := label(text, 40, COL_ACCENT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

static func button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 18)
	b.custom_minimum_size = Vector2(160, 40)
	return b

static func vbox(separation: int = 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", separation)
	return v

static func hbox(separation: int = 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", separation)
	return h

static func panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_PANEL
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(12)
	p.add_theme_stylebox_override("panel", sb)
	return p

static func background(control: Control) -> ColorRect:
	var bg := ColorRect.new()
	bg.color = COL_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control.add_child(bg)
	return bg
