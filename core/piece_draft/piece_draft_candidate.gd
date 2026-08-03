class_name PieceDraftCandidate
extends RefCounted

enum Source { RANDOM_COLLECTION }

var card: PieceCardState = PieceCardState.new()
var source: Source = Source.RANDOM_COLLECTION

var candidate_id: int:
	get:
		return card.card_id
	set(value):
		card.card_id = value

var piece: PieceDefinition:
	get:
		return card.piece
	set(value):
		card.piece = value

func to_save_data() -> Dictionary:
	return {
		"card": card.to_save_data(),
		"piece": ContentReferenceCodec.encode(card.piece),
		"source": int(source)
	}

static func from_save_data(data: Dictionary) -> PieceDraftCandidate:
	var candidate: PieceDraftCandidate = PieceDraftCandidate.new()
	var card_data: Dictionary = data.get("card", {}) as Dictionary
	if not card_data.is_empty():
		candidate.card = PieceCardState.from_save_data(card_data)
	else:
		candidate.card.card_id = maxi(0, int(data.get("candidate_id", 0)))
		candidate.card.piece = ContentReferenceCodec.decode_legacy(String(data.get("piece", data.get("piece_id", ""))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
		candidate.card.intrinsic_effect = ContentReferenceCodec.decode(String(data.get("intrinsic_effect", "")), PieceCardEffectDefinition) as PieceCardEffectDefinition
		candidate.card.origin = PieceCardState.Origin.STARTING_DRAFT
		candidate.card.is_starting_card = true
	candidate.source = clampi(int(data.get("source", Source.RANDOM_COLLECTION)), Source.RANDOM_COLLECTION, Source.RANDOM_COLLECTION) as Source
	return candidate
