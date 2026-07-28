extends Test
## Tests de QualityCalculator. Ver docs/systems/05_Crafting.md.

func test_quality_rounds_and_clamps() -> void:
	assert_eq(QualityCalculator.quality_from_score(2.4), 2)
	assert_eq(QualityCalculator.quality_from_score(2.6), 3)
	assert_eq(QualityCalculator.quality_from_score(-1.0), 0, "no baja de 0")
	assert_eq(QualityCalculator.quality_from_score(9.0), 5, "no sube de 5")

func test_defect_chance_bounds() -> void:
	assert_almost_eq(QualityCalculator.defect_chance(0.0, -1.0, 0.0), 0.0, 0.0001, "no baja de 0")
	assert_almost_eq(QualityCalculator.defect_chance(2.0, 0.0, 0.0), 0.95, 0.0001, "no sube de 0.95")

func test_volatility_raises_defect_chance() -> void:
	var base := QualityCalculator.defect_chance(0.05, 0.0, 0.0)
	var volatile := QualityCalculator.defect_chance(0.05, 0.2, 0.0)
	assert_true(volatile > base, "la volatilidad sube la probabilidad de defecto")

func test_station_reduces_defect_chance() -> void:
	var without := QualityCalculator.defect_chance(0.1, 0.0, 0.0)
	var with_station := QualityCalculator.defect_chance(0.1, 0.0, 0.05)
	assert_true(with_station < without, "una mejor estación reduce el defecto")
