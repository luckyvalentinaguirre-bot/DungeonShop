class_name Test
extends RefCounted
## Base mínima de tests, sin dependencias externas (migrable a GUT en el futuro).
## Cada caso de prueba extiende esta clase y define métodos que empiezan por
## "test_"; el runner (tests/run_tests.gd) los descubre y ejecuta.
## Ver docs/systems/00_Architecture.md §9.

var _failures: Array[String] = []
var _assertions: int = 0

func assert_true(cond: bool, msg: String = "") -> void:
	_assertions += 1
	if not cond:
		_failures.append("assert_true falló: " + msg)

func assert_false(cond: bool, msg: String = "") -> void:
	assert_true(not cond, msg)

func assert_eq(a, b, msg: String = "") -> void:
	_assertions += 1
	if a != b:
		_failures.append("assert_eq falló: %s != %s  %s" % [str(a), str(b), msg])

func assert_almost_eq(a: float, b: float, tol: float = 0.0001, msg: String = "") -> void:
	_assertions += 1
	if absf(a - b) > tol:
		_failures.append("assert_almost_eq falló: %s !~ %s  %s" % [str(a), str(b), msg])

func get_failures() -> Array[String]:
	return _failures

func get_assertion_count() -> int:
	return _assertions
