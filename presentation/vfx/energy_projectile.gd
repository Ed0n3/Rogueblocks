class_name EnergyProjectile
extends Node2D

var start_position: Vector2
var end_position: Vector2
var control_position: Vector2
var progress: float = 0.0
var trail: PackedVector2Array = PackedVector2Array()
var color: Color = Color("7ee7d8")

func play(from: Vector2, to: Vector2, target_color: Color, motion: MotionSettings) -> void:
	start_position = from
	end_position = to
	control_position = (from + to) * 0.5 + Vector2(0.0, -90.0)
	color = target_color
	progress = 0.0
	trail.clear()
	visible = true
	var tween: Tween = create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, motion.duration(0.38)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: visible = false; trail.clear(); queue_redraw())

func _set_progress(value: float) -> void:
	progress = value
	var inverse: float = 1.0 - progress
	position = inverse * inverse * start_position + 2.0 * inverse * progress * control_position + progress * progress * end_position
	trail.append(position)
	while trail.size() > 14:
		trail.remove_at(0)
	queue_redraw()

func _draw() -> void:
	for index: int in trail.size() - 1:
		var alpha: float = float(index + 1) / float(trail.size())
		draw_line(to_local(trail[index]), to_local(trail[index + 1]), Color(color, alpha * 0.5), 2.0 + alpha * 3.0, true)
	draw_circle(Vector2.ZERO, 8.0, Color(color, 0.22))
	draw_circle(Vector2.ZERO, 4.0, color)
