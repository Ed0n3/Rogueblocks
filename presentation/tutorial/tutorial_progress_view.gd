class_name TutorialProgressView
extends Control

var current_step: int = 0
var step_count: int = 0

func setup(current: int, total: int) -> void:
	current_step = current
	step_count = total
	custom_minimum_size = Vector2(maxf(80.0, float(total) * 18.0), 18.0)
	queue_redraw()

func _draw() -> void:
	if step_count <= 0:
		return
	var spacing: float = size.x / float(step_count)
	for index: int in step_count:
		var center: Vector2 = Vector2(spacing * (float(index) + 0.5), size.y * 0.5)
		var color: Color = Color("82f0ac") if index <= current_step else Color("465171")
		draw_circle(center, 4.0 if index != current_step else 6.0, color)
