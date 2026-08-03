class_name DebugEncounterPieceSelection
extends Resource

@export var piece: PieceDefinition
@export var effect: PieceCardEffectDefinition

func _init(selected_piece: PieceDefinition = null, selected_effect: PieceCardEffectDefinition = null) -> void:
	piece = selected_piece
	effect = selected_effect

func resolved_effect() -> PieceCardEffectDefinition:
	if piece != null and piece.permanent_card_effect != null:
		return piece.permanent_card_effect
	return effect

func is_valid(allow_incompatible_effects: bool = false) -> bool:
	if piece == null or not piece.is_valid():
		return false
	var selected_effect: PieceCardEffectDefinition = resolved_effect()
	if selected_effect == null:
		return true
	if not selected_effect.is_valid():
		return false
	return allow_incompatible_effects or piece.permanent_card_effect == selected_effect or selected_effect.can_roll_for(piece)

func duplicate_selection() -> DebugEncounterPieceSelection:
	return DebugEncounterPieceSelection.new(piece, effect)
