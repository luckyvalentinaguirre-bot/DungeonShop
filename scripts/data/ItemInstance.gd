class_name ItemInstance
extends RefCounted
## Instancia concreta de un objeto en la partida (a diferencia de ItemData, que
## es la plantilla). Versión mínima de la Fase 3: referencia a los datos, calidad
## y cantidad. Se amplía en las Fases 5/6/9 (rasgos aplicados, durabilidad,
## defectos). Ver docs/systems/09_Inventory.md.

var data: ItemData
## Nivel de calidad 0..5 (resultado de fabricación; 0 = objeto base sin fabricar).
var quality: int = 0
## Unidades representadas por esta instancia (para objetos apilables).
var quantity: int = 1
## Rasgos de material aplicados al fabricarlo (Array[MaterialTrait]). Fase 6.
var traits: Array = []
## Perfil agregado del objeto fabricado (p. ej. {"edge": 4, "durability": -1}). Fase 6.
var attributes: Dictionary = {}
## ¿Salió defectuoso al fabricarlo? Afecta a valor y a los héroes. Fase 6.
var defect: bool = false

func _init(p_data: ItemData = null, p_quality: int = 0, p_quantity: int = 1) -> void:
	data = p_data
	quality = p_quality
	quantity = p_quantity
