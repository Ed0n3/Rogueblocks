class_name PieceHandCard
extends Button

const SHAPE_HORIZONTAL_PADDING: float = 12.0
const SHAPE_TOP_PADDING: float = 8.0
const SHAPE_BOTTOM_RESERVE: float = 34.0
const PIECE_BORDER_PADDING: float = 2.0
const PIECE_BORDER_WIDTH: float = 2.0
const EFFECT_BORDER_GAP: float = 1.0
const SELECTED_BORDER_WIDTH_BONUS: float = 1.0
const STATUS_MARKER_RADIUS: float = 4.5
const STATUS_MARKER_SPACING: float = 13.0
const STATUS_MARKER_ORIGIN: Vector2 = Vector2(11.0, 11.0)
const STATUS_MARKER_SEGMENTS: int = 12
const STATUS_MARKER_OUTLINE_WIDTH: float = 1.5
const PLACEABLE_SHAPE_OPACITY: float = 0.92
const UNPLACEABLE_SHAPE_OPACITY: float = 0.25

@export var block_visual_settings: BlockVisualSettings

var card_state: PieceCardState
var selected: bool = false
var placeable: bool = true
var modifiers: Array[PieceModifierDefinition] = []

func setup(card: PieceCardState, is_selected: bool, can_place: bool) -> void:
	card_state = card
	selected = is_selected
	placeable = can_place
	disabled = not can_place
	text = ""
	_update_piece_name()
	_update_tooltip()
	queue_redraw()

func set_modifiers(states: Array[PieceModifierState]) -> void:
	modifiers.clear()
	for state: PieceModifierState in states:
		if state.definition != null:
			modifiers.append(state.definition)
	_update_tooltip()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()

func _draw() -> void:
	if card_state == null or card_state.piece == null:
		return
	var piece: PieceDefinition = card_state.piece
	var shape_height: float = maxf(24.0, size.y - SHAPE_TOP_PADDING - SHAPE_BOTTOM_RESERVE)
	var shape_area: Rect2 = Rect2(SHAPE_HORIZONTAL_PADDING, SHAPE_TOP_PADDING, size.x - SHAPE_HORIZONTAL_PADDING * 2.0, shape_height)
	var shape_opacity: float = PLACEABLE_SHAPE_OPACITY if placeable else UNPLACEABLE_SHAPE_OPACITY
	var shape_color: Color = Color(piece.preview_color, shape_opacity)
	var outline_color: Color = Color("7ee7d8") if selected else Color("a3acc5")
	PieceDrawing.draw_cells(self, PieceRotationService.normalize_cells(piece.base_cells), shape_area, shape_color, outline_color, block_visual_settings)
	if card_state.intrinsic_effect != null:
		var effect_inset: float = PIECE_BORDER_PADDING + PIECE_BORDER_WIDTH + EFFECT_BORDER_GAP
		draw_rect(Rect2(effect_inset, effect_inset, size.x - effect_inset * 2.0, size.y - effect_inset * 2.0), Color(card_state.intrinsic_effect.accent_color, 0.82), false, PIECE_BORDER_WIDTH)
	if selected:
		draw_rect(Rect2(PIECE_BORDER_PADDING, PIECE_BORDER_PADDING, size.x - PIECE_BORDER_PADDING * 2.0, size.y - PIECE_BORDER_PADDING * 2.0), Color("7ee7d8"), false, PIECE_BORDER_WIDTH + SELECTED_BORDER_WIDTH_BONUS)
	if not placeable:
		draw_line(Vector2(SHAPE_HORIZONTAL_PADDING, SHAPE_TOP_PADDING), Vector2(size.x - SHAPE_HORIZONTAL_PADDING, size.y - SHAPE_BOTTOM_RESERVE), Color("ff786f"), PIECE_BORDER_WIDTH)
	for index: int in mini(3, modifiers.size()):
		var definition: PieceModifierDefinition = modifiers[index]
		var marker_color: Color = definition.visual_definition.accent_color if definition.visual_definition != null else Color.WHITE
		var marker: Vector2 = STATUS_MARKER_ORIGIN + Vector2(float(index) * STATUS_MARKER_SPACING, 0.0)
		draw_circle(marker, STATUS_MARKER_RADIUS, Color(marker_color, 0.28))
		draw_arc(marker, STATUS_MARKER_RADIUS, 0.0, TAU, STATUS_MARKER_SEGMENTS, marker_color, STATUS_MARKER_OUTLINE_WIDTH, true)

func _update_piece_name() -> void:
	if not is_node_ready():
		return
	%PieceName.text = "PIECE" if card_state == null or card_state.piece == null else card_state.piece.display_name

func _update_tooltip() -> void:
	tooltip_text = details_text()

func details_text() -> String:
	if card_state == null or card_state.piece == null:
		return ""
	var effect_text: String = "Filler piece: No intrinsic effect."
	if card_state.intrinsic_effect != null:
		effect_text = "%s: %s" % [card_state.intrinsic_effect.display_name, card_state.intrinsic_effect.description]
	var modifier_details: PackedStringArray = []
	for definition: PieceModifierDefinition in modifiers:
		modifier_details.append("%s: %s" % [definition.display_name, definition.description])
	var modifier_text: String = "" if modifier_details.is_empty() else "\n\nRun modifiers:\n%s" % "\n".join(modifier_details)
	var placement_text: String = "" if placeable else "\n\nNo valid placement"
	return "%s\n%s%s%s" % [card_state.piece.display_name, effect_text, modifier_text, placement_text]
