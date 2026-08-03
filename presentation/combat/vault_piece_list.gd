class_name VaultPieceList
extends Control

signal piece_requested(index: int)

const EFFECT_BADGE_INSET: float = 9.0
const EFFECT_BADGE_RADIUS: float = 4.0

var artifact_state: BossArtifactState
var slot_count: int = 1
var turns_remaining: int = 0
var usable: bool = false
var retrieval_active: bool = false
var hovered_index: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func set_vault(state: BossArtifactState, capacity: int, remaining_turns: int, can_use: bool, active: bool) -> void:
	artifact_state = state
	slot_count = maxi(1, capacity)
	turns_remaining = maxi(0, remaining_turns)
	usable = can_use
	retrieval_active = active
	visible = state != null
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		hovered_index = _slot_at(motion.position)
		tooltip_text = _tooltip_for(hovered_index)
		queue_redraw()
	elif event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_request_slot(_slot_at(mouse.position))
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			_request_slot(_slot_at(touch.position))

func _draw() -> void:
	if artifact_state == null:
		return
	var gap: float = 8.0
	var slot_width: float = minf(96.0, (size.x - gap * float(slot_count - 1)) / float(slot_count))
	var list_width: float = slot_width * float(slot_count) + gap * float(slot_count - 1)
	var start_x: float = maxf(0.0, (size.x - list_width) * 0.5)
	for index: int in slot_count:
		var rectangle: Rect2 = Rect2(Vector2(start_x + float(index) * (slot_width + gap), 2.0), Vector2(slot_width, size.y - 4.0))
		var card: PieceCardState = artifact_state.stored_cards[index] if index < artifact_state.stored_cards.size() else null
		var border_color: Color = _slot_border_color(index, card)
		draw_style_box(_slot_style(Color("12172a"), border_color), rectangle)
		if card != null and card.piece != null:
			PieceDrawing.draw_cells(self, card.piece.base_cells, rectangle.grow(-8.0), card.piece.preview_color, card.piece.preview_color.lightened(0.35))
			if card.intrinsic_effect != null:
				draw_circle(rectangle.position + Vector2(rectangle.size.x - EFFECT_BADGE_INSET, EFFECT_BADGE_INSET), EFFECT_BADGE_RADIUS, card.intrinsic_effect.accent_color)
		else:
			_draw_empty_slot(rectangle)

func _draw_empty_slot(rectangle: Rect2) -> void:
	var center: Vector2 = rectangle.get_center()
	var color: Color = Color("626a82")
	draw_rect(Rect2(center - Vector2(12.0, 9.0), Vector2(24.0, 18.0)), color, false, 2.0)
	draw_circle(center, 5.0, color, false, 1.5)
	var status: String = "ACTIVE" if retrieval_active else ("READY" if turns_remaining == 0 else "%dT" % turns_remaining)
	draw_string(ThemeDB.fallback_font, Vector2(rectangle.position.x + 4.0, rectangle.end.y - 5.0), status, HORIZONTAL_ALIGNMENT_CENTER, rectangle.size.x - 8.0, 9, color)

func _slot_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	return style

func _slot_at(position: Vector2) -> int:
	var gap: float = 8.0
	var slot_width: float = minf(96.0, (size.x - gap * float(slot_count - 1)) / float(slot_count))
	var list_width: float = slot_width * float(slot_count) + gap * float(slot_count - 1)
	var start_x: float = maxf(0.0, (size.x - list_width) * 0.5)
	var index: int = floori((position.x - start_x) / (slot_width + gap))
	return index if index >= 0 and index < slot_count else -1

func _request_slot(index: int) -> void:
	if artifact_state == null or not usable or index < 0 or index >= artifact_state.stored_cards.size():
		return
	piece_requested.emit(index)

func _tooltip_for(index: int) -> String:
	if artifact_state == null or index < 0:
		return ""
	if index >= artifact_state.stored_cards.size():
		return "Vault ready to store an unplayed Block" if turns_remaining == 0 else "%d turn(s) until the Vault can store a Block" % turns_remaining
	var card: PieceCardState = artifact_state.stored_cards[index]
	if card == null or card.piece == null:
		return "Stored Block unavailable"
	var effect_text: String = "Filler Block" if card.intrinsic_effect == null else "%s: %s" % [card.intrinsic_effect.display_name, card.intrinsic_effect.description]
	return "%s\n%s\nSelect to place this stored Block" % [card.piece.display_name, effect_text]

func _slot_border_color(index: int, card: PieceCardState) -> Color:
	if retrieval_active:
		return Color("f1c75b")
	if index == hovered_index:
		return Color("75d7e8")
	if card != null and card.intrinsic_effect != null:
		return card.intrinsic_effect.accent_color.darkened(0.2)
	return Color("303b5d")
