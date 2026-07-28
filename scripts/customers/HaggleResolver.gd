class_name HaggleResolver
extends RefCounted
## Resuelve si un cliente acepta un precio (regateo AUTOMÁTICO POR ÁNIMO, decisión
## de Fase 3). Puro y testeable: sin estado, sin UI. Un cliente tolera pagar por
## encima del precio justo un margen que crece con su ánimo, y nunca por encima de
## su presupuesto. Ver docs/systems/02_Customers.md §7 y docs/systems/01_Economy.md.

## Resultado de evaluar una oferta.
class Result:
	var accepted: bool = false
	## Cambio de ánimo resultante (una ganga sube el ánimo; caro-pero-aceptado lo baja).
	var mood_delta: float = 0.0
	var reason: String = ""

## Evalúa una oferta de venta.
## - offered_price: precio que pide el jugador.
## - fair_price: precio justo/sugerido (ver EconomySystem.suggested_price).
## - budget: máximo que el cliente puede pagar.
## - mood: ánimo del cliente 0..1.
static func evaluate(offered_price: int, fair_price: int, budget: int, mood: float, config: EconomyConfig) -> Result:
	var r := Result.new()
	if offered_price > budget:
		r.accepted = false
		r.mood_delta = -0.15
		r.reason = "over_budget"
		return r
	var fair: int = maxi(1, fair_price)
	# Desviación relativa sobre el precio justo (>0 = más caro que lo justo).
	var over_ratio: float = float(offered_price - fair) / float(fair)
	# Con ánimo neutro (0.5) la tolerancia es la base; sube con el ánimo.
	var tolerance: float = config.haggle_tolerance * (0.5 + mood)
	if over_ratio <= tolerance:
		r.accepted = true
		r.mood_delta = clampf(-over_ratio, -0.2, 0.2)
		r.reason = "accepted"
	else:
		r.accepted = false
		r.mood_delta = -0.1
		r.reason = "too_expensive"
	return r
