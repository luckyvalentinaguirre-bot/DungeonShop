extends Test
## Tests de empleados, exploración e investigación. Ver docs/systems/06_Progression.md.

# --- Empleados ---
func _employee(salary: int, role: int = EmployeeData.Role.CLERK) -> EmployeeData:
	var e := EmployeeData.new()
	e.weekly_salary = salary
	e.role = role
	return e

func test_hire_and_salary() -> void:
	var m := EmployeeManager.new()
	m.hire(_employee(20))
	m.hire(_employee(30, EmployeeData.Role.SMITH))
	assert_eq(m.count(), 2)
	assert_eq(m.total_weekly_salary(), 50)
	assert_eq(m.with_role(EmployeeData.Role.SMITH).size(), 1)

# --- Exploración ---
func _region(cost: int, materials: Array) -> RegionData:
	var r := RegionData.new()
	r.unlock_cost = cost
	r.provided_materials = materials
	return r

func test_unlock_region_with_gold() -> void:
	var sys := ExplorationSystem.new()
	var region := _region(100, [&"mat_mithril"])
	assert_false(sys.can_unlock(region, 50), "sin oro suficiente no se puede")
	var mats := sys.unlock(region, 150)
	assert_true(sys.is_unlocked(region))
	assert_eq(mats, [&"mat_mithril"], "devuelve los materiales que aporta")

func test_cannot_unlock_twice() -> void:
	var sys := ExplorationSystem.new()
	var region := _region(50, [])
	sys.unlock(region, 100)
	assert_true(sys.unlock(region, 100).is_empty(), "ya estaba desbloqueada")

# --- Investigación ---
func _node(id: StringName, cost: int, prereqs: Array, recipes: Array) -> ResearchNode:
	var n := ResearchNode.new()
	n.id = id
	n.cost = cost
	n.prerequisites = prereqs
	n.unlocks_recipes = recipes
	return n

func test_research_respects_prerequisites() -> void:
	var sys := ResearchSystem.new()
	var advanced := _node(&"steelworking", 100, [&"basic_forge"], [&"recipe_longsword"])
	assert_false(sys.can_research(advanced, 999), "faltan prerrequisitos")
	var basic := _node(&"basic_forge", 50, [], [])
	sys.research(basic, 100)
	assert_true(sys.can_research(advanced, 100))
	var recipes := sys.research(advanced, 100)
	assert_eq(recipes, [&"recipe_longsword"])
