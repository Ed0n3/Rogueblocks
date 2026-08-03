class_name PieceDraftState
extends RefCounted

var candidates: Array[PieceDraftCandidate] = []
var selected_card_ids: Array[int] = []
var required_selection_count: int = 0
var required_effect_selection_count: int = 0
var is_confirmed: bool = false
var generation_seed_state: int = 0
var draft_version: int = 2

var selected_pieces: Array[PieceDefinition]:
	get:
		var pieces: Array[PieceDefinition] = []
		for card: PieceCardState in selected_cards():
			pieces.append(card.piece)
		return pieces
	set(value):
		selected_card_ids.clear()
		for piece: PieceDefinition in value:
			for candidate: PieceDraftCandidate in candidates:
				if candidate.piece == piece and not selected_card_ids.has(candidate.candidate_id):
					selected_card_ids.append(candidate.candidate_id)
					break

func candidate_cards() -> Array[PieceCardState]:
	var cards: Array[PieceCardState] = []
	for candidate: PieceDraftCandidate in candidates:
		cards.append(candidate.card)
	return cards

func candidate_pieces() -> Array[PieceDefinition]:
	var pieces: Array[PieceDefinition] = []
	for candidate: PieceDraftCandidate in candidates:
		pieces.append(candidate.piece)
	return pieces

func selected_cards() -> Array[PieceCardState]:
	var cards: Array[PieceCardState] = []
	for card_id: int in selected_card_ids:
		var candidate: PieceDraftCandidate = find_candidate(card_id)
		if candidate != null:
			cards.append(candidate.card)
	return cards

func selected_candidates() -> Array[PieceDraftCandidate]:
	var result: Array[PieceDraftCandidate] = []
	for card_id: int in selected_card_ids:
		var candidate: PieceDraftCandidate = find_candidate(card_id)
		if candidate != null:
			result.append(candidate)
	return result

func find_candidate(card_id: int) -> PieceDraftCandidate:
	for candidate: PieceDraftCandidate in candidates:
		if candidate.candidate_id == card_id:
			return candidate
	return null

func is_card_selected(card_id: int) -> bool:
	return selected_card_ids.has(card_id)

func selected_effect_count() -> int:
	var count: int = 0
	for card: PieceCardState in selected_cards():
		if card.intrinsic_effect != null:
			count += 1
	return count

func to_save_data() -> Dictionary:
	var candidate_data: Array[Dictionary] = []
	for candidate: PieceDraftCandidate in candidates:
		candidate_data.append(candidate.to_save_data())
	var selected_references: Array[String] = []
	for card: PieceCardState in selected_cards():
		selected_references.append(ContentReferenceCodec.encode(card.piece))
	return {
		"candidates": candidate_data,
		"selected_card_ids": selected_card_ids,
		"selected_pieces": selected_references,
		"required_selection_count": required_selection_count,
		"required_effect_selection_count": required_effect_selection_count,
		"is_confirmed": is_confirmed,
		"generation_seed_state": str(generation_seed_state),
		"draft_version": draft_version
	}

static func from_save_data(data: Dictionary) -> PieceDraftState:
	var state: PieceDraftState = PieceDraftState.new()
	var next_candidate_id: int = 1
	for value: Variant in data.get("candidates", []) as Array:
		var candidate: PieceDraftCandidate = PieceDraftCandidate.from_save_data(value as Dictionary)
		if candidate.piece == null:
			continue
		if candidate.candidate_id <= 0 or state.find_candidate(candidate.candidate_id) != null:
			while state.find_candidate(next_candidate_id) != null:
				next_candidate_id += 1
			candidate.candidate_id = next_candidate_id
		next_candidate_id = maxi(next_candidate_id, candidate.candidate_id + 1)
		state.candidates.append(candidate)
	var saved_card_ids: Array = data.get("selected_card_ids", []) as Array
	if not saved_card_ids.is_empty():
		for value: Variant in saved_card_ids:
			var card_id: int = int(value)
			if state.find_candidate(card_id) != null and not state.selected_card_ids.has(card_id):
				state.selected_card_ids.append(card_id)
	else:
		var legacy_selected_pieces: Array[PieceDefinition] = []
		for value: Variant in data.get("selected_pieces", data.get("selected_piece_ids", [])) as Array:
			var piece: PieceDefinition = ContentReferenceCodec.decode_legacy(String(value), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
			if piece != null:
				legacy_selected_pieces.append(piece)
		state.selected_pieces = legacy_selected_pieces
	state.required_selection_count = clampi(int(data.get("required_selection_count", 0)), 0, state.candidates.size())
	state.required_effect_selection_count = clampi(int(data.get("required_effect_selection_count", 0)), 0, state.required_selection_count)
	state.is_confirmed = bool(data.get("is_confirmed", false))
	state.generation_seed_state = String(data.get("generation_seed_state", "0")).to_int()
	state.draft_version = maxi(2, int(data.get("draft_version", 1)))
	return state
