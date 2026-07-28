class_name HeroManager
extends RefCounted
## Rastrea a los héroes del reino y resuelve sus expediciones. Al volver, aplica
## lealtad y nivel según el resultado. Ver docs/systems/03_Heroes.md.

var heroes: Array = []  # HeroProfile

func add(hero: HeroProfile) -> void:
	if hero != null:
		heroes.append(hero)

## Envía a un héroe a una expedición con el equipo dado y aplica el resultado.
func send(hero: HeroProfile, expedition: ExpeditionData, equipment: Array, rng: RandomNumberGenerator) -> ExpeditionOutcome:
	var power := ExpeditionResolver.equipment_power(equipment)
	var outcome := ExpeditionResolver.resolve(power, expedition.difficulty, hero.level, rng)
	hero.loyalty = clampf(hero.loyalty + outcome.loyalty_delta, 0.0, 1.0)
	if outcome.kind == ExpeditionOutcome.Kind.TRIUMPH:
		hero.level += 1
	elif outcome.kind == ExpeditionOutcome.Kind.LOST:
		heroes.erase(hero)
	return outcome
