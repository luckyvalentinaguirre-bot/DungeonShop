extends Test
## Tests de WorldClock (día/noche) y WeatherSystem (clima/estaciones).
## Ver docs/ArtDirection.md §3.

# --- WorldClock ---
func test_phase_by_time() -> void:
	var c := WorldClock.new()
	c.set_time(0.5)
	assert_eq(c.phase(), WorldClock.Phase.DAY, "mediodía es día")
	c.set_time(0.0)
	assert_eq(c.phase(), WorldClock.Phase.NIGHT, "medianoche es noche")
	c.set_time(0.30)
	assert_eq(c.phase(), WorldClock.Phase.DAWN)
	c.set_time(0.78)
	assert_eq(c.phase(), WorldClock.Phase.DUSK)

func test_daylight_peaks_at_noon() -> void:
	var c := WorldClock.new()
	c.set_time(0.5)
	var noon := c.daylight()
	c.set_time(0.0)
	var midnight := c.daylight()
	assert_true(noon > midnight, "hay más luz a mediodía que a medianoche")

func test_advance_wraps_around() -> void:
	var c := WorldClock.new()
	c.day_length = 10.0
	c.set_time(0.95)
	c.advance(1.0)  # +0.1 -> 1.05 -> 0.05
	assert_true(c.time_of_day < 0.1, "el tiempo da la vuelta al pasar de medianoche")

func test_light_color_interpolates() -> void:
	var c := WorldClock.new()
	c.set_time(0.5)
	var col := c.light_color()
	assert_true(col.r > 0.9 and col.g > 0.9, "a mediodía la luz es casi blanca")

# --- WeatherSystem ---
func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng

func test_season_cycles() -> void:
	var w := WeatherSystem.new()
	w.days_per_season = 10
	assert_eq(w.season_for_day(1), WeatherSystem.Season.SPRING)
	assert_eq(w.season_for_day(11), WeatherSystem.Season.SUMMER)
	assert_eq(w.season_for_day(31), WeatherSystem.Season.WINTER)
	assert_eq(w.season_for_day(41), WeatherSystem.Season.SPRING)

func test_roll_is_deterministic() -> void:
	var a := WeatherSystem.new()
	var b := WeatherSystem.new()
	a.roll_for_day(5, _rng(123))
	b.roll_for_day(5, _rng(123))
	assert_eq(a.weather, b.weather, "mismo seed => mismo clima")

func test_winter_can_snow() -> void:
	var w := WeatherSystem.new()
	w.days_per_season = 10
	var snowed := false
	for i in 200:
		w.roll_for_day(31, _rng(i))  # día 31 = invierno
		if w.weather == WeatherSystem.Weather.SNOW:
			snowed = true
			break
	assert_true(snowed, "en invierno puede nevar")
