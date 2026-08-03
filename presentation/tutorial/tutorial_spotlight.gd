class_name TutorialSpotlight
extends Control

var target_rect: Rect2
var accent_color: Color = Color("72e7d4")
var high_contrast: bool = false

func set_target(rectangle: Rect2) -> void:
	target_rect = rectangle
	queue_redraw()

func _draw() -> void:
	var dim_alpha: float = 0.72 if high_contrast else 0.58
	var dim: Color = Color(0.01, 0.02, 0.06, dim_alpha)
	if target_rect.size.x <= 0.0 or target_rect.size.y <= 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), dim, true)
		return
	var local_target: Rect2 = Rect2(target_rect.position - global_position, target_rect.size)
	draw_rect(Rect2(0.0, 0.0, size.x, maxf(0.0, local_target.position.y)), dim, true)
	draw_rect(Rect2(0.0, local_target.end.y, size.x, maxf(0.0, size.y - local_target.end.y)), dim, true)
	draw_rect(Rect2(0.0, local_target.position.y, maxf(0.0, local_target.position.x), local_target.size.y), dim, true)
	draw_rect(Rect2(local_target.end.x, local_target.position.y, maxf(0.0, size.x - local_target.end.x), local_target.size.y), dim, true)
	draw_rect(local_target, Color(accent_color, 0.13), false, 5.0)
	draw_rect(local_target.grow(4.0), Color(accent_color, 0.5), false, 1.5)
