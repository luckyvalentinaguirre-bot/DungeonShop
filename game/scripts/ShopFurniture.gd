class_name ShopFurniture
extends Node2D
## Un mueble colocado en la tienda (estanteria, mostrador, vitrina). Dibuja su sprite
## y expone PUNTOS DE COLOCACION donde luego se posan los sprites de los objetos.
## En la Etapa 2 los huecos se muestran como marcas tenues ("espacio para objetos");
## en la Etapa 3, place_item() pondra el sprite real del objeto en el hueco.
##
## El sprite base se ancla por su borde inferior para apoyarse en el suelo (vista 3/4),
## y el nodo usa y-sort del contenedor para el orden de profundidad.

var data: FurnitureData
var _base: Sprite2D
var _slot_markers: Array = []
var _slot_items: Array = []          # Sprite2D del objeto por hueco (o null)

func setup(furniture_data: FurnitureData) -> void:
	data = furniture_data
	_base = Sprite2D.new()
	_base.texture = AssetLibrary.texture(data.texture_path)
	_base.centered = true
	# Anclar por el pie: el origen del nodo queda en la base del mueble.
	if _base.texture != null:
		_base.position = Vector2(0, -_base.texture.get_height() * 0.5)
	add_child(_base)
	_build_slot_markers()

	_slot_items.resize(data.slots.size())

# --- puntos de colocacion -------------------------------------------------
func _build_slot_markers() -> void:
	for pos in data.slots:
		var m := _make_marker(pos, data.slot_size)
		add_child(m)
		_slot_markers.append(m)

## Marca tenue que indica "aqui se puede colocar un objeto".
func _make_marker(pos: Vector2, s: float) -> Node2D:
	var n := Node2D.new()
	n.position = pos
	var half := s * 0.5
	var fill := Polygon2D.new()
	fill.polygon = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half),
	])
	fill.color = Color(1.0, 0.9, 0.6, 0.10)
	n.add_child(fill)
	var border := Line2D.new()
	border.points = PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half),
		Vector2(half, half), Vector2(-half, half), Vector2(-half, -half),
	])
	border.width = 1.5
	border.default_color = Color(1.0, 0.85, 0.5, 0.35)
	n.add_child(border)
	return n

func set_slots_visible(v: bool) -> void:
	for m in _slot_markers:
		m.visible = v

# --- colocacion de objetos (usado en Etapa 3) -----------------------------
## Coloca el sprite de un objeto en un hueco. Devuelve false si el hueco no existe
## o el mueble no admite esa categoria.
func place_item(slot_index: int, texture: Texture2D, category: int = -1) -> bool:
	if slot_index < 0 or slot_index >= data.slots.size():
		return false
	if category != -1 and not data.can_hold(category):
		return false
	clear_slot(slot_index)
	if texture == null:
		return false
	var spr := Sprite2D.new()
	spr.texture = texture
	spr.centered = true
	spr.position = data.slots[slot_index]
	# Escalar el sprite para que entre en el hueco conservando proporcion.
	var t := texture.get_size()
	if t.x > 0.0 and t.y > 0.0:
		var f: float = data.slot_size / maxf(t.x, t.y)
		spr.scale = Vector2(f, f)
	add_child(spr)
	_slot_items[slot_index] = spr
	return true

func clear_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= _slot_items.size():
		return
	var existing = _slot_items[slot_index]
	if existing != null and is_instance_valid(existing):
		existing.queue_free()
	_slot_items[slot_index] = null

func free_slot_index() -> int:
	for i in _slot_items.size():
		if _slot_items[i] == null:
			return i
	return -1
