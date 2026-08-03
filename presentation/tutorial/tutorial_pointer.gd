class_name TutorialPointer
extends Control

var target_rect: Rect2
var accent_color: Color = Color("82f0ac")
var reduced_motion: bool = false
var phase: float = 0.0

func set_target(rectangle: Rect2) -> void:
	target_rect = rectangle
	queue_redraw()

func _process(delta: float) -> void:
	if not reduced_motion:
		phase += delta
		queue_redraw()

func _draw() -> void:
	if target_rect.size.x <= 0.0:
		return
	var rectangle: Rect2 = Rect2(target_rect.position - global_position, target_rect.size)
	var pulse: float = 0.0 if reduced_motion else sin(phase * 3.0) * 3.0
	rectangle = rectangle.grow(7.0 + pulse)
	var length: float = 18.0
	var corners: Array[Vector2] = [rectangle.position, Vector2(rectangle.end.x, rectangle.position.y), rectangle.end, Vector2(rectangle.position.x, rectangle.end.y)]
	draw_line(corners[0], corners[0] + Vector2(length, 0), accent_color, 3.0)
	draw_line(corners[0], corners[0] + Vector2(0, length), accent_color, 3.0)
	draw_line(corners[1], corners[1] + Vector2(-length, 0), accent_color, 3.0)
	draw_line(corners[1], corners[1] + Vector2(0, length), accent_color, 3.0)
	draw_line(corners[2], corners[2] + Vector2(-length, 0), accent_color, 3.0)
	draw_line(corners[2], corners[2] + Vector2(0, -length), accent_color, 3.0)
	draw_line(corners[3], corners[3] + Vector2(length, 0), accent_color, 3.0)
	draw_line(corners[3], corners[3] + Vector2(0, -length), accent_color, 3.0)
