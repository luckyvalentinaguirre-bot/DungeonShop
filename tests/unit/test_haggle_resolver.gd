extends Test
## Tests de HaggleResolver (regateo automático por ánimo). Ver docs/systems/02_Customers.md.

func _config() -> EconomyConfig:
	return EconomyConfig.new()

func test_fair_price_is_accepted() -> void:
	# Precio justo, presupuesto de sobra, ánimo neutro -> acepta.
	var r := HaggleResolver.evaluate(100, 100, 200, 0.5, _config())
	assert_true(r.accepted, "un precio justo se acepta")

func test_over_budget_is_rejected() -> void:
	var r := HaggleResolver.evaluate(250, 100, 200, 1.0, _config())
	assert_false(r.accepted)
	assert_eq(r.reason, "over_budget")

func test_too_expensive_is_rejected() -> void:
	# Muy por encima del precio justo pero dentro del presupuesto -> rechaza por caro.
	var r := HaggleResolver.evaluate(180, 100, 500, 0.5, _config())
	assert_false(r.accepted)
	assert_eq(r.reason, "too_expensive")

func test_happier_customer_tolerates_more() -> void:
	var cfg := _config()
	var price := 110  # 10% sobre lo justo
	var grumpy := HaggleResolver.evaluate(price, 100, 500, 0.0, cfg)
	var happy := HaggleResolver.evaluate(price, 100, 500, 1.0, cfg)
	assert_false(grumpy.accepted, "un cliente gruñón tolera menos margen")
	assert_true(happy.accepted, "un cliente contento tolera más margen")

func test_bargain_raises_mood() -> void:
	# Vender por debajo del precio justo sube el ánimo.
	var r := HaggleResolver.evaluate(80, 100, 500, 0.5, _config())
	assert_true(r.accepted)
	assert_true(r.mood_delta > 0.0, "una ganga mejora el ánimo")
