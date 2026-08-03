class_name PieceTargetSelectionOverlay
extends Control

signal selection_completed()

var run_state: RunState
var state: PieceModifierState
var selected_pieces: Array[PieceDefinition] = []

func start(current_run: RunState, modifier_state: PieceModifierState) -> void:
	run_state = current_run
	state = modifier_state
	var definition: PieceModifierDefinition = state.definition
	%Title.text = "CHOOSE %s" % (definition.display_name.to_upper() if definition != null else "A BLOCK")
	%Description.text = definition.description if definition != null else "Choose the affected Block."
	%Counter.text = "Choose %d of %d" % [state.required_selection_count, state.candidate_pieces.size()]
	var buttons: Array[PieceChoiceCard] = [%CandidateOne, %CandidateTwo, %CandidateThree, %CandidateFour, %CandidateFive]
	for index: int in buttons.size():
		var button: PieceChoiceCard = buttons[index]
		if index >= state.candidate_pieces.size():
			button.visible = false
			continue
		var piece: PieceDefinition = state.candidate_pieces[index]
		button.visible = piece != null
		if piece == null:
			continue
		button.set_piece(piece, false, true, false)
		button.set_modifiers(run_state.get_piece_modifiers(piece))
		button.pressed.connect(_toggle_piece.bind(piece, button))
	%Confirm.disabled = true
	%Confirm.pressed.connect(_confirm)

func _toggle_piece(piece: PieceDefinition, button: PieceChoiceCard) -> void:
	if selected_pieces.has(piece):
		selected_pieces.erase(piece)
		button.selected = false
	elif selected_pieces.size() < state.required_selection_count:
		selected_pieces.append(piece)
		button.selected = true
	button.queue_redraw()
	%Counter.text = "Choose %d of %d  |  Selected %d" % [state.required_selection_count, state.candidate_pieces.size(), selected_pieces.size()]
	%Confirm.disabled = selected_pieces.size() != state.required_selection_count

func _confirm() -> void:
	if not run_state.resolve_piece_modifier_selection(state.definition, selected_pieces):
		return
	selection_completed.emit()
