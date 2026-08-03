class_name DebugEncounterBuilder
extends RefCounted

var last_error: String

func validate(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules, game_rules: GameRules) -> String:
	if configuration == null:
		return "Debug encounter configuration is unavailable"
	if rules == null:
		return "Debug encounter rules are unavailable"
	if game_rules == null:
		return "Game rules are unavailable"
	if rules.minimum_piece_count <= 0:
		return "Minimum piece count must be positive"
	if rules.maximum_piece_count < rules.minimum_piece_count:
		return "Maximum piece count cannot be lower than the minimum"
	if rules.default_piece_count < rules.minimum_piece_count or rules.default_piece_count > rules.maximum_piece_count:
		return "Default piece count must be within the configured limits"
	if rules.maximum_repeatable_relic_copies <= 0:
		return "Maximum repeatable relic copies must be positive"
	if rules.maximum_item_slots <= 0:
		return "Maximum item slots must be positive"
	if rules.default_player_health < 0 or rules.default_player_shield < 0:
		return "Default player health and shield cannot be negative"
	if rules.default_board_width < 0 or rules.default_board_height < 0:
		return "Default board dimensions cannot be negative"
	if rules.artifact_obtained_act < 0:
		return "Artifact obtained act cannot be negative"
	if configuration.player_health < 0:
		return "Player health cannot be negative"
	if configuration.player_shield < -1:
		return "Player shield cannot be lower than its default sentinel"
	if configuration.board_width < 0 or configuration.board_height < 0:
		return "Board dimensions cannot be negative"
	var enemy: EnemyDefinition = configuration.enemy if configuration.enemy != null else rules.default_enemy
	if enemy == null or not enemy.is_valid():
		return "A valid enemy must be selected"
	var selections: Array[DebugEncounterPieceSelection] = _resolved_piece_selections(configuration, rules)
	if selections.size() < rules.minimum_piece_count or selections.size() > rules.maximum_piece_count:
		return "Piece count must be between %d and %d" % [rules.minimum_piece_count, rules.maximum_piece_count]
	for selection: DebugEncounterPieceSelection in selections:
		if selection == null or not selection.is_valid(rules.allow_incompatible_effects):
			return "Every selected piece and effect combination must be valid"
	var item_error: String = _validate_items(configuration.items, mini(rules.maximum_item_slots, game_rules.maximum_item_slots))
	if not item_error.is_empty():
		return item_error
	if _resolved_player_health(configuration, rules, game_rules) <= 0:
		return "Player health must be positive"
	if _resolved_player_shield(configuration, rules) < 0:
		return "Player shield cannot be negative"
	if _resolved_board_width(configuration, rules, game_rules) <= 0 or _resolved_board_height(configuration, rules, game_rules) <= 0:
		return "Board dimensions must be positive"
	var artifact_error: String = _validate_artifacts(configuration.artifacts, game_rules)
	if not artifact_error.is_empty():
		return artifact_error
	var relic_error: String = _validate_relics(configuration.relics, configuration.artifacts, rules.maximum_repeatable_relic_copies)
	if not relic_error.is_empty():
		return relic_error
	return String()

func _validate_relics(relics: Array[RelicDefinition], artifacts: Array[BossArtifactDefinition], maximum_repeatable_copies: int) -> String:
	for index: int in relics.size():
		var relic: RelicDefinition = relics[index]
		if relic == null:
			return "Selected relics cannot be empty"
		var copy_count: int = relics.count(relic)
		if copy_count > 1 and not relic.repeatable:
			return "%s cannot be selected more than once" % relic.display_name
		if copy_count > maximum_repeatable_copies:
			return "%s cannot have more than %d stacks" % [relic.display_name, maximum_repeatable_copies]
		if relics.find(relic) != index:
			continue
		for required_artifact: BossArtifactDefinition in relic.required_artifacts:
			if not artifacts.has(required_artifact):
				return "%s requires %s" % [relic.display_name, required_artifact.display_name]
	return String()

