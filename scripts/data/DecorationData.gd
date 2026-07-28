class_name DecorationData
extends Resource
## Un objeto decorativo para la tienda. Además de estético, puede aportar prestigio y
## mejorar el ánimo de la clientela. Se coloca en la cuadrícula (ShopLayout, casillas
## DECOR). Ver docs/systems/06_Progression.md §4 y docs/ArtDirection.md.

@export var id: StringName = &""
@export var display_name: String = ""
## Bonus de prestigio que aporta mientras está colocado.
@export var prestige_bonus: float = 0.0
## Bonus de ánimo base a la clientela (0..1).
@export var mood_bonus: float = 0.0
