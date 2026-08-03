class_name BossArtifactState
extends RefCounted

var definition: BossArtifactDefinition
var obtained_act: int = 0
var trigger_counter: int = 0
var remaining_encounter_uses: int = -1
var stored_cards: Array[PieceCardState] = []
var last_piece: PieceDefinition
var repeat_count: int = 0
var ready: bool = false

func to_save_data() -> Dictionary:
	var serialized_cards: Array[Dictionary] = []
	for card: PieceCardState in stored_cards:
		serialized_cards.append(card.to_save_data())
	return {
		"definition": ContentReferenceCodec.encode(definition),
		"obtained_act": obtained_act,
		"trigger_counter": trigger_counter,
		"remaining_encounter_uses": remaining_encounter_uses,
		"stored_cards": serialized_cards,
		"last_piece": ContentReferenceCodec.encode(last_piece),
		"repeat_count": repeat_count,
		"ready": ready
	}

static func from_save_data(data: Dictionary) -> BossArtifactState:
	var state: BossArtifactState = BossArtifactState.new()
	state.apply_save_data(data)
	return state

func apply_save_data(data: Dictionary) -> void:
	var definition_reference: String = String(data.get("definition", data.get("artifact_id", "")))
	definition = ContentReferenceCodec.decode_legacy(definition_reference, BossArtifactDefinition, ContentRegistry.catalog) as BossArtifactDefinition
	obtained_act = maxi(0, int(data.get("obtained_act", 0)))
	trigger_counter = maxi(0, int(data.get("trigger_counter", 0)))
	remaining_encounter_uses = int(data.get("remaining_encounter_uses", -1))
	stored_cards.clear()
	for stored_card_value: Variant in data.get("stored_cards", []) as Array:
		var stored_card: PieceCardState = PieceCardState.from_save_data(stored_card_value as Dictionary)
		if stored_card.piece != null:
			stored_cards.append(stored_card)
	if stored_cards.is_empty():
		var stored_values: Array = data.get("stored_pieces", data.get("stored_piece_ids", [])) as Array
		for stored_value: Variant in stored_values:
			var stored_piece: PieceDefinition = ContentReferenceCodec.decode_legacy(String(stored_value), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
			if stored_piece != null:
				var migrated_card: PieceCardState = PieceCardState.new()
				migrated_card.piece = stored_piece
				migrated_card.origin = PieceCardState.Origin.MIGRATED
				stored_cards.append(migrated_card)
	if stored_cards.is_empty():
		var legacy_piece: PieceDefinition = ContentReferenceCodec.decode_legacy(String(data.get("stored_piece_id", "")), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
		if legacy_piece != null:
			var migrated_card: PieceCardState = PieceCardState.new()
			migrated_card.piece = legacy_piece
			migrated_card.origin = PieceCardState.Origin.MIGRATED
			stored_cards.append(migrated_card)
	var last_piece_reference: String = String(data.get("last_piece", data.get("last_piece_id", "")))
	last_piece = ContentReferenceCodec.decode_legacy(last_piece_reference, PieceDefinition, ContentRegistry.catalog) as PieceDefinition
	repeat_count = maxi(0, int(data.get("repeat_count", 0)))
	ready = bool(data.get("ready", false))
