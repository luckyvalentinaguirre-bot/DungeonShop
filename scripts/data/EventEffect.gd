class_name EventEffect
extends Resource
## Efecto componible de un evento del reino: se aplica al empezar y se revierte al
## terminar. Las subclases lo especializan (así el motor no conoce cada tipo,
## principio Abierto/Cerrado). Ver docs/systems/07_Events.md §4.

## Aplica el efecto. 'demand' es el DemandModel de la economía (puede ser null).
func apply(_demand: DemandModel) -> void:
	pass

## Revierte el efecto al terminar el evento.
func revert(_demand: DemandModel) -> void:
	pass
