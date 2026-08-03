class_name ShopItemIcon
extends Control

const EMPTY_ICON: Texture2D = preload("res://assets/icons/empty_texture.tres")
const PIECE_BADGE_SIZE: Vector2 = Vector2(24.0, 24.0)
const PIECE_BADGE_MARGIN: float = 2.0
const PIECE_BADGE_PADDING: float = 3.0

var view_state: ShopItemViewState

func setup(state: ShopItemViewState) -> void:
	view_state = state
	var item_texture: TextureRect = $ItemTexture
	var consumable: bool = view_state != null and (view_state.category == ShopItemViewState.Category.POTION or view_state.category == ShopItemViewState.Category.BLOCK_CAPSULE)
	item_texture.texture = view_state.icon if consumable and view_state.icon != null else EMPTY_ICON
	item_texture.visible = consumable
	queue_redraw()

func _draw() -> void:
	if view_state == null:
		return
	match view_state.category:
		ShopItemViewState.Category.RELIC:
			_draw_relic()
		ShopItemViewState.Category.BLOCK_CAPSULE:
			_draw_piece_badge()
		ShopItemViewState.Category.BOARD_PIECE:
			_draw_block()
		ShopItemViewState.Category.SERVICE:
			_draw_service()

func _draw_relic() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.28
	var points: PackedVector2Array = PackedVector2Array([center + Vector2(0.0, -radius), center + Vector2(radius, 0.0), center + Vector2(0.0, radius), center + Vector2(-radius, 0.0)])
	draw_colored_polygon(points, Color(view_state.accent_color, 0.28))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), view_state.accent_color, 2.0, true)
	draw_circle(center, radius * 0.25, view_state.accent_color)

func _draw_block() -> void:
	if view_state.piece == null:
		_draw_service()
		return
	PieceDrawing.draw_cells(self, PieceRotationService.normalize_cells(view_state.piece.base_cells), Rect2(Vector2.ZERO, size).grow(-5.0), Color(view_state.piece.preview_color, 0.8), view_state.piece.preview_color.lightened(0.35))

func _draw_piece_badge() -> void:
	if view_state.piece == null:
		return
	var badge_position: Vector2 = Vector2(size.x - PIECE_BADGE_SIZE.x - PIECE_BADGE_MARGIN, size.y - PIECE_BADGE_SIZE.y - PIECE_BADGE_MARGIN)
	var badge_rect: Rect2 = Rect2(badge_position, PIECE_BADGE_SIZE)
	draw_rect(badge_rect, Color(0.04, 0.06, 0.12, 0.92), true)
	draw_rect(badge_rect, Color(0.45, 0.84, 0.91, 1.0), false, 1.0, true)
	PieceDrawing.draw_cells(self, PieceRotationService.normalize_cells(view_state.piece.base_cells), badge_rect.grow(-PIECE_BADGE_PADDING), Color(0.45, 0.84, 0.91, 0.72), Color(0.72, 1.0, 0.94, 1.0))

func _draw_service() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.24
	draw_circle(center, radius, Color(view_state.accent_color, 0.22))
	draw_arc(center, radius, 0.0, TAU, 12, view_state.accent_color, 2.0, true)
	draw_line(center + Vector2(-radius * 0.65, radius * 0.65), center + Vector2(radius * 0.65, -radius * 0.65), view_state.accent_color, 4.0, true)
	draw_circle(center + Vector2(radius * 0.65, -radius * 0.65), 4.0, view_state.accent_color)