func create_run(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules, game_rules: GameRules) -> RunState:
	last_error = validate(configuration, rules, game_rules)
	if not last_error.is_empty():
		return null
	var run_state: RunState = RunState.new()
	run_state.game_rules = game_rules
	run_state.debug_run = true
	run_state.run_mode = RunMode.Value.DEBUG
	run_state.seed_value = _resolved_seed(configuration, rules)
	if configuration.difficulty != null:
		run_state.difficulty = configuration.difficulty
	var player_health: int = _resolved_player_health(configuration, rules, game_rules)
	run_state.apply_starting_modifiers(StartingRunModifiers.new(), player_health)
	run_state.player_shield = _resolved_player_shield(configuration, rules)
	run_state.pending_board_width = _resolved_board_width(configuration, rules, game_rules)
	run_state.pending_board_height = _resolved_board_height(configuration, rules, game_rules)
	run_state.minimum_active_piece_pool_size = rules.minimum_piece_count
	run_state.maximum_active_piece_pool_size = rules.maximum_piece_count
	var selections: Array[DebugEncounterPieceSelection] = _resolved_piece_selections(configuration, rules)
	run_state.maximum_piece_copies = maxi(run_state.maximum_piece_copies, selections.size())
	_initialize_deck(run_state, selections)
	for artifact: BossArtifactDefinition in configuration.artifacts:
		if not run_state.add_artifact(artifact, rules.artifact_obtained_act):
			last_error = "Could not add artifact %s" % artifact.display_name
			return null
	for relic: RelicDefinition in _ordered_relics(configuration.relics):
		relic.apply(run_state, rules.relic_source_description)
		if not _resolve_pending_relic_selections(run_state):
			return null
	if _has_pending_relic_selection(run_state):
		last_error = "Relic selections must be resolved before combat"
		return null
	if not _initialize_items(run_state, configuration.items):
		return null
	return run_state

func _validate_items(items: Array[DebugEncounterItemSelection], maximum_item_slots: int) -> String:
	if items.size() > maximum_item_slots:
		return "No more than %d item stacks can be selected" % maximum_item_slots
	for index: int in items.size():
		var selection: DebugEncounterItemSelection = items[index]
		if selection == null or not selection.is_valid():
			return "Every selected item stack must be valid"
		for previous_index: int in index:
			var previous: DebugEncounterItemSelection = items[previous_index]
			if previous != null and previous.item == selection.item:
				return "The same item cannot occupy multiple configured stacks"
	return String()

func _initialize_items(run_state: RunState, selections: Array[DebugEncounterItemSelection]) -> bool:
	var required_capacity: int = maxi(run_state.inventory.capacity, selections.size())
	if required_capacity > run_state.inventory.maximum_capacity:
		last_error = "Selected items exceed the run inventory capacity"
		return false
	run_state.inventory.expand(required_capacity - run_state.inventory.capacity)
	for selection: DebugEncounterItemSelection in selections:
		var stack: ItemStack = ItemStack.new()
		stack.definition = selection.item
		stack.quantity = selection.quantity
		stack.bonus_piece = selection.bonus_piece
		var add_result: InventoryAddResult = run_state.inventory.add(stack, run_state.starting_modifiers.potion_stack_limit_bonus)
		if not add_result.added:
			last_error = "Could not add item %s to the test inventory" % selection.item.display_name
			return false
	return true

func _initialize_deck(run_state: RunState, selections: Array[DebugEncounterPieceSelection]) -> void:
	run_state.deck_cards.clear()
	run_state.next_piece_card_id = 1
	for selection: DebugEncounterPieceSelection in selections:
		var card: PieceCardState = PieceCardState.new()
		card.card_id = run_state.allocate_piece_card_id()
		card.piece = selection.piece
		card.intrinsic_effect = selection.resolved_effect()
		card.origin = PieceCardState.Origin.STARTING_DRAFT
		card.is_starting_card = true
		run_state.deck_cards.append(card)
	run_state.piece_pool_changed.emit()

func _resolve_pending_relic_selections(run_state: RunState) -> bool:
	for modifier_state: PieceModifierState in run_state.piece_modifiers:
		if not modifier_state.pending_selection:
			continue
		var selected_pieces: Array[PieceDefinition] = []
		var selected_count: int = mini(modifier_state.required_selection_count, modifier_state.candidate_pieces.size())
		for index: int in selected_count:
			selected_pieces.append(modifier_state.candidate_pieces[index])
		if selected_pieces.size() != modifier_state.required_selection_count or not run_state.resolve_piece_modifier_selection(modifier_state.definition, selected_pieces):
			last_error = "Could not resolve the Block selection for a relic"
			return false
	if run_state.pending_piece_addition != null:
		if not _resolve_pending_piece_addition(run_state):
			return false
	return true

