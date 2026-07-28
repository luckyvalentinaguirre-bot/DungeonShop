class_name ItemDatabase
extends RefCounted
## Carga e indexa todas las plantillas de objeto (ItemData .tres) de resources/items/.
## Fuente única para resolver objetos por id (ventas, recetas, guardado). Ver
## docs/Items.md y docs/systems/09_Inventory.md.

const ITEMS_DIR := "res://resources/items/"

## id(StringName) -> ItemData
var _by_id: Dictionary = {}

## Carga todos los .tres del directorio de objetos. Devuelve cuántos cargó.
func load_all() -> int:
	_by_id.clear()
	var dir := DirAccess.open(ITEMS_DIR)
	if dir == null:
		push_warning("No se pudo abrir %s" % ITEMS_DIR)
		return 0
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res: Resource = load(ITEMS_DIR + file_name)
			if res is ItemData and res.id != &"":
				_by_id[res.id] = res
		file_name = dir.get_next()
	dir.list_dir_end()
	return _by_id.size()

func get_item(item_id: StringName) -> ItemData:
	return _by_id.get(item_id)

func has(item_id: StringName) -> bool:
	return _by_id.has(item_id)

func all() -> Array:
	return _by_id.values()

func size() -> int:
	return _by_id.size()
