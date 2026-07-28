extends Test
## Tests de CustomerController (visita atendida en el mostrador de principio a fin).
## Ver docs/systems/02_Customers.md.

func _economy() -> EconomySystem:
	var e := EconomySystem.new()
	e.setup(EconomyConfig.new(), 1)
	return e

func _customer(category: GameEnums.Category, min_quality: int, budget: int, mood: float) -> Customer:
	var need := CustomerNeed.new()
	need.category = category
	need.min_quality = min_quality
	need.budget = budget
	var data := CustomerData.new()
	data.display_name = "Prueba"
	var wallet := WalletComponent.new()
	wallet.balance = budget
	var mc := MoodComponent.new()
	mc.value = mood
	return Customer.new(data, need, wallet, mc)

func _item(category: GameEnums.Category, base_value: int, quality: int) -> ItemInstance:
	var it := ItemData.new()
	it.category = category
	it.base_value = base_value
	return ItemInstance.new(it, quality, 1)

func test_full_visit_sells() -> void:
	var economy := _economy()
	var player := WalletComponent.new()
	var c := _customer(GameEnums.Category.WEAPON, 1, 200, 0.6)
	var ctrl := CustomerController.new(c)
	ctrl.present_need()
	var item := _item(GameEnums.Category.WEAPON, 40, 2)
	var price := economy.suggested_price(item)
	var out := ctrl.receive_offer(item, price, economy, player)
	assert_true(out.accepted, "acepta un precio justo dentro de presupuesto")
	assert_true(out.sold, "la venta se ejecuta")
	assert_true(ctrl.is_finished())
	assert_eq(player.balance, price, "el tendero cobra el precio")

func test_wrong_category_is_rejected() -> void:
	var economy := _economy()
	var player := WalletComponent.new()
	var c := _customer(GameEnums.Category.WEAPON, 0, 200, 0.6)
	var ctrl := CustomerController.new(c)
	ctrl.present_need()
	var item := _item(GameEnums.Category.POTION, 20, 1)
	var out := ctrl.receive_offer(item, 20, economy, player)
	assert_false(out.sold)
	assert_eq(out.reason, "wrong_item")

func test_offer_before_present_is_ignored() -> void:
	var economy := _economy()
	var player := WalletComponent.new()
	var c := _customer(GameEnums.Category.WEAPON, 0, 200, 0.6)
	var ctrl := CustomerController.new(c)
	var item := _item(GameEnums.Category.WEAPON, 40, 1)
	var out := ctrl.receive_offer(item, 40, economy, player)
	assert_false(out.sold)
	assert_eq(out.reason, "not_awaiting_offer")
