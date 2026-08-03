class_name PieceDraftService
extends RefCounted

const DRAFT_SEED_SALT: int = 0x5A17D4AF
const RANDOM_SELECTION_SEED_SALT: int = 0x21C0FFEE

func generate_starting_draft(profile: ProfileState, run_seed: int, rules: PieceDraftRules, additional_unlocked_pieces: Array[PieceDefinition] = []) -> PieceDraftState:
	var eligible: Array[PieceDefinition] = _eligible_collection(profile, rules, additional_unlocked_pieces)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = run_seed ^ DRAFT_SEED_SALT
	var selected: Array[PieceDefinition] = []
	for attempt: int in maxi(1, rules.validation_attempt_count):
		selected = _weighted_with_copy_limit(eligible, rules.candidate_count, rng, rules)
		if _composition_valid(selected, rules, eligible.size()):
			break
	_repair_required_tags(selected, eligible, rules, rng)
	_repair_minimum_distinct_count(selected, eligible, rules, rng)
	var draft: PieceDraftState = PieceDraftState.new()
	for index: int in selected.size():
		var candidate: PieceDraftCandidate = PieceDraftCandidate.new()
		candidate.candidate_id = index + 1
		candidate.piece = selected[index]
		candidate.card.origin = PieceCardState.Origin.STARTING_DRAFT
		candidate.card.is_starting_card = true
		draft.candidates.append(candidate)
	_assign_intrinsic_effects(draft.candidates, rules, rng)
	draft.required_selection_count = mini(rules.selection_count, draft.candidates.size())
	draft.required_effect_selection_count = _resolved_required_effect_count(draft, rules)
	if draft.candidates.size() <= rules.selection_count:
		for candidate: PieceDraftCandidate in draft.candidates:
			draft.selected_card_ids.append(candidate.candidate_id)
	draft.generation_seed_state = rng.state
	return draft

func can_select_candidate(draft: PieceDraftState, card_id: int) -> bool:
	if draft == null or draft.is_confirmed:
		return false
	var candidate: PieceDraftCandidate = draft.find_candidate(card_id)
	if candidate == null:
		return false
	if draft.is_card_selected(card_id):
		return true
	if draft.selected_card_ids.size() >= draft.required_selection_count:
		return false
	var selected_effects: int = draft.selected_effect_count()
	var required_fillers: int = draft.required_selection_count - draft.required_effect_selection_count
	var selected_fillers: int = draft.selected_card_ids.size() - selected_effects
	if candidate.card.intrinsic_effect != null:
		return selected_effects < draft.required_effect_selection_count
	return selected_fillers < required_fillers

func toggle_candidate_selection(draft: PieceDraftState, card_id: int) -> bool:
	if not can_select_candidate(draft, card_id):
		return false
	if draft.is_card_selected(card_id):
		draft.selected_card_ids.erase(card_id)
	else:
		draft.selected_card_ids.append(card_id)
	return true

func can_select_piece(draft: PieceDraftState, piece: PieceDefinition) -> bool:
	if draft == null:
		return false
	for candidate: PieceDraftCandidate in draft.candidates:
		if candidate.piece == piece and can_select_candidate(draft, candidate.candidate_id):
			return true
	return false

func toggle_piece_selection(draft: PieceDraftState, piece: PieceDefinition) -> bool:
	if draft == null or draft.is_confirmed:
		return false
	for candidate: PieceDraftCandidate in draft.selected_candidates():
		if candidate.piece == piece:
			return toggle_candidate_selection(draft, candidate.candidate_id)
	for candidate: PieceDraftCandidate in draft.candidates:
		if candidate.piece == piece and not draft.is_card_selected(candidate.candidate_id):
			return toggle_candidate_selection(draft, candidate.candidate_id)
	return false

