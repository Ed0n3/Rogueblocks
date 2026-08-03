class_name ModifyDeckCardCopiesRelicEffect
extends RelicEffect

enum Operation { DUPLICATE, REMOVE_DUPLICATE }
enum CardPreference { ANY, POWERED, FILLER }

@export var operation: Operation = Operation.DUPLICATE
@export_range(1, 4, 1) var card_count: int = 1
@export var card_preference: CardPreference = CardPreference.ANY
@export var allowed_piece_tags: Array[StringName] = []
@export var excluded_piece_tags: Array[StringName] = []
@export_range(0, 100, 1) var fallback_shards: int = 8

func apply(run_state: RunState, source_relic: RelicDefinition = null) -> void:
	super.apply(run_state, source_relic)
	if run_state == null:
		return
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var source_path_hash: int = source_relic.resource_path.hash() if source_relic != null else 0
	rng.seed = run_state.seed_value ^ source_path_hash ^ run_state.deck_cards.size() * 7919
	var changed_count: int = 0
	for modification_index: int in card_count:
		var candidates: Array[PieceCardState] = _candidates(run_state)
		if candidates.is_empty():
			break
		var selected_card: PieceCardState = candidates[rng.randi_range(0, candidates.size() - 1)]
		if _apply_to_card(run_state, selected_card, source_relic):
			changed_count += 1
	if changed_count == 0:
		run_state.shards += fallback_shards

func _candidates(run_state: RunState) -> Array[PieceCardState]:
	var candidates: Array[PieceCardState] = []
	for card: PieceCardState in run_state.deck_cards:
		if not _is_eligible(run_state, card):
			continue
		candidates.append(card)
	return candidates

func _is_eligible(run_state: RunState, card: PieceCardState) -> bool:
	if card == null or card.piece == null or card.is_temporary:
		return false
	if not allowed_piece_tags.is_empty() and not _has_any_tag(card.piece.tags, allowed_piece_tags):
		return false
	if _has_any_tag(card.piece.tags, excluded_piece_tags):
		return false
	if card_preference == CardPreference.POWERED and card.intrinsic_effect == null:
		return false
	if card_preference == CardPreference.FILLER and card.intrinsic_effect != null:
		return false
	var pool_service: PiecePoolService = PiecePoolService.new()
	if operation == Operation.DUPLICATE:
		return run_state.deck_cards.size() < run_state.maximum_active_piece_pool_size and pool_service.count_piece_copies(run_state, card.piece) < run_state.maximum_piece_copies
	return run_state.deck_cards.size() > run_state.minimum_active_piece_pool_size and pool_service.count_piece_copies(run_state, card.piece) > 1

func _apply_to_card(run_state: RunState, card: PieceCardState, source_relic: RelicDefinition) -> bool:
	var pool_service: PiecePoolService = PiecePoolService.new()
	if operation == Operation.REMOVE_DUPLICATE:
		return pool_service.remove_card(run_state, card.card_id, null, run_state.minimum_active_piece_pool_size).changed
	var duplicate: PieceCardState = card.duplicate_card()
	duplicate.card_id = 0
	duplicate.origin = PieceCardState.Origin.RELIC
	duplicate.added_node = null
	duplicate.is_starting_card = false
	duplicate.is_temporary = false
	var result: PiecePoolChangeResult = pool_service.add_card(run_state, duplicate, source_relic)
	if result.changed and not run_state.debug_run:
		TutorialService.publish(TutorialEventId.Value.PIECE_ADDED_TO_POOL, result.pool_size, result.piece)
	return result.changed

func _has_any_tag(piece_tags: Array[StringName], filter_tags: Array[StringName]) -> bool:
	for tag: StringName in filter_tags:
		if piece_tags.has(tag):
			return true
	return false
