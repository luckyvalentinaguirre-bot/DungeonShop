extends Test
## Tests de ItemDatabase (carga del catálogo de objetos desde resources/items/).
## Ver docs/Items.md.

func test_loads_catalog() -> void:
	var db := ItemDatabase.new()
	var n := db.load_all()
	assert_true(n >= 5, "el catálogo semilla carga al menos 5 objetos (cargados: %d)" % n)

func test_get_known_item() -> void:
	var db := ItemDatabase.new()
	db.load_all()
	var sword := db.get_item(&"weapon_short_sword")
	assert_true(sword != null, "existe la espada corta en el catálogo")
	if sword != null:
		assert_eq(sword.category, GameEnums.Category.WEAPON)
		assert_eq(sword.base_value, 40)

func test_missing_item_is_null() -> void:
	var db := ItemDatabase.new()
	db.load_all()
	assert_false(db.has(&"nonexistent_item"))
	assert_true(db.get_item(&"nonexistent_item") == null)