func can_confirm_draft(draft: PieceDraftState, minimum_size: int = 2) -> bool:
	if draft == null or draft.is_confirmed:
		return false
	if draft.selected_card_ids.size() != draft.required_selection_count:
		return false
	if draft.selected_card_ids.size() < mini(minimum_size, draft.candidates.size()):
		return false
	return draft.selected_effect_count() == draft.required_effect_selection_count

func confirm_draft(draft: PieceDraftState, run_state: RunState, rules: PieceDraftRules) -> PiecePoolChangeResult:
	var result: PiecePoolChangeResult = PiecePoolChangeResult.new()
	if not can_confirm_draft(draft, rules.minimum_active_pool_size):
		result.reason = PiecePoolChangeResult.Reason.INVALID_SELECTION
		return result
	run_state.maximum_piece_copies = rules.maximum_copies_per_piece if rules.allow_duplicate_pieces else 1
	result = PiecePoolService.new().initialize_deck(run_state, draft.selected_cards(), rules.maximum_active_pool_size)
	draft.is_confirmed = result.changed
	return result

func randomize_selection(draft: PieceDraftState, seed_value: int) -> void:
	if draft == null or draft.is_confirmed:
		return
	var effect_ids: Array[int] = []
	var filler_ids: Array[int] = []
	for candidate: PieceDraftCandidate in draft.candidates:
		if candidate.card.intrinsic_effect != null:
			effect_ids.append(candidate.candidate_id)
		else:
			filler_ids.append(candidate.candidate_id)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value ^ draft.generation_seed_state ^ RANDOM_SELECTION_SEED_SALT
	_shuffle_ints(effect_ids, rng)
	_shuffle_ints(filler_ids, rng)
	draft.selected_card_ids.clear()
	for index: int in mini(draft.required_effect_selection_count, effect_ids.size()):
		draft.selected_card_ids.append(effect_ids[index])
	var filler_count: int = draft.required_selection_count - draft.selected_card_ids.size()
	for index: int in mini(filler_count, filler_ids.size()):
		draft.selected_card_ids.append(filler_ids[index])
	draft.generation_seed_state = rng.state

func _eligible_collection(profile: ProfileState, rules: PieceDraftRules, additional_unlocked_pieces: Array[PieceDefinition]) -> Array[PieceDefinition]:
	var result: Array[PieceDefinition] = []
	var collection: Array[PieceDefinition] = ContentRegistry.pieces.duplicate()
	for piece: PieceDefinition in additional_unlocked_pieces:
		if piece != null and not collection.has(piece):
			collection.append(piece)
	for piece: PieceDefinition in collection:
		if not piece.initially_unlocked and not profile.unlocked_pieces.has(piece) and not additional_unlocked_pieces.has(piece):
			continue
		if not piece.can_appear_in_starting_draft or rules.excluded_pieces.has(piece) or _has_any_tag(piece.tags, rules.excluded_piece_tags):
			continue
		result.append(piece)
	result.sort_custom(func(left: PieceDefinition, right: PieceDefinition) -> bool: return left.resource_path < right.resource_path)
	return result

func _weighted_with_copy_limit(pool: Array[PieceDefinition], count: int, rng: RandomNumberGenerator, rules: PieceDraftRules) -> Array[PieceDefinition]:
	var result: Array[PieceDefinition] = []
	var copy_counts: Dictionary[PieceDefinition, int] = {}
	var copy_limit: int = rules.maximum_copies_per_piece if rules.allow_duplicate_pieces else 1
	for draw_index: int in count:
		var available: Array[PieceDefinition] = []
		for piece: PieceDefinition in pool:
			if copy_counts.get(piece, 0) < copy_limit:
				available.append(piece)
		if available.is_empty():
			break
		var selected_piece: PieceDefinition = _weighted_piece(available, rng, rules.use_piece_draft_weights)
		result.append(selected_piece)
		copy_counts[selected_piece] = copy_counts.get(selected_piece, 0) + 1
	return result

