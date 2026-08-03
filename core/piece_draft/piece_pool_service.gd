class_name PiecePoolService
extends RefCounted

func initialize_deck(run_state: RunState, selected_cards: Array[PieceCardState], maximum_size: int = 20) -> PiecePoolChangeResult:
	run_state.deck_cards.clear()
	run_state.maximum_active_piece_pool_size = maxi(run_state.minimum_active_piece_pool_size, maximum_size)
	run_state.next_piece_card_id = 1
	var result: PiecePoolChangeResult = PiecePoolChangeResult.new()
	for selected_card: PieceCardState in selected_cards:
		result = add_card(run_state, selected_card)
	result.changed = not run_state.deck_cards.is_empty()
	result.pool_size = run_state.deck_cards.size()
	run_state.piece_pool_changed.emit()
	return result

func initialize_pool(run_state: RunState, selected_pieces: Array[PieceDefinition], maximum_size: int = 20) -> PiecePoolChangeResult:
	var cards: Array[PieceCardState] = []
	for piece: PieceDefinition in selected_pieces:
		var card: PieceCardState = PieceCardState.new()
		card.piece = piece
		card.origin = PieceCardState.Origin.STARTING_DRAFT
		card.is_starting_card = true
		cards.append(card)
	return initialize_deck(run_state, cards, maximum_size)

func add_card(run_state: RunState, card: PieceCardState, source_relic: RelicDefinition = null) -> PiecePoolChangeResult:
	var result: PiecePoolChangeResult = PiecePoolChangeResult.new()
	result.card = card
	result.piece = card.piece if card != null else null
	result.source_relic = source_relic
	if card == null or card.piece == null:
		result.reason = PiecePoolChangeResult.Reason.UNKNOWN_PIECE
		return result
	if run_state.removed_pieces.has(card.piece):
		result.reason = PiecePoolChangeResult.Reason.NOT_ACTIVE
		return result
	if run_state.deck_cards.size() >= run_state.maximum_active_piece_pool_size:
		result.reason = PiecePoolChangeResult.Reason.POOL_FULL
		return result
	if count_piece_copies(run_state, card.piece) >= run_state.maximum_piece_copies:
		result.reason = PiecePoolChangeResult.Reason.POOL_FULL
		return result
	var entry: ActivePiecePoolEntry = ActivePiecePoolEntry.from_card(card)
	entry.card_id = run_state.allocate_piece_card_id(card.card_id)
	if source_relic != null and not entry.source_relics.has(source_relic):
		entry.source_relics.append(source_relic)
	if entry.added_node == null:
		entry.added_act = _current_act(run_state)
		entry.added_node = run_state.route.current_node if run_state.route != null else null
	run_state.deck_cards.append(entry)
	result.card = entry
	result.piece = entry.piece
	result.changed = true
	result.reason = PiecePoolChangeResult.Reason.PIECE_ADDED
	result.pool_size = run_state.deck_cards.size()
	if not run_state.unviewed_pieces.has(entry.piece):
		run_state.unviewed_pieces.append(entry.piece)
	run_state.piece_pool_changed.emit()
	return result

func add_piece(run_state: RunState, piece: PieceDefinition, source_relic: RelicDefinition = null, starting: bool = false, temporary: bool = false) -> PiecePoolChangeResult:
	var card: PieceCardState = PieceCardState.new()
	card.piece = piece
	card.intrinsic_effect = piece.permanent_card_effect if piece != null else null
	card.origin = PieceCardState.Origin.STARTING_DRAFT if starting else PieceCardState.Origin.RELIC if source_relic != null else PieceCardState.Origin.REWARD
	card.is_starting_card = starting
	card.is_temporary = temporary
	return add_card(run_state, card, source_relic)

func remove_card(run_state: RunState, card_id: int, source_relic: RelicDefinition = null, minimum_size: int = 2) -> PiecePoolChangeResult:
	var result: PiecePoolChangeResult = PiecePoolChangeResult.new()
	var card: PieceCardState = run_state.get_deck_card(card_id)
	result.card = card
	result.piece = card.piece if card != null else null
	result.source_relic = source_relic
	if card == null:
		result.reason = PiecePoolChangeResult.Reason.NOT_ACTIVE
		return result
	if run_state.deck_cards.size() <= minimum_size:
		result.reason = PiecePoolChangeResult.Reason.MINIMUM_POOL
		return result
	if source_relic != null and not card.source_relics.has(source_relic):
		result.reason = PiecePoolChangeResult.Reason.NOT_ACTIVE
		return result
	run_state.deck_cards.erase(card)
	result.changed = true
	result.reason = PiecePoolChangeResult.Reason.PIECE_REMOVED
	result.pool_size = run_state.deck_cards.size()
	run_state.piece_pool_changed.emit()
	return result

