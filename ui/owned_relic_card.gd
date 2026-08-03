class_name OwnedRelicCard
extends Button

var relic_state: OwnedRelicState

func setup(state: OwnedRelicState) -> void:
	relic_state = state
	tooltip_text = "%s\n\n%s\n\nStacks: %d\nCondition: %s\nObtained from: %s" % [state.display_name, state.description, state.stacks, state.condition_description, state.source_description]
	queue_redraw()

func _draw() -> void:
	if relic_state == null:
		return
	var center: Vector2 = Vector2(25.0, 31.0)
	var points: PackedVector2Array = PackedVector2Array([center + Vector2(0.0, -12.0), center + Vector2(12.0, 0.0), center + Vector2(0.0, 12.0), center + Vector2(-12.0, 0.0)])
	draw_colored_polygon(points, Color(relic_state.accent_color, 0.3))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), relic_state.accent_color, 2.0)
	var font: Font = get_theme_font("font")
	var color: Color = get_theme_color("font_color")
	draw_string(font, Vector2(46.0, 27.0), relic_state.display_name, HORIZONTAL_ALIGNMENT_LEFT, size.x - 84.0, 15, color)
	if relic_state.stacks > 1:
		draw_string(font, Vector2(size.x - 40.0, 27.0), "×%d" % relic_state.stacks, HORIZONTAL_ALIGNMENT_RIGHT, 30.0, 13, Color("8fffe2"))
	draw_string(font, Vector2(46.0, 50.0), relic_state.description, HORIZONTAL_ALIGNMENT_LEFT, size.x - 56.0, 12, Color("aebbc9"))
	draw_string(font, Vector2(46.0, 73.0), relic_state.condition_description, HORIZONTAL_ALIGNMENT_LEFT, size.x - 56.0, 11, Color("71859b"))
	if relic_state.is_new:
		draw_rect(Rect2(1.0, 1.0, size.x - 2.0, size.y - 2.0), Color("6fe5ee"), false, 2.0)
		draw_string(font, Vector2(size.x - 42.0, size.y - 8.0), "NEW", HORIZONTAL_ALIGNMENT_CENTER, 34.0, 10, Color("6fe5ee"))
