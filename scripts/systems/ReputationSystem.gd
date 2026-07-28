class_name ReputationSystem
extends RefCounted
## Prestigio global de la tienda + afinidad por facción, con tensiones entre rivales.
## Puro y testeable. Ver docs/systems/04_Reputation.md y docs/WorldBible.md §5.

## Fracción del delta que se resta a la facción rival al subir con una (roce suave).
const TENSION_FACTOR := 0.3

## Pares enfrentados (bidireccional). Ver WorldBible §5.
const TENSIONS := [
	[GameEnums.Faction.CROWN, GameEnums.Faction.PEDDLERS],
	[GameEnums.Faction.ARCANE, GameEnums.Faction.CROWN],
	[GameEnums.Faction.GUILD, GameEnums.Faction.ARTISANS],
]

var _prestige: float = 0.0
## Faction(int) -> afinidad (float)
var _affinity: Dictionary = {}

func prestige() -> float:
	return _prestige

## Suma prestigio directamente (p. ej. recompensa de misión).
func add_prestige(delta: float) -> void:
	_prestige = maxf(0.0, _prestige + delta)

func affinity_of(faction: int) -> float:
	return float(_affinity.get(faction, 0.0))

## Registra una venta satisfactoria: sube prestigio y afinidad de la facción del
## cliente en función de su ánimo (0..1). Un mal trato (ánimo bajo) puede restar.
func register_sale(faction: int, mood: float) -> void:
	var quality: float = (mood - 0.5) * 2.0  # -1..1
	_prestige = maxf(0.0, _prestige + 0.5 + quality * 0.5)
	add_affinity(faction, 1.0 + quality)

## Ajusta la afinidad de una facción; sus rivales pierden una fracción (tensión).
func add_affinity(faction: int, delta: float) -> void:
	_affinity[faction] = affinity_of(faction) + delta
	if delta > 0.0:
		for rival in rivals_of(faction):
			_affinity[rival] = affinity_of(rival) - delta * TENSION_FACTOR

## Facciones enfrentadas con la dada.
func rivals_of(faction: int) -> Array:
	var out: Array = []
	for pair in TENSIONS:
		if pair[0] == faction:
			out.append(pair[1])
		elif pair[1] == faction:
			out.append(pair[0])
	return out

## Serialización (ISaveable, ver docs/systems/08_Save.md).
func capture_state() -> Dictionary:
	return {"prestige": _prestige, "affinity": _affinity.duplicate()}

func restore_state(data: Dictionary) -> void:
	_prestige = float(data.get("prestige", 0.0))
	_affinity.clear()
	var aff = data.get("affinity", {})
	if aff is Dictionary:
		for key in aff.keys():
			_affinity[int(key)] = float(aff[key])
