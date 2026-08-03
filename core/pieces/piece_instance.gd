class_name PieceInstance
extends RefCounted

var definition: PieceDefinition
var card: PieceCardState
var rotation_index: int = 0
var unique_rotations: Array[Array] = []
var instance_id: int = 0
var source_type: PieceSourceType.Value = PieceSourceType.Value.DRAWN_CARD
var modifiers: Array[PieceModifierDefinition] = []

func _init(piece_definition: PieceDefinition = null) -> void:
	definition = piece_definition
	if definition != null:
		unique_rotations = PieceRotationService.get_unique_rotations(definition)

func bind_card(piece_card: PieceCardState) -> void:
	card = piece_card
	definition = card.piece if card != null else null
	unique_rotations = PieceRotationService.get_unique_rotations(definition) if definition != null else []
	rotation_index = 0

func get_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if unique_rotations.is_empty():
		return result
	for cell: Variant in unique_rotations[rotation_index]:
		result.append(cell as Vector2i)
	return result

func rotate_clockwise() -> void:
	if not unique_rotations.is_empty():
		rotation_index = (rotation_index + 1) % unique_rotations.size()

func rotate_counterclockwise() -> void:
	if not unique_rotations.is_empty():
		rotation_index = posmod(rotation_index - 1, unique_rotations.size())

func get_size() -> Vector2i:
	var size: Vector2i = Vector2i.ZERO
	for cell: Vector2i in get_cells():
		size.x = maxi(size.x, cell.x + 1)
		size.y = maxi(size.y, cell.y + 1)
	return size

func duplicate_instance() -> PieceInstance:
	var copy: PieceInstance = PieceInstance.new(definition)
	copy.card = card
	copy.rotation_index = rotation_index
	copy.instance_id = instance_id
	copy.source_type = source_type
	copy.modifiers = modifiers.duplicate()
	return copy
