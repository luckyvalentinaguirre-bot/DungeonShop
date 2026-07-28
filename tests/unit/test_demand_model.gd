extends Test
## Tests de DemandModel (demanda por categoría). Ver docs/systems/01_Economy.md.

func _model() -> DemandModel:
	return DemandModel.new(EconomyConfig.new())

func test_default_is_neutral() -> void:
	assert_almost_eq(_model().get_multiplier(GameEnums.Category.POTION), 1.0)

func test_sale_reduces_demand() -> void:
	var m := _model()
	m.register_sale(GameEnums.Category.WEAPON, 1)
	assert_true(m.get_multiplier(GameEnums.Category.WEAPON) < 1.0, "vender satura y baja la demanda")

func test_request_increases_demand() -> void:
	var m := _model()
	m.register_request(GameEnums.Category.ARMOR)
	assert_true(m.get_multiplier(GameEnums.Category.ARMOR) > 1.0, "pedir sube la demanda")

func test_reversion_moves_toward_neutral() -> void:
	var m := _model()
	for i in 5:
		m.register_sale(GameEnums.Category.TOOL, 1)
	var before := m.get_multiplier(GameEnums.Category.TOOL)
	m.advance_day()
	var after := m.get_multiplier(GameEnums.Category.TOOL)
	assert_true(after > before, "la demanda revierte hacia el neutro con el tiempo")

func test_clamped_within_bounds() -> void:
	var m := _model()
	for i in 1000:
		m.register_sale(GameEnums.Category.POTION, 10)
	assert_true(m.get_multiplier(GameEnums.Category.POTION) >= 0.5, "no baja del mínimo configurado")
