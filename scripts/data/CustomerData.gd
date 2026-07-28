class_name CustomerData
extends Resource
## Plantilla de un cliente (recurrente o arquetipo genérico). Los datos concretos
## de cada visita (qué quiere hoy) se generan en un CustomerNeed. Composición: el
## cliente en juego se arma con este dato + carteras/ánimo. Ver docs/systems/02_Customers.md.

## Identificador estable (p. ej. &"npc_dona_mabel" o &"archetype_villager").
@export var id: StringName = &""
## Nombre visible (clave de localización en producción).
@export var display_name: String = ""
## Facción a la que pertenece/afecta (ver GameEnums.Faction y docs/WorldBible.md).
@export var faction: GameEnums.Faction = GameEnums.Faction.COMMONERS
## Categorías que este cliente suele querer (valores de GameEnums.Category).
## Array sin tipar a propósito: evita fricciones al asignar literales de enum.
@export var preferred_categories: Array = []
## Rango de presupuesto que trae (coronas).
@export var budget_min: int = 10
@export var budget_max: int = 40
## Ánimo base 0..1 (0 = gruñón, 0.5 = neutro, 1 = encantado).
@export_range(0.0, 1.0) var base_mood: float = 0.5
## Probabilidad 0..1 de comprar solo en la estantería (modelo híbrido) en vez de
## ir al mostrador a una venta atendida. Ver docs/systems/02_Customers.md §3.
@export_range(0.0, 1.0) var shelf_preference: float = 0.5