func _weighted_piece(pool: Array[PieceDefinition], rng: RandomNumberGenerator, use_weights: bool) -> PieceDefinition:
	if pool.is_empty():
		return null
	var total_weight: float = 0.0
	for piece: PieceDefinition in pool:
		total_weight += piece.starting_draft_weight if use_weights else 1.0
	if total_weight <= 0.0:
		return pool[rng.randi_range(0, pool.size() - 1)]
	var roll: float = rng.randf_range(0.0, total_weight)
	for piece: PieceDefinition in pool:
		roll -= piece.starting_draft_weight if use_weights else 1.0
		if roll <= 0.0:
			return piece
	return pool.back()

func _assign_intrinsic_effects(candidates: Array[PieceDraftCandidate], rules: PieceDraftRules, rng: RandomNumberGenerator) -> void:
	var effect_count: int = 0
	var available_indexes: Array[int] = []
	for index: int in candidates.size():
		var card: PieceCardState = candidates[index].card
		card.intrinsic_effect = card.piece.permanent_card_effect
		if card.intrinsic_effect != null:
			effect_count += 1
		elif not _compatible_effects(card.piece, rules.random_effect_pool).is_empty():
			available_indexes.append(index)
	_shuffle_ints(available_indexes, rng)
	var target_count: int = clampi(rules.effect_candidate_count, effect_count, candidates.size())
	for candidate_index: int in available_indexes:
		if effect_count >= target_count:
			break
		var candidate: PieceDraftCandidate = candidates[candidate_index]
		candidate.card.intrinsic_effect = _weighted_effect(_compatible_effects(candidate.piece, rules.random_effect_pool), rng)
		if candidate.card.intrinsic_effect != null:
			effect_count += 1

func _compatible_effects(piece: PieceDefinition, effects: Array[PieceCardEffectDefinition]) -> Array[PieceCardEffectDefinition]:
	var compatible: Array[PieceCardEffectDefinition] = []
	for effect: PieceCardEffectDefinition in effects:
		if effect != null and effect.can_roll_for(piece):
			compatible.append(effect)
	return compatible

func _weighted_effect(effects: Array[PieceCardEffectDefinition], rng: RandomNumberGenerator) -> PieceCardEffectDefinition:
	if effects.is_empty():
		return null
	var total_weight: float = 0.0
	for effect: PieceCardEffectDefinition in effects:
		total_weight += effect.roll_weight
	if total_weight <= 0.0:
		return effects[rng.randi_range(0, effects.size() - 1)]
	var roll: float = rng.randf_range(0.0, total_weight)
	for effect: PieceCardEffectDefinition in effects:
		roll -= effect.roll_weight
		if roll <= 0.0:
			return effect
	return effects.back()

func _resolved_required_effect_count(draft: PieceDraftState, rules: PieceDraftRules) -> int:
	var effect_candidates: int = 0
	for candidate: PieceDraftCandidate in draft.candidates:
		if candidate.card.intrinsic_effect != null:
			effect_candidates += 1
	var filler_candidates: int = draft.candidates.size() - effect_candidates
	var minimum_effects: int = maxi(0, draft.required_selection_count - filler_candidates)
	var maximum_effects: int = mini(draft.required_selection_count, effect_candidates)
	return clampi(rules.required_effect_selection_count, minimum_effects, maximum_effects)

func _composition_valid(pieces: Array[PieceDefinition], rules: PieceDraftRules, eligible_count: int) -> bool:
	if pieces.is_empty():
		return false
	for required_tag: StringName in rules.required_piece_tags:
		var contains_required_tag: bool = false
		for piece: PieceDefinition in pieces:
			if piece.tags.has(required_tag):
				contains_required_tag = true
				break
		if not contains_required_tag:
			return false
	var distinct_pieces: Dictionary[PieceDefinition, bool] = {}
	var all_small: bool = true
	var all_large: bool = true
	for piece: PieceDefinition in pieces:
		distinct_pieces[piece] = true
		all_small = all_small and piece.base_cells.size() <= 2
		all_large = all_large and piece.base_cells.size() >= 4
	var required_distinct_count: int = mini(rules.minimum_distinct_piece_count, mini(eligible_count, pieces.size()))
	var valid_small_composition: bool = not rules.prevent_all_small_piece_draft or not all_small
	var valid_large_composition: bool = not rules.prevent_all_large_piece_draft or not all_large
	return distinct_pieces.size() >= required_distinct_count and valid_small_composition and valid_large_composition

