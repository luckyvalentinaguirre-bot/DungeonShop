extends Test
## Tests de QuestSystem. Ver docs/systems/11_Quests.md.

func _quest(stat: StringName, target: int) -> QuestData:
	var obj := QuestObjective.new()
	obj.stat = stat
	obj.target = target
	var q := QuestData.new()
	q.id = &"q"
	q.objectives = [obj]
	q.reward_gold = 50
	return q

func test_quest_completes_when_target_reached() -> void:
	var qs := QuestSystem.new()
	qs.add_quest(_quest(&"items_sold", 3))
	assert_true(qs.record(&"items_sold", 2).is_empty(), "aún no se completa")
	var done := qs.record(&"items_sold", 1)
	assert_eq(done.size(), 1, "se completa al llegar al objetivo")
	assert_eq(qs.active().size(), 0)
	assert_eq(qs.completed().size(), 1)

func test_progress_is_fractional() -> void:
	var qs := QuestSystem.new()
	var q := _quest(&"items_sold", 4)
	qs.add_quest(q)
	qs.record(&"items_sold", 2)
	assert_almost_eq(qs.progress(q), 0.5, 0.001)

func test_unrelated_stat_does_not_complete() -> void:
	var qs := QuestSystem.new()
	qs.add_quest(_quest(&"items_sold", 1))
	assert_true(qs.record(&"gold_earned", 100).is_empty())
