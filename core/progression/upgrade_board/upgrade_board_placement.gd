class_name UpgradeBoardPlacement
extends RefCounted

var placement_token: int
var piece: PieceDefinition
var origin: Vector2i
var rotation_index: int

func _init(
	placement_piece: PieceDefinition = null,
	placement_origin: Vector2i = Vector2i.ZERO,
	placement_rotation_index: int = 0,
	stable_placement_token: int = 0
) -> void:
	placement_token = stable_placement_token
	piece = placement_piece
	origin = placement_origin
	rotation_index = placement_rotation_index

func duplicate_placement() -> UpgradeBoardPlacement:
	return UpgradeBoardPlacement.new(piece, origin, rotation_index, placement_token)

func to_save_data() -> Dictionary:
	return {
		"placement_token": placement_token,
		"piece": ContentReferenceCodec.encode(piece),
		"origin_x": origin.x,
		"origin_y": origin.y,
		"rotation_index": rotation_index,
	}

static func from_save_data(data: Dictionary) -> UpgradeBoardPlacement:
	return UpgradeBoardPlacement.new(
		ContentReferenceCodec.decode_legacy(String(data.get("piece", data.get("piece_id", ""))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition,
		Vector2i(int(data.get("origin_x", 0)), int(data.get("origin_y", 0))),
		int(data.get("rotation_index", 0)),
		int(data.get("placement_token", String(data.get("placement_id", "")).hash()))
	)
