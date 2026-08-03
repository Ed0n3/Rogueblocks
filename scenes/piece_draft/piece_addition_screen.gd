class_name PieceAdditionScreen
extends Control

signal selection_completed()
signal selection_changed()

const CARD_SCENE: PackedScene = preload("res://scenes/piece_draft/piece_draft_card.tscn")

@export_range(0.25, 0.9, 0.05) var dialog_width_ratio: float = 0.5
@export var touch_scroll_direction_threshold: float = 10.0

var run_state: RunState
var scroll_touch_index: int = -1
var scroll_touch_start: Vector2
var scroll_touch_horizontal: bool = false

func _ready() -> void:
	%Confirm.pressed.connect(_confirm)
	resized.connect(_refresh_dialog_size)
	_refresh_dialog_size.call_deferred()

func start(current_run: RunState) -> void:
	run_state = current_run
	_refresh()

func _refresh() -> void:
	for child: Node in %Candidates.get_children():
		child.queue_free()
	var pending: PendingPieceAdditionState = run_state.pending_piece_addition
	for definition: PieceDefinition in pending.candidate_pieces:
		var card: PieceDraftCard = CARD_SCENE.instantiate() as PieceDraftCard
		%Candidates.add_child(card)
		card.setup(definition, pending.selected_pieces.find(definition) + 1)
		card.pressed.connect(_toggle.bind(definition))
	%Pool.text = "CURRENT BLOCK PILE  %d / %d  |  AFTER PICK  %d / %d" % [run_state.deck_cards.size(), run_state.maximum_active_piece_pool_size, mini(run_state.maximum_active_piece_pool_size, run_state.deck_cards.size() + pending.required_selection_count), run_state.maximum_active_piece_pool_size]
	%Confirm.disabled = pending.selected_pieces.size() != pending.required_selection_count

func _toggle(piece: PieceDefinition) -> void:
	var pending: PendingPieceAdditionState = run_state.pending_piece_addition
	if pending.selected_pieces.has(piece):
		pending.selected_pieces.erase(piece)
	elif pending.selected_pieces.size() < pending.required_selection_count:
		pending.selected_pieces.append(piece)
	selection_changed.emit()
	_refresh()

func _confirm() -> void:
	var pending: PendingPieceAdditionState = run_state.pending_piece_addition
	if pending.selected_pieces.size() != pending.required_selection_count:
		return
	for piece: PieceDefinition in pending.selected_pieces:
		var result: PiecePoolChangeResult = PiecePoolService.new().add_piece(run_state, piece, pending.source_relic, false, pending.temporary)
		if result.changed and (not is_equal_approx(pending.score_multiplier, 1.0) or pending.granted_modifier != null):
			var modifier: PieceModifierState = PieceModifierState.new()
			modifier.definition = pending.granted_modifier
			modifier.source_relic = pending.source_relic
			modifier.target_pieces = [piece]
			modifier.score_multiplier = pending.score_multiplier
			modifier.expires_after_act = pending.modifier_expires_after_act
			run_state.add_piece_modifier(modifier)
		if result.changed:
			TutorialService.publish(TutorialEventId.Value.PIECE_ADDED_TO_POOL, run_state.deck_cards.size(), piece)
	run_state.pending_piece_addition = null
	selection_completed.emit()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var scroll: ScrollContainer = %CandidateScroll
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and scroll.get_global_rect().has_point(touch.position):
			scroll_touch_index = touch.index
			scroll_touch_start = touch.position
			scroll_touch_horizontal = false
		elif not touch.pressed and touch.index == scroll_touch_index:
			if scroll_touch_horizontal:
				get_viewport().set_input_as_handled()
			_clear_scroll_touch()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != scroll_touch_index:
			return
		var movement: Vector2 = drag.position - scroll_touch_start
		if not scroll_touch_horizontal and movement.length() >= touch_scroll_direction_threshold:
			if absf(movement.x) <= absf(movement.y):
				_clear_scroll_touch()
				return
			scroll_touch_horizontal = true
		if scroll_touch_horizontal:
			scroll.scroll_horizontal -= roundi(drag.relative.x)
			get_viewport().set_input_as_handled()

func _refresh_dialog_size() -> void:
	if is_node_ready():
		%Panel.custom_minimum_size.x = size.x * dialog_width_ratio

func _clear_scroll_touch() -> void:
	scroll_touch_index = -1
	scroll_touch_horizontal = false
