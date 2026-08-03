class_name TutorialValidator
extends RefCounted

func validate_all(definitions: Array[TutorialDefinition]) -> PackedStringArray:
	var errors: PackedStringArray = []
	for definition: TutorialDefinition in definitions:
		if definition == null:
			errors.append("Tutorial catalog contains an empty resource")
			continue
		errors.append_array(_validate_definition(definition))
		for prerequisite: TutorialDefinition in definition.prerequisite_tutorials:
			if prerequisite == null or not definitions.has(prerequisite):
				errors.append("%s references a missing prerequisite" % definition.display_name)
		if _has_prerequisite_cycle(definition, []):
			errors.append("Tutorial prerequisite cycle includes %s" % definition.display_name)
	return errors

func _validate_definition(definition: TutorialDefinition) -> PackedStringArray:
	var errors: PackedStringArray = []
	if definition.display_name.strip_edges().is_empty():
		errors.append("Tutorial is missing a display name")
	if definition.steps.is_empty():
		errors.append("%s has no steps" % definition.display_name)
	if _requires_activation_event(definition.activation_mode) and definition.activation_event == TutorialEventId.Value.NONE:
		errors.append("%s requires an activation event" % definition.display_name)
	if definition.repeat_policy == TutorialRepeatPolicy.Value.MANUAL_ONLY and definition.activation_mode != TutorialActivationMode.Value.MANUAL and definition.activation_mode != TutorialActivationMode.Value.DEBUG_ONLY:
		errors.append("%s is manual-only but uses automatic activation" % definition.display_name)
	var has_restricted_step: bool = false
	errors.append_array(_validate_conditions(definition, null, definition.availability_conditions))
	for step: TutorialStepDefinition in definition.steps:
		if step == null:
			errors.append("%s contains an empty step" % definition.display_name)
			continue
		if step.title.strip_edges().is_empty() and step.body.strip_edges().is_empty():
			errors.append("%s contains a step without text" % definition.display_name)
		if step.input_mode != TutorialInputMode.Value.NORMAL_GAMEPLAY and step.input_mode != TutorialInputMode.Value.NORMAL_WITH_HINT:
			has_restricted_step = true
		if step.input_mode == TutorialInputMode.Value.FULLY_BLOCKED and not step.wait_for_player_confirmation and step.completion_conditions.is_empty() and step.auto_advance_delay <= 0.0:
			errors.append("%s contains a blocking step without completion" % definition.display_name)
		if step.input_mode == TutorialInputMode.Value.TARGET_ONLY and (step.target == null or step.target.target_key == TutorialTargetKey.Value.NONE):
			errors.append("%s limits input to a missing target" % definition.display_name)
		if step.input_mode == TutorialInputMode.Value.ACTIONS_ONLY and step.allowed_input_actions.is_empty():
			errors.append("%s limits input without allowed actions" % definition.display_name)
		if step.auto_advance_delay < 0.0 or step.fallback_timeout < 0.0:
			errors.append("%s uses a negative tutorial timeout" % definition.display_name)
		if step.target != null:
			errors.append_array(_validate_target(definition, step, step.target))
		for input_target: TutorialTarget in step.additional_input_targets:
			if input_target == null:
				errors.append("%s contains an empty additional input target" % definition.display_name)
			else:
				errors.append_array(_validate_target(definition, step, input_target))
		errors.append_array(_validate_conditions(definition, step, step.completion_conditions))
		errors.append_array(_validate_actions(definition, step.entry_actions))
		errors.append_array(_validate_actions(definition, step.completion_actions))
		errors.append_array(_validate_actions(definition, step.exit_actions))
		if step.fallback_step != null and not definition.steps.has(step.fallback_step):
			errors.append("%s references a fallback outside its steps" % definition.display_name)
	if has_restricted_step and not definition.blocks_gameplay:
		errors.append("%s restricts input but does not block gameplay" % definition.display_name)
	return errors

func _requires_activation_event(mode: TutorialActivationMode.Value) -> bool:
	return mode == TutorialActivationMode.Value.CONTEXTUAL_EVENT or mode == TutorialActivationMode.Value.FIRST_MECHANIC_APPEARANCE or mode == TutorialActivationMode.Value.FIRST_SCREEN_VISIT

func _validate_target(tutorial: TutorialDefinition, _step: TutorialStepDefinition, target: TutorialTarget) -> PackedStringArray:
	var errors: PackedStringArray = []
	if not TutorialReplayContext.supports_target(tutorial.replay_context, target.target_key):
		errors.append("%s targets a control outside its replay scene" % tutorial.display_name)
	if target.padding < 0.0:
		errors.append("%s uses negative target padding" % tutorial.display_name)
	if target.target_type == TutorialTargetType.Value.BOARD_ROW and target.board_row < 0:
		errors.append("%s has a board-row target without a row" % tutorial.display_name)
	if target.target_type == TutorialTargetType.Value.BOARD_COLUMN and target.board_column < 0:
		errors.append("%s has a board-column target without a column" % tutorial.display_name)
	if target.target_type == TutorialTargetType.Value.BOARD_CELL_SET and target.board_cells.is_empty():
		errors.append("%s has an empty board-cell target" % tutorial.display_name)
	return errors

func _validate_conditions(tutorial: TutorialDefinition, _step: TutorialStepDefinition, conditions: Array[TutorialCondition]) -> PackedStringArray:
	var errors: PackedStringArray = []
	for condition: TutorialCondition in conditions:
		if condition == null:
			errors.append("%s contains an empty condition" % tutorial.display_name)
		elif condition is EventOccurredCondition and (condition as EventOccurredCondition).event_type == TutorialEventId.Value.NONE:
			errors.append("%s waits for an empty event" % tutorial.display_name)
	return errors

func _validate_actions(tutorial: TutorialDefinition, actions: Array[TutorialAction]) -> PackedStringArray:
	var errors: PackedStringArray = []
	for action: TutorialAction in actions:
		if action == null:
			errors.append("%s contains an empty tutorial action" % tutorial.display_name)
			continue
		var sandbox_action: TutorialSandboxAction = action as TutorialSandboxAction
		if sandbox_action == null or sandbox_action.pieces.is_empty():
			continue
		if sandbox_action.command != TutorialSandboxAction.Command.INJECT_HAND and sandbox_action.command != TutorialSandboxAction.Command.ADD_DISCARD_CARDS:
			errors.append("%s configures tutorial Pieces for an action that does not use them" % tutorial.display_name)
	return errors

func _has_prerequisite_cycle(definition: TutorialDefinition, path: Array[TutorialDefinition]) -> bool:
	if path.has(definition):
		return true
	var next_path: Array[TutorialDefinition] = path.duplicate()
	next_path.append(definition)
	for prerequisite: TutorialDefinition in definition.prerequisite_tutorials:
		if prerequisite != null and _has_prerequisite_cycle(prerequisite, next_path):
			return true
	return false
