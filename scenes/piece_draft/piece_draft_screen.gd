class_name PieceDraftScreen
extends Control

signal draft_confirmed()
signal back_requested()
signal draft_changed()

const CARD_SCENE: PackedScene = preload("res://scenes/piece_draft/piece_draft_card.tscn")

@export_category("Touch")
## Minimum drag distance before a vertical gesture scrolls the Block candidates.
@export var touch_scroll_direction_threshold: float = 12.0

var run_state: RunState
var rules: PieceDraftRules
var service: PieceDraftService = PieceDraftService.new()
var scroll_touch_index: int = -1
var scroll_touch_start: Vector2
var scroll_touch_vertical: bool = false

func _ready() -> void:
	%Randomize.pressed.connect(_randomize)
	%Begin.pressed.connect(_confirm)
	%Back.pressed.connect(func() -> void: back_requested.emit())
	resized.connect(_refresh_columns)

func start(current_run: RunState, draft_rules: PieceDraftRules) -> void:
	run_state = current_run
	rules = draft_rules
	_refresh()
	TutorialService.enter_screen(TutorialScreen.Value.DRAFT, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.DRAFT_CANDIDATES, %CandidateGrid, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.DRAFT_BEGIN, %Begin, self)
	TutorialService.publish(TutorialEventId.Value.PIECE_DRAFT_OPENED)
	tree_exiting.connect(_unregister_targets, CONNECT_ONE_SHOT)

func _refresh() -> void:
	for child: Node in %CandidateGrid.get_children():
		child.queue_free()
	for candidate: PieceDraftCandidate in run_state.piece_draft.candidates:
		var card_state: PieceCardState = candidate.card
		if card_state == null or card_state.piece == null:
			continue
		var card: PieceDraftCard = CARD_SCENE.instantiate() as PieceDraftCard
		%CandidateGrid.add_child(card)
		card.setup_card(card_state, run_state.piece_draft.selected_card_ids.find(card_state.card_id) + 1)
		card.disabled = not service.can_select_candidate(run_state.piece_draft, card_state.card_id)
		card.pressed.connect(_toggle.bind(card_state.card_id))
		card.mouse_entered.connect(_show_details.bind(card_state))
		card.focus_entered.connect(_show_details.bind(card_state))
	var selected_count: int = run_state.piece_draft.selected_card_ids.size()
	var selected_effect_count: int = run_state.piece_draft.selected_effect_count()
	%Selection.text = "%d / %d PIECES  |  %d / %d EFFECTS" % [selected_count, run_state.piece_draft.required_selection_count, selected_effect_count, run_state.piece_draft.required_effect_selection_count]
	%Begin.disabled = not service.can_confirm_draft(run_state.piece_draft, rules.minimum_active_pool_size)
	%PoolSummary.text = _pool_summary()
	_refresh_columns()

func _toggle(card_id: int) -> void:
	if service.toggle_candidate_selection(run_state.piece_draft, card_id):
		draft_changed.emit()
	_refresh()

func _randomize() -> void:
	service.randomize_selection(run_state.piece_draft, run_state.seed_value)
	draft_changed.emit()
	_refresh()

func _confirm() -> void:
	if not service.confirm_draft(run_state.piece_draft, run_state, rules).changed:
		return
	TutorialService.publish(TutorialEventId.Value.PIECE_DRAFT_CONFIRMED, run_state.deck_cards.size())
	draft_confirmed.emit()

func _show_details(card: PieceCardState) -> void:
	if card == null or card.piece == null:
		return
	var definition: PieceDefinition = card.piece
	var effect_name: String = "FILLER PIECE" if card.intrinsic_effect == null else card.intrinsic_effect.display_name.to_upper()
	var effect_description: String = "No intrinsic effect." if card.intrinsic_effect == null else card.intrinsic_effect.description
	%DetailTitle.text = definition.display_name.to_upper()
	%Detail.text = "%s\n%s\n\n%d cells\n%d unique rotations" % [effect_name, effect_description, definition.base_cells.size(), PieceRotationService.get_unique_rotations(definition).size()]

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var scroll: ScrollContainer = $Margin/Layout/Content/Scroll as ScrollContainer
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and scroll.get_global_rect().has_point(touch.position):
			scroll_touch_index = touch.index
			scroll_touch_start = touch.position
			scroll_touch_vertical = false
		elif not touch.pressed and touch.index == scroll_touch_index:
			if scroll_touch_vertical:
				get_viewport().set_input_as_handled()
			_clear_scroll_touch()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != scroll_touch_index:
			return
		var movement: Vector2 = drag.position - scroll_touch_start
		if not scroll_touch_vertical and movement.length() >= touch_scroll_direction_threshold:
			if absf(movement.y) <= absf(movement.x):
				_clear_scroll_touch()
				return
			scroll_touch_vertical = true
		if scroll_touch_vertical:
			scroll.scroll_vertical -= roundi(drag.relative.y)
			get_viewport().set_input_as_handled()

func _pool_summary() -> String:
	var cells: int = 0
	var effect_count: int = 0
	var selected_cards: Array[PieceCardState] = run_state.piece_draft.selected_cards()
	for card: PieceCardState in selected_cards:
		if card.piece != null:
			cells += card.piece.base_cells.size()
		if card.intrinsic_effect != null:
			effect_count += 1
	var average: float = float(cells) / float(maxi(1, selected_cards.size()))
	return "BLOCK PILE  |  %d / %d PIECES  |  %d EFFECTS  |  %.1f AVG CELLS" % [selected_cards.size(), run_state.piece_draft.required_selection_count, effect_count, average]

func _refresh_columns() -> void:
	if is_node_ready():
		%CandidateGrid.columns = 1 if size.x < 430.0 else 2 if size.x < 720.0 else 4
		%DetailPanel.visible = size.x >= 720.0

func _clear_scroll_touch() -> void:
	scroll_touch_index = -1
	scroll_touch_start = Vector2.ZERO
	scroll_touch_vertical = false

func _unregister_targets() -> void:
	TutorialService.leave_screen(TutorialScreen.Value.DRAFT, self)
	TutorialTargetRegistry.unregister_owner(self)
