class_name CraftingStationData
extends Resource
## Definición de una estación de fabricación (yunque, alambique, mesa de encantar…).
## Su nivel mejora la calidad y reduce los defectos. Ver docs/systems/05_Crafting.md §2.

@export var id: StringName = &""
@export var display_name: String = ""
## Nivel de la estación (mejorable). Escala los bonus.
@export var level: int = 1
## Bonus de calidad por nivel.
@export var quality_bonus_per_level: float = 0.3
## Reducción de probabilidad de defecto por nivel.
@export var defect_reduction_per_level: float = 0.02

func quality_bonus() -> float:
	return quality_bonus_per_level * float(level)

func defect_reduction() -> float:
	return defect_reduction_per_level * float(level)
