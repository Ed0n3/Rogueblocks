class_name PieceModifierState
extends RefCounted

var definition: PieceModifierDefinition
var source_relic: RelicDefinition
var target_pieces: Array[PieceDefinition] = []
var trigger_count: int = 0
var encounter_trigger_count: int = 0
var remaining_charges: int = -1
var score_multiplier: float = 1.0
var expires_after_act: int = -1
var pending_selection: bool = false
var candidate_pieces: Array[PieceDefinition] = []
var required_selection_count: int = 1
var triggered_piece_instance_ids: PackedInt64Array = PackedInt64Array()
var last_trigger_turn: int = -1

func to_save_data() -> Dictionary:
	return {"definition": ContentReferenceCodec.encode(definition), "source_relic": ContentReferenceCodec.encode(source_relic), "target_pieces": _encode_pieces(target_pieces), "trigger_count": trigger_count, "encounter_trigger_count": encounter_trigger_count, "remaining_charges": remaining_charges, "score_multiplier": score_multiplier, "expires_after_act": expires_after_act, "pending_selection": pending_selection, "candidate_pieces": _encode_pieces(candidate_pieces), "required_selection_count": required_selection_count, "triggered_piece_instance_ids": Array(triggered_piece_instance_ids), "last_trigger_turn": last_trigger_turn}

static func from_save_data(data: Dictionary) -> PieceModifierState:
	var state: PieceModifierState = PieceModifierState.new()
	state.definition = ContentReferenceCodec.decode_legacy(String(data.get("definition", data.get("modifier_id", ""))), PieceModifierDefinition, ContentRegistry.catalog) as PieceModifierDefinition
	state.source_relic = ContentReferenceCodec.decode_legacy(String(data.get("source_relic", data.get("source_relic_id", ""))), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
	state.target_pieces = _decode_pieces(data.get("target_pieces", data.get("target_piece_ids", [])) as Array)
	state.trigger_count = maxi(0, int(data.get("trigger_count", 0)))
	state.encounter_trigger_count = maxi(0, int(data.get("encounter_trigger_count", 0)))
	state.remaining_charges = maxi(-1, int(data.get("remaining_charges", -1)))
	state.score_multiplier = maxf(0.0, float(data.get("score_multiplier", 1.0)))
	state.expires_after_act = maxi(-1, int(data.get("expires_after_act", -1)))
	state.pending_selection = bool(data.get("pending_selection", false))
	state.candidate_pieces = _decode_pieces(data.get("candidate_pieces", data.get("candidate_piece_ids", [])) as Array)
	state.required_selection_count = maxi(1, int(data.get("required_selection_count", 1)))
	state.triggered_piece_instance_ids = PackedInt64Array(data.get("triggered_piece_instance_ids", []) as Array)
	state.last_trigger_turn = int(data.get("last_trigger_turn", -1))
	return state

static func _encode_pieces(pieces: Array[PieceDefinition]) -> Array[String]:
	var references: Array[String] = []
	for piece: PieceDefinition in pieces:
		references.append(ContentReferenceCodec.encode(piece))
	return references

static func _decode_pieces(values: Array) -> Array[PieceDefinition]:
	var pieces: Array[PieceDefinition] = []
	for value: Variant in values:
		var piece: PieceDefinition = ContentReferenceCodec.decode_legacy(String(value), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
		if piece != null:
			pieces.append(piece)
	return pieces
