class_name PieceAffinityRelicEffect
extends RelicEffect

@export var modifier_definition: PieceModifierDefinition
@export var target_selection: PieceTargetRequest

func apply(run_state: RunState, source_relic: RelicDefinition = null) -> void:
	super.apply(run_state, source_relic)
	if modifier_definition == null or target_selection == null:
		return
	var rng: RandomNumberGenerator = _selection_rng(run_state, source_relic)
	var state: PieceModifierState = PieceModifierState.new()
	state.definition = modifier_definition
	state.source_relic = source_relic
	state.candidate_pieces = PieceTargetSelector.new().get_candidates(run_state, target_selection, rng)
	state.pending_selection = target_selection.selection_mode == PieceTargetSelectionMode.Value.CHOOSE_ONE_FROM_CANDIDATES or target_selection.selection_mode == PieceTargetSelectionMode.Value.CHOOSE_MULTIPLE_FROM_CANDIDATES
	state.required_selection_count = mini(state.candidate_pieces.size(), 1 if target_selection.selection_mode == PieceTargetSelectionMode.Value.CHOOSE_ONE_FROM_CANDIDATES else target_selection.selection_count)
	state.pending_selection = state.pending_selection and state.required_selection_count > 0
	if not state.pending_selection:
		state.target_pieces = _resolved_random_targets(state.candidate_pieces, target_selection)
	run_state.add_piece_modifier(state)

func _selection_rng(run_state: RunState, source_relic: RelicDefinition) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = run_state.seed_value ^ source_relic.resource_path.hash() ^ run_state.piece_modifiers.size() * 7919
	return rng

func _resolved_random_targets(candidates: Array[PieceDefinition], request: PieceTargetRequest) -> Array[PieceDefinition]:
	if request.selection_mode == PieceTargetSelectionMode.Value.ALL_MATCHING_FILTER:
		return candidates.duplicate()
	var count: int = 1 if request.selection_mode == PieceTargetSelectionMode.Value.RANDOM_ONE else request.selection_count
	var result: Array[PieceDefinition] = candidates.duplicate()
	result.resize(mini(count, result.size()))
	return result
