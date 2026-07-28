extends Test
## Tests de PriceCalculator (cálculo puro de precios). Ver docs/systems/01_Economy.md.

func _config() -> EconomyConfig:
	return EconomyConfig.new()

func _item(base: int) -> ItemData:
	var it := ItemData.new()
	it.base_value = base
	it.category = GameEnums.Category.WEAPON
	return it

func test_neutral_price_equals_base() -> void:
	# Calidad 2 => multiplicador 1.0; demanda/reputación/evento neutros (1.0).
	var p := PriceCalculator.suggested_price(_item(100), 2, 1.0, 1.0, 1.0, _config())
	assert_eq(p, 100, "precio neutro debe igualar el valor base")

func test_higher_quality_costs_more() -> void:
	var cfg := _config()
	var low := PriceCalculator.suggested_price(_item(100), 0, 1.0, 1.0, 1.0, cfg)
	var high := PriceCalculator.suggested_price(_item(100), 5, 1.0, 1.0, 1.0, cfg)
	assert_true(high > low, "mayor calidad => mayor precio")

func test_demand_scales_price() -> void:
	var p := PriceCalculator.suggested_price(_item(100), 2, 2.0, 1.0, 1.0, _config())
	assert_eq(p, 200, "demanda x2 duplica el precio")

func test_null_item_returns_zero() -> void:
	assert_eq(PriceCalculator.suggested_price(null, 2, 1.0, 1.0, 1.0, _config()), 0)

func test_price_never_below_one() -> void:
	var p := PriceCalculator.suggested_price(_item(1), 0, 0.5, 0.9, 0.5, _config())
	assert_true(p >= 1, "el precio nunca baja de 1 corona")
