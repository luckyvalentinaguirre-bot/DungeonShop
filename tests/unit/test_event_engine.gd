extends Test
## Tests de EventEngine (eventos del reino). Ver docs/systems/07_Events.md.

func _demand() -> DemandModel:
	return DemandModel.new(EconomyConfig.new())

func _war_event(duration: int) -> EventData:
	var effect := DemandBiasEffect.new()
	effect.category = GameEnums.Category.WEAPON
	effect.delta = 0.5
	var event := EventData.new()
	event.id = &"war"
	event.duration_days = duration
	event.effects = [effect]
	return event

func test_start_applies_effect() -> void:
	var engine := EventEngine.new()
	var demand := _demand()
	var before := demand.get_multiplier(GameEnums.Category.WEAPON)
	engine.start(_war_event(2), demand)
	assert_true(demand.get_multiplier(GameEnums.Category.WEAPON) > before, "el evento sube la demanda de armas")
	assert_eq(engine.active_events().size(), 1)

func test_event_ends_and_reverts() -> void:
	var engine := EventEngine.new()
	var demand := _demand()
	var neutral := demand.get_multiplier(GameEnums.Category.WEAPON)
	engine.start(_war_event(2), demand)
	engine.advance_day(demand)  # remaining 1
	assert_eq(engine.active_events().size(), 1, "sigue activo tras 1 día")
	var ended := engine.advance_day(demand)  # remaining 0 -> termina
	assert_eq(ended.size(), 1)
	assert_eq(engine.active_events().size(), 0)
	assert_almost_eq(demand.get_multiplier(GameEnums.Category.WEAPON), neutral, 0.0001, "al terminar, la demanda vuelve")
