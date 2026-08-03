class_name UpgradePieceInventory
extends RefCounted

var stacks: Array[UpgradePieceStack] = []

func add(piece: PieceDefinition, quantity: int = 1) -> void:
	if piece == null or quantity <= 0:
		return
	var stack: UpgradePieceStack = _find_stack(piece)
	if stack == null:
		stacks.append(UpgradePieceStack.new(piece, quantity))
	else:
		stack.quantity += quantity
	_sort_stacks()

func consume(piece: PieceDefinition, quantity: int = 1) -> bool:
	if quantity <= 0:
		return true
	var stack: UpgradePieceStack = _find_stack(piece)
	if stack == null or stack.quantity < quantity:
		return false
	stack.quantity -= quantity
	if stack.quantity == 0:
		stacks.erase(stack)
	return true

func get_quantity(piece: PieceDefinition) -> int:
	var stack: UpgradePieceStack = _find_stack(piece)
	return stack.quantity if stack != null else 0

func get_total_quantity() -> int:
	var total: int = 0
	for stack: UpgradePieceStack in stacks:
		total += stack.quantity
	return total

func duplicate_inventory() -> UpgradePieceInventory:
	var duplicated: UpgradePieceInventory = UpgradePieceInventory.new()
	for stack: UpgradePieceStack in stacks:
		duplicated.stacks.append(stack.duplicate_stack())
	return duplicated

func sanitize(known_pieces: Array[PieceDefinition]) -> void:
	var sanitized: UpgradePieceInventory = UpgradePieceInventory.new()
	for stack: UpgradePieceStack in stacks:
		if stack != null and known_pieces.has(stack.piece) and stack.quantity > 0:
			sanitized.add(stack.piece, stack.quantity)
	stacks = sanitized.stacks

func to_save_data() -> Dictionary:
	var stack_data: Array[Dictionary] = []
	for stack: UpgradePieceStack in stacks:
		stack_data.append(stack.to_save_data())
	return {"stacks": stack_data}

static func from_save_data(data: Dictionary) -> UpgradePieceInventory:
	var inventory: UpgradePieceInventory = UpgradePieceInventory.new()
	for stack_value: Variant in data.get("stacks", []) as Array:
		if stack_value is Dictionary:
			var stack: UpgradePieceStack = UpgradePieceStack.from_save_data(stack_value as Dictionary)
			inventory.add(stack.piece, stack.quantity)
	return inventory

func _find_stack(piece: PieceDefinition) -> UpgradePieceStack:
	for stack: UpgradePieceStack in stacks:
		if stack.piece == piece:
			return stack
	return null

func _sort_stacks() -> void:
	stacks.sort_custom(func(left: UpgradePieceStack, right: UpgradePieceStack) -> bool: return left.piece.resource_path < right.piece.resource_path)
