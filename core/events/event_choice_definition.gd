class_name EventChoiceDefinition
extends Resource

@export var choice_text: String
@export var result_preview: String
@export var shard_cost: int = 0
@export var health_cost: int = 0
@export var shard_reward: int = 0
@export var heal_amount: int = 0
@export var relic_reward: bool = false
@export var unlock_piece_for_run: bool = false
@export var remove_piece_from_pool: bool = false
@export var corrupted_cells_next_encounter: int = 0
@export var board_size_override: int = 0
@export var board_width_override: int = 0
@export var board_height_override: int = 0
@export var shard_reward_multiplier: float = 1.0
@export var maximum_health_reward: int = 0
@export var item_reward_count: int = 0
@export var cleanse_status_count: int = 0
@export var emergency_clear_reward: int = 0

func is_available(run_state: RunState) -> bool:
	return run_state.shards >= shard_cost and run_state.player_health > health_cost
