class_name WeatherSystem
extends RefCounted
## Clima y estaciones. Determina el clima de cada jornada (con probabilidades que
## dependen de la estación) y expone datos para que la vista top-down pinte lluvia,
## nieve, niebla, etc. Puro, determinista con semilla, y testeable.
## Ver docs/ArtDirection.md §3.

enum Weather { CLEAR, CLOUDY, RAIN, STORM, SNOW, FOG }
enum Season { SPRING, SUMMER, AUTUMN, WINTER }

## Jornadas por estación (4 estaciones = un año).
var days_per_season: int = 12
var weather: Weather = Weather.CLEAR
var season: Season = Season.SPRING

## Pesos de clima por estación [CLEAR, CLOUDY, RAIN, STORM, SNOW, FOG].
const _WEIGHTS := {
	Season.SPRING: [5, 3, 4, 1, 0, 2],
	Season.SUMMER: [7, 2, 2, 2, 0, 1],
	Season.AUTUMN: [4, 4, 4, 1, 0, 3],
	Season.WINTER: [3, 3, 1, 1, 5, 3],
}

## Estación correspondiente a una jornada dada.
func season_for_day(day: int) -> Season:
	var index: int = int(floor(float(maxi(1, day) - 1) / float(maxi(1, days_per_season)))) % 4
	return index as Season

## Recalcula estación y clima para una jornada (llamar al avanzar la jornada).
func roll_for_day(day: int, rng: RandomNumberGenerator) -> void:
	season = season_for_day(day)
	weather = _weighted_pick(_WEIGHTS[season], rng)

func _weighted_pick(weights: Array, rng: RandomNumberGenerator) -> Weather:
	var total: int = 0
	for w in weights:
		total += int(w)
	if total <= 0:
		return Weather.CLEAR
	var roll: int = rng.randi_range(1, total)
	var acc: int = 0
	for i in weights.size():
		acc += int(weights[i])
		if roll <= acc:
			return i as Weather
	return Weather.CLEAR

func weather_name() -> String:
	match weather:
		Weather.CLEAR: return "Despejado"
		Weather.CLOUDY: return "Nublado"
		Weather.RAIN: return "Lluvia"
		Weather.STORM: return "Tormenta"
		Weather.SNOW: return "Nieve"
		Weather.FOG: return "Niebla"
		_: return "?"

func season_name() -> String:
	match season:
		Season.SPRING: return "Primavera"
		Season.SUMMER: return "Verano"
		Season.AUTUMN: return "Otoño"
		Season.WINTER: return "Invierno"
		_: return "?"

func is_precipitation() -> bool:
	return weather == Weather.RAIN or weather == Weather.STORM or weather == Weather.SNOW

func capture_state() -> Dictionary:
	return {"weather": int(weather), "season": int(season)}

func restore_state(data: Dictionary) -> void:
	weather = int(data.get("weather", 0)) as Weather
	season = int(data.get("season", 0)) as Season
