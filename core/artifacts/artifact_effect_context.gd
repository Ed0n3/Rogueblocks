class_name ArtifactEffectContext
extends RefCounted

var run_state: RunState
var artifact_state: BossArtifactState
var board: BoardState
var rng: RandomNumberGenerator
var placed_piece: PieceDefinition
var piece_source_type: PieceSourceType.Value = PieceSourceType.Value.DRAWN_CARD
var clear_result: ClearResult
var draw_count: int = 0
var maximum_placement_points: int = 0
var redraw_placement_point_cost: int = 0
var free_redraws_per_turn: int = 0
var countdown_step: int = 0
var activated: bool = false
var activated_artifact: BossArtifactDefinition
var activation_message: String
var combo_level: int = 0
var preserve_combo: bool = false
var enemy_status: StatusDefinition
var enemy_status_duration: int = 0
var enemy_status_stacks: int = 1
