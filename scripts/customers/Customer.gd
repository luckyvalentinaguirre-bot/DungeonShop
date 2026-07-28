class_name Customer
extends RefCounted
## Agregado en tiempo de ejecución de un cliente presente en la tienda: combina su
## plantilla (CustomerData), su necesidad de hoy (CustomerNeed) y sus componentes
## de cartera y ánimo. Composición pura, sin herencia. Ver docs/systems/02_Customers.md §2.

var data: CustomerData
var need: CustomerNeed
var wallet: WalletComponent
var mood: MoodComponent

func _init(p_data: CustomerData, p_need: CustomerNeed, p_wallet: WalletComponent, p_mood: MoodComponent) -> void:
	data = p_data
	need = p_need
	wallet = p_wallet
	mood = p_mood

func display_name() -> String:
	return data.display_name if data != null else "Cliente"
