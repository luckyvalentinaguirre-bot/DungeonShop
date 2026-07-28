extends Node
## Escena de prueba de la Fase 6 (sin UI): fabrica objetos combinando materiales con
## RASGOS y muestra por consola cómo la MISMA receta produce PERFILES distintos según
## los materiales. Escena principal temporal. Ver docs/Roadmap.md (Fase 6).

func _ready() -> void:
	run_demo()

func run_demo() -> void:
	var db := ItemDatabase.new()
	db.load_all()
	var recipe := _load_recipe(db)
	var station := _load_station()
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242

	print("=== Fabricación — Dungeon Shop (Fase 6) ===")
	print("Receta: %s  |  Estación: %s (nivel %d)" % [recipe.display_name, station.display_name, station.level])

	# Materiales con rasgos opuestos, construidos para ilustrar los perfiles.
	var edge_mat := _material(&"mat_edgy", "Mineral afilado", [
		_trait(&"edge", 0.3, 0.0, {"edge": 3, "durability": -1}),
	])
	var tough_mat := _material(&"mat_tough", "Mineral tenaz", [
		_trait(&"tenacity", 0.2, -0.02, {"edge": -1, "durability": 3}),
	])
	var volatile_mat := _material(&"mat_volatile", "Esencia inestable", [
		_trait(&"volatile", 0.6, 0.25, {"arcane": 4}),
	])

	# 1) Misma receta, materiales equilibrados -> perfil equilibrado.
	_craft_and_report("Filo + Tenacidad", recipe, [
		ItemInstance.new(edge_mat, 0, 1), ItemInstance.new(tough_mat, 0, 1),
	], station, db, rng)

	# 2) Misma receta, doble filo -> perfil agresivo (mucho filo, poca durabilidad).
	_craft_and_report("Doble Filo", recipe, [
		ItemInstance.new(edge_mat, 0, 1), ItemInstance.new(edge_mat, 0, 1),
	], station, db, rng)

	# 3) Materiales volátiles -> mayor calidad potencial pero riesgo de defecto.
	_craft_and_report("Filo + Volátil", recipe, [
		ItemInstance.new(edge_mat, 0, 1), ItemInstance.new(volatile_mat, 0, 1),
	], station, db, rng)

	# 4) Faltan materiales -> la fabricación falla.
	var fail := CraftingResolver.craft(recipe, [ItemInstance.new(edge_mat, 0, 1)], station, db, rng)
	print("\nUn solo material -> éxito=%s (motivo: '%s')" % [str(fail.success), fail.reason])

	# 5) Materiales del catálogo (.tres) para mostrar fabricación data-driven.
	var steel := db.get_item(&"mat_steel")
	if steel != null:
		_craft_and_report("Acero del catálogo x2", recipe, [
			ItemInstance.new(steel, 0, 1), ItemInstance.new(steel, 0, 1),
		], station, db, rng)

	print("=== Fin de la demo ===")

func _craft_and_report(label: String, recipe: RecipeData, materials: Array, station: CraftingStationData, db: ItemDatabase, rng: RandomNumberGenerator) -> void:
	var result := CraftingResolver.craft(recipe, materials, station, db, rng)
	if not result.success:
		print("\n[%s] fabricación fallida: %s" % [label, result.reason])
		return
	var out := result.output
	print("\n[%s] -> %s | calidad %d | defecto=%s | perfil=%s" % [
		label, out.data.display_name, out.quality, str(out.defect), str(out.attributes),
	])

func _load_recipe(_db: ItemDatabase) -> RecipeData:
	var path := "res://resources/recipes/recipe_short_sword.tres"
	if ResourceLoader.exists(path):
		var res: Resource = load(path)
		if res is RecipeData:
			return res
	# Respaldo en código si el recurso no está disponible.
	var r := RecipeData.new()
	r.id = &"recipe_short_sword"
	r.display_name = "Espada corta"
	r.output_item_id = &"weapon_short_sword"
	r.base_quality_score = 2.0
	r.base_defect_chance = 0.05
	r.required_categories = [GameEnums.Category.MATERIAL]
	r.required_quantities = [2]
	return r

func _load_station() -> CraftingStationData:
	var path := "res://resources/stations/station_forge.tres"
	if ResourceLoader.exists(path):
		var res: Resource = load(path)
		if res is CraftingStationData:
			return res
	var s := CraftingStationData.new()
	s.id = &"forge"
	s.display_name = "Yunque"
	s.level = 1
	return s

func _trait(id: StringName, qbonus: float, dchance: float, attrs: Dictionary) -> MaterialTrait:
	var t := MaterialTrait.new()
	t.id = id
	t.quality_bonus = qbonus
	t.defect_chance_delta = dchance
	t.attributes = attrs
	return t

func _material(id: StringName, mat_name: String, traits: Array) -> ItemData:
	var d := ItemData.new()
	d.id = id
	d.display_name = mat_name
	d.category = GameEnums.Category.MATERIAL
	d.material_traits = traits
	return d
