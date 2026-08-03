class_name GameRules
extends Resource

@export var board_width: int = 10
@export var board_height: int = 10
@export var starting_player_health: int = 20
@export var score_per_line_count: PackedInt32Array = PackedInt32Array([0, 100, 300, 600, 1000])
@export var damage_per_line_count: PackedInt32Array = PackedInt32Array([0, 1, 3, 6, 10])
@export var extra_score_per_line_after_four: int = 400
@export var extra_damage_per_line_after_four: int = 4
@export var cross_score_bonus: int = 150
@export var cross_damage_bonus: int = 2
@export var perfect_clear_score_bonus: int = 1000
@export var perfect_clear_damage_bonus: int = 5
@export var combo_score_multiplier_step: float = 0.2
@export var combo_damage_bonus_per_level: int = 1
@export var base_item_slots: int = 4
@export var maximum_item_slots: int = 8
@export var base_item_uses_per_turn: int = -1
@export var cross_status_duration_reduction: int = 1
@export var perfect_clear_shield: int = 3
@export var unknown_item_shard_compensation: int = 5
@export var boss_artifact_offer_count: int = 3
@export var maximum_active_boss_artifacts: int = 3
@export var piece_draft_rules: PieceDraftRules

func score_for_lines(line_count: int) -> int:
	return _indexed_value(score_per_line_count, line_count, extra_score_per_line_after_four)

func damage_for_lines(line_count: int) -> int:
	return _indexed_value(damage_per_line_count, line_count, extra_damage_per_line_after_four)

func _indexed_value(values: PackedInt32Array, line_count: int, extra: int) -> int:
	if line_count <= 0 or values.is_empty():
		return 0
	var index: int = mini(line_count, values.size() - 1)
	var result: int = values[index]
	if line_count > values.size() - 1:
		result += (line_count - values.size() + 1) * extra
	return result
