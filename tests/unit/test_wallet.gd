extends Test
## Tests de WalletComponent (oro y deuda). Ver docs/systems/01_Economy.md.

func _wallet(balance: int, credit: int = 0) -> WalletComponent:
	var w := WalletComponent.new()
	w.balance = balance
	w.credit_limit = credit
	return w

func test_can_afford() -> void:
	var w := _wallet(100)
	assert_true(w.can_afford(100))
	assert_false(w.can_afford(101))

func test_pay_reduces_balance() -> void:
	var w := _wallet(100)
	assert_true(w.pay(30))
	assert_eq(w.balance, 70)

func test_pay_fails_when_insufficient() -> void:
	var w := _wallet(10)
	assert_false(w.pay(50))
	assert_eq(w.balance, 10, "un pago fallido no cambia el saldo")

func test_receive_adds() -> void:
	var w := _wallet(0)
	w.receive(25)
	assert_eq(w.balance, 25)

func test_credit_allows_debt() -> void:
	var w := _wallet(0, 50)
	assert_true(w.pay(40))
	assert_eq(w.balance, -40)
	assert_false(w.pay(20), "no puede superar el límite de crédito")
