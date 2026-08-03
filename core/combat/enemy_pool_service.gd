class_name EnemyPoolService
extends RefCounted

const TRAINING_SLIME: EnemyDefinition = preload("res://content/enemies/training_slime.tres")
const GRID_WARDEN: EnemyDefinition = preload("res://content/enemies/bosses/grid_warden.tres")
const ARCHITECT: EnemyDefinition = preload("res://content/enemies/bosses/architect.tres")
const ARCANE_SENTINEL: EnemyDefinition = preload("res://content/enemies/elites/arcane_sentinel.tres")
const ELITE_MASON: EnemyDefinition = preload("res://content/enemies/elites/elite_mason.tres")
const SURVEYOR: EnemyDefinition = preload("res://content/enemies/elites/surveyor.tres")
const MASON: EnemyDefinition = preload("res://content/enemies/mason.tres")
const HOARDER: EnemyDefinition = preload("res://content/enemies/hoarder.tres")
const DIVIDER: EnemyDefinition = preload("res://content/enemies/divider.tres")
const GUARANTEED_TRAINING_ENCOUNTER_LIMIT: int = 10

func select_for_node(run_state: RunState, node: RouteNodeState, profile: ProfileState, enemies: Array[EnemyDefinition]) -> EnemyDefinition:
	var role: EnemyDefinition.EncounterRole = _role_for_node(node)
	var additional_unlocks: Array[EnemyDefinition] = run_state.starting_modifiers.unlocked_enemies
	var recorded: EnemyDefinition = run_state.get_selected_enemy(node)
	if recorded != null and recorded.is_unlocked(profile, additional_unlocks) and recorded.is_available_in_act(node.act) and recorded.encounter_role == role:
		return recorded
	var pool: Array[EnemyDefinition] = []
	for enemy: EnemyDefinition in enemies:
		if not enemy.is_unlocked(profile, additional_unlocks) or not enemy.is_available_in_act(node.act) or enemy.encounter_role != role or enemy.selection_weight <= 0.0:
			continue
		if role == EnemyDefinition.EncounterRole.NORMAL and enemy == run_state.last_normal_enemy:
			continue
		if profile.completed_runs == 0 and run_state.encounter_index < 2 and enemy.mechanic_tier > run_state.encounter_index:
			continue
		pool.append(enemy)
	if profile.total_enemies_defeated <= GUARANTEED_TRAINING_ENCOUNTER_LIMIT and run_state.encounter_index == 0 and role == EnemyDefinition.EncounterRole.NORMAL:
		run_state.record_enemy_selection(node, TRAINING_SLIME, true)
		return TRAINING_SLIME
	if pool.is_empty():
		for enemy: EnemyDefinition in enemies:
			if enemy.is_unlocked(profile, additional_unlocks) and enemy.is_available_in_act(node.act) and enemy.encounter_role == role and enemy.selection_weight > 0.0:
				pool.append(enemy)
	if pool.is_empty():
		var fallback: EnemyDefinition = _legacy_fallback(role, node.act)
		if fallback != null and fallback.is_unlocked(profile, additional_unlocks):
			run_state.record_enemy_selection(node, fallback, role == EnemyDefinition.EncounterRole.NORMAL)
			return fallback
		return null
	pool.sort_custom(func(left: EnemyDefinition, right: EnemyDefinition) -> bool: return left.resource_path < right.resource_path)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = run_state.seed_value ^ node.act * 73856093 ^ node.column * 19349663 ^ node.row * 83492791 ^ (run_state.encounter_index * 7919)
	var total_weight: float = 0.0
	for enemy: EnemyDefinition in pool:
		total_weight += enemy.selection_weight
	var roll: float = rng.randf_range(0.0, total_weight)
	var selected: EnemyDefinition = pool.back()
	for enemy: EnemyDefinition in pool:
		roll -= enemy.selection_weight
		if roll <= 0.0:
			selected = enemy
			break
	run_state.record_enemy_selection(node, selected, role == EnemyDefinition.EncounterRole.NORMAL)
	return selected

func _role_for_node(node: RouteNodeState) -> EnemyDefinition.EncounterRole:
	if node.type == RouteNodeState.NodeType.BOSS:
		return EnemyDefinition.EncounterRole.BOSS
	if node.type == RouteNodeState.NodeType.ELITE_COMBAT or node.type == RouteNodeState.NodeType.CHALLENGE:
		return EnemyDefinition.EncounterRole.ELITE
	return EnemyDefinition.EncounterRole.NORMAL

func _legacy_fallback(role: EnemyDefinition.EncounterRole, act: int) -> EnemyDefinition:
	if role == EnemyDefinition.EncounterRole.BOSS:
		return GRID_WARDEN if act == 0 else ARCHITECT
	if role == EnemyDefinition.EncounterRole.ELITE:
		if act == 0:
			return ARCANE_SENTINEL
		if act == 1:
			return ELITE_MASON
		return SURVEYOR
	if act == 0:
		return TRAINING_SLIME
	if act == 1:
		return MASON
	if act == 2:
		return HOARDER
	return DIVIDER
