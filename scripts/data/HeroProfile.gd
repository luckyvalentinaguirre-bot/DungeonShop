class_name HeroProfile
extends Resource
## Datos de un héroe. Los héroes compran como clientes y además parten a expediciones
## cuyo resultado depende del equipo que les vendiste. Ver docs/systems/03_Heroes.md.

@export var id: StringName = &""
@export var display_name: String = ""
@export var profession: ProfessionData
@export var level: int = 1
## Lealtad hacia la tienda (0..1): sube al equiparle bien.
@export_range(0.0, 1.0) var loyalty: float = 0.2
@export var traits: Array = []
