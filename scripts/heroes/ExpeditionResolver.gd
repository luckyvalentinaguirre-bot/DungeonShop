class_name ExpeditionResolver
extends RefCounted
## Resuelve una expedición FUERA DE CÁMARA a partir del equipo que le vendiste al
## héroe, la dificultad del reto, su nivel y azar acotado. Puro y determinista con
## la misma semilla (clave para balancear y testear). Ver docs/systems/03_Heroes.md §4.

## Poder de combate del equipo: mejor calidad y buenos atributos suman; los defectos
## restan (una espada frágil puede costarle la vida al héroe).
static func equipment_power(items: Array) -> float:
	var power: float = 0.0
	for it in items:
		if it == null or it.data == null:
			continue
		power += 1.0 + float(it.quality)
		if it.defect:
			power -= 1.5
		for value in it.attributes.values():
			power += float(value) * 0.1
	return maxf(0.0, power)

## Calcula el resultado de la expedición (gradiente triunfo→baja).
static func resolve(power: float, difficulty: float, hero_level: int, rng: RandomNumberGenerator) -> ExpeditionOutcome:
	var o := ExpeditionOutcome.new()
	var effective: float = power + float(hero_level) * 0.5 + rng.randf_range(-1.0, 1.0)
	var ratio: float = effective / maxf(1.0, difficulty)
	if ratio >= 1.3:
		o.kind = ExpeditionOutcome.Kind.TRIUMPH
		o.survived = true
		o.loot_value = int(difficulty * 12.0)
		o.loyalty_delta = 0.15
		o.narrative = "Volvió victorioso, cargado de botín."
	elif ratio >= 1.0:
		o.kind = ExpeditionOutcome.Kind.NARROW
		o.survived = true
		o.loot_value = int(difficulty * 6.0)
		o.loyalty_delta = 0.1
		o.narrative = "Regresó herido pero vivo; tu equipo le salvó la vida."
	elif ratio >= 0.6:
		o.kind = ExpeditionOutcome.Kind.RETREAT
		o.survived = true
		o.loot_value = 0
		o.loyalty_delta = -0.1
		o.narrative = "Tuvo que retirarse sin botín."
	else:
		o.kind = ExpeditionOutcome.Kind.LOST
		o.survived = false
		o.loot_value = 0
		o.loyalty_delta = 0.0
		o.narrative = "No regresó de las Grietas. Su equipo no bastó."
	return o
