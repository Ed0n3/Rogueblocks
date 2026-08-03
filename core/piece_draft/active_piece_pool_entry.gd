class_name ActivePiecePoolEntry
extends PieceCardState

static func from_card(card: PieceCardState) -> ActivePiecePoolEntry:
	var entry: ActivePiecePoolEntry = ActivePiecePoolEntry.new()
	entry.card_id = card.card_id
	entry.piece = card.piece
	entry.intrinsic_effect = card.intrinsic_effect
	entry.origin = card.origin
	entry.source_relics.assign(card.source_relics)
	entry.added_act = card.added_act
	entry.added_node = card.added_node
	entry.is_starting_card = card.is_starting_card
	entry.is_temporary = card.is_temporary
	return entry

static func from_save_data(data: Dictionary, route: GeneratedRoute = null) -> ActivePiecePoolEntry:
	var card: PieceCardState = PieceCardState.from_save_data(data, route)
	return from_card(card)
