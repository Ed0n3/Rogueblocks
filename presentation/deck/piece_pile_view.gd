class_name PiecePileView
extends Button

signal pile_pressed(kind: int)

enum PileKind { DRAW, DISCARD }

const PILE_EDGE_INSET: float = 10.0
const PILE_PREVIEW_HEIGHT: float = 48.0
const PILE_CARD_OFFSET: float = 3.0
const PILE_CARD_OUTLINE_WIDTH: float = 1.5
const PILE_BACK_LINE_INSET: float = 12.0
const PILE_BACK_LINE_HALF_GAP: float = 5.0
const MAXIMUM_VISIBLE_CARD_LAYERS: int = 3
const EMPTY_COUNT: int = 0

@export var pile_kind: PileKind = PileKind.DRAW
@export var empty_icon: Texture2D
@export var block_visual_settings: BlockVisualSettings

var card_count: int = EMPTY_COUNT
var top_card: PieceCardState
var interactable: bool = false

func _ready() -> void:
	pressed.connect(_emit_pile_pressed)
	_update_presentation()

func set_pile(kind: PileKind, count: int, visible_top_card: PieceCardState = null) -> void:
	pile_kind = kind
	card_count = maxi(EMPTY_COUNT, count)
	top_card = visible_top_card if kind == PileKind.DISCARD else null
	_update_presentation()
	queue_redraw()

func set_interactable(can_interact: bool) -> void:
	interactable = can_interact
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if interactable else Control.CURSOR_ARROW

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()

func _draw() -> void:
	var preview_width: float = maxf(1.0, size.x - PILE_EDGE_INSET * 2.0)
	var preview_area: Rect2 = Rect2(PILE_EDGE_INSET, PILE_EDGE_INSET, preview_width, PILE_PREVIEW_HEIGHT)
	if card_count <= EMPTY_COUNT:
		draw_rect(preview_area, Color("303b5d"), false, PILE_CARD_OUTLINE_WIDTH)
		return
	if pile_kind == PileKind.DISCARD and top_card != null and top_card.piece != null:
		var piece: PieceDefinition = top_card.piece
		PieceDrawing.draw_cells(self, PieceRotationService.normalize_cells(piece.base_cells), preview_area, piece.preview_color, piece.preview_color.lightened(0.35), block_visual_settings)
		return
	#var visible_layers: int = mini(MAXIMUM_VISIBLE_CARD_LAYERS, card_count)
	#for layer: int in range(visible_layers - 1, -1, -1):
		#var offset: float = float(layer) * PILE_CARD_OFFSET
		#var layer_rect: Rect2 = Rect2(preview_area.position + Vector2(offset, offset), preview_area.size - Vector2(PILE_CARD_OFFSET * 2.0, PILE_CARD_OFFSET * 2.0))
		#draw_rect(layer_rect, Color("182039"), true)
		#draw_rect(layer_rect, Color("78a8ff"), false, PILE_CARD_OUTLINE_WIDTH)
	#var center_y: float = preview_area.position.y + preview_area.size.y * 0.5
	#draw_line(Vector2(preview_area.position.x + PILE_BACK_LINE_INSET, center_y - PILE_BACK_LINE_HALF_GAP), Vector2(preview_area.end.x - PILE_BACK_LINE_INSET, center_y - PILE_BACK_LINE_HALF_GAP), Color("78a8ff"), PILE_CARD_OUTLINE_WIDTH)
	#draw_line(Vector2(preview_area.position.x + PILE_BACK_LINE_INSET, center_y + PILE_BACK_LINE_HALF_GAP), Vector2(preview_area.end.x - PILE_BACK_LINE_INSET, center_y + PILE_BACK_LINE_HALF_GAP), Color("78a8ff"), PILE_CARD_OUTLINE_WIDTH)

func _update_presentation() -> void:
	if not is_node_ready():
		return
	%PileName.text = "DRAW" if pile_kind == PileKind.DRAW else "DISCARD"
	%Count.text = str(card_count)
	var effect: PieceCardEffectDefinition = top_card.intrinsic_effect if top_card != null else null
	%EffectIcon.texture = effect.icon if effect != null and effect.icon != null else empty_icon
	%EffectIcon.visible = pile_kind == PileKind.DISCARD and effect != null
	var top_name: String = top_card.piece.display_name if top_card != null and top_card.piece != null else ""
	var contents: String = "Empty" if card_count == EMPTY_COUNT else "%d pieces" % card_count
	tooltip_text = "%s PILE\n%s%s" % [%PileName.text, contents, "\nTop: %s" % top_name if not top_name.is_empty() else ""]

func _emit_pile_pressed() -> void:
	if interactable:
		pile_pressed.emit(int(pile_kind))
