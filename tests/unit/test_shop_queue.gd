extends Test
## Tests de ShopQueue (cola del mostrador). Ver docs/systems/02_Customers.md.

func _controller(mood: float) -> CustomerController:
	var need := CustomerNeed.new()
	var wallet := WalletComponent.new()
	var mc := MoodComponent.new()
	mc.value = mood
	var c := Customer.new(CustomerData.new(), need, wallet, mc)
	return CustomerController.new(c)

func test_enqueue_and_size() -> void:
	var q := ShopQueue.new()
	assert_true(q.is_empty())
	q.enqueue(_controller(0.5))
	q.enqueue(_controller(0.5))
	assert_eq(q.size(), 2)

func test_current_is_front() -> void:
	var q := ShopQueue.new()
	var first := _controller(0.5)
	q.enqueue(first)
	q.enqueue(_controller(0.5))
	assert_eq(q.current(), first)

func test_advance_pops_front() -> void:
	var q := ShopQueue.new()
	var first := _controller(0.5)
	var second := _controller(0.5)
	q.enqueue(first)
	q.enqueue(second)
	q.advance()
	assert_eq(q.current(), second)
	assert_eq(q.size(), 1)

func test_decay_patience_affects_waiting_not_current() -> void:
	var q := ShopQueue.new()
	var first := _controller(0.8)
	var second := _controller(0.8)
	q.enqueue(first)
	q.enqueue(second)
	q.decay_patience(0.1)
	assert_almost_eq(first.customer.mood.value, 0.8, 0.0001, "el atendido no pierde paciencia")
	assert_true(second.customer.mood.value < 0.8, "los que esperan sí pierden paciencia")
