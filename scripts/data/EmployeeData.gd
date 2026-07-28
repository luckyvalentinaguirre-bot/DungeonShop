class_name EmployeeData
extends Resource
## Un empleado contratable. Cada uno tiene un rol y una habilidad, y cobra un salario
## semanal. Ver docs/systems/06_Progression.md §5.

enum Role { CLERK, SMITH, ORGANIZER }

@export var id: StringName = &""
@export var display_name: String = ""
@export var role: Role = Role.CLERK
## Habilidad 1..5 (mejora con el uso; afecta a su eficiencia).
@export var skill: int = 1
## Salario por semana (coronas).
@export var weekly_salary: int = 20
