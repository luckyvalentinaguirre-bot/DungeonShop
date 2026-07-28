class_name ExpeditionOutcome
extends RefCounted
## Resultado estructurado de una expedición (gradiente, no binario). Ver
## docs/systems/03_Heroes.md §4.

enum Kind { TRIUMPH, NARROW, RETREAT, LOST }

var kind: Kind = Kind.RETREAT
var survived: bool = true
var loot_value: int = 0
var loyalty_delta: float = 0.0
var narrative: String = ""
