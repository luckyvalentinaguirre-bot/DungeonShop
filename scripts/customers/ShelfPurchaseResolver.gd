class_name ShelfPurchaseResolver
extends RefCounted
## Resuelve la compra AUTÓNOMA de un cliente que va directo a la estantería (vía
## SHELF del modelo híbrido): sin regateo, compra al precio expuesto si encuentra un
## producto que cumple su necesidad y su presupuesto. Puro y testeable.
##
## Los productos expuestos se pasan como una lista de ofertas
## [{ "item": ItemInstance, "price": int }, ...]. En la Fase 5 esa lista vendrá del
## contenedor real de la estantería (ver docs/systems/09_Inventory.md).
## Ver docs/systems/02_Customers.md §3.

## Resultado de intentar comprar de la estantería.
class Result:
	var bought: bool = false
	var item: ItemInstance = null
	var price: int = 0
	var reason: String = ""

## Busca el producto expuesto más barato que satisface la necesidad y lo compra.
static func resolve(need: CustomerNeed, offers: Array, buyer: WalletComponent, seller: WalletComponent, demand: DemandModel) -> Result:
	var r := Result.new()
	var best_item: ItemInstance = null
	var best_price: int = 0
	for offer in offers:
		var item: ItemInstance = offer.get("item")
		var price: int = int(offer.get("price", 0))
		if item == null or item.data == null:
			continue
		if item.data.category != need.category:
			continue
		if item.quality < need.min_quality:
			continue
		if price > need.budget or not buyer.can_afford(price):
			continue
		if best_item == null or price < best_price:
			best_item = item
			best_price = price
	if best_item == null:
		r.reason = "no_match"
		return r
	var sale := TransactionResolver.resolve_sale(best_item, best_price, buyer, seller, demand)
	r.bought = sale.success
	r.item = best_item
	r.price = best_price
	r.reason = "bought" if sale.success else sale.reason
	return r
