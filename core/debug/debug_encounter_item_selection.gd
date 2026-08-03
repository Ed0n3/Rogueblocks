class_name DebugEncounterItemSelection
extends RefCounted

var item: ItemDefinition
var quantity: int = 1
var bonus_piece: PieceDefinition

func _init(
	selected_item: ItemDefinition = null,
	selected_quantity: int = 1,
	selected_bonus_piece: PieceDefinition = null
) -> void:
	item = selected_item
	quantity = selected_quantity
	bonus_piece = selected_bonus_piece

func duplicate_selection() -> DebugEncounterItemSelection:
	return DebugEncounterItemSelection.new(item, quantity, bonus_piece)

func is_valid() -> bool:
	if item == null or item.display_name.is_empty():
		return false
	if quantity <= 0 or quantity > maxi(1, item.maximum_stack_size):
		return false
	if item.category == ItemCategory.Value.BONUS_BLOCK:
		return bonus_piece != null and bonus_piece.is_valid()
	return bonus_piece == null
