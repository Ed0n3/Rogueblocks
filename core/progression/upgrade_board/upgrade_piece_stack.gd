class_name UpgradePieceStack
extends RefCounted

var piece: PieceDefinition
var quantity: int

func _init(definition: PieceDefinition = null, stack_quantity: int = 0) -> void:
	piece = definition
	quantity = maxi(0, stack_quantity)

func duplicate_stack() -> UpgradePieceStack:
	return UpgradePieceStack.new(piece, quantity)

func to_save_data() -> Dictionary:
	return {
		"piece": ContentReferenceCodec.encode(piece),
		"quantity": quantity,
	}

static func from_save_data(data: Dictionary) -> UpgradePieceStack:
	return UpgradePieceStack.new(
		ContentReferenceCodec.decode_legacy(String(data.get("piece", data.get("piece_id", ""))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition,
		maxi(0, int(data.get("quantity", 0)))
	)
