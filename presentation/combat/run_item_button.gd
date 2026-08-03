class_name RunItemButton
extends Button

const EMPTY_ICON: Texture2D = preload("res://assets/icons/empty_texture.tres")
const PIECE_BADGE_SIZE: Vector2 = Vector2(40.0, 40.0)
const PIECE_BADGE_MARGIN: float = 4.0
const PIECE_BADGE_PADDING: float = 3.0

var slot_number: int = 1
var stack: ItemStack
var definition: ItemDefinition
var modifiers: Array[PieceModifierDefinition] = []

func set_item(index: int, item_stack: ItemStack, item_definition: ItemDefinition, modifier_states: Array[PieceModifierState] = []) -> void:
	slot_number = index + 1
	stack = item_stack
	definition = item_definition
	modifiers.clear()
	for state: PieceModifierState in modifier_states:
		var modifier: PieceModifierDefinition = state.definition
		if modifier != null:
			modifiers.append(modifier)
	text = ""
	icon = definition.icon if definition != null and definition.icon != null else EMPTY_ICON
	queue_redraw()

func _draw() -> void:
	var alpha: float = 0.42 if disabled else 1.0
	draw_string(ThemeDB.fallback_font, Vector2(5, 12), "%d" % slot_number, HORIZONTAL_ALIGNMENT_LEFT, 12, 9, Color(0.65, 0.7, 0.82, alpha))
	if definition == null or stack == null:
		draw_line(Vector2(size.x * 0.38, size.y * 0.5), Vector2(size.x * 0.62, size.y * 0.5), Color(0.35, 0.4, 0.55, alpha), 2.0)
		return
	if stack.quantity > 1:
		draw_circle(Vector2(size.x - 10, size.y - 10), 9.0, Color(0.04, 0.06, 0.12, 0.94))
		draw_string(ThemeDB.fallback_font, Vector2(size.x - 16, size.y - 6), "%d" % stack.quantity, HORIZONTAL_ALIGNMENT_CENTER, 12, 10, Color.WHITE)
	if stack.bonus_piece != null:
		var badge_position: Vector2 = Vector2(PIECE_BADGE_MARGIN, size.y - PIECE_BADGE_SIZE.y - PIECE_BADGE_MARGIN)
		var badge_rect: Rect2 = Rect2(badge_position, PIECE_BADGE_SIZE)
		draw_rect(badge_rect, Color(0.04, 0.06, 0.12, 0.92), true)
		draw_rect(badge_rect, Color(0.45, 0.84, 0.91, alpha), false, 1.0, true)
		PieceDrawing.draw_cells(self, PieceRotationService.normalize_cells(stack.bonus_piece.base_cells), badge_rect.grow(-PIECE_BADGE_PADDING), Color(0.45, 0.84, 0.91, 0.72 * alpha), Color(0.72, 1.0, 0.94, alpha))
	for index: int in mini(3, modifiers.size()):
		var modifier: PieceModifierDefinition = modifiers[index]
		var marker_color: Color = modifier.visual_definition.accent_color if modifier.visual_definition != null else Color.WHITE
		var marker: Vector2 = Vector2(size.x - 8.0, 8.0 + float(index) * 10.0)
		draw_circle(marker, 3.5, marker_color)
		draw_arc(marker, 5.0, 0.0, TAU, 10, Color(marker_color, 0.65), 1.0, true)
