class_name DemandBiasEffect
extends EventEffect
## Sesga la demanda de una categoría mientras el evento está activo (p. ej. una guerra
## sube la demanda de armas). Ver docs/systems/07_Events.md.

@export var category: GameEnums.Category = GameEnums.Category.WEAPON
@export var delta: float = 0.3

func apply(demand: DemandModel) -> void:
	if demand != null:
		demand.apply_bias(category, delta)

func revert(demand: DemandModel) -> void:
	if demand != null:
		demand.apply_bias(category, -delta)
