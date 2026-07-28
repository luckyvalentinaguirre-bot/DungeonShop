extends Test
## Tests de ReputationSystem. Ver docs/systems/04_Reputation.md.

func test_sale_raises_prestige_and_affinity() -> void:
	var r := ReputationSystem.new()
	r.register_sale(GameEnums.Faction.GUILD, 0.9)
	assert_true(r.prestige() > 0.0, "una venta contenta sube el prestigio")
	assert_true(r.affinity_of(GameEnums.Faction.GUILD) > 0.0)

func test_tension_lowers_rival() -> void:
	var r := ReputationSystem.new()
	# Corona y Buhoneros están enfrentados.
	r.add_affinity(GameEnums.Faction.CROWN, 2.0)
	assert_true(r.affinity_of(GameEnums.Faction.PEDDLERS) < 0.0, "subir con Corona resta a Buhoneros")

func test_rivals_lookup() -> void:
	var r := ReputationSystem.new()
	assert_true(r.rivals_of(GameEnums.Faction.GUILD).has(GameEnums.Faction.ARTISANS))

func test_save_roundtrip() -> void:
	var r := ReputationSystem.new()
	r.register_sale(GameEnums.Faction.ARCANE, 0.8)
	var data := r.capture_state()
	var r2 := ReputationSystem.new()
	r2.restore_state(data)
	assert_almost_eq(r2.prestige(), r.prestige())
	assert_almost_eq(r2.affinity_of(GameEnums.Faction.ARCANE), r.affinity_of(GameEnums.Faction.ARCANE))
