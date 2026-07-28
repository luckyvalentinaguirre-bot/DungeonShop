extends Test
## Tests de TransactionResolver (movimiento de oro en una venta).
## Ver docs/systems/01_Economy.md §6.

func _wallet(balance: int) -> WalletComponent:
	var w := WalletComponent.new()
	w.balance = balance
	return w

func _sword_instance() -> ItemInstance:
	var it := ItemData.new()
	it.id = &"weapon_short_sword"
	it.category = GameEnums.Category.WEAPON
	it.base_value = 40
	return ItemInstance.new(it, 3, 1)

func test_successful_sale_moves_gold() -> void:
	var buyer := _wallet(100)
	var seller := _wallet(0)
	var demand := DemandModel.new(EconomyConfig.new())
	var r := TransactionResolver.resolve_sale(_sword_instance(), 60, buyer, seller, demand)
	assert_true(r.success)
	assert_eq(buyer.balance, 40)
	assert_eq(seller.balance, 60)

func test_sale_fails_when_buyer_broke() -> void:
	var buyer := _wallet(10)
	var seller := _wallet(0)
	var r := TransactionResolver.resolve_sale(_sword_instance(), 60, buyer, seller, null)
	assert_false(r.success)
	assert_eq(r.reason, "buyer_cannot_afford")
	assert_eq(buyer.balance, 10, "una venta fallida no mueve oro")

func test_sale_updates_demand() -> void:
	var buyer := _wallet(100)
	var seller := _wallet(0)
	var demand := DemandModel.new(EconomyConfig.new())
	var before := demand.get_multiplier(GameEnums.Category.WEAPON)
	TransactionResolver.resolve_sale(_sword_instance(), 50, buyer, seller, demand)
	assert_true(demand.get_multiplier(GameEnums.Category.WEAPON) < before, "vender baja la demanda de armas")
