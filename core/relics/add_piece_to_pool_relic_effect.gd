class_name AddPieceToPoolRelicEffect
extends RelicEffect

@export var selection_mode: PieceAdditionSelectionMode.Value = PieceAdditionSelectionMode.Value.RANDOM_ONE
@export var candidate_count: int = 3
@export var selection_count: int = 1
@export var allowed_tags: Array[StringName] = []
@export var excluded_tags: Array[StringName] = []
@export var include_locked_pieces: bool = false
@export var temporary_addition: bool = false
@export var added_score_multiplier: float = 1.0
@export var granted_modifier: PieceModifierDefinition
@export var modifier_duration_acts: int = 0
@export var empty_pool_shards: int = 8

func apply(run_state: RunState, source_relic: RelicDefinition = null) -> void:
	super.apply(run_state, source_relic)
	if run_state.deck_cards.size() >= run_state.maximum_active_piece_pool_size:
		run_state.shards += empty_pool_shards
		return
	var eligibility_profile: ProfileState = ProfileState.new()
	var eligible: Array[PieceDefinition] = PiecePoolService.new().get_eligible_additions(eligibility_profile, run_state, allowed_tags, excluded_tags, include_locked_pieces)
	if eligible.is_empty():
		run_state.shards += empty_pool_shards
		return
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = run_state.seed_value ^ source_relic.resource_path.hash() ^ run_state.deck_cards.size() * 7919
	_shuffle(eligible, rng)
	var count: int = mini(candidate_count, eligible.size())
	if selection_mode == PieceAdditionSelectionMode.Value.RANDOM_ONE or selection_mode == PieceAdditionSelectionMode.Value.RANDOM_MATCHING_TAG:
		var addition_count: int = mini(selection_count, count)
		for index: int in addition_count:
			if not _add_piece(run_state, eligible[index], source_relic):
				run_state.shards += empty_pool_shards
		return
	var pending: PendingPieceAdditionState = PendingPieceAdditionState.new()
	pending.source_relic = source_relic
	pending.required_selection_count = mini(selection_count, count)
	pending.score_multiplier = added_score_multiplier
	pending.granted_modifier = granted_modifier
	pending.modifier_expires_after_act = _modifier_expiration_act(run_state)
	pending.temporary = temporary_addition
	for index: int in count:
		pending.candidate_pieces.append(eligible[index])
	run_state.pending_piece_addition = pending

func _add_piece(run_state: RunState, piece: PieceDefinition, source_relic: RelicDefinition) -> bool:
	var result: PiecePoolChangeResult = PiecePoolService.new().add_piece(run_state, piece, source_relic, false, temporary_addition)
	if result.changed and not run_state.debug_run:
		TutorialService.publish(TutorialEventId.Value.PIECE_ADDED_TO_POOL, result.pool_size, piece)
	if result.changed and (not is_equal_approx(added_score_multiplier, 1.0) or granted_modifier != null):
		var modifier: PieceModifierState = PieceModifierState.new()
		modifier.definition = granted_modifier
		modifier.source_relic = source_relic
		modifier.target_pieces = [piece]
		modifier.score_multiplier = added_score_multiplier
		modifier.expires_after_act = _modifier_expiration_act(run_state)
		run_state.add_piece_modifier(modifier)
	return result.changed

func _modifier_expiration_act(run_state: RunState) -> int:
	if modifier_duration_acts <= 0:
		return -1
	var node: RouteNodeState = run_state.route.current_node if run_state.route != null else null
	var current_act: int = node.act if node != null else 0
	return current_act + modifier_duration_acts - 1

func _shuffle(values: Array[PieceDefinition], rng: RandomNumberGenerator) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var value: PieceDefinition = values[index]
		values[index] = values[other]
		values[other] = value
