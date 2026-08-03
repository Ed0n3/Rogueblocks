class_name PieceTargetRequest
extends Resource

@export var selection_mode: PieceTargetSelectionMode.Value = PieceTargetSelectionMode.Value.RANDOM_ONE
@export_range(1, 10) var candidate_count: int = 3
@export_range(1, 5) var selection_count: int = 1
@export var allowed_piece_tags: Array[StringName] = []
@export var excluded_piece_tags: Array[StringName] = []
@export var excluded_pieces: Array[PieceDefinition] = []
@export var minimum_cell_count: int = 0
@export var maximum_cell_count: int = 0
@export var include_temporarily_removed_pieces: bool = false
@export var prefer_unmodified_pieces: bool = true
@export var allow_same_piece_for_multiple_relics: bool = true
