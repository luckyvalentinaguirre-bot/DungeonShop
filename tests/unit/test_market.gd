extends Test
## Tests de MarketSystem (precios de material fluctuantes). Ver docs/systems/01_Economy.md.

func _market(seed_value: int = 999) -> MarketSystem:
	var m := MarketSystem.new()
	m.setup(EconomyConfig.new(), seed_value)
	return m

func _iron() -> ItemData:
	var it := ItemData.new()
	it.id = &"mat_iron"
	it.base_value = 10
	it.category = GameEnums.Category.MATERIAL
	return it

func test_price_positive() -> void:
	var m := _market()
	var iron := _iron()
	m.track_material(iron)
	assert_true(m.material_price(iron) >= 1)

func test_deterministic_same_seed() -> void:
	var a := _market(42)
	var b := _market(42)
	var iron_a := _iron()
	var iron_b := _iron()
	a.track_material(iron_a)
	b.track_material(iron_b)
	assert_eq(a.material_price(iron_a), b.material_price(iron_b), "mismo seed => mismo precio")

func test_week_advances() -> void:
	var m := _market()
	assert_eq(m.current_week(), 0)
	m.advance_week()
	assert_eq(m.current_week(), 1)
