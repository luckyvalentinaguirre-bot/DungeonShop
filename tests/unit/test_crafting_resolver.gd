extends Test
## Tests de CraftingResolver (fabricación combinando rasgos). Ver docs/systems/05_Crafting.md.

func _db() -> ItemDatabase:
	var db := ItemDatabase.new()
	db.load_all()
	return db

func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 100
	return rng

func _recipe(output_id: StringName) -> RecipeData:
	var r := RecipeData.new()
	r.output_item_id = output_id
	r.base_quality_score = 2.0
	r.base_defect_chance = 0.0
	r.required_categories = [GameEnums.Category.MATERIAL]
	r.required_quantities = [2]
	return r

func _trait(qbonus: float, dchance: float, attrs: Dictionary) -> MaterialTrait:
	var t := MaterialTrait.new()
	t.quality_bonus = qbonus
	t.defect_chance_delta = dchance
	t.attributes = attrs
	return t

func _material(traits: Array) -> ItemData:
	var d := ItemData.new()
	d.category = GameEnums.Category.MATERIAL
	d.material_traits = traits
	return d

func _two(material: ItemData) -> Array:
	return [ItemInstance.new(material, 0, 1), ItemInstance.new(material, 0, 1)]

func test_craft_succeeds_with_enough_materials() -> void:
	var mat := _material([_trait(0.0, 0.0, {})])
	var r := CraftingResolver.craft(_recipe(&"weapon_short_sword"), _two(mat), null, _db(), _rng())
	assert_true(r.success)
	assert_eq(r.output.data.id, &"weapon_short_sword", "produce el objeto de salida de la receta")

func test_missing_materials_fails() -> void:
	var mat := _material([])
	var r := CraftingResolver.craft(_recipe(&"weapon_short_sword"), [ItemInstance.new(mat, 0, 1)], null, _db(), _rng())
	assert_false(r.success)
	assert_eq(r.reason, "missing_materials")

func test_unknown_output_fails() -> void:
	var mat := _material([])
	var r := CraftingResolver.craft(_recipe(&"does_not_exist"), _two(mat), null, _db(), _rng())
	assert_false(r.success)
	assert_eq(r.reason, "unknown_output")

func test_traits_aggregate_into_attributes() -> void:
	var mat := _material([_trait(0.0, 0.0, {"edge": 2, "durability": -1})])
	var r := CraftingResolver.craft(_recipe(&"weapon_short_sword"), _two(mat), null, _db(), _rng())
	assert_true(r.success)
	# Dos unidades del mismo material => el rasgo se aplica dos veces.
	assert_eq(int(r.output.attributes.get("edge", 0)), 4)
	assert_eq(int(r.output.attributes.get("durability", 0)), -2)

func test_more_quality_bonus_yields_higher_quality() -> void:
	var low := CraftingResolver.craft(_recipe(&"weapon_short_sword"), _two(_material([_trait(0.0, 0.0, {})])), null, _db(), _rng())
	var high := CraftingResolver.craft(_recipe(&"weapon_short_sword"), _two(_material([_trait(1.5, 0.0, {})])), null, _db(), _rng())
	assert_true(high.quality >= low.quality, "mejores rasgos => igual o mejor calidad (mismo seed)")

func test_no_defect_when_chance_zero() -> void:
	var mat := _material([_trait(0.0, 0.0, {})])
	var r := CraftingResolver.craft(_recipe(&"weapon_short_sword"), _two(mat), null, _db(), _rng())
	assert_false(r.output.defect, "con probabilidad de defecto 0 nunca sale defectuoso")
