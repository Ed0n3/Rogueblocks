class_name ItemInventory
extends RefCounted

var capacity: int = 4
var maximum_capacity: int = 8
var slots: Array[ItemStack] = []
var locked_slots: PackedInt32Array = PackedInt32Array()

func _init(initial_capacity: int = 4, cap: int = 8) -> void:
	capacity = clampi(initial_capacity, 1, cap)
	maximum_capacity = maxi(capacity, cap)
	for index: int in capacity:
		slots.append(null)

func add(stack: ItemStack, stack_limit_bonus: int = 0) -> InventoryAddResult:
	var result: InventoryAddResult = InventoryAddResult.new()
	if stack == null or stack.definition == null:
		return result
	result.remaining_quantity = stack.quantity
	var limit: int = maxi(1, stack.definition.maximum_stack_size + stack_limit_bonus)
	for index: int in slots.size():
		var existing: ItemStack = slots[index]
		if existing != null and existing.is_compatible(stack) and existing.quantity < limit:
			var merged: int = mini(limit - existing.quantity, result.remaining_quantity)
			existing.quantity += merged
			result.merged_quantity += merged
			result.remaining_quantity -= merged
			result.slot_index = index
			if result.remaining_quantity == 0:
				result.added = true
				return result
	for index: int in slots.size():
		if slots[index] == null and result.remaining_quantity > 0:
			var inserted: ItemStack = ItemStack.new()
			inserted.definition = stack.definition
			inserted.bonus_piece = stack.bonus_piece
			inserted.quantity = mini(limit, result.remaining_quantity)
			slots[index] = inserted
			result.remaining_quantity -= inserted.quantity
			result.slot_index = index
	result.added = result.remaining_quantity == 0
	return result

func consume(index: int, quantity: int = 1) -> bool:
	if index < 0 or index >= slots.size() or locked_slots.has(index) or slots[index] == null or slots[index].quantity < quantity:
		return false
	slots[index].quantity -= quantity
	if slots[index].quantity <= 0:
		slots[index] = null
	return true

func lock_slot(index: int) -> bool:
	if index < 0 or index >= slots.size() or locked_slots.size() >= maxi(0, capacity - 1):
		return false
	if not locked_slots.has(index):
		locked_slots.append(index)
	return true

func expand(amount: int = 1) -> int:
	var added: int = mini(maximum_capacity - capacity, maxi(0, amount))
	for index: int in added:
		slots.append(null)
	capacity += added
	return added

func to_save_data() -> Dictionary:
	var slot_data: Array = []
	for stack: ItemStack in slots:
		slot_data.append(stack.to_save_data() if stack != null else null)
	return {"capacity": capacity, "maximum_capacity": maximum_capacity, "slots": slot_data, "locked_slots": Array(locked_slots)}

static func from_save_data(data: Dictionary) -> ItemInventory:
	var inventory: ItemInventory = ItemInventory.new(maxi(1, int(data.get("capacity", 4))), maxi(1, int(data.get("maximum_capacity", 8))))
	inventory.slots.clear()
	for value: Variant in data.get("slots", []) as Array:
		inventory.slots.append(null if value == null else ItemStack.from_save_data(value as Dictionary))
	while inventory.slots.size() < inventory.capacity:
		inventory.slots.append(null)
	inventory.locked_slots = PackedInt32Array(data.get("locked_slots", []) as Array)
	return inventory
