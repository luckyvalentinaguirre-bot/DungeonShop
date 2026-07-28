class_name QualityCalculator
extends RefCounted
## Deriva la calidad final (0..5) y la probabilidad de defecto de una fabricación.
## Puro y testeable. Ver docs/systems/05_Crafting.md §4.

## Convierte una puntuación de calidad continua en un nivel entero 0..5.
static func quality_from_score(score: float) -> int:
	return clampi(int(round(score)), 0, 5)

## Probabilidad de defecto (0..0.95) a partir de la base de la receta, el aporte de
## los rasgos y la reducción de la estación.
static func defect_chance(base: float, trait_delta: float, station_reduction: float) -> float:
	return clampf(base + trait_delta - station_reduction, 0.0, 0.95)
