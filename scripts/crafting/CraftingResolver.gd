class_name CraftingResolver
extends RefCounted
## Resuelve una fabricación: valida que los materiales cubren las ranuras de la
## receta, combina sus RASGOS en un perfil, y produce el objeto con calidad y posible
## defecto. Puro y testeable (dado el mismo input y semilla, mismo resultado). NO
## consume el inventario (eso lo hace quien llama, como en las ventas). Ver
## docs/systems/05_Crafting.md §5.

class Result:
	var success: bool = false
	var output: ItemInstance = null
	var quality: int = 0
	var defect: bool = false
	var reason: String = ""

## Fabrica a partir de una receta, unos materiales elegidos, una estación, el
## catálogo (para resolver el objeto de salida) y un RNG sembrado.
static func craft(recipe: RecipeData, materials: Array, station: CraftingStationData, database: ItemDatabase, rng: RandomNumberGenerator, skill_quality_bonus: float = 0.0, skill_defect_reduction: float = 0.0) -> Result:
	var r := Result.new()
	if recipe == null:
		r.reason = "no_recipe"
		return r
	if not _satisfies_slots(recipe, materials):
		r.reason = "missing_materials"
		return r

	# Combina los rasgos de todos los materiales de entrada.
	var quality_bonus: float = 0.0
	var defect_delta: float = 0.0
	var attributes: Dictionary = {}
	var applied_traits: Array = []
	for m in materials:
		if m == null or m.data == null:
			continue
		for t in m.data.material_traits:
			applied_traits.append(t)
			quality_bonus += t.quality_bonus
			defect_delta += t.defect_chance_delta
			for key in t.attributes.keys():
				attributes[key] = attributes.get(key, 0) + t.attributes[key]

	var station_qbonus: float = station.quality_bonus() if station != null else 0.0
	var station_dreduction: float = station.defect_reduction() if station != null else 0.0

	var jitter: float = rng.randf_range(-0.25, 0.25)
	var score: float = recipe.base_quality_score + quality_bonus + station_qbonus + skill_quality_bonus + jitter
	var quality: int = QualityCalculator.quality_from_score(score)
	var dchance: float = QualityCalculator.defect_chance(recipe.base_defect_chance, defect_delta, station_dreduction + skill_defect_reduction)
	var defect: bool = rng.randf() < dchance

	var base_data: ItemData = database.get_item(recipe.output_item_id) if database != null else null
	if base_data == null:
		r.reason = "unknown_output"
		return r

	var out := ItemInstance.new(base_data, quality, 1)
	out.traits = applied_traits
	out.attributes = attributes
	out.defect = defect

	r.success = true
	r.output = out
	r.quality = quality
	r.defect = defect
	r.reason = "crafted"
	return r

## ¿Los materiales elegidos son suficientes para la receta? (comprobación pública
## para que la UI pueda habilitar/deshabilitar el botón de fabricar).
static func satisfies(recipe: RecipeData, materials: Array) -> bool:
	if recipe == null:
		return false
	return _satisfies_slots(recipe, materials)

## ¿Los materiales aportados cubren todas las ranuras (categoría + cantidad)?
static func _satisfies_slots(recipe: RecipeData, materials: Array) -> bool:
	var provided: Dictionary = {}
	for m in materials:
		if m == null or m.data == null:
			continue
		var cat: int = m.data.category
		provided[cat] = provided.get(cat, 0) + m.quantity
	var slot_count: int = mini(recipe.required_categories.size(), recipe.required_quantities.size())
	for i in slot_count:
		var cat: int = int(recipe.required_categories[i])
		var qty: int = int(recipe.required_quantities[i])
		if int(provided.get(cat, 0)) < qty:
			return false
	return true