func _resolve_pending_piece_addition(run_state: RunState) -> bool:
	var pending: PendingPieceAdditionState = run_state.pending_piece_addition
	var selected_count: int = mini(pending.required_selection_count, pending.candidate_pieces.size())
	if selected_count != pending.required_selection_count:
		last_error = "Could not resolve the Block addition for a relic"
		return false
	pending.selected_pieces.clear()
	for index: int in selected_count:
		pending.selected_pieces.append(pending.candidate_pieces[index])
	var selected_pieces: Array[PieceDefinition] = pending.selected_pieces.duplicate()
	for piece: PieceDefinition in selected_pieces:
		var result: PiecePoolChangeResult = PiecePoolService.new().add_piece(run_state, piece, pending.source_relic, false, pending.temporary)
		if not result.changed:
			last_error = "Could not add the selected Block for a relic"
			return false
		if not is_equal_approx(pending.score_multiplier, 1.0) or pending.granted_modifier != null:
			var modifier: PieceModifierState = PieceModifierState.new()
			modifier.definition = pending.granted_modifier
			modifier.source_relic = pending.source_relic
			modifier.target_pieces = [piece]
			modifier.score_multiplier = pending.score_multiplier
			modifier.expires_after_act = pending.modifier_expires_after_act
			run_state.add_piece_modifier(modifier)
	run_state.pending_piece_addition = null
	return true

func _ordered_relics(relics: Array[RelicDefinition]) -> Array[RelicDefinition]:
	var ordered: Array[RelicDefinition] = relics.duplicate()
	ordered.sort_custom(_relic_precedes)
	return ordered

func _relic_precedes(left: RelicDefinition, right: RelicDefinition) -> bool:
	if left == null:
		return false
	if right == null:
		return true
	if left.trigger_priority != right.trigger_priority:
		return left.trigger_priority < right.trigger_priority
	if left.resource_path == right.resource_path:
		return left.display_name.naturalnocasecmp_to(right.display_name) < 0
	return left.resource_path < right.resource_path

func _has_pending_relic_selection(run_state: RunState) -> bool:
	if run_state.pending_piece_addition != null or run_state.pending_piece_selection_flow != PieceSelectionFlow.Value.NONE:
		return true
	for modifier_state: PieceModifierState in run_state.piece_modifiers:
		if modifier_state.pending_selection:
			return true
	return false

func _resolved_piece_selections(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules) -> Array[DebugEncounterPieceSelection]:
	if not configuration.pieces.is_empty():
		return configuration.pieces
	var selections: Array[DebugEncounterPieceSelection] = []
	if rules.default_pieces.is_empty():
		return selections
	for index: int in rules.default_piece_count:
		var piece: PieceDefinition = rules.default_pieces[index % rules.default_pieces.size()]
		selections.append(DebugEncounterPieceSelection.new(piece))
	return selections

func _resolved_seed(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules) -> int:
	if configuration.seed_value != 0:
		return configuration.seed_value
	return rules.default_seed if rules.default_seed != 0 else 1

func _resolved_player_health(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules, game_rules: GameRules) -> int:
	if configuration.player_health > 0:
		return configuration.player_health
	if rules.default_player_health > 0:
		return rules.default_player_health
	return game_rules.starting_player_health

func _resolved_player_shield(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules) -> int:
	return configuration.player_shield if configuration.player_shield >= 0 else rules.default_player_shield

func _resolved_board_width(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules, game_rules: GameRules) -> int:
	if configuration.board_width > 0:
		return configuration.board_width
	if rules.default_board_width > 0:
		return rules.default_board_width
	return game_rules.board_width

func _resolved_board_height(configuration: DebugEncounterConfiguration, rules: DebugEncounterRules, game_rules: GameRules) -> int:
	if configuration.board_height > 0:
		return configuration.board_height
	if rules.default_board_height > 0:
		return rules.default_board_height
	return game_rules.board_height

func _validate_artifacts(artifacts: Array[BossArtifactDefinition], game_rules: GameRules) -> String:
	if artifacts.size() > game_rules.maximum_active_boss_artifacts:
		return "No more than %d artifacts can be selected" % game_rules.maximum_active_boss_artifacts
	for index: int in artifacts.size():
		var artifact: BossArtifactDefinition = artifacts[index]
		if artifact == null or not artifact.is_valid():
			return "Selected artifacts must be valid"
		if artifacts.find(artifact) != index:
			return "The same artifact cannot be selected more than once"
		for other_index: int in range(index):
			var other: BossArtifactDefinition = artifacts[other_index]
			if artifact.incompatible_artifacts.has(other) or other.incompatible_artifacts.has(artifact):
				return "%s is incompatible with %s" % [artifact.display_name, other.display_name]
	return String()
