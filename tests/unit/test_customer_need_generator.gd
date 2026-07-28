extends Test
## Tests de CustomerNeedGenerator (generación determinista de necesidades).
## Ver docs/systems/02_Customers.md.

func _data() -> CustomerData:
	var d := CustomerData.new()
	d.preferred_categories = [GameEnums.Category.WEAPON]
	d.budget_min = 20
	d.budget_max = 60
	d.base_mood = 0.5
	d.shelf_preference = 0.5
	return d

func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng

func test_budget_within_range() -> void:
	var need := CustomerNeedGenerator.generate(_data(), _rng(1))
	assert_true(need.budget >= 20 and need.budget <= 60, "el presupuesto está en el rango de la plantilla")

func test_category_from_preferences() -> void:
	var need := CustomerNeedGenerator.generate(_data(), _rng(2))
	assert_eq(need.category, GameEnums.Category.WEAPON, "usa una categoría preferida")

func test_deterministic_same_seed() -> void:
	var a := CustomerNeedGenerator.generate(_data(), _rng(99))
	var b := CustomerNeedGenerator.generate(_data(), _rng(99))
	assert_eq(a.budget, b.budget, "mismo seed => misma necesidad")
	assert_eq(a.min_quality, b.min_quality)

func test_default_category_when_no_preferences() -> void:
	var d := CustomerData.new()
	d.budget_min = 10
	d.budget_max = 10
	var need := CustomerNeedGenerator.generate(d, _rng(3))
	assert_eq(need.category, CustomerNeedGenerator.DEFAULT_CATEGORY)
