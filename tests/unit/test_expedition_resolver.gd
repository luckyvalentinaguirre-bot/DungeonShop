extends Test
## Tests de ExpeditionResolver (héroes). Ver docs/systems/03_Heroes.md.

func _rng(seed_value: int = 7) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng

func _item(quality: int, defect: bool = false) -> ItemInstance:
	var d := ItemData.new()
	d.category = GameEnums.Category.WEAPON
	var inst := ItemInstance.new(d, quality, 1)
	inst.defect = defect
	return inst

func test_power_grows_with_quality() -> void:
	var low := ExpeditionResolver.equipment_power([_item(0)])
	var high := ExpeditionResolver.equipment_power([_item(5)])
	assert_true(high > low, "mejor calidad => más poder de equipo")

func test_defect_reduces_power() -> void:
	var clean := ExpeditionResolver.equipment_power([_item(3, false)])
	var faulty := ExpeditionResolver.equipment_power([_item(3, true)])
	assert_true(faulty < clean, "un objeto defectuoso resta poder")

func test_good_gear_easy_dungeon_triumphs() -> void:
	var power := ExpeditionResolver.equipment_power([_item(5), _item(5), _item(4)])
	var o := ExpeditionResolver.resolve(power, 3.0, 3, _rng())
	assert_true(o.survived)
	assert_eq(o.kind, ExpeditionOutcome.Kind.TRIUMPH)
	assert_true(o.loot_value > 0)

func test_no_gear_hard_dungeon_is_lost() -> void:
	var o := ExpeditionResolver.resolve(0.0, 20.0, 1, _rng())
	assert_false(o.survived)
	assert_eq(o.kind, ExpeditionOutcome.Kind.LOST)

func test_deterministic_same_seed() -> void:
	var a := ExpeditionResolver.resolve(5.0, 6.0, 2, _rng(42))
	var b := ExpeditionResolver.resolve(5.0, 6.0, 2, _rng(42))
	assert_eq(a.kind, b.kind, "mismo seed => mismo resultado")
