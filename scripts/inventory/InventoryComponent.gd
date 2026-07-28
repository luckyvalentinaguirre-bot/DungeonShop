class_name InventoryComponent
extends Node
## Envuelve un Inventory para colgarlo de una escena (almacén, estantería, cliente,
## héroe) por composición. Reenvía la señal 'changed' del modelo. Ver
## docs/systems/09_Inventory.md §2 y docs/systems/00_Architecture.md §7.

signal changed()

## Capacidad en slots (0 = ilimitada). Editable en el inspector.
@export var capacity: int = 0

var _inventory: Inventory

## Devuelve el Inventory subyacente, creándolo la primera vez (perezoso, para que
## funcione también en tests que no pasan por _ready).
func get_inventory() -> Inventory:
	if _inventory == null:
		_inventory = Inventory.new(capacity)
		_inventory.changed.connect(func() -> void: changed.emit())
	return _inventory

func _ready() -> void:
	get_inventory()
