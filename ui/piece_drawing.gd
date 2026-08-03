class_name PieceDrawing
extends RefCounted

const BlockVisualSettings = preload("res://presentation/board/block_visual_settings.gd")

static func draw_cells(canvas: CanvasItem, cells: Array[Vector2i], area: Rect2, color: Color, outline: Color = Color.TRANSPARENT, settings_override: BlockVisualSettings = null) -> void:
	if cells.is_empty():
		return
	var visual_settings: BlockVisualSettings = settings_override if settings_override != null else BlockVisualSettings.load_default()
	var resolved_outline: Color = visual_settings.outline_color if outline == Color.TRANSPARENT else outline
	var maximum: Vector2i = Vector2i.ONE
	for cell: Vector2i in cells:
		maximum.x = maxi(maximum.x, cell.x + 1)
		maximum.y = maxi(maximum.y, cell.y + 1)
	var cell_size: float = floorf(minf(area.size.x / float(maximum.x), area.size.y / float(maximum.y)))
	var shape_size: Vector2 = Vector2(maximum) * cell_size
	var offset: Vector2 = area.position + (area.size - shape_size) * 0.5
	for cell: Vector2i in cells:
		var rectangle: Rect2 = Rect2(offset + Vector2(cell) * cell_size, Vector2.ONE * cell_size).grow(-2.0)
		draw_block_rectangle(canvas, rectangle, color, resolved_outline, visual_settings.canvas_outline_width, visual_settings)

static func draw_beveled_rectangle(canvas: CanvasItem, rectangle: Rect2, color: Color, outline: Color, outline_width: float, visual_settings: BlockVisualSettings = null) -> void:
	var resolved_settings: BlockVisualSettings = visual_settings if visual_settings != null else BlockVisualSettings.load_default()
	var bevel_width: float = clampf(minf(rectangle.size.x, rectangle.size.y) * resolved_settings.canvas_bevel_width_ratio, resolved_settings.canvas_minimum_bevel_width, resolved_settings.canvas_maximum_bevel_width)
	var edge_inset: float = maxf(outline_width, resolved_settings.canvas_minimum_bevel_width)
	var top_left: Vector2 = rectangle.position + Vector2.ONE * edge_inset
	var bottom_right: Vector2 = rectangle.end - Vector2.ONE * edge_inset
	var highlight_color: Color = Color(Color.WHITE, color.a * resolved_settings.highlight_opacity)
	var shadow_color: Color = Color(Color.BLACK, color.a * resolved_settings.shadow_opacity)
	canvas.draw_rect(rectangle, color, true)
	if bottom_right.x > top_left.x and bottom_right.y > top_left.y:
		canvas.draw_line(top_left, Vector2(bottom_right.x, top_left.y), highlight_color, bevel_width, true)
		canvas.draw_line(top_left, Vector2(top_left.x, bottom_right.y), highlight_color, bevel_width, true)
		canvas.draw_line(Vector2(top_left.x, bottom_right.y), bottom_right, shadow_color, bevel_width, true)
		canvas.draw_line(Vector2(bottom_right.x, top_left.y), bottom_right, shadow_color, bevel_width, true)
	canvas.draw_rect(rectangle, outline, false, outline_width)

static func draw_block_rectangle(canvas: CanvasItem, rectangle: Rect2, color: Color, outline: Color, outline_width: float, visual_settings: BlockVisualSettings = null) -> void:
	var resolved_settings: BlockVisualSettings = visual_settings if visual_settings != null else BlockVisualSettings.load_default()
	if resolved_settings.block_style_texture != null:
		var texture_modulate: Color = color if resolved_settings.tint_block_style_texture else Color(1.0, 1.0, 1.0, color.a)
		canvas.draw_texture_rect(resolved_settings.block_style_texture, rectangle, false, texture_modulate)
		return
	var resolved_outline: Color = resolved_settings.outline_color if outline == Color.TRANSPARENT else outline
	draw_beveled_rectangle(canvas, rectangle, color, resolved_outline, outline_width, resolved_settings)
	var minimum_size: float = minf(rectangle.size.x, rectangle.size.y)
	var corner_size: float = minimum_size * resolved_settings.mechanical_corner_cut_ratio
	var corner_color: Color = Color(resolved_outline, color.a * resolved_settings.mechanical_corner_cut_opacity)
	canvas.draw_colored_polygon(PackedVector2Array([rectangle.position, rectangle.position + Vector2(corner_size, 0.0), rectangle.position + Vector2(0.0, corner_size)]), corner_color)
	var top_right: Vector2 = Vector2(rectangle.end.x, rectangle.position.y)
	canvas.draw_colored_polygon(PackedVector2Array([top_right, top_right + Vector2(-corner_size, 0.0), top_right + Vector2(0.0, corner_size)]), corner_color)
	canvas.draw_colored_polygon(PackedVector2Array([rectangle.end, rectangle.end + Vector2(-corner_size, 0.0), rectangle.end + Vector2(0.0, -corner_size)]), corner_color)
	var bottom_left: Vector2 = Vector2(rectangle.position.x, rectangle.end.y)
	canvas.draw_colored_polygon(PackedVector2Array([bottom_left, bottom_left + Vector2(corner_size, 0.0), bottom_left + Vector2(0.0, -corner_size)]), corner_color)
