class_name EconomySystem
extends Node
## Fachada del subsistema económico: coordina demanda, mercado y transacciones, y
## expone una API mínima al resto del juego. Tras cada operación reenvía una señal
## global al EventBus (si el autoload existe), manteniendo el bajo acoplamiento.
## Ver docs/systems/01_Economy.md §8 y docs/systems/00_Architecture.md §5.

## Señal local (siempre disponible, también en tests sin autoloads).
signal sale_completed(item_data: ItemData, price: int, buyer: Object)

var config: EconomyConfig
var demand: DemandModel
var market: MarketSystem

## Inicializa el subsistema con la configuración y una semilla de partida.
func setup(p_config: EconomyConfig, rng_seed: int = 0) -> void:
	config = p_config
	demand = DemandModel.new(config)
	market = MarketSystem.new()
	market.name = "MarketSystem"
	add_child(market)
	market.setup(config, rng_seed)

## Precio sugerido de venta de un objeto según la demanda actual y modificadores
## opcionales de reputación/evento (1.0 = sin efecto).
func suggested_price(item: ItemInstance, reputation_mult: float = 1.0, event_mult: float = 1.0) -> int:
	if item == null or item.data == null:
		return 0
	var d: float = demand.get_multiplier(item.data.category)
	return PriceCalculator.suggested_price(item.data, item.quality, d, reputation_mult, event_mult, config)

## Vende un objeto de 'buyer' a 'seller' por 'price'. Devuelve el resultado de la
## transacción y, si tiene éxito, emite señales (local + EventBus).
func sell(item: ItemInstance, price: int, buyer: WalletComponent, seller: WalletComponent) -> TransactionResolver.Result:
	var result := TransactionResolver.resolve_sale(item, price, buyer, seller, demand)
	if result.success:
		sale_completed.emit(item.data, price, buyer)
		var bus := _event_bus()
		if bus != null:
			# emit_signal por nombre: evita acoplar el tipo estático a EventBus.
			bus.emit_signal("item_sold", item.data, price, buyer)
	return result

## Localiza el autoload EventBus sin depender del identificador global (así los
## tests headless, que no cargan autoloads, no fallan).
func _event_bus() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("EventBus")
