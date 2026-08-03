class_name ItemStack
extends RefCounted

var definition: ItemDefinition
var quantity: int = 1
var bonus_piece: PieceDefinition

func is_compatible(other: ItemStack) -> bool:
	return other != null and definition == other.definition and bonus_piece == other.bonus_piece

func to_save_data() -> Dictionary:
	return {"definition": ContentReferenceCodec.encode(definition), "quantity": quantity, "bonus_piece": ContentReferenceCodec.encode(bonus_piece)}

static func from_save_data(data: Dictionary) -> ItemStack:
	var stack: ItemStack = ItemStack.new()
	stack.definition = ContentReferenceCodec.decode_legacy(String(data.get("definition", data.get("item_id", ""))), ItemDefinition, ContentRegistry.catalog) as ItemDefinition
	stack.quantity = maxi(0, int(data.get("quantity", 0)))
	stack.bonus_piece = ContentReferenceCodec.decode_legacy(String(data.get("bonus_piece", data.get("piece_id", ""))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
	return stack
