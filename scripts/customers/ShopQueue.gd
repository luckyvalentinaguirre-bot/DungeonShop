class_name ShopQueue
extends RefCounted
## Cola del mostrador (vía COUNTER del modelo híbrido): se atiende a un cliente cada
## vez; los demás esperan y pierden paciencia (ánimo) con el tiempo. Sin UI.
## Ver docs/systems/02_Customers.md §6.

var _waiting: Array[CustomerController] = []

## Añade un cliente al final de la cola.
func enqueue(controller: CustomerController) -> void:
	if controller != null:
		_waiting.append(controller)

## Cliente que se está atendiendo ahora (el primero), o null si la cola está vacía.
func current() -> CustomerController:
	return _waiting[0] if not _waiting.is_empty() else null

## Retira al cliente atendido (visita terminada) y pasa al siguiente.
func advance() -> void:
	if not _waiting.is_empty():
		_waiting.pop_front()

func size() -> int:
	return _waiting.size()

func is_empty() -> bool:
	return _waiting.is_empty()

## Los que esperan detrás del actual pierden un poco de paciencia (ánimo).
func decay_patience(amount: float) -> void:
	for i in range(1, _waiting.size()):
		_waiting[i].customer.mood.adjust(-amount)
