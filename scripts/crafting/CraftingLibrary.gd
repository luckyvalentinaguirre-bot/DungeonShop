class_name CraftingLibrary
extends RefCounted
## Carga las recetas y estaciones de fabricación desde resources/. Fuente única para
## la UI de fabricación. Ver docs/systems/05_Crafting.md y docs/Items.md.

const RECIPES_DIR := "res://resources/recipes/"
const STATIONS_DIR := "res://resources/stations/"

var _recipes: Array = []
## id(StringName) -> CraftingStationData
var _stations: Dictionary = {}

func load_all() -> void:
	_recipes.clear()
	_stations.clear()
	for res in _load_dir(RECIPES_DIR):
		if res is RecipeData:
			_recipes.append(res)
	for res in _load_dir(STATIONS_DIR):
		if res is CraftingStationData:
			_stations[res.id] = res

func recipes() -> Array:
	return _recipes

func station(station_id: StringName) -> CraftingStationData:
	return _stations.get(station_id)

func _load_dir(path: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res: Resource = load(path + file_name)
			if res != null:
				out.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()
	return out
