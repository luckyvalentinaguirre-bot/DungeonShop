class_name ResearchSystem
extends RefCounted
## Árbol de investigación: completa nodos (respetando prerrequisitos) para desbloquear
## recetas y tecnologías. Puro y testeable. Ver docs/systems/05_Crafting.md §6.

var _done: Array = []  # ids(StringName) de nodos completados

func is_researched(node_id: StringName) -> bool:
	return _done.has(node_id)

## ¿Están cumplidos los prerrequisitos de un nodo?
func prerequisites_met(node: ResearchNode) -> bool:
	for req in node.prerequisites:
		if not is_researched(req):
			return false
	return true

func can_research(node: ResearchNode, available_gold: int) -> bool:
	return node != null and not is_researched(node.id) and prerequisites_met(node) and available_gold >= node.cost

## Completa un nodo si se cumplen prerrequisitos y coste. Devuelve las recetas
## desbloqueadas, o [] si no se pudo.
func research(node: ResearchNode, available_gold: int) -> Array:
	if not can_research(node, available_gold):
		return []
	_done.append(node.id)
	return node.unlocks_recipes.duplicate()

func completed() -> Array:
	return _done
