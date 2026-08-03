class_name PieceModifierService
extends RefCounted

func resolve_after_clear(run_state: RunState, clear: ClearResult, context: EffectContext) -> PieceModifierTriggerResult:
	var result: PieceModifierTriggerResult = PieceModifierTriggerResult.new()
	var states: Array[PieceModifierState] = run_state.piece_modifiers.duplicate()
	states.sort_custom(func(left: PieceModifierState, right: PieceModifierState) -> bool:
		var left_definition: PieceModifierDefinition = left.definition
		var right_definition: PieceModifierDefinition = right.definition
		var left_priority: int = left_definition.priority if left_definition != null else 0
		var right_priority: int = right_definition.priority if right_definition != null else 0
		var left_path: String = left_definition.resource_path if left_definition != null else String()
		var right_path: String = right_definition.resource_path if right_definition != null else String()
		return left_priority < right_priority or left_priority == right_priority and left_path < right_path)
	for state: PieceModifierState in states:
		var definition: PieceModifierDefinition = state.definition
		if definition == null or state.remaining_charges == 0 or definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_ENCOUNTER and state.encounter_trigger_count > 0 or definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_TURN and state.last_trigger_turn == context.current_turn:
			continue
		if _uses_line_based_resolution(definition):
			_resolve_line_effects(state, definition, clear, context, result)
			continue
		for contribution: PieceClearContribution in clear.piece_contributions:
			if not state.target_pieces.has(contribution.piece) or definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_PIECE_INSTANCE and state.triggered_piece_instance_ids.has(contribution.piece_instance_id) or not _matches_trigger(definition, contribution, clear):
				continue
			context.source = definition
			var repeat_count: int = _repeat_count(definition, contribution)
			for repeat_index: int in repeat_count:
				for effect: GameplayEffect in definition.effects:
					if effect != null and effect.can_apply(context):
						result.merge_effect(definition, effect.apply(context))
			state.trigger_count += 1
			state.encounter_trigger_count += 1
			state.last_trigger_turn = context.current_turn
			if definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_PIECE_INSTANCE:
				state.triggered_piece_instance_ids.append(contribution.piece_instance_id)
			if state.remaining_charges > 0:
				state.remaining_charges -= 1
			if definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_TURN or definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_ENCOUNTER:
				break
	return result

func _resolve_line_effects(state: PieceModifierState, definition: PieceModifierDefinition, clear: ClearResult, context: EffectContext, result: PieceModifierTriggerResult) -> void:
	var affected_lines: Dictionary[Vector2i, bool] = {}
	var contributing_instance_ids: PackedInt64Array = PackedInt64Array()
	for contribution: PieceClearContribution in clear.piece_contributions:
		if not state.target_pieces.has(contribution.piece) or not _matches_trigger(definition, contribution, clear):
			continue
		if definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_PIECE_INSTANCE and state.triggered_piece_instance_ids.has(contribution.piece_instance_id):
			continue
		contributing_instance_ids.append(contribution.piece_instance_id)
		for row: int in contribution.affected_rows:
			affected_lines[Vector2i(0, row)] = true
		for column: int in contribution.affected_columns:
			affected_lines[Vector2i(1, column)] = true
	var line_count: int = affected_lines.size()
	if definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_TURN or definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_ENCOUNTER:
		line_count = mini(1, line_count)
	context.source = definition
	for line_index: int in line_count:
		if state.remaining_charges == 0:
			break
		for effect: GameplayEffect in definition.effects:
			if effect != null and effect.can_apply(context):
				result.merge_effect(definition, effect.apply(context))
		state.trigger_count += 1
		state.encounter_trigger_count += 1
		state.last_trigger_turn = context.current_turn
		if state.remaining_charges > 0:
			state.remaining_charges -= 1
	if definition.trigger_limit == PieceModifierTriggerLimit.Value.ONCE_PER_PIECE_INSTANCE:
		for instance_id: int in contributing_instance_ids:
			if not state.triggered_piece_instance_ids.has(instance_id):
				state.triggered_piece_instance_ids.append(instance_id)

func _uses_line_based_resolution(definition: PieceModifierDefinition) -> bool:
	for effect: GameplayEffect in definition.effects:
		if effect is DamageEffect:
			return true
		var status_effect: ApplyStatusEffect = effect as ApplyStatusEffect
		if status_effect != null and status_effect.status != null and status_effect.status.tags.has(&"damage_over_time"):
			return true
	return false

func reset_encounter(run_state: RunState) -> void:
	for state: PieceModifierState in run_state.piece_modifiers:
		state.encounter_trigger_count = 0
		state.triggered_piece_instance_ids.clear()
		state.last_trigger_turn = -1

func _matches_trigger(definition: PieceModifierDefinition, contribution: PieceClearContribution, clear: ClearResult) -> bool:
	match definition.trigger_mode:
		PieceModifierTriggerMode.Value.ON_FULL_PIECE_REMOVAL:
			return contribution.all_remaining_cells_cleared
		PieceModifierTriggerMode.Value.ON_CROSS_CLEAR_PARTICIPATION:
			return contribution.participated_in_cross_clear
		PieceModifierTriggerMode.Value.ON_PERFECT_CLEAR_PARTICIPATION:
			return clear.perfect_clear
		PieceModifierTriggerMode.Value.ON_PLACEMENT:
			return false
	return true

func _repeat_count(definition: PieceModifierDefinition, contribution: PieceClearContribution) -> int:
	if definition.trigger_mode == PieceModifierTriggerMode.Value.ON_EACH_CLEARED_LINE:
		return maxi(1, contribution.affected_rows.size() + contribution.affected_columns.size())
	if definition.trigger_mode == PieceModifierTriggerMode.Value.ON_CLEARED_CELL_COUNT:
		return maxi(1, contribution.cleared_cells.size())
	return 1
