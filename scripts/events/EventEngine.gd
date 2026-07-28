class_name EventEngine
extends RefCounted
## Activa y retira eventos del reino, aplicando/revirtiendo sus efectos sin conocer
## sus tipos concretos (polimorfismo por composición). Ver docs/systems/07_Events.md §5.

var _active: Array = []  # [{event, remaining}]

func active_events() -> Array:
	var out: Array = []
	for entry in _active:
		out.append(entry["event"])
	return out

func is_active(event: EventData) -> bool:
	for entry in _active:
		if entry["event"] == event:
			return true
	return false

## Empieza un evento: aplica sus efectos y lo pone en curso por su duración.
func start(event: EventData, demand: DemandModel) -> void:
	if event == null:
		return
	for effect in event.effects:
		if effect is EventEffect:
			effect.apply(demand)
	_active.append({"event": event, "remaining": event.duration_days})

## Avanza una jornada: descuenta duración y termina (revirtiendo efectos) los que
## expiran. Devuelve los eventos que terminaron.
func advance_day(demand: DemandModel) -> Array:
	var ended: Array = []
	var still: Array = []
	for entry in _active:
		entry["remaining"] = int(entry["remaining"]) - 1
		if int(entry["remaining"]) <= 0:
			var event: EventData = entry["event"]
			for effect in event.effects:
				if effect is EventEffect:
					effect.revert(demand)
			ended.append(event)
		else:
			still.append(entry)
	_active = still
	return ended
