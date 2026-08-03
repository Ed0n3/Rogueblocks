class_name PendingPieceAdditionState
extends RefCounted

var source_relic: RelicDefinition
var candidate_pieces: Array[PieceDefinition] = []
var required_selection_count: int = 1
var selected_pieces: Array[PieceDefinition] = []
var score_multiplier: float = 1.0
var granted_modifier: PieceModifierDefinition
var modifier_expires_after_act: int = -1
var temporary: bool = false
var continuation_flow: PieceSelectionFlow.Value = PieceSelectionFlow.Value.NONE

func to_save_data() -> Dictionary:
	return {"source_relic": ContentReferenceCodec.encode(source_relic), "candidate_pieces": PieceModifierState._encode_pieces(candidate_pieces), "required_selection_count": required_selection_count, "selected_pieces": PieceModifierState._encode_pieces(selected_pieces), "score_multiplier": score_multiplier, "granted_modifier": ContentReferenceCodec.encode(granted_modifier), "modifier_expires_after_act": modifier_expires_after_act, "temporary": temporary, "continuation_flow": int(continuation_flow)}

static func from_save_data(data: Dictionary) -> PendingPieceAdditionState:
	var state: PendingPieceAdditionState = PendingPieceAdditionState.new()
	state.source_relic = ContentReferenceCodec.decode_legacy(String(data.get("source_relic", data.get("source_id", ""))), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
	state.candidate_pieces = PieceModifierState._decode_pieces(data.get("candidate_pieces", data.get("candidate_piece_ids", [])) as Array)
	state.required_selection_count = clampi(int(data.get("required_selection_count", 1)), 1, maxi(1, state.candidate_pieces.size()))
	state.selected_pieces = PieceModifierState._decode_pieces(data.get("selected_pieces", data.get("selected_piece_ids", [])) as Array)
	state.score_multiplier = maxf(0.0, float(data.get("score_multiplier", 1.0)))
	state.granted_modifier = ContentReferenceCodec.decode_legacy(String(data.get("granted_modifier", data.get("granted_modifier_id", ""))), PieceModifierDefinition, ContentRegistry.catalog) as PieceModifierDefinition
	state.modifier_expires_after_act = maxi(-1, int(data.get("modifier_expires_after_act", -1)))
	state.temporary = bool(data.get("temporary", false))
	state.continuation_flow = PieceSelectionFlow.from_save_value(data.get("continuation_flow", PieceSelectionFlow.Value.NONE))
	return state
