extends Node
## Guardar/cargar la partida en user://saves/ como JSON versionado, con copia de
## respaldo del guardado anterior. Orquesta: pide a GameState su estado y se lo
## devuelve; no conoce el contenido de cada sección. Autoload.
## Ver docs/systems/08_Save.md.
##
## NO declara class_name para no chocar con el nombre del singleton.

const SAVE_DIR := "user://saves/"
const SLOT_COUNT := 3

func _slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%02d.json" % slot

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))

## Guarda la partida en un slot. Devuelve true si se escribió correctamente.
func save_game(slot: int) -> bool:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var path := _slot_path(slot)
	# Respaldo del guardado anterior antes de sobrescribir.
	if FileAccess.file_exists(path):
		var prev := FileAccess.open(path, FileAccess.READ)
		if prev != null:
			var prev_text := prev.get_as_text()
			prev.close()
			var bak := FileAccess.open(path + ".bak", FileAccess.WRITE)
			if bak != null:
				bak.store_string(prev_text)
				bak.close()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(GameState.capture_state(), "\t"))
	file.close()
	var bus := get_node_or_null("/root/EventBus")
	if bus != null:
		bus.emit_signal("game_saved", slot)
	return true

## Carga la partida de un slot. Devuelve true si se cargó correctamente.
func load_game(slot: int) -> bool:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	GameState.restore_state(parsed)
	var bus := get_node_or_null("/root/EventBus")
	if bus != null:
		bus.emit_signal("game_loaded", slot)
	return true