func remove_piece(run_state: RunState, piece: PieceDefinition, source_relic: RelicDefinition = null, minimum_size: int = 2) -> PiecePoolChangeResult:
	var entry: PieceCardState = get_entry(run_state, piece, source_relic)
	if entry == null:
		var result: PiecePoolChangeResult = PiecePoolChangeResult.new()
		result.piece = piece
		result.source_relic = source_relic
		result.reason = PiecePoolChangeResult.Reason.NOT_ACTIVE
		return result
	return remove_card(run_state, entry.card_id, source_relic, minimum_size)

func contains_piece(run_state: RunState, piece: PieceDefinition) -> bool:
	return get_entry(run_state, piece) != null

func get_entry(run_state: RunState, piece: PieceDefinition, source_relic: RelicDefinition = null) -> PieceCardState:
	for card: PieceCardState in run_state.deck_cards:
		if card.piece == piece and (source_relic == null or card.source_relics.has(source_relic)):
			return card
	return null

func get_entries(run_state: RunState, piece: PieceDefinition) -> Array[PieceCardState]:
	var entries: Array[PieceCardState] = []
	for card: PieceCardState in run_state.deck_cards:
		if card.piece == piece:
			entries.append(card)
	return entries

func count_piece_copies(run_state: RunState, piece: PieceDefinition) -> int:
	return get_entries(run_state, piece).size()

func count_enabled_piece_copies(run_state: RunState, piece: PieceDefinition) -> int:
	if run_state == null or piece == null or run_state.removed_pieces.has(piece):
		return 0
	var copy_count: int = 0
	for card: PieceCardState in run_state.deck_cards:
		if card != null and card.piece == piece:
			copy_count += 1
	return copy_count

func can_remove_piece_type(run_state: RunState, piece: PieceDefinition) -> bool:
	if run_state == null or piece == null or run_state.removed_pieces.has(piece):
		return false
	var enabled_card_count: int = 0
	var matching_card_count: int = 0
	for card: PieceCardState in run_state.deck_cards:
		if card == null or card.piece == null or run_state.removed_pieces.has(card.piece):
			continue
		enabled_card_count += 1
		if card.piece == piece:
			matching_card_count += 1
	return matching_card_count > 0 and enabled_card_count - matching_card_count >= run_state.minimum_active_piece_pool_size

func get_removable_piece_types(run_state: RunState) -> Array[PieceDefinition]:
	var removable: Array[PieceDefinition] = []
	if run_state == null:
		return removable
	for card: PieceCardState in run_state.deck_cards:
		var piece: PieceDefinition = card.piece if card != null else null
		if piece != null and not removable.has(piece) and can_remove_piece_type(run_state, piece):
			removable.append(piece)
	removable.sort_custom(func(left: PieceDefinition, right: PieceDefinition) -> bool: return left.resource_path < right.resource_path)
	return removable

func get_eligible_additions(profile: ProfileState, run_state: RunState, allowed_tags: Array[StringName] = [], excluded_tags: Array[StringName] = [], include_locked: bool = false) -> Array[PieceDefinition]:
	var eligible: Array[PieceDefinition] = []
	for piece: PieceDefinition in ContentRegistry.pieces:
		var unlocked: bool = piece.initially_unlocked or profile.unlocked_pieces.has(piece) or run_state.starting_modifiers.unlocked_pieces.has(piece)
		if run_state.removed_pieces.has(piece):
			continue
		if (not include_locked and not unlocked) or count_piece_copies(run_state, piece) >= run_state.maximum_piece_copies:
			continue
		if not allowed_tags.is_empty() and not _has_any_tag(piece.tags, allowed_tags) or _has_any_tag(piece.tags, excluded_tags):
			continue
		eligible.append(piece)
	eligible.sort_custom(func(left: PieceDefinition, right: PieceDefinition) -> bool: return left.resource_path < right.resource_path)
	return eligible

func _has_any_tag(piece_tags: Array[StringName], filter_tags: Array[StringName]) -> bool:
	for tag: StringName in filter_tags:
		if piece_tags.has(tag):
			return true
	return false

func _current_act(run_state: RunState) -> int:
	var node: RouteNodeState = run_state.route.current_node if run_state.route != null else null
	return node.act if node != null else 0
