class_name EnemyActionSelector
extends RefCounted

func select_action(enemy: EnemyDefinition, phase_index: int, state: EncounterEffectState, board: BoardState, rng: RandomNumberGenerator, previous_action: EnemyActionDefinition, cooldowns: Array[EnemyActionCooldownState]) -> EnemyActionDefinition:
	var available: Array[EnemyActionDefinition] = []
	var total_weight: float = 0.0
	for action: EnemyActionDefinition in enemy.possible_actions:
		if _is_available(action, phase_index, state, board, previous_action, cooldowns):
			available.append(action)
			total_weight += maxf(0.0, action.weight)
	if available.is_empty() or total_weight <= 0.0:
		return enemy.fallback_action if _has_required_board_target(enemy.fallback_action, board) else null
	var roll: float = rng.randf_range(0.0, total_weight)
	for action: EnemyActionDefinition in available:
		roll -= maxf(0.0, action.weight)
		if roll <= 0.0:
			return action
	return available.back()

func advance_cooldowns(cooldowns: Array[EnemyActionCooldownState], selected: EnemyActionDefinition) -> void:
	for index: int in range(cooldowns.size() - 1, -1, -1):
		cooldowns[index].remaining_actions -= 1
		if cooldowns[index].remaining_actions <= 0:
			cooldowns.remove_at(index)
	if selected == null or selected.cooldown_actions <= 0:
		return
	var cooldown: EnemyActionCooldownState = EnemyActionCooldownState.new()
	cooldown.action = selected
	cooldown.remaining_actions = selected.cooldown_actions
	cooldowns.append(cooldown)

func resolve_intent(action: EnemyActionDefinition, turns_remaining: int) -> ResolvedEnemyIntent:
	var intent: ResolvedEnemyIntent = ResolvedEnemyIntent.new()
	if action == null:
		return intent
	intent.action = action
	intent.display_name = action.display_name
	intent.description = action.intent_description
	intent.action_tags = action.action_tags.duplicate()
	intent.turns_remaining = turns_remaining
	intent.direct_damage = action.direct_damage
	intent.healing_amount = action.enemy_healing
	intent.applied_statuses = action.applied_statuses.duplicate()
	intent.affected_cell_count = action.blocker_count + action.special_cell_count
	intent.counter_definition = action.counter_definition
	intent.icon_type = action.icon_type
	intent.accent_color = action.accent_color
	if action.counter_definition != null:
		for effect: GameplayEffect in action.counter_definition.failure_effects:
			if effect is DamageEffect and (effect as DamageEffect).target == EffectTarget.Value.PLAYER:
				intent.direct_damage += (effect as DamageEffect).amount
	for effect: GameplayEffect in action.effects:
		if effect is ShieldEffect:
			intent.shield_amount += (effect as ShieldEffect).amount
	return intent

func _is_available(action: EnemyActionDefinition, phase_index: int, state: EncounterEffectState, board: BoardState, previous_action: EnemyActionDefinition, cooldowns: Array[EnemyActionCooldownState]) -> bool:
	if action == null or action.minimum_phase > phase_index or action.weight <= 0.0:
		return false
	if action.cannot_repeat and action == previous_action:
		return false
	for cooldown: EnemyActionCooldownState in cooldowns:
		if cooldown.action == action and cooldown.remaining_actions > 0:
			return false
	var health_percent: float = float(state.enemy_health) / float(maxi(1, state.enemy_maximum_health))
	if health_percent < action.minimum_health_percent or health_percent > action.maximum_health_percent:
		return false
	if action.enemy_healing > 0 and state.enemy_health >= state.enemy_maximum_health:
		return false
	if action.disallow_while_shielded and state.enemy_shield > 0:
		return false
	if not _has_required_board_target(action, board):
		return false
	if action.disallow_status_refresh:
		for status: StatusDefinition in action.applied_statuses:
			if state.enemy_statuses.get_status(status) != null:
				return false
	for status: StatusDefinition in action.applied_statuses:
		var player_status: StatusInstance = state.player_statuses.get_status(status)
		if player_status != null and player_status.stacks >= status.maximum_stacks:
			return false
	for cooldown: EnemyActionCooldownState in cooldowns:
		if cooldown.action == action:
			return false
	return true

func _has_required_board_target(action: EnemyActionDefinition, board: BoardState) -> bool:
	if action == null or board == null:
		return false
	if action.requires_empty_cell and board.count_empty_cells() <= 0:
		return false
	if action.required_absent_block_flag != CellFlag.Value.NONE and not board.has_block_without_flag(action.required_absent_block_flag):
		return false
	return true
