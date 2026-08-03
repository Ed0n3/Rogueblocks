class_name ProgressionRules
extends Resource

@export var normal_enemy_fragments: int = 1
@export var elite_enemy_fragments: int = 3
@export var boss_fragments: int = 5
@export var run_victory_fragments: int = 10
@export var first_enemy_victory_fragments: int = 2
@export var run_history_limit: int = 50

func calculate_run_fragments(run_state: RunState, won: bool, multiplier: float) -> int:
	var normal_count: int = mini(run_state.enemies_defeated, 3)
	var reward: int = normal_count * normal_enemy_fragments
	if normal_count > 0:
		reward += first_enemy_victory_fragments
	if run_state.enemies_defeated >= 4:
		reward += elite_enemy_fragments
	if won:
		reward += run_victory_fragments
	return floori(float(reward) * multiplier)
