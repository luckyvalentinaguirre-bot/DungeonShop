extends Test
## Tests de PlayerSkills (aprender haciendo). Ver docs/systems/06_Progression.md.

func test_starts_at_level_one() -> void:
	var s := PlayerSkills.new()
	assert_eq(s.level_of(PlayerSkills.SMITHING), 1)

func test_xp_accumulates() -> void:
	var s := PlayerSkills.new()
	var leveled := s.add_xp(PlayerSkills.SMITHING, 40)
	assert_false(leveled, "40 xp no bastan para el nivel 2 (umbral 100)")
	assert_eq(s.xp_of(PlayerSkills.SMITHING), 40)

func test_levels_up_past_threshold() -> void:
	var s := PlayerSkills.new()
	var leveled := s.add_xp(PlayerSkills.SMITHING, 100)
	assert_true(leveled)
	assert_eq(s.level_of(PlayerSkills.SMITHING), 2)

func test_quality_bonus_grows_with_level() -> void:
	var s := PlayerSkills.new()
	var base := s.quality_bonus(PlayerSkills.SMITHING)
	s.add_xp(PlayerSkills.SMITHING, 100)
	assert_true(s.quality_bonus(PlayerSkills.SMITHING) > base, "más nivel => más bonus de calidad")

func test_save_roundtrip() -> void:
	var s := PlayerSkills.new()
	s.add_xp(PlayerSkills.SMITHING, 150)
	var data := s.capture_state()
	var s2 := PlayerSkills.new()
	s2.restore_state(data)
	assert_eq(s2.level_of(PlayerSkills.SMITHING), s.level_of(PlayerSkills.SMITHING))
	assert_eq(s2.xp_of(PlayerSkills.SMITHING), s.xp_of(PlayerSkills.SMITHING))
