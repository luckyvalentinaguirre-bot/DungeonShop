extends Node
## Cambio de escena centralizado (menú ↔ tienda…). Autoload. En esta primera versión
## hace un cambio directo; las transiciones con fundido se añaden en el pulido.
## Ver docs/systems/00_Architecture.md §6.
##
## NO declara class_name para no chocar con el nombre del singleton.

const MAIN_MENU := "res://scenes/main_menu/MainMenu.tscn"
const SHOP := "res://scenes/shop/Shop.tscn"
const CRAFTING := "res://scenes/crafting/CraftingScreen.tscn"

func goto(path: String) -> void:
	get_tree().change_scene_to_file(path)

func goto_shop() -> void:
	goto(SHOP)

func goto_main_menu() -> void:
	goto(MAIN_MENU)

func goto_crafting() -> void:
	goto(CRAFTING)
