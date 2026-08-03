class_name PieceHandView
extends VBoxContainer

signal card_selected(card_id: int)

const CARD_SCENE: PackedScene = preload("res://presentation/deck/piece_hand_card.tscn")
const NO_CARD_ID: int = -1
const EFFECT_PREVIEW_NON_TEXT_WIDTH: float = 60.0
const MINIMUM_EFFECT_PREVIEW_TEXT_WIDTH: float = 180.0

@export_range(0.1, 2.0, 0.05) var touch_hold_duration: float = 0.5
@export_range(1.0, 64.0, 1.0) var touch_scroll_deadzone: float = 12.0
@export_range(0.25, 3.0, 0.05) var touch_scroll_speed: float = 1.0
@export_range(220.0, 560.0, 10.0) var effect_preview_width: float = 360.0
@export_range(0.0, 48.0, 1.0) var effect_preview_gap: float = 8.0
@export_range(0.0, 48.0, 1.0) var effect_preview_edge_margin: float = 12.0

var current_cards: Array[PieceCardState] = []
var selected_card_id: int = NO_CARD_ID
var unplaceable_card_ids: Array[int] = []
var remaining_placement_points: int = 0
var maximum_placement_points: int = 0
var interaction_enabled: bool = true
var active_touch_index: int = -1
var touch_start_position: Vector2 = Vector2.ZERO
var touch_start_scroll: int = 0
var touch_started_msec: int = 0
var touch_dragging: bool = false
var touch_details_visible: bool = false
var touched_card: PieceHandCard
var suppressed_card_id: int = NO_CARD_ID

func _ready() -> void:
	_rebuild_cards()
	_update_placement_points()

func _process(_delta: float) -> void:
	if active_touch_index < 0 or touched_card == null or touch_dragging or touch_details_visible:
		return
	var held_duration: float = float(Time.get_ticks_msec() - touch_started_msec) / 1000.0
	if held_duration >= touch_hold_duration:
		_show_touch_details()

func _input(event: InputEvent) -> void:
	var touch: InputEventScreenTouch = event as InputEventScreenTouch
	if touch != null:
		_handle_touch(touch)
		return
	var drag: InputEventScreenDrag = event as InputEventScreenDrag
	if drag != null:
		_handle_touch_drag(drag)

func set_hand(cards: Array[PieceCardState], selected_id: int = NO_CARD_ID, blocked_card_ids: Array[int] = []) -> void:
	current_cards = cards.duplicate()
	selected_card_id = selected_id
	unplaceable_card_ids = blocked_card_ids.duplicate()
	_rebuild_cards()

func clear_hand() -> void:
	var empty_cards: Array[PieceCardState] = []
	var empty_card_ids: Array[int] = []
	set_hand(empty_cards, NO_CARD_ID, empty_card_ids)

func set_selected_card(card_id: int) -> void:
	selected_card_id = card_id
	_rebuild_cards()

func set_unplaceable_cards(card_ids: Array[int]) -> void:
	unplaceable_card_ids = card_ids.duplicate()
	_rebuild_cards()

func set_placement_points(remaining: int, maximum: int) -> void:
	maximum_placement_points = maxi(0, maximum)
	remaining_placement_points = clampi(remaining, 0, maximum_placement_points)
	_update_placement_points()

func set_interaction_enabled(enabled: bool) -> void:
	if interaction_enabled == enabled:
		return
	interaction_enabled = enabled
	_rebuild_cards()

func card_control(card_id: int) -> PieceHandCard:
	for child: Node in %Cards.get_children():
		var card: PieceHandCard = child as PieceHandCard
		if card != null and card.card_state != null and card.card_state.card_id == card_id:
			return card
	return null

func _rebuild_cards() -> void:
	if not is_node_ready():
		return
	_reset_touch_interaction()
	for child: Node in %Cards.get_children():
		%Cards.remove_child(child)
		child.queue_free()
	for card_state: PieceCardState in current_cards:
		if card_state == null or card_state.piece == null:
			continue
		var card: PieceHandCard = CARD_SCENE.instantiate() as PieceHandCard
		%Cards.add_child(card)
		card.setup(card_state, card_state.card_id == selected_card_id, not unplaceable_card_ids.has(card_state.card_id))
		card.disabled = card.disabled or not interaction_enabled
		card.pressed.connect(_select_card.bind(card_state.card_id))
	%CardCount.text = "%d PIECE%s" % [current_cards.size(), "" if current_cards.size() == 1 else "S"]
	%EmptyState.visible = current_cards.is_empty()
	%CardScroll.visible = not current_cards.is_empty()

