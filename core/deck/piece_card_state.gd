class_name PieceCardState
extends RefCounted

enum Origin { STARTING_DRAFT, REWARD, RELIC, MIGRATED, TEMPORARY }

var card_id: int = 0
var piece: PieceDefinition
var intrinsic_effect: PieceCardEffectDefinition
var origin: Origin = Origin.MIGRATED
var source_relics: Array[RelicDefinition] = []
var added_act: int = 0
var added_node: RouteNodeState
var is_starting_card: bool = false
var is_temporary: bool = false

var is_starting_piece: bool:
	get:
		return is_starting_card
	set(value):
		is_starting_card = value

func duplicate_card() -> PieceCardState:
	var copy: PieceCardState = PieceCardState.new()
	copy.card_id = card_id
	copy.piece = piece
	copy.intrinsic_effect = intrinsic_effect
	copy.origin = origin
	copy.source_relics.assign(source_relics)
	copy.added_act = added_act
	copy.added_node = added_node
	copy.is_starting_card = is_starting_card
	copy.is_temporary = is_temporary
	return copy

func is_valid() -> bool:
	return card_id > 0 and piece != null

func to_save_data(route: GeneratedRoute = null) -> Dictionary:
	var saved_sources: Array[String] = []
	for relic: RelicDefinition in source_relics:
		saved_sources.append(ContentReferenceCodec.encode(relic))
	return {
		"card_id": card_id,
		"piece": ContentReferenceCodec.encode(piece),
		"intrinsic_effect": ContentReferenceCodec.encode(intrinsic_effect),
		"origin": int(origin),
		"source_relics": saved_sources,
		"added_act": added_act,
		"added_node": route.nodes.find(added_node) if route != null else -1,
		"is_starting_card": is_starting_card,
		"is_temporary": is_temporary
	}

static func from_save_data(data: Dictionary, route: GeneratedRoute = null) -> PieceCardState:
	var card: PieceCardState = PieceCardState.new()
	card.card_id = maxi(0, int(data.get("card_id", data.get("candidate_id", 0))))
	card.piece = ContentReferenceCodec.decode_legacy(String(data.get("piece", data.get("piece_id", ""))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
	card.intrinsic_effect = ContentReferenceCodec.decode(String(data.get("intrinsic_effect", data.get("effect", ""))), PieceCardEffectDefinition) as PieceCardEffectDefinition
	card.origin = clampi(int(data.get("origin", Origin.MIGRATED)), Origin.STARTING_DRAFT, Origin.TEMPORARY) as Origin
	for source_value: Variant in data.get("source_relics", data.get("source_ids", [])) as Array:
		var relic: RelicDefinition = ContentReferenceCodec.decode_legacy(String(source_value), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
		if relic != null and not card.source_relics.has(relic):
			card.source_relics.append(relic)
	card.added_act = maxi(0, int(data.get("added_act", 0)))
	var added_node_index: int = int(data.get("added_node", -1))
	if route != null and added_node_index >= 0 and added_node_index < route.nodes.size():
		card.added_node = route.nodes[added_node_index]
	elif route != null:
		card.added_node = route._find_legacy_node(StringName(String(data.get("added_node_id", ""))))
	card.is_starting_card = bool(data.get("is_starting_card", data.get("is_starting_piece", false)))
	card.is_temporary = bool(data.get("is_temporary", false))
	return card
