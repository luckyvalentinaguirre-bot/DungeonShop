extends SceneTree
## Runner de tests headless de Dungeon Shop (sin addons).
##
## Ejecutar desde la carpeta del proyecto:
##   godot --headless --script res://tests/run_tests.gd
##
## Sale con código 0 si todo pasa y 1 si hay fallos (integrable en CI).
## Ver docs/systems/00_Architecture.md §9 y docs/Roadmap.md (Fase 3).

const TEST_SCRIPTS: Array = [
	# Economía (Fase 3)
	preload("res://tests/unit/test_price_calculator.gd"),
	preload("res://tests/unit/test_demand_model.gd"),
	preload("res://tests/unit/test_wallet.gd"),
	preload("res://tests/unit/test_market.gd"),
	preload("res://tests/unit/test_transaction.gd"),
	# Clientes (Fase 4)
	preload("res://tests/unit/test_haggle_resolver.gd"),
	preload("res://tests/unit/test_mood.gd"),
	preload("res://tests/unit/test_customer_need_generator.gd"),
	preload("res://tests/unit/test_customer_controller.gd"),
	preload("res://tests/unit/test_shelf_purchase.gd"),
	preload("res://tests/unit/test_shop_queue.gd"),
]

func _initialize() -> void:
	var total_failures: int = 0
	var total_asserts: int = 0
	var total_tests: int = 0
	print("=== Dungeon Shop — tests (Fase 3) ===")
	for script in TEST_SCRIPTS:
		var instance: Test = script.new()
		var file_name: String = script.resource_path.get_file()
		for method in instance.get_method_list():
			var mname: String = method.name
			if mname.begins_with("test_"):
				total_tests += 1
				instance.call(mname)
		total_asserts += instance.get_assertion_count()
		var failures: Array[String] = instance.get_failures()
		for f in failures:
			total_failures += 1
			printerr("  [FALLO] %s :: %s" % [file_name, f])
		var status: String = "OK" if failures.is_empty() else "CON FALLOS"
		print("  %-28s %s (%d asserts)" % [file_name, status, instance.get_assertion_count()])
	print("=== Resumen: %d tests, %d asserts, %d fallos ===" % [total_tests, total_asserts, total_failures])
	quit(1 if total_failures > 0 else 0)
