extends Test
## Tests de Inventory (modelo de almacenamiento). Ver docs/systems/09_Inventory.md.

func _material(id: StringName, max_stack: int = 99) -> ItemData:
	var it := ItemData.new()
	it.id = id
	it.category = GameEnums.Category.MATERIAL
	it.stackable = true
	it.max_stack = max_stack
	return it

func _unique(id: StringName) -> ItemData:
	var it := ItemData.new()
	it.id = id
	it.category = GameEnums.Category.WEAPON
	it.stackable = false
	it.max_stack = 1
	return it

func test_add_and_count() -> void:
	var inv := Inventory.new()
	inv.add(ItemInstance.new(_material(&"iron"), 0, 5))
	assert_eq(inv.count(&"iron"), 5)
	assert_true(inv.has(&"iron", 3))
	assert_false(inv.has(&"iron", 6))

func test_stacking_merges_same_item() -> void:
	var inv := Inventory.new()
	var iron := _material(&"iron")
	inv.add(ItemInstance.new(iron, 0, 3))
	inv.add(ItemInstance.new(iron, 0, 4))
	assert_eq(inv.count(&"iron"), 7)
	assert_eq(inv.slot_count(), 1, "los apilables se funden en una sola pila")

func test_stack_overflow_creates_new_slot() -> void:
	var inv := Inventory.new()
	var iron := _material(&"iron", 10)
	inv.add(ItemInstance.new(iron, 0, 12))
	assert_eq(inv.count(&"iron"), 12)
	assert_eq(inv.slot_count(), 2, "al superar max_stack se crea otra pila")

func test_unique_items_do_not_stack() -> void:
	var inv := Inventory.new()
	inv.add(ItemInstance.new(_unique(&"sword"), 2, 1))
	inv.add(ItemInstance.new(_unique(&"sword"), 4, 1))
	assert_eq(inv.slot_count(), 2, "los objetos únicos ocupan pilas propias")

func test_capacity_blocks_add() -> void:
	var inv := Inventory.new(1)
	assert_true(inv.add(ItemInstance.new(_unique(&"sword"), 1, 1)))
	assert_false(inv.add(ItemInstance.new(_unique(&"axe"), 1, 1)), "no cabe más al llenar la capacidad")

func test_remove_quantity() -> void:
	var inv := Inventory.new()
	inv.add(ItemInstance.new(_material(&"iron"), 0, 5))
	assert_true(inv.remove(&"iron", 2))
	assert_eq(inv.count(&"iron"), 3)
	assert_false(inv.remove(&"iron", 10), "no se puede quitar más de lo que hay")

func test_move_instance_to_other() -> void:
	var a := Inventory.new()
	var b := Inventory.new()
	var sword := ItemInstance.new(_unique(&"sword"), 3, 1)
	a.add(sword)
	assert_true(a.move_instance_to(b, sword))
	assert_eq(a.slot_count(), 0)
	assert_eq(b.slot_count(), 1)
