class_name IconActionButton
extends Button

const BADGE_LEFT_OFFSET: float = 30.0
const BADGE_RIGHT_MARGIN: float = 8.0
const BADGE_BASELINE_OFFSET: float = 3.0
const BADGE_FONT_SIZE: int = 11

enum ActionIcon {
	LOG,
	PAUSE,
	ROTATE_LEFT,
	ROTATE_RIGHT,
	PLACE,
	REROLL,
	EMERGENCY,
	VAULT,
	SKIP,
	END_TURN
}

## Hide the scene label and render only the action icon and badge.
@export var icon_only: bool = false
## Fallback symbol used when no sprite texture is assigned.
@export var action_icon: ActionIcon = ActionIcon.PLACE
## Optional sprite for icon-only buttons.
@export var sprite_texture: Texture2D
## Size of the icon-only sprite or fallback symbol in pixels.
@export var icon_size: float = 40.0

var badge_text: String

func _ready() -> void:
	if icon_only:
		text = ""
	queue_redraw()

func set_badge(value: String) -> void:
	badge_text = value
	queue_redraw()

func _draw() -> void:
	if not icon_only:
		return
	var center: Vector2 = size * 0.5
	var draw_size: Vector2 = Vector2.ONE * icon_size
	if sprite_texture != null:
		draw_texture_rect(sprite_texture, Rect2(center - draw_size * 0.5, draw_size), false, Color.WHITE)
	else:
		_draw_fallback(center, icon_size * 0.5)
	if not badge_text.is_empty():
		var font: Font = get_theme_font("font")
		var color: Color = get_theme_color("font_disabled_color" if disabled else "font_color")
		draw_string(font, Vector2(BADGE_LEFT_OFFSET, size.y * 0.5 + BADGE_BASELINE_OFFSET), badge_text, HORIZONTAL_ALIGNMENT_CENTER, size.x - BADGE_RIGHT_MARGIN, BADGE_FONT_SIZE, color)

func _draw_fallback(center: Vector2, radius: float) -> void:
	var color: Color = get_theme_color("font_disabled_color" if disabled else "font_color")
	match action_icon:
		ActionIcon.LOG:
			draw_rect(Rect2(center - Vector2(radius * 0.7, radius), Vector2(radius * 1.4, radius * 2.0)), color, false, 2.0)
			for offset: float in [-0.45, 0.0, 0.45]:
				draw_line(center + Vector2(-radius * 0.42, offset * radius), center + Vector2(radius * 0.42, offset * radius), color, 2.0)
		ActionIcon.PAUSE:
			draw_rect(Rect2(center + Vector2(-radius * 0.65, -radius), Vector2(radius * 0.45, radius * 2.0)), color)
			draw_rect(Rect2(center + Vector2(radius * 0.2, -radius), Vector2(radius * 0.45, radius * 2.0)), color)
		ActionIcon.ROTATE_LEFT, ActionIcon.ROTATE_RIGHT:
			pass
		ActionIcon.PLACE:
			draw_colored_polygon(PackedVector2Array([center + Vector2(0.0, radius), center + Vector2(-radius * 0.75, 0.1 * radius), center + Vector2(-radius * 0.25, 0.1 * radius), center + Vector2(-radius * 0.25, -radius), center + Vector2(radius * 0.25, -radius), center + Vector2(radius * 0.25, 0.1 * radius), center + Vector2(radius * 0.75, 0.1 * radius)]), color)
		ActionIcon.REROLL:
			draw_arc(center, radius * 0.72, -PI * 0.2, PI * 1.35, 20, color, 2.5, true)
			draw_colored_polygon(PackedVector2Array([center + Vector2(radius * 0.88, -radius * 0.15), center + Vector2(radius * 0.15, -radius * 0.28), center + Vector2(radius * 0.55, radius * 0.35)]), color)
		ActionIcon.EMERGENCY:
			draw_colored_polygon(PackedVector2Array([center + Vector2(0.0, -radius), center + Vector2(radius, radius), center + Vector2(-radius, radius)]), Color(color, 0.9))
			draw_line(center + Vector2(0.0, -radius * 0.45), center + Vector2(0.0, radius * 0.3), Color("111525"), 3.0)
			draw_circle(center + Vector2(0.0, radius * 0.62), 1.8, Color("111525"))
		ActionIcon.VAULT:
			draw_rect(Rect2(center - Vector2(radius, radius * 0.8), Vector2(radius * 2.0, radius * 1.6)), color, false, 2.5)
			draw_circle(center, radius * 0.38, color, false, 2.0)
			draw_circle(center, 2.0, color)
		ActionIcon.SKIP:
			draw_colored_polygon(PackedVector2Array([center + Vector2(-radius, -radius), center + Vector2(0.15 * radius, 0.0), center + Vector2(-radius, radius)]), color)
			draw_colored_polygon(PackedVector2Array([center + Vector2(-0.05 * radius, -radius), center + Vector2(radius, 0.0), center + Vector2(-0.05 * radius, radius)]), color)
		ActionIcon.END_TURN:
			draw_colored_polygon(PackedVector2Array([center + Vector2(-radius, -radius), center + Vector2(radius * 0.35, 0.0), center + Vector2(-radius, radius)]), color)
			draw_rect(Rect2(center + Vector2(radius * 0.48, -radius), Vector2(radius * 0.3, radius * 2.0)), color)
