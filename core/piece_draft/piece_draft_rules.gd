class_name PieceDraftRules
extends Resource

@export_category("Draft Size")
@export_range(1, 30, 1) var candidate_count: int = 12
@export_range(1, 20, 1) var selection_count: int = 8
@export_range(1, 20, 1) var minimum_active_pool_size: int = 4
@export_range(1, 30, 1) var maximum_active_pool_size: int = 20

@export_category("Duplicate Blocks")
@export var allow_duplicate_pieces: bool = true
@export_range(1, 12, 1) var maximum_copies_per_piece: int = 3
@export_range(1, 12, 1) var minimum_distinct_piece_count: int = 4

@export_category("Piece Effects")
@export var random_effect_pool: Array[PieceCardEffectDefinition] = []
@export_range(0, 30, 1) var effect_candidate_count: int = 6
@export_range(0, 20, 1) var required_effect_selection_count: int = 4

@export_category("Composition")
@export var use_piece_draft_weights: bool = true
@export var prevent_all_small_piece_draft: bool = true
@export var prevent_all_large_piece_draft: bool = true
@export var required_piece_tags: Array[StringName] = []
@export var excluded_piece_tags: Array[StringName] = [&"tutorial_only"]
@export var excluded_pieces: Array[PieceDefinition] = []
@export_range(1, 100, 1) var validation_attempt_count: int = 8
