class_name PieceClearContribution
extends RefCounted

var piece: PieceDefinition
var card: PieceCardState
var piece_instance_id: int = 0
var source_type: PieceSourceType.Value = PieceSourceType.Value.DRAWN_CARD
var modifiers: Array[PieceModifierDefinition] = []
var cleared_cells: Array[Vector2i] = []
var affected_rows: PackedInt32Array = PackedInt32Array()
var affected_columns: PackedInt32Array = PackedInt32Array()
var participated_in_cross_clear: bool = false
var all_remaining_cells_cleared: bool = false
