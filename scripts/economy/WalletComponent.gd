class_name WalletComponent
extends Node
## Oro y deuda de una entidad (jugador, cliente, héroe). Componente reutilizable:
## se agrega como nodo hijo (composición, no herencia). Emite señales locales y
## no conoce la UI. Ver docs/systems/01_Economy.md §8 y docs/systems/00_Architecture.md §7.

signal balance_changed(new_balance: int)

## Saldo actual en coronas.
@export var balance: int = 0
## Límite de crédito: el saldo puede bajar hasta -credit_limit (deuda). 0 = sin crédito.
@export var credit_limit: int = 0

## ¿Puede permitirse pagar 'amount' sin exceder su límite de crédito?
func can_afford(amount: int) -> bool:
	return balance - amount >= -credit_limit

## Paga 'amount'. Devuelve false (sin cambiar el saldo) si no puede permitírselo.
func pay(amount: int) -> bool:
	if amount < 0:
		return receive(-amount)
	if not can_afford(amount):
		return false
	balance -= amount
	balance_changed.emit(balance)
	return true

## Ingresa 'amount' en la cartera.
func receive(amount: int) -> bool:
	if amount < 0:
		return pay(-amount)
	balance += amount
	balance_changed.emit(balance)
	return true
