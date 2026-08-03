class_name LoadoutCounterButton
extends Button

const HOVER_LINE_INSET: float = 8.0
const HOVER_LINE_BOTTOM_OFFSET: float = 4.0
const HOVER_LINE_WIDTH: float = 2.0
const BADGE_RIGHT_MARGIN: float = 8.0
const BADGE_BOTTOM_MARGIN: float = 7.0
const BADGE_WIDTH: float = 36.0
const BADGE_FONT_SIZE: int = 11

var badge_text: String

func set_count(value: String) -> void:
	badge_text = value
	queue_redraw()

func _draw() -> void:
	if is_hovered() or has_focus():
		draw_line(Vector2(HOVER_LINE_INSET, size.y - HOVER_LINE_BOTTOM_OFFSET), Vector2(size.x - HOVER_LINE_INSET, size.y - HOVER_LINE_BOTTOM_OFFSET), Color("6fe5ee"), HOVER_LINE_WIDTH)
	if not badge_text.is_empty():
		var font: Font = get_theme_font(&"font")
		var color: Color = get_theme_color(&"font_disabled_color" if disabled else &"font_color")
		var position: Vector2 = Vector2(size.x - BADGE_WIDTH - BADGE_RIGHT_MARGIN, size.y - BADGE_BOTTOM_MARGIN)
		draw_string(font, position, badge_text, HORIZONTAL_ALIGNMENT_RIGHT, BADGE_WIDTH, BADGE_FONT_SIZE, color)

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER or what == NOTIFICATION_MOUSE_EXIT or what == NOTIFICATION_FOCUS_ENTER or what == NOTIFICATION_FOCUS_EXIT:
		queue_redraw()
