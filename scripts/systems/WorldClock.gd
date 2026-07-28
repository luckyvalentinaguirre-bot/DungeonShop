class_name WorldClock
extends RefCounted
## Ciclo de día y noche. El tiempo del día va de 0..1 (0 y 1 = medianoche, 0.5 =
## mediodía) y produce una FASE y un COLOR de luz ambiente interpolado suavemente
## entre puntos clave, para alimentar el CanvasModulate de la vista top-down.
## Puro y testeable. Ver docs/ArtDirection.md §3.

enum Phase { NIGHT, DAWN, DAY, DUSK }

## Duración de un día completo en segundos de tiempo real (una jornada de juego).
var day_length: float = 240.0
## Momento del día, 0..1.
var time_of_day: float = 0.30

## Puntos clave de color de luz ambiente [tiempo, Color]. Se interpola entre ellos.
const _KEYS := [
	[0.00, Color(0.16, 0.18, 0.34)],  # medianoche: azul profundo
	[0.22, Color(0.20, 0.20, 0.38)],  # antes del alba
	[0.28, Color(0.85, 0.62, 0.48)],  # amanecer cálido
	[0.35, Color(1.00, 0.96, 0.88)],  # mañana
	[0.50, Color(1.00, 1.00, 0.98)],  # mediodía (luz plena)
	[0.68, Color(1.00, 0.92, 0.80)],  # tarde
	[0.76, Color(0.92, 0.58, 0.42)],  # atardecer
	[0.85, Color(0.35, 0.30, 0.45)],  # anochecer
	[1.00, Color(0.16, 0.18, 0.34)],  # medianoche
]

## Avanza el reloj 'delta_seconds' de tiempo real.
func advance(delta_seconds: float) -> void:
	if day_length <= 0.0:
		return
	time_of_day = fposmod(time_of_day + delta_seconds / day_length, 1.0)

func set_time(t: float) -> void:
	time_of_day = fposmod(t, 1.0)

## Fase actual del día.
func phase() -> Phase:
	var t := time_of_day
	if t >= 0.24 and t < 0.34:
		return Phase.DAWN
	if t >= 0.34 and t < 0.72:
		return Phase.DAY
	if t >= 0.72 and t < 0.84:
		return Phase.DUSK
	return Phase.NIGHT

func phase_name() -> String:
	match phase():
		Phase.DAWN: return "Amanecer"
		Phase.DAY: return "Día"
		Phase.DUSK: return "Atardecer"
		_: return "Noche"

## Intensidad de luz diurna 0..1 (0 de noche, 1 a mediodía). Útil para la niebla,
## el volumen de ambiente, etc.
func daylight() -> float:
	# Curva suave centrada en el mediodía.
	return clampf(1.0 - absf(time_of_day - 0.5) * 2.2, 0.05, 1.0)

## Color de luz ambiente interpolado (para el CanvasModulate).
func light_color() -> Color:
	var t := time_of_day
	for i in range(_KEYS.size() - 1):
		var a = _KEYS[i]
		var b = _KEYS[i + 1]
		var ta: float = a[0]
		var tb: float = b[0]
		if t >= ta and t <= tb:
			var f: float = 0.0 if tb == ta else (t - ta) / (tb - ta)
			return (a[1] as Color).lerp(b[1] as Color, f)
	return _KEYS[0][1]

## Serialización (parte del guardado; el reloj persiste entre sesiones).
func capture_state() -> Dictionary:
	return {"time": time_of_day, "day_length": day_length}

func restore_state(data: Dictionary) -> void:
	time_of_day = float(data.get("time", 0.30))
	day_length = float(data.get("day_length", 240.0))
