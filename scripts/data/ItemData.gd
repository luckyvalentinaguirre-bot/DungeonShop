class_name ItemData
extends Resource
## Plantilla inmutable de un objeto. Versión mínima de la Fase 3 (economía):
## contiene solo lo necesario para tasar y comerciar. Se amplía en la Fase 5
## (rasgos de material, icono, tags de adecuación...). Ver docs/Items.md.

## Identificador único y estable (p. ej. &"weapon_short_sword").
@export var id: StringName = &""
## Nombre visible; en producción será una clave de localización.
@export var display_name: String = ""
## Categoría del objeto (ver GameEnums.Category).
@export var category: GameEnums.Category = GameEnums.Category.MATERIAL
## Valor base en coronas: punto de partida del precio (ver docs/Economy.md).
@export var base_value: int = 1
## Rareza (afecta a valor y disponibilidad).
@export var rarity: GameEnums.Rarity = GameEnums.Rarity.COMMON
## ¿Se puede apilar en el inventario? (materiales/consumibles sí).
@export var stackable: bool = false
## Tamaño máximo de pila cuando es apilable.
@export var max_stack: int = 1
## Etiquetas libres para adecuación con héroes/clientes (p. ej. &"ligero",
## &"arcano"). Se explota en la Fase 3-héroes/Fase 6. Ver docs/systems/03_Heroes.md.
@export var tags: Array = []
