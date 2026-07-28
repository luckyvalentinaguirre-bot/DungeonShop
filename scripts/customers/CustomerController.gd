class_name CustomerController
extends RefCounted
## Máquina de estados de UNA visita atendida en el mostrador (vía COUNTER del modelo
## híbrido). Coordina presentar la necesidad, recibir la oferta del jugador, resolver
## el regateo por ánimo y ejecutar la venta contra la economía. Sin UI: emite señales
## locales. Ver docs/systems/02_Customers.md §6-7.

signal need_presented(need: CustomerNeed)
signal visit_finished(happy: bool)

enum State { WAITING, PRESENTING, AWAITING_OFFER, DONE_HAPPY, DONE_UNHAPPY }

## Resultado de una oferta del jugador.
class OfferResult:
	var accepted: bool = false
	var sold: bool = false
	var price: int = 0
	var reason: String = ""
	var mood_after: float = 0.0

var customer: Customer
var state: State = State.WAITING

func _init(p_customer: Customer) -> void:
	customer = p_customer

## El cliente expone lo que quiere. Devuelve su necesidad y queda a la espera de oferta.
func present_need() -> CustomerNeed:
	state = State.AWAITING_OFFER
	need_presented.emit(customer.need)
	return customer.need

## El jugador ofrece 'item' por 'price'. Resuelve match de necesidad + regateo + venta.
func receive_offer(item: ItemInstance, price: int, economy: EconomySystem, player_wallet: WalletComponent) -> OfferResult:
	var out := OfferResult.new()
	out.price = price
	if state != State.AWAITING_OFFER:
		out.reason = "not_awaiting_offer"
		out.mood_after = customer.mood.value
		return out
	if not _matches_need(item):
		customer.mood.adjust(-0.05)
		out.reason = "wrong_item"
		out.mood_after = customer.mood.value
		return out

	var fair: int = economy.suggested_price(item)
	var haggle := HaggleResolver.evaluate(price, fair, customer.need.budget, customer.mood.value, economy.config)
	customer.mood.adjust(haggle.mood_delta)
	out.accepted = haggle.accepted
	out.mood_after = customer.mood.value

	if haggle.accepted:
		var sale := economy.sell(item, price, customer.wallet, player_wallet)
		out.sold = sale.success
		out.reason = "sold" if sale.success else sale.reason
		state = State.DONE_HAPPY if sale.success else State.DONE_UNHAPPY
	else:
		out.reason = haggle.reason
		state = State.DONE_UNHAPPY

	visit_finished.emit(state == State.DONE_HAPPY)
	return out

func is_finished() -> bool:
	return state == State.DONE_HAPPY or state == State.DONE_UNHAPPY

func _matches_need(item: ItemInstance) -> bool:
	if item == null or item.data == null:
		return false
	return item.data.category == customer.need.category and item.quality >= customer.need.min_quality
