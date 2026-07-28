class_name ShopLayout
extends RefCounted
## Distribución de la tienda en cuadrícula (para la VISTA CENITAL / top-down): qué
## mueble hay en cada casilla y qué producto se expone en cada estante. La vista
## top-down lo renderiza y el jugador coloca muebles y asigna productos a cada
## estante. Puro y testeable. Ver docs/ArtDirection.md §3 y docs/systems/09_Inventory.md.

enum Furniture { NONE, SHELF, COUNTER, DECOR }

var width: int
var height: int
var _tiles: Array = []              # index -> Furniture(int)
var _assignments: Dictionary = {}   # index -> item_id(StringName) para estantes

func _init(w: int = 8, h: int = 6) -> void:
	width = w
	height = h
	_tiles.resize(w * h)
	_tiles.fill(Furniture.NONE)

func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < width and y >= 0 and y < height

func furniture_at(x: int, y: int) -> int:
	return int(_tiles[_index(x, y)]) if in_bounds(x, y) else Furniture.NONE

## Coloca (o cambia) un mueble en una casilla. Al dejar de ser estante, borra su
## producto asignado.
func place(x: int, y: int, furniture: int) -> bool:
	if not in_bounds(x, y):
		return false
	var idx := _index(x, y)
	_tiles[idx] = furniture
	if furniture != Furniture.SHELF:
		_assignments.erase(idx)
	return true

func remove(x: int, y: int) -> bool:
	return place(x, y, Furniture.NONE)

## Asigna qué producto se expone en un estante. Falla si la casilla no es estante.
func assign(x: int, y: int, item_id: StringName) -> bool:
	if furniture_at(x, y) != Furniture.SHELF:
		return false
	_assignments[_index(x, y)] = item_id
	return true

func assigned_item(x: int, y: int) -> StringName:
	return _assignments.get(_index(x, y), &"")

## Lista de estantes con producto: [{x, y, item_id}, ...].
func shelves() -> Array:
	var out: Array = []
	for y in height:
		for x in width:
			if furniture_at(x, y) == Furniture.SHELF:
				out.append({"x": x, "y": y, "item_id": assigned_item(x, y)})
	return out

func _index(x: int, y: int) -> int:
	return y * width + x

## Serialización (ISaveable). Guarda tamaño, muebles y asignaciones.
func capture_state() -> Dictionary:
	var assigns: Dictionary = {}
	for idx in _assignments.keys():
		assigns[str(idx)] = String(_assignments[idx])
	return {"w": width, "h": height, "tiles": _tiles.duplicate(), "assign": assigns}

func restore_state(data: Dictionary) -> void:
	width = int(data.get("w", 8))
	height = int(data.get("h", 6))
	var tiles = data.get("tiles", [])
	_tiles = tiles.duplicate() if tiles is Array else []
	_assignments.clear()
	var assigns = data.get("assign", {})
	if assigns is Dictionary:
		for key in assigns.keys():
			_assignments[int(key)] = StringName(assigns[key])
