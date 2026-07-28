class_name TransactionResolver
extends RefCounted
## Ejecuta ventas: mueve oro entre carteras y actualiza la demanda. Puro respecto
## a la UI y sin emitir señales (eso lo hace EconomySystem tras recibir el
## resultado), para mantener esta clase 100% testeable.
##
## NOTA DE ALCANCE (Fase 3): aquí solo se mueve el DINERO. El movimiento del
## objeto entre inventarios es responsabilidad del sistema de inventario (Fase 5);
## se integrará entonces. Ver docs/systems/01_Economy.md §6 y §09_Inventory.

## Resultado estructurado de una transacción.
class Result:
	var success: bool = false
	var reason: String = ""
	var price: int = 0

## Resuelve una venta: 'buyer' paga 'price' a 'seller' por 'item'. Si se pasa un
## DemandModel, registra la venta para actualizar la demanda de la categoría.
static func resolve_sale(
		item: ItemInstance,
		price: int,
		buyer: WalletComponent,
		seller: WalletComponent,
		demand: DemandModel) -> Result:
	var r := Result.new()
	r.price = price
	if item == null or item.data == null or buyer == null or seller == null:
		r.reason = "invalid_arguments"
		return r
	if price < 0:
		r.reason = "negative_price"
		return r
	if not buyer.can_afford(price):
		r.reason = "buyer_cannot_afford"
		return r
	buyer.pay(price)
	seller.receive(price)
	if demand != null:
		demand.register_sale(item.data.category, item.quantity)
	r.success = true
	return r
