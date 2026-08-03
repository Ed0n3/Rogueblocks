class_name PieceTargetSelector
extends RefCounted

func get_candidates(run_state: RunState, request: PieceTargetRequest, rng: RandomNumberGenerator) -> Array[PieceDefinition]:
	var eligible: Array[PieceDefinition] = _eligible_pieces(run_state, request)
	eligible.sort_custom(func(left: PieceDefinition, right: PieceDefinition) -> bool: return left.resource_path < right.resource_path)
	var shuffled: Array[PieceDefinition] = eligible.duplicate()
	for index: int in range(shuffled.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var value: PieceDefinition = shuffled[index]
		shuffled[index] = shuffled[other]
		shuffled[other] = value
	var count: int = shuffled.size() if request.selection_mode == PieceTargetSelectionMode.Value.ALL_MATCHING_FILTER else mini(request.candidate_count, shuffled.size())
	var result: Array[PieceDefinition] = []
	for index: int in count:
		result.append(shuffled[index])
	return result

func resolve_targets(run_state: RunState, request: PieceTargetRequest, rng: RandomNumberGenerator) -> Array[PieceDefinition]:
	var candidates: Array[PieceDefinition] = get_candidates(run_state, request, rng)
	var selection_count: int = 1 if request.selection_mode == PieceTargetSelectionMode.Value.RANDOM_ONE or request.selection_mode == PieceTargetSelectionMode.Value.CHOOSE_ONE_FROM_CANDIDATES else request.selection_count
	if request.selection_mode == PieceTargetSelectionMode.Value.ALL_MATCHING_FILTER:
		selection_count = candidates.size()
	candidates.resize(mini(selection_count, candidates.size()))
	return candidates

func _eligible_pieces(run_state: RunState, request: PieceTargetRequest) -> Array[PieceDefinition]:
	run_state.ensure_active_piece_pool()
	var result: Array[PieceDefinition] = []
	for active_entry: PieceCardState in run_state.deck_cards:
		var piece: PieceDefinition = active_entry.piece
		if piece == null:
			continue
		if run_state.removed_pieces.has(piece) and not request.include_temporarily_removed_pieces:
			continue
		if request.excluded_pieces.has(piece) or request.minimum_cell_count > 0 and piece.base_cells.size() < request.minimum_cell_count or request.maximum_cell_count > 0 and piece.base_cells.size() > request.maximum_cell_count:
			continue
		if not request.allowed_piece_tags.is_empty() and not _has_any_tag(piece.tags, request.allowed_piece_tags):
			continue
		if _has_any_tag(piece.tags, request.excluded_piece_tags):
			continue
		if request.prefer_unmodified_pieces and not request.allow_same_piece_for_multiple_relics and run_state.has_piece_modifier(piece):
			continue
		if not result.has(piece):
			result.append(piece)
	return result

func _has_any_tag(piece_tags: Array[StringName], filter_tags: Array[StringName]) -> bool:
	for tag: StringName in filter_tags:
		if piece_tags.has(tag):
			return true
	return false
