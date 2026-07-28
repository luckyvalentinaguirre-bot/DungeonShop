class_name EmployeeManager
extends RefCounted
## Gestiona la plantilla de la tienda: contratar empleados y pagar salarios.
## Ver docs/systems/06_Progression.md §5.

var _hired: Array = []  # EmployeeData

func hired() -> Array:
	return _hired

func count() -> int:
	return _hired.size()

func hire(employee: EmployeeData) -> void:
	if employee != null and not _hired.has(employee):
		_hired.append(employee)

func fire(employee: EmployeeData) -> void:
	_hired.erase(employee)

## Salario total semanal de toda la plantilla.
func total_weekly_salary() -> int:
	var total: int = 0
	for e in _hired:
		total += e.weekly_salary
	return total

## Empleados con un rol concreto (para saber quién atiende, quién fabrica…).
func with_role(role: int) -> Array:
	var out: Array = []
	for e in _hired:
		if e.role == role:
			out.append(e)
	return out
