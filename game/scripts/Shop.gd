extends Node2D
## ESCENA INICIAL DE DUNGEON SHOP (Etapa 1 + 2). Construye la tienda con piezas
## MODULARES (piso en rejilla, paredes, puerta, muebles) en una vista 2D 3/4, con
## iluminacion calida y camara encuadrada. Deja los muebles con sus PUNTOS DE
## COLOCACION visibles ("espacio para objetos"), listos para la Etapa 3.
##
## Todo se compone por codigo a partir de piezas reemplazables: cambiar un .svg de
## game/art/ por el sprite final del diseñador basta para renovar el look.

const ART := "res://game/art/"
const TILE := Vector2(128, 74)         # tamaño visual del azulejo de piso

# Rectangulo interior de la tienda (en unidades de mundo).
const ROOM := Rect2(-560, -300, 1120, 620)

var _yard: Node2D                      # contenedor de muebles con y-sort (profundidad)

func _ready() -> void:
	_build_camera()
	_build_ambient_light()
	_build_floor()
	_build_walls()
	_yard = Node2D.new()
	_yard.y_sort_enabled = true
	add_child(_yard)
	_build_furniture()
	_build_lamps()

# ------------------------------------------------------------------- camara
func _build_camera() -> void:
	var cam := Camera2D.new()
	cam.position = Vector2(0, -20)
	# zoom 1.1: agranda un poco la escena dejando ver toda la sala con margen.
	cam.zoom = Vector2(1.1, 1.1)
	cam.make_current()
	add_child(cam)

# --------------------------------------------------------------- iluminacion
## Tienda "nivel 1": vieja y en penumbra calida. Los faroles agregan focos de luz.
func _build_ambient_light() -> void:
	var cm := CanvasModulate.new()
	cm.color = Color(0.62, 0.55, 0.48)
	add_child(cm)

# ------------------------------------------------------------------- piso
func _build_floor() -> void:
	var floor_tex := _tex("floor_tile.svg")
	var layer := Node2D.new()
	add_child(layer)
	var cols := int(ROOM.size.x / TILE.x) + 2
	var rows := int(ROOM.size.y / (TILE.y * 0.7)) + 2
	for r in rows:
		for c in cols:
			var s := Sprite2D.new()
			s.texture = floor_tex
			s.centered = true
			# Filas alternas desplazadas media baldosa (aspecto de tablones 3/4).
			var ox := (TILE.x * 0.5) if (r % 2 == 1) else 0.0
			s.position = ROOM.position + Vector2(c * TILE.x + ox, r * TILE.y * 0.7)
			if _in_room(s.position):
				layer.add_child(s)

func _in_room(p: Vector2) -> bool:
	return p.x > ROOM.position.x - TILE.x and p.x < ROOM.end.x + TILE.x \
		and p.y > ROOM.position.y - TILE.y and p.y < ROOM.end.y + TILE.y

# ----------------------------------------------------------------- paredes
func _build_walls() -> void:
	var wall_tex := _tex("wall.svg")
	var layer := Node2D.new()
	add_child(layer)
	# Pared del fondo (arriba), fila de segmentos.
	var wall_w := 128.0
	var n := int(ROOM.size.x / wall_w) + 1
	for i in n:
		var s := Sprite2D.new()
		s.texture = wall_tex
		s.centered = true
		s.position = Vector2(ROOM.position.x + i * wall_w + wall_w * 0.5, ROOM.position.y - 20)
		layer.add_child(s)
	# Puerta centrada en la pared del fondo.
	var door := Sprite2D.new()
	door.texture = _tex("door.svg")
	door.centered = true
	if door.texture != null:
		door.position = Vector2(0, ROOM.position.y - 20 - (door.texture.get_height() - 96) * 0.5)
	else:
		door.position = Vector2(0, ROOM.position.y - 20)
	layer.add_child(door)

# ----------------------------------------------------------------- muebles
func _build_furniture() -> void:
	# Estanterias contra la pared del fondo (a los lados de la puerta).
	_place(FurnitureCatalog.shelf_weapons(), Vector2(-360, ROOM.position.y + 150))
	_place(FurnitureCatalog.shelf_potions(), Vector2(360, ROOM.position.y + 150))
	# Estanteria de armaduras en el lateral izquierdo.
	_place(FurnitureCatalog.shelf_armor(), Vector2(-470, ROOM.position.y + 320))
	# Vitrina a la derecha, mas adelante.
	_place(FurnitureCatalog.vitrina(), Vector2(330, ROOM.position.y + 360))
	# Mostrador en primer plano (centro).
	_place(FurnitureCatalog.counter(), Vector2(0, ROOM.end.y - 70))

func _place(data: FurnitureData, at: Vector2) -> ShopFurniture:
	var f := ShopFurniture.new()
	f.position = at
	_yard.add_child(f)
	f.setup(data)              # setup tras add_child para que AssetLibrary este listo
	return f

# ------------------------------------------------------------------- faroles
func _build_lamps() -> void:
	_lamp(Vector2(-230, ROOM.position.y + 40))
	_lamp(Vector2(230, ROOM.position.y + 40))
	_lamp(Vector2(0, ROOM.end.y - 210))

func _lamp(pos: Vector2) -> void:
	var lamp := Sprite2D.new()
	lamp.texture = _tex("lamp.svg")
	lamp.centered = true
	lamp.position = pos
	_yard.add_child(lamp)
	var light := PointLight2D.new()
	light.texture = _light_texture()
	light.color = Color(1.0, 0.82, 0.5)
	light.energy = 1.1
	light.texture_scale = 3.2
	light.position = pos
	add_child(light)

# ------------------------------------------------------------------- helpers
func _tex(name: String) -> Texture2D:
	return AssetLibrary.texture(ART + name)

## Textura radial suave para las luces de los faroles.
func _light_texture() -> Texture2D:
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
