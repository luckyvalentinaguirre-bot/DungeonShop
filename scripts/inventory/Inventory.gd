class_name Inventory
extends RefCounted
## Modelo de inventario puro y testeable (sin nodos ni UI): una colección de
## ItemInstance con capacidad y reglas de apilado. Reutilizable por almacén,
## estantería, cliente o héroe (a través de InventoryComponent). Ver
## docs/systems/09_Inventory.md.

signal changed()
signal item_added(instance: ItemInstance)
signal item_removed(instance: ItemInstance)

## Capacidad en número de pilas/slots. 0 = ilimitada.
var capacity: int = 0
var _slots: Array[ItemInstance] = []

func _init(p_capacity: int = 0) -> void:
	capacity = p_capacity

func is_full() -> bool:
	return capacity > 0 and _slots.size() >= capacity

func slot_count() -> int:
	return _slots.size()

## Copia superficial de las pilas (para iterar sin exponer el array interno).
func get_items() -> Array:
	return _slots.duplicate()

## Unidades totales de un objeto por id (suma de cantidades en todas sus pilas).
func count(item_id: StringName) -> int:
	var total: int = 0
	for slot in _slots:
		if slot.data != null and slot.data.id == item_id:
			total += slot.quantity
	return total

func has(item_id: StringName, qty: int = 1) -> bool:
	return count(item_id) >= qty

## Añade una instancia. Los objetos apilables se funden en pilas existentes
## respetando max_stack; los no apilables ocupan una pila propia. Devuelve false si
## no cupo todo (capacidad llena).
func add(instance: ItemInstance) -> bool:
	if instance == null or instance.data == null:
		return false
	if not instance.data.stackable:
		if is_full():
			return false
		_slots.append(instance)
		item_added.emit(instance)
		changed.emit()
		return true

	var remaining: int = instance.quantity
	var max_stack: int = instance.data.max_stack if instance.data.max_stack > 0 else 0x7FFFFFFF
	# Rellena pilas existentes del mismo objeto.
	for slot in _slots:
		if remaining <= 0:
			break
		if slot.data != null and slot.data.id == instance.data.id and slot.quantity < max_stack:
			var space: int = max_stack - slot.quantity
			var moved: int = mini(space, remaining)
			slot.quantity += moved
			remaining -= moved
	# Crea pilas nuevas para el resto.
	while remaining > 0:
		if is_full():
			changed.emit()
			return false
		var chunk: int = mini(max_stack, remaining)
		_slots.append(ItemInstance.new(instance.data, instance.quality, chunk))
		remaining -= chunk
	item_added.emit(instance)
	changed.emit()
	return true

## Quita 'qty' unidades de un objeto por id (a través de sus pilas). Devuelve false
## si no hay suficientes.
func remove(item_id: StringName, qty: int = 1) -> bool:
	if count(item_id) < qty:
		return false
	var remaining: int = qty
	for i in range(_slots.size() - 1, -1, -1):
		if remaining <= 0:
			break
		var slot: ItemInstance = _slots[i]
		if slot.data != null and slot.data.id == item_id:
			if slot.quantity <= remaining:
				remaining -= slot.quantity
				_slots.remove_at(i)
			else:
				slot.quantity -= remaining
				remaining = 0
	changed.emit()
	return true

## Quita una instancia concreta (para objetos únicos con estado propio).
func remove_instance(instance: ItemInstance) -> bool:
	var idx: int = _slots.find(instance)
	if idx == -1:
		return false
	_slots.remove_at(idx)
	item_removed.emit(instance)
	changed.emit()
	return true

## Mueve una instancia concreta a otro inventario de forma atómica (o se mueve
## entera, o no se mueve). Preserva el estado del objeto.
func move_instance_to(other: Inventory, instance: ItemInstance) -> bool:
	if other == null or other.is_full():
		return false
	if not _slots.has(instance):
		return false
	remove_instance(instance)
	other.add(instance)
	return true

## Serialización (contrato ISaveable). La reconstrucción con un ItemDatabase se
## integra en la Fase 8 (ver docs/systems/08_Save.md).
func capture_state() -> Array:
	var out: Array = []
	for slot in _slots:
		if slot.data != null:
			out.append({"id": slot.data.id, "quality": slot.quality, "quantity": slot.quantity})
	return out
