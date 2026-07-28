extends Test
## Tests de ShelfPurchaseResolver (compra autónoma de estantería). Ver docs/systems/02_Customers.md.

func _need(category: GameEnums.Category, min_quality: int, budget: int) -> CustomerNeed:
	var n := CustomerNeed.new()
	n.category = category
	n.min_quality = min_quality
	n.budget = budget
	n.intent = CustomerNeed.Intent.SHELF
	return n

func _offer(category: GameEnums.Category, quality: int, price: int) -> Dictionary:
	var it := ItemData.new()
	it.category = category
	it.base_value = price
	return {"item": ItemInstance.new(it, quality, 1), "price": price}

func test_buys_matching_item() -> void:
	var buyer := WalletComponent.new()
	buyer.balance = 100
	var seller := WalletComponent.new()
	var offers := [_offer(GameEnums.Category.POTION, 2, 15)]
	var r := ShelfPurchaseResolver.resolve(_need(GameEnums.Category.POTION, 1, 50), offers, buyer, seller, null)
	assert_true(r.bought)
	assert_eq(seller.balance, 15)

func test_picks_cheapest_match() -> void:
	var buyer := WalletComponent.new()
	buyer.balance = 100
	var seller := WalletComponent.new()
	var offers := [
		_offer(GameEnums.Category.POTION, 2, 25),
		_offer(GameEnums.Category.POTION, 2, 12),
		_offer(GameEnums.Category.POTION, 2, 18),
	]
	var r := ShelfPurchaseResolver.resolve(_need(GameEnums.Category.POTION, 1, 50), offers, buyer, seller, null)
	assert_true(r.bought)
	assert_eq(r.price, 12, "elige el más barato que cumple")

func test_no_match_when_over_budget() -> void:
	var buyer := WalletComponent.new()
	buyer.balance = 100
	var seller := WalletComponent.new()
	var offers := [_offer(GameEnums.Category.WEAPON, 3, 80)]
	var r := ShelfPurchaseResolver.resolve(_need(GameEnums.Category.WEAPON, 1, 50), offers, buyer, seller, null)
	assert_false(r.bought)
	assert_eq(r.reason, "no_match")

func test_no_match_when_quality_too_low() -> void:
	var buyer := WalletComponent.new()
	buyer.balance = 100
	var seller := WalletComponent.new()
	var offers := [_offer(GameEnums.Category.WEAPON, 1, 30)]
	var r := ShelfPurchaseResolver.resolve(_need(GameEnums.Category.WEAPON, 3, 50), offers, buyer, seller, null)
	assert_false(r.bought)