func _repair_required_tags(selected: Array[PieceDefinition], eligible: Array[PieceDefinition], rules: PieceDraftRules, rng: RandomNumberGenerator) -> void:
	var copy_limit: int = rules.maximum_copies_per_piece if rules.allow_duplicate_pieces else 1
	for required_tag: StringName in rules.required_piece_tags:
		if selected.any(func(piece: PieceDefinition) -> bool: return piece.tags.has(required_tag)):
			continue
		var replacements: Array[PieceDefinition] = []
		for piece: PieceDefinition in eligible:
			if piece.tags.has(required_tag) and _count_piece(selected, piece) < copy_limit:
				replacements.append(piece)
		if replacements.is_empty() or selected.is_empty():
			continue
		var replacement: PieceDefinition = _weighted_piece(replacements, rng, rules.use_piece_draft_weights)
		var replacement_index: int = selected.size() - 1
		for index: int in range(selected.size() - 1, -1, -1):
			if not _is_only_required_match(selected[index], selected, rules.required_piece_tags):
				replacement_index = index
				break
		selected[replacement_index] = replacement

func _repair_minimum_distinct_count(selected: Array[PieceDefinition], eligible: Array[PieceDefinition], rules: PieceDraftRules, rng: RandomNumberGenerator) -> void:
	var target_count: int = mini(rules.minimum_distinct_piece_count, mini(eligible.size(), selected.size()))
	while _distinct_piece_count(selected) < target_count:
		var missing: Array[PieceDefinition] = []
		for piece: PieceDefinition in eligible:
			if not selected.has(piece):
				missing.append(piece)
		if missing.is_empty():
			return
		var replacement_index: int = -1
		for index: int in range(selected.size() - 1, -1, -1):
			if _count_piece(selected, selected[index]) > 1 and not _is_only_required_match(selected[index], selected, rules.required_piece_tags):
				replacement_index = index
				break
		if replacement_index < 0:
			return
		selected[replacement_index] = _weighted_piece(missing, rng, rules.use_piece_draft_weights)

func _distinct_piece_count(pieces: Array[PieceDefinition]) -> int:
	var distinct: Dictionary[PieceDefinition, bool] = {}
	for piece: PieceDefinition in pieces:
		distinct[piece] = true
	return distinct.size()

func _count_piece(pieces: Array[PieceDefinition], target: PieceDefinition) -> int:
	var count: int = 0
	for piece: PieceDefinition in pieces:
		if piece == target:
			count += 1
	return count

func _has_any_tag(piece_tags: Array[StringName], filter_tags: Array[StringName]) -> bool:
	for tag: StringName in filter_tags:
		if piece_tags.has(tag):
			return true
	return false

func _is_only_required_match(piece: PieceDefinition, selected: Array[PieceDefinition], required_tags: Array[StringName]) -> bool:
	for required_tag: StringName in required_tags:
		if not piece.tags.has(required_tag):
			continue
		var match_count: int = 0
		for candidate: PieceDefinition in selected:
			match_count += 1 if candidate.tags.has(required_tag) else 0
		if match_count <= 1:
			return true
	return false

func _shuffle_ints(values: Array[int], rng: RandomNumberGenerator) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var other_index: int = rng.randi_range(0, index)
		var value: int = values[index]
		values[index] = values[other_index]
		values[other_index] = value
