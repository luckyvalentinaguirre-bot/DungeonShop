extends Test
## Tests de MoodComponent. Ver docs/systems/02_Customers.md.

func test_default_is_neutral() -> void:
	assert_almost_eq(MoodComponent.new().value, 0.5)

func test_adjust_changes_value() -> void:
	var m := MoodComponent.new()
	m.adjust(0.2)
	assert_almost_eq(m.value, 0.7)

func test_clamped_to_one() -> void:
	var m := MoodComponent.new()
	m.adjust(5.0)
	assert_almost_eq(m.value, 1.0)

func test_clamped_to_zero() -> void:
	var m := MoodComponent.new()
	m.adjust(-5.0)
	assert_almost_eq(m.value, 0.0)
