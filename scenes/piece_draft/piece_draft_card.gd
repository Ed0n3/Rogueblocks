class_name PieceDraftCard
extends Button

const SHAPE_HORIZONTAL_PADDING: float = 18.0
const SHAPE_TOP_PADDING: float = 14.0
const SHAPE_HEIGHT: float = 66.0
const PIECE_NAME_BASELINE: float = 101.0
const PIECE_STATS_BASELINE: float = 121.0
const CARD_TEXT_HORIZONTAL_PADDING: float = 8.0
const PIECE_NAME_FONT_SIZE: int = 16
const PIECE_STATS_FONT_SIZE: int = 12
const SELECTION_BADGE_CENTER: Vector2 = Vector2(18.0, 18.0)
const SELECTION_BADGE_RADIUS: float = 13.0
const SELECTION_NUMBER_BASELINE: Vector2 = Vector2(8.0, 23.0)
const SELECTION_NUMBER_WIDTH: float = 20.0
const SELECTION_NUMBER_FONT_SIZE: int = 14
const EFFECT_BORDER_PADDING: float = 2.0
const EFFECT_BORDER_WIDTH: float = 2.0

@export var block_visual_settings: BlockVisualSettings
@export var empty_effect_icon: Texture2D

var card_state: PieceCardState
var definition: PieceDefinition
var intrinsic_effect: PieceCardEffectDefinition
var selection_number: int = 0

func setup(piece: PieceDefinition, selected_index: int) -> void:
	card_state = null
	_apply_content(piece, piece.permanent_card_effect if piece != null else null, selected_index)

func setup_card(card: PieceCardState, selected_index: int) -> void:
	card_state = card
	_apply_content(card.piece if card != null else null, card.intrinsic_effect if card != null else null, selected_index)

func _apply_content(piece: PieceDefinition, effect: PieceCardEffectDefinition, selected_index: int) -> void:
	definition = piece
	intrinsic_effect = effect
	selection_number = selected_index
	theme_type_variation = &"PrimaryButton" if selection_number > 0 else &"RewardCard"
	if piece == null:
		tooltip_text = ""
		%EffectIcon.texture = empty_effect_icon
		%EffectIcon.visible = false
		queue_redraw()
		return
	var effect_name: String = "Filler piece" if effect == null else effect.display_name
	var effect_description: String = "No intrinsic effect" if effect == null else effect.description
	tooltip_text = "%s\n%d cells | %d rotations\n%s: %s" % [piece.display_name, piece.base_cells.size(), PieceRotationService.get_unique_rotations(piece).size(), effect_name, effect_description]
	%EffectIcon.texture = effect.icon if effect != null and effect.icon != null else empty_effect_icon
	%EffectIcon.visible = effect != null
	queue_redraw()

func _draw() -> void:
	if definition == null:
		return
	PieceDrawing.draw_cells(self, definition.base_cells, Rect2(SHAPE_HORIZONTAL_PADDING, SHAPE_TOP_PADDING, size.x - SHAPE_HORIZONTAL_PADDING * 2.0, SHAPE_HEIGHT), definition.preview_color, definition.preview_color.lightened(0.35), block_visual_settings)
	var font: Font = get_theme_font("font")
	draw_string(font, Vector2(CARD_TEXT_HORIZONTAL_PADDING, PIECE_NAME_BASELINE), definition.display_name, HORIZONTAL_ALIGNMENT_CENTER, size.x - CARD_TEXT_HORIZONTAL_PADDING * 2.0, PIECE_NAME_FONT_SIZE, get_theme_color("font_color"))
	draw_string(font, Vector2(CARD_TEXT_HORIZONTAL_PADDING, PIECE_STATS_BASELINE), "%d CELLS | %d ROT" % [definition.base_cells.size(), PieceRotationService.get_unique_rotations(definition).size()], HORIZONTAL_ALIGNMENT_CENTER, size.x - CARD_TEXT_HORIZONTAL_PADDING * 2.0, PIECE_STATS_FONT_SIZE, Color("93a4c0"))
	if intrinsic_effect != null:
		draw_rect(Rect2(EFFECT_BORDER_PADDING, EFFECT_BORDER_PADDING, size.x - EFFECT_BORDER_PADDING * 2.0, size.y - EFFECT_BORDER_PADDING * 2.0), Color(intrinsic_effect.accent_color, 0.82), false, EFFECT_BORDER_WIDTH)
	if selection_number > 0:
		draw_circle(SELECTION_BADGE_CENTER, SELECTION_BADGE_RADIUS, Color("72e7d4"))
		draw_string(font, SELECTION_NUMBER_BASELINE, str(selection_number), HORIZONTAL_ALIGNMENT_CENTER, SELECTION_NUMBER_WIDTH, SELECTION_NUMBER_FONT_SIZE, Color("07101e"))
