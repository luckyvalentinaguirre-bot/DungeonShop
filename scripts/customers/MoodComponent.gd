class_name MoodComponent
extends Node
## Ánimo/paciencia de un cliente (0 = molesto, 0.5 = neutro, 1 = encantado).
## Componente reutilizable (composición). Afecta al margen que acepta en el regateo
## y a la reputación/propinas que otorga. Ver docs/systems/02_Customers.md §8.

signal mood_changed(value: float)

@export_range(0.0, 1.0) var value: float = 0.5

## Ajusta el ánimo por 'delta', manteniéndolo en [0, 1].
func adjust(delta: float) -> void:
	value = clampf(value + delta, 0.0, 1.0)
	mood_changed.emit(value)