func _update_placement_points() -> void:
	if is_node_ready():
		%PlacementPoints.text = "PM %d / %d" % [remaining_placement_points, maximum_placement_points]

func _select_card(card_id: int) -> void:
	if card_id == suppressed_card_id:
		suppressed_card_id = NO_CARD_ID
		return
	if not interaction_enabled or unplaceable_card_ids.has(card_id):
		return
	selected_card_id = card_id
	card_selected.emit(card_id)
	_rebuild_cards()

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if active_touch_index >= 0 or not %CardScroll.visible or not %CardScroll.get_global_rect().has_point(event.position):
			return
		active_touch_index = event.index
		touch_start_position = event.position
		touch_start_scroll = %CardScroll.scroll_horizontal
		touch_started_msec = Time.get_ticks_msec()
		touch_dragging = false
		touch_details_visible = false
		touched_card = _card_at_position(event.position)
	elif event.index == active_touch_index:
		var suppress_selection: bool = touch_dragging or touch_details_visible
		var released_card_id: int = NO_CARD_ID
		if touched_card != null and is_instance_valid(touched_card) and touched_card.card_state != null:
			released_card_id = touched_card.card_state.card_id
		_reset_touch_interaction()
		if suppress_selection and released_card_id != NO_CARD_ID:
			suppressed_card_id = released_card_id
			_clear_suppressed_card.call_deferred(released_card_id)

func _handle_touch_drag(event: InputEventScreenDrag) -> void:
	if event.index != active_touch_index:
		return
	var drag_offset: Vector2 = event.position - touch_start_position
	if not touch_dragging and drag_offset.length() < touch_scroll_deadzone:
		return
	touch_dragging = true
	_hide_touch_details()
	var target_scroll: int = touch_start_scroll - roundi(drag_offset.x * touch_scroll_speed)
	%CardScroll.scroll_horizontal = maxi(0, target_scroll)
	get_viewport().set_input_as_handled()

func _card_at_position(global_position: Vector2) -> PieceHandCard:
	for child: Node in %Cards.get_children():
		var card: PieceHandCard = child as PieceHandCard
		if card != null and card.is_visible_in_tree() and card.get_global_rect().has_point(global_position):
			return card
	return null

func _show_touch_details() -> void:
	if touched_card == null or not is_instance_valid(touched_card):
		_reset_touch_interaction()
		return
	var details: String = touched_card.details_text()
	if details.is_empty():
		return
	touch_details_visible = true
	%EffectPreviewText.text = details
	var viewport_size: Vector2 = get_viewport_rect().size
	var available_width: float = maxf(0.0, viewport_size.x - effect_preview_edge_margin * 2.0)
	var preview_width: float = minf(effect_preview_width, available_width)
	%EffectPreviewText.custom_minimum_size.x = maxf(MINIMUM_EFFECT_PREVIEW_TEXT_WIDTH, preview_width - EFFECT_PREVIEW_NON_TEXT_WIDTH)
	%EffectPreview.custom_minimum_size.x = preview_width
	%EffectPreview.reset_size()
	var preview_size: Vector2 = %EffectPreview.get_combined_minimum_size()
	%EffectPreview.size = preview_size
	var anchor: Rect2 = touched_card.get_global_rect()
	var target_x: float = clampf(anchor.get_center().x - preview_size.x * 0.5, effect_preview_edge_margin, maxf(effect_preview_edge_margin, viewport_size.x - preview_size.x - effect_preview_edge_margin))
	var target_y: float = anchor.position.y - preview_size.y - effect_preview_gap
	if target_y < effect_preview_edge_margin:
		target_y = minf(viewport_size.y - preview_size.y - effect_preview_edge_margin, anchor.end.y + effect_preview_gap)
	%EffectPreview.position = Vector2(target_x, maxf(effect_preview_edge_margin, target_y))
	%EffectPreview.visible = true

func _hide_touch_details() -> void:
	if is_node_ready():
		%EffectPreview.visible = false
	touch_details_visible = false

func _reset_touch_interaction() -> void:
	_hide_touch_details()
	active_touch_index = -1
	touch_start_position = Vector2.ZERO
	touch_start_scroll = 0
	touch_started_msec = 0
	touch_dragging = false
	touched_card = null

func _clear_suppressed_card(card_id: int) -> void:
	if suppressed_card_id == card_id:
		suppressed_card_id = NO_CARD_ID
