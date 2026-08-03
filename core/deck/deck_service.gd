class_name DeckService
extends RefCounted

func initialize_encounter(cards: Array[PieceCardState], rng: RandomNumberGenerator, shuffle_cards: bool = true) -> EncounterDeckState:
	var state: EncounterDeckState = EncounterDeckState.new()
	state.draw_pile.assign(cards)
	if shuffle_cards:
		shuffle(state.draw_pile, rng)
	return state

func draw(state: EncounterDeckState, count: int, rng: RandomNumberGenerator, maximum_hand_size: int = 0, reshuffle_when_empty: bool = true) -> Array[PieceCardState]:
	var drawn_cards: Array[PieceCardState] = []
	if state == null or rng == null or count <= 0:
		return drawn_cards
	var available_hand_space: int = count
	if maximum_hand_size > 0:
		available_hand_space = mini(count, maxi(0, maximum_hand_size - state.hand.size()))
	while drawn_cards.size() < available_hand_space:
		if state.draw_pile.is_empty():
			if not reshuffle_when_empty or not reshuffle_discard(state, rng):
				break
		var card: PieceCardState = state.draw_pile.pop_back() as PieceCardState
		state.hand.append(card)
		drawn_cards.append(card)
	return drawn_cards

func reshuffle_discard(state: EncounterDeckState, rng: RandomNumberGenerator) -> bool:
	if state == null or rng == null or state.discard_pile.is_empty():
		return false
	state.draw_pile.append_array(state.discard_pile)
	state.discard_pile.clear()
	shuffle(state.draw_pile, rng)
	state.shuffle_count += 1
	return true

func discard_cards(state: EncounterDeckState, cards: Array[PieceCardState]) -> void:
	if state == null:
		return
	for card: PieceCardState in cards:
		if card == null:
			continue
		_remove_from_all_zones(state, card.card_id)
		state.discard_pile.append(card)

func discard_hand(state: EncounterDeckState) -> Array[PieceCardState]:
	var discarded_cards: Array[PieceCardState] = []
	if state == null:
		return discarded_cards
	discarded_cards.assign(state.hand)
	discard_cards(state, discarded_cards)
	return discarded_cards

func move_to_in_play(state: EncounterDeckState, card_id: int) -> PieceCardState:
	if state == null:
		return null
	var card: PieceCardState = _take_card(state.hand, card_id)
	if card != null:
		state.in_play.append(card)
	return card

func put_in_play(state: EncounterDeckState, card: PieceCardState) -> bool:
	if state == null or card == null:
		return false
	_remove_from_all_zones(state, card.card_id)
	state.in_play.append(card)
	return true

func discard_in_play(state: EncounterDeckState, card_id: int) -> PieceCardState:
	if state == null:
		return null
	var card: PieceCardState = _take_card(state.in_play, card_id)
	if card != null:
		state.discard_pile.append(card)
	return card

func put_on_top_of_draw_pile(state: EncounterDeckState, card: PieceCardState) -> bool:
	if state == null or card == null:
		return false
	_remove_from_all_zones(state, card.card_id)
	state.draw_pile.append(card)
	return true

func shuffle(cards: Array[PieceCardState], rng: RandomNumberGenerator) -> void:
	if rng == null:
		return
	for index: int in range(cards.size() - 1, 0, -1):
		var other_index: int = rng.randi_range(0, index)
		var card: PieceCardState = cards[index]
		cards[index] = cards[other_index]
		cards[other_index] = card

func _remove_from_all_zones(state: EncounterDeckState, card_id: int) -> PieceCardState:
	var card: PieceCardState = _take_card(state.draw_pile, card_id)
	if card == null:
		card = _take_card(state.hand, card_id)
	if card == null:
		card = _take_card(state.discard_pile, card_id)
	if card == null:
		card = _take_card(state.in_play, card_id)
	return card

func _take_card(cards: Array[PieceCardState], card_id: int) -> PieceCardState:
	for index: int in cards.size():
		if cards[index].card_id == card_id:
			return cards.pop_at(index) as PieceCardState
	return null
