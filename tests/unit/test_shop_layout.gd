extends Test
## Tests de ShopLayout (distribución cenital de la tienda). Ver docs/ArtDirection.md.

func test_place_and_query() -> void:
	var layout := ShopLayout.new(4, 4)
	assert_true(layout.place(1, 1, ShopLayout.Furniture.SHELF))
	assert_eq(layout.furniture_at(1, 1), ShopLayout.Furniture.SHELF)

func test_out_of_bounds_fails() -> void:
	var layout := ShopLayout.new(3, 3)
	assert_false(layout.place(5, 5, ShopLayout.Furniture.SHELF))

func test_assign_item_only_to_shelf() -> void:
	var layout := ShopLayout.new(4, 4)
	assert_false(layout.assign(0, 0, &"potion_heal"), "no se puede asignar producto a una casilla vacía")
	layout.place(0, 0, ShopLayout.Furniture.SHELF)
	assert_true(layout.assign(0, 0, &"potion_heal"))
	assert_eq(layout.assigned_item(0, 0), &"potion_heal")

func test_shelves_lists_assigned() -> void:
	var layout := ShopLayout.new(4, 4)
	layout.place(2, 1, ShopLayout.Furniture.SHELF)
	layout.assign(2, 1, &"weapon_short_sword")
	var shelves := layout.shelves()
	assert_eq(shelves.size(), 1)
	assert_eq(shelves[0]["item_id"], &"weapon_short_sword")

func test_save_roundtrip() -> void:
	var layout := ShopLayout.new(4, 4)
	layout.place(1, 1, ShopLayout.Furniture.SHELF)
	layout.assign(1, 1, &"potion_heal")
	var data := JSON.parse_string(JSON.stringify(layout.capture_state()))
	var restored := ShopLayout.new()
	restored.restore_state(data)
	assert_eq(restored.furniture_at(1, 1), ShopLayout.Furniture.SHELF)
	assert_eq(restored.assigned_item(1, 1), &"potion_heal")
