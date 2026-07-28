extends Test
## Tests de AchievementSystem. Ver docs/systems/12_Achievements.md.

func _ach(id: StringName, stat: StringName, target: int) -> AchievementData:
	var a := AchievementData.new()
	a.id = id
	a.stat = stat
	a.target = target
	return a

func test_unlocks_when_target_reached() -> void:
	var sys := AchievementSystem.new()
	var a := _ach(&"rich", &"gold_earned", 100)
	sys.register([a])
	assert_true(sys.record(&"gold_earned", 50).is_empty(), "50 < 100")
	var newly := sys.record(&"gold_earned", 60)
	assert_eq(newly.size(), 1)
	assert_true(sys.is_unlocked(a))

func test_does_not_unlock_twice() -> void:
	var sys := AchievementSystem.new()
	sys.register([_ach(&"seller", &"items_sold", 1)])
	assert_eq(sys.record(&"items_sold", 1).size(), 1)
	assert_true(sys.record(&"items_sold", 5).is_empty(), "no se vuelve a desbloquear")
