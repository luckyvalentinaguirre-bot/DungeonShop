extends Test
## Test de guardado: captura -> JSON -> restauración conserva el estado.
## Ver docs/systems/08_Save.md. Es un test de integración ligero de GameState.

const GameStateScript = preload("res://scripts/managers/GameState.gd")

func _new_state():
	var gs = GameStateScript.new()
	gs.new_game()
	return gs

func test_capture_restore_preserves_core_state() -> void:
	var gs = _new_state()
	gs.day = 7
	gs.player_wallet.balance = 1234
	gs.skills.add_xp(PlayerSkills.SMITHING, 120)  # sube a nivel 2
	gs.reputation.register_sale(GameEnums.Faction.GUILD, 0.9)

	# Captura -> JSON -> parse (simula el paso por disco).
	var text := JSON.stringify(gs.capture_state())
	var parsed = JSON.parse_string(text)
	assert_true(typeof(parsed) == TYPE_DICTIONARY, "el guardado es un diccionario JSON válido")

	var gs2 = _new_state()
	gs2.restore_state(parsed)
	assert_eq(gs2.day, 7, "conserva la jornada")
	assert_eq(gs2.gold(), 1234, "conserva el oro")
	assert_eq(gs2.skills.level_of(PlayerSkills.SMITHING), 2, "conserva el nivel de herrería")
	assert_true(gs2.reputation.affinity_of(GameEnums.Faction.GUILD) > 0.0, "conserva la reputación")
	gs.free()
	gs2.free()

func test_stock_survives_save() -> void:
	var gs = _new_state()
	var before := gs.stock.count(&"weapon_short_sword")
	var text := JSON.stringify(gs.capture_state())
	var gs2 = _new_state()
	gs2.restore_state(JSON.parse_string(text))
	assert_eq(gs2.stock.count(&"weapon_short_sword"), before, "el stock se conserva")
	gs.free()
	gs2.free()
