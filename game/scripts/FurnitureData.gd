class_name FurnitureData
extends Resource
## Datos de un mueble modular de la tienda. DATA-DRIVEN: describe su sprite, que
## categorias de objeto admite y sus PUNTOS DE COLOCACION (donde se posan los sprites
## de los objetos expuestos). Asi, "estanteria + sprite del objeto = objeto expuesto"
## sin dibujar cada combinacion. Ver el mensaje-guia del diseñador, puntos 6 y 7.
##
## Se puede crear por codigo (FurnitureCatalog) o como .tres en el editor.

@export var id: StringName = &""
@export var display_name: String = ""
## ShopEnums.FurnitureKind (int, sin tipar para evitar problemas de export de enums).
@export var kind: int = ShopEnums.FurnitureKind.SHELF
@export var texture_path: String = ""

## Categorias de objeto que este mueble puede contener (ShopEnums.Category). Vacio =
## cualquiera. Sin tipar a Array[int] a proposito (asignacion de arrays tipados es
## fragil en GDScript).
@export var allowed_categories: Array = []

## Puntos de colocacion, en coordenadas LOCALES respecto al PIE del mueble (Vector2).
## Cada uno es un hueco donde se posa el sprite de un objeto expuesto.
@export var slots: Array = []

## Tamaño (px) al que se ajusta el sprite del objeto en cada hueco.
@export var slot_size: float = 44.0

## Ancho/alto aproximado del mueble en px (para colisiones/colocacion futura).
@export var size: Vector2 = Vector2(160, 150)

func can_hold(category: int) -> bool:
	return allowed_categories.is_empty() or allowed_categories.has(category)

func slot_count() -> int:
	return slots.size()
