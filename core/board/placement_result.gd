class_name PlacementResult
extends RefCounted

var success: bool = false
var origin: Vector2i = Vector2i.ZERO
var placed_cells: Array[Vector2i] = []
var piece: PieceDefinition
var card_id: int = 0
var piece_instance_id: int = 0
var source_type: PieceSourceType.Value = PieceSourceType.Value.DRAWN_CARD
var failure_reason: String = ""
