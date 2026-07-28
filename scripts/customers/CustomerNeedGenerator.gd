class_name CustomerNeedGenerator
extends RefCounted
## Genera la necesidad de una visita a partir de la plantilla del cliente y un RNG
## sembrado (determinista y testeable). Ver docs/systems/02_Customers.md §5.

## Categoría por defecto si la plantilla no declara preferencias.
const DEFAULT_CATEGORY := GameEnums.Category.POTION

static func generate(data: CustomerData, rng: RandomNumberGenerator) -> CustomerNeed:
	var need := CustomerNeed.new()
	need.category = _pick_category(data, rng)
	need.budget = rng.randi_range(data.budget_min, data.budget_max)
	need.min_quality = rng.randi_range(0, 2)
	need.flexibility = clampf(0.5 + rng.randf_range(-0.2, 0.2), 0.0, 1.0)
	need.intent = CustomerNeed.Intent.SHELF if rng.randf() < data.shelf_preference else CustomerNeed.Intent.COUNTER
	return need

static func _pick_category(data: CustomerData, rng: RandomNumberGenerator) -> GameEnums.Category:
	if data.preferred_categories.is_empty():
		return DEFAULT_CATEGORY
	var idx: int = rng.randi() % data.preferred_categories.size()
	return data.preferred_categories[idx]
