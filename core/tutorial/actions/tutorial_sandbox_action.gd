class_name TutorialSandboxAction
extends TutorialAction

enum Command { INJECT_HAND, SET_BOARD_CELLS, CLEAR_BOARD, SET_PLAYER_HEALTH, SET_ENEMY_HEALTH, ADD_DISCARD_CARDS, PAUSE_ENEMY_COUNTDOWN, RESUME_ENEMY_COUNTDOWN, SHOW_ACTIVE_PIECE_PREVIEW }

@export var command: Command = Command.CLEAR_BOARD
@export var pieces: Array[PieceDefinition] = []
@export var board_cells: Array[Vector2i] = []
@export var int_value: int = 0

func execute(context: TutorialContext) -> void:
	if context.run_state == null or context.run_state.run_mode != RunMode.Value.TUTORIAL or context.encounter_controller == null:
		return
	var controller: EncounterController = context.encounter_controller
	match command:
		Command.INJECT_HAND:
			_inject_hand(context, controller)
			if controller.deck_state != null and not controller.deck_state.hand.is_empty():
				controller.select_choice(0)
		Command.SET_BOARD_CELLS:
			for cell: Vector2i in board_cells:
				if controller.board.is_inside(cell) and controller.board.is_empty(cell):
					controller.board.set_cell(cell, controller.board.next_piece_value)
					controller.board.next_piece_value += 1
			context.board_view.queue_redraw()
		Command.CLEAR_BOARD:
			controller.board.clear_board()
			context.board_view.queue_redraw()
		Command.SET_PLAYER_HEALTH:
			context.run_state.player_health = clampi(int_value, 1, context.run_state.maximum_health)
			controller.status_changed.emit()
		Command.SET_ENEMY_HEALTH:
			controller.enemy_health = clampi(int_value, 1, controller.enemy_maximum_health)
			controller.status_changed.emit()
		Command.ADD_DISCARD_CARDS:
			if controller.deck_state == null:
				return
			for piece: PieceDefinition in pieces:
				if piece != null:
					controller.deck_state.discard_pile.append(_create_temporary_card(context.run_state, piece))
			controller.hand_changed.emit(controller.deck_state.hand, controller.hand_placeable)
			controller.status_changed.emit()
		Command.PAUSE_ENEMY_COUNTDOWN:
			controller.enemy_countdown = 99
			controller.status_changed.emit()
		Command.RESUME_ENEMY_COUNTDOWN:
			controller.enemy_countdown = maxi(1, controller.enemy.attack_interval)
			controller.status_changed.emit()
		Command.SHOW_ACTIVE_PIECE_PREVIEW:
			if controller.active_piece != null and context.board_view != null:
				var candidate: PiecePlacementCandidate = controller.board.find_piece_placement(controller.active_piece.definition)
				if candidate.found:
					context.board_view.arm_preview(candidate)

func _inject_hand(context: TutorialContext, controller: EncounterController) -> void:
	if controller.deck_state == null:
		return
	_remove_temporary_cards(controller.deck_state.draw_pile)
	_remove_temporary_cards(controller.deck_state.discard_pile)
	_remove_temporary_cards(controller.deck_state.in_play)
	var previous_hand: Array[PieceCardState] = controller.deck_state.hand.duplicate()
	for card: PieceCardState in previous_hand:
		if card.is_temporary:
			controller.deck_state.hand.erase(card)
		else:
			controller.deck_service.put_on_top_of_draw_pile(controller.deck_state, card)
	for piece: PieceDefinition in pieces:
		if piece != null:
			controller.deck_state.hand.append(_create_temporary_card(context.run_state, piece))
	controller.active_card = null
	controller.active_card_index = -1
	controller.active_piece = null
	controller.hand_placeable.clear()
	for card: PieceCardState in controller.deck_state.hand:
		controller.hand_placeable.append(controller.board.can_place_piece_anywhere(card.piece))
	controller.hand_changed.emit(controller.deck_state.hand, controller.hand_placeable)

func _remove_temporary_cards(cards: Array[PieceCardState]) -> void:
	var candidates: Array[PieceCardState] = cards.duplicate()
	for card: PieceCardState in candidates:
		if card.is_temporary:
			cards.erase(card)

func _create_temporary_card(current_run: RunState, piece: PieceDefinition) -> PieceCardState:
	var card: PieceCardState = PieceCardState.new()
	card.card_id = current_run.allocate_piece_card_id()
	card.piece = piece
	card.intrinsic_effect = piece.permanent_card_effect
	card.origin = PieceCardState.Origin.TEMPORARY
	card.is_temporary = true
	return card
