class_name ClearResult
extends RefCounted

var completed_rows: PackedInt32Array = PackedInt32Array()
var completed_columns: PackedInt32Array = PackedInt32Array()
var cleared_cells: Array[Vector2i] = []
var line_count: int = 0
var cleared_cell_count: int = 0
var cross_clear: bool = false
var perfect_clear: bool = false
var shard_reward: int = 0
var player_damage: int = 0
var targets_cleared: int = 0
var blockers_destroyed: int = 0
var poisoned_block_count: int = 0
var poisoned_block_damage: int = 0
var poison_damage_source_cells: Array[Vector2i] = []
var electrified_block_count: int = 0
var electrified_source_cells: Array[Vector2i] = []
var cleared_pieces: Array[PieceDefinition] = []
var cleared_piece_instance_ids: PackedInt64Array = PackedInt64Array()
var piece_contributions: Array[PieceClearContribution] = []
