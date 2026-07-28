class_name DialogueRunner
extends RefCounted
## Recorre un DialogueData línea a línea. Puro y testeable; la UI (DialogueView) solo
## consulta la línea actual y avanza. Ver docs/systems/10_Dialogue.md §6.

var _lines: Array = []
var _index: int = -1

## Empieza un diálogo (deja el cursor antes de la primera línea).
func start(data: DialogueData) -> void:
	_lines = data.lines.duplicate() if data != null else []
	_index = -1

func has_next() -> bool:
	return _index + 1 < _lines.size()

## Avanza a la siguiente línea y la devuelve (o null si no hay más).
func advance() -> DialogueLine:
	if has_next():
		_index += 1
		return _lines[_index]
	return null

func current() -> DialogueLine:
	if _index >= 0 and _index < _lines.size():
		return _lines[_index]
	return null

func is_finished() -> bool:
	return _index >= _lines.size() - 1
