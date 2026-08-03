class_name DebugEncounterRules
extends Resource

@export_category("Default Content")
@export var default_enemy: EnemyDefinition
@export var default_pieces: Array[PieceDefinition] = []

@export_category("Piece Pile")
@export_range(1, 64, 1) var minimum_piece_count: int = 1
@export_range(1, 64, 1) var maximum_piece_count: int = 12
@export_range(1, 64, 1) var default_piece_count: int = 8
@export_range(1, 16, 1) var maximum_repeatable_relic_copies: int = 8

@export_category("Items")
## Maximum number of distinct item stacks that can be loaded into a test encounter.
@export_range(1, 16, 1) var maximum_item_slots: int = 8

@export_category("Encounter")
@export var default_seed: int = 1
@export_range(0, 999, 1) var default_player_health: int = 0
@export_range(0, 999, 1) var default_player_shield: int = 0
@export_range(0, 64, 1) var default_board_width: int = 0
@export_range(0, 64, 1) var default_board_height: int = 0
@export_range(0, 99, 1) var artifact_obtained_act: int = 0

@export_category("Resolution")
@export var allow_incompatible_effects: bool = false
@export var relic_source_description: String = "Test Area"
