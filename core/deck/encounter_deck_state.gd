class_name EncounterDeckState
extends RefCounted

var draw_pile: Array[PieceCardState] = []
var hand: Array[PieceCardState] = []
var discard_pile: Array[PieceCardState] = []
var in_play: Array[PieceCardState] = []
var shuffle_count: int = 0

func all_cards() -> Array[PieceCardState]:
	var cards: Array[PieceCardState] = []
	cards.append_array(draw_pile)
	cards.append_array(hand)
	cards.append_array(discard_pile)
	cards.append_array(in_play)
	return cards

func find_card(card_id: int) -> PieceCardState:
	for card: PieceCardState in all_cards():
		if card.card_id == card_id:
			return card
	return null

func contains_unique_card_ids() -> bool:
	var seen_ids: Dictionary[int, bool] = {}
	for card: PieceCardState in all_cards():
		if card == null or card.card_id <= 0 or seen_ids.has(card.card_id):
			return false
		seen_ids[card.card_id] = true
	return true

func to_save_data(route: GeneratedRoute = null) -> Dictionary:
	return {
		"draw_pile": _cards_to_save_data(draw_pile, route),
		"hand": _cards_to_save_data(hand, route),
		"discard_pile": _cards_to_save_data(discard_pile, route),
		"in_play": _cards_to_save_data(in_play, route),
		"shuffle_count": shuffle_count
	}

static func from_save_data(data: Dictionary, route: GeneratedRoute = null) -> EncounterDeckState:
	var state: EncounterDeckState = EncounterDeckState.new()
	state.draw_pile = _cards_from_save_data(data.get("draw_pile", data.get("draw_stack", [])) as Array, route)
	state.hand = _cards_from_save_data(data.get("hand", data.get("choices", [])) as Array, route)
	state.discard_pile = _cards_from_save_data(data.get("discard_pile", data.get("discard_stack", [])) as Array, route)
	state.in_play = _cards_from_save_data(data.get("in_play", []) as Array, route)
	state.shuffle_count = maxi(0, int(data.get("shuffle_count", 0)))
	state._repair_card_ids()
	return state

static func _cards_from_save_data(values: Array, route: GeneratedRoute) -> Array[PieceCardState]:
	var cards: Array[PieceCardState] = []
	for value: Variant in values:
		var card: PieceCardState
		if value is Dictionary:
			card = PieceCardState.from_save_data(value as Dictionary, route)
		else:
			card = PieceCardState.new()
			card.piece = ContentReferenceCodec.decode_legacy(String(value), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
			card.origin = PieceCardState.Origin.MIGRATED
		if card.piece != null:
			cards.append(card)
	return cards

static func _cards_to_save_data(cards: Array[PieceCardState], route: GeneratedRoute) -> Array[Dictionary]:
	var values: Array[Dictionary] = []
	for card: PieceCardState in cards:
		values.append(card.to_save_data(route))
	return values

func _repair_card_ids() -> void:
	var next_available_id: int = 1
	var seen_ids: Dictionary[int, bool] = {}
	for card: PieceCardState in all_cards():
		if card.card_id > 0 and not seen_ids.has(card.card_id):
			seen_ids[card.card_id] = true
			next_available_id = maxi(next_available_id, card.card_id + 1)
			continue
		while seen_ids.has(next_available_id):
			next_available_id += 1
		card.card_id = next_available_id
		seen_ids[card.card_id] = true
		next_available_id += 1
