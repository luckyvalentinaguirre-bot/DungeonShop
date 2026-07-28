class_name CustomerSpawner
extends RefCounted
## Produce los clientes de una jornada a partir de un conjunto de plantillas y un RNG
## sembrado (determinista). En v1.0 el número de clientes lo decide quien llama; más
## adelante escalará con la reputación y los eventos (ver docs/systems/02_Customers.md §5
## y docs/systems/04_Reputation.md). No conoce la UI.

## Genera 'count' clientes eligiendo plantillas del 'pool'. Cada cliente trae su
## necesidad, su cartera (con el presupuesto del día) y su ánimo base.
static func spawn_day(pool: Array[CustomerData], count: int, rng: RandomNumberGenerator) -> Array[Customer]:
	var result: Array[Customer] = []
	if pool.is_empty() or count <= 0:
		return result
	for i in count:
		var data: CustomerData = pool[rng.randi() % pool.size()]
		var need := CustomerNeedGenerator.generate(data, rng)
		var wallet := WalletComponent.new()
		wallet.balance = need.budget
		var mood := MoodComponent.new()
		mood.value = data.base_mood
		result.append(Customer.new(data, need, wallet, mood))
	return result
