class_name TransferDeckCardsEffect
extends GameplayEffect

@export var source_pile: DeckPileType.Value = DeckPileType.Value.DISCARD
@export var destination_pile: DeckPileType.Value = DeckPileType.Value.HAND
@export var selection: DeckCardSelection.Value = DeckCardSelection.Value.TOP
@export_range(1, 20) var count: int = 1
@export var allow_hand_overflow: bool = false

func can_apply(context: EffectContext) -> bool:
	if not super.can_apply(context) or context.deck_state == null or count <= 0:
		return false
	if not _is_valid_pile(source_pile) or not _is_valid_pile(destination_pile) or not _is_valid_selection(selection):
		return false
	if source_pile == destination_pile:
		return false
	if _transfer_limit(context) <= 0:
		return false
	return _get_pile(context.deck_state, source_pile).any(func(card: PieceCardState) -> bool: return card != null and card.is_valid())

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	if not can_apply(context):
		return result
	var source_cards: Array[PieceCardState] = _get_pile(context.deck_state, source_pile)
	var destination_cards: Array[PieceCardState] = _get_pile(context.deck_state, destination_pile)
	var transfer_limit: int = _transfer_limit(context)
	while result.moved_cards.size() < transfer_limit and not source_cards.is_empty():
		var source_index: int = _get_source_index(source_cards, context.rng)
		var card: PieceCardState = source_cards.pop_at(source_index)
		if card != null and card.is_valid():
			result.moved_cards.append(card)
	for reverse_index: int in range(result.moved_cards.size() - 1, -1, -1):
		destination_cards.append(result.moved_cards[reverse_index])
	result.applied = not result.moved_cards.is_empty()
	return result

func _transfer_limit(context: EffectContext) -> int:
	if destination_pile != DeckPileType.Value.HAND or allow_hand_overflow or context.maximum_hand_size <= 0:
		return count
	return mini(count, maxi(0, context.maximum_hand_size - context.deck_state.hand.size()))

func _get_pile(deck_state: EncounterDeckState, pile: DeckPileType.Value) -> Array[PieceCardState]:
	match pile:
		DeckPileType.Value.DRAW:
			return deck_state.draw_pile
		DeckPileType.Value.HAND:
			return deck_state.hand
	return deck_state.discard_pile

func _get_source_index(cards: Array[PieceCardState], rng: RandomNumberGenerator) -> int:
	match selection:
		DeckCardSelection.Value.BOTTOM:
			return 0
		DeckCardSelection.Value.RANDOM:
			return rng.randi_range(0, cards.size() - 1) if rng != null else cards.size() - 1
	return cards.size() - 1

func _is_valid_pile(pile: DeckPileType.Value) -> bool:
	return pile >= DeckPileType.Value.DRAW and pile <= DeckPileType.Value.DISCARD

func _is_valid_selection(value: DeckCardSelection.Value) -> bool:
	return value >= DeckCardSelection.Value.TOP and value <= DeckCardSelection.Value.RANDOM
