class_name FurnitureCatalog
extends RefCounted
## Definiciones de los muebles modulares (Etapa 2), por codigo. Cada uno describe su
## sprite, que admite y sus puntos de colocacion (huecos locales, con el origen en el
## PIE del mueble; hacia arriba = y negativo). Mas adelante pueden pasarse a .tres.

const ART := "res://game/art/"

static func _mk(id: StringName, name: String, kind: int, tex: String,
		cats: Array, slots: Array, slot_size: float, size: Vector2) -> FurnitureData:
	var d := FurnitureData.new()
	d.id = id
	d.display_name = name
	d.kind = kind
	d.texture_path = ART + tex
	d.allowed_categories = cats
	d.slots = slots
	d.slot_size = slot_size
	d.size = size
	return d

## Estanteria de armas (6 huecos, 2 filas de 3).
static func shelf_weapons() -> FurnitureData:
	return _mk(&"shelf_weapons", "Estantería de armas", ShopEnums.FurnitureKind.SHELF,
		"shelf.svg", [ShopEnums.Category.WEAPON],
		_grid_slots(3, 2, 52.0, -128.0, 58.0), 44.0, Vector2(160, 170))

## Estanteria de pociones (6 huecos).
static func shelf_potions() -> FurnitureData:
	return _mk(&"shelf_potions", "Estantería de pociones", ShopEnums.FurnitureKind.SHELF,
		"shelf.svg", [ShopEnums.Category.POTION, ShopEnums.Category.MATERIAL],
		_grid_slots(3, 2, 52.0, -128.0, 58.0), 40.0, Vector2(160, 170))

## Estanteria de armaduras (4 huecos, 2 filas de 2).
static func shelf_armor() -> FurnitureData:
	return _mk(&"shelf_armor", "Estantería de armaduras", ShopEnums.FurnitureKind.SHELF,
		"shelf.svg", [ShopEnums.Category.ARMOR],
		_grid_slots(2, 2, 60.0, -128.0, 58.0), 48.0, Vector2(160, 170))

## Mostrador (3 huecos sobre la tabla; admite cualquier categoria para atender).
static func counter() -> FurnitureData:
	return _mk(&"counter", "Mostrador", ShopEnums.FurnitureKind.COUNTER,
		"counter.svg", [],
		[Vector2(-64, -96), Vector2(0, -96), Vector2(64, -96)], 44.0, Vector2(220, 120))

## Vitrina (2 huecos para objetos raros/legendarios).
static func vitrina() -> FurnitureData:
	return _mk(&"vitrina", "Vitrina", ShopEnums.FurnitureKind.DISPLAY,
		"vitrina.svg", [ShopEnums.Category.MAGIC, ShopEnums.Category.MISC],
		[Vector2(-32, -120), Vector2(32, -120)], 46.0, Vector2(150, 180))

## Genera una rejilla de huecos centrada en x, apilada hacia arriba desde y_top.
static func _grid_slots(cols: int, rows: int, step: float, y_top: float, y_step: float) -> Array:
	var out: Array = []
	var x0 := -step * (cols - 1) * 0.5
	for r in rows:
		for c in cols:
			out.append(Vector2(x0 + c * step, y_top + r * y_step))
	return out
