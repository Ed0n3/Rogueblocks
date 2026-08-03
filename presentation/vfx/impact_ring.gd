class_name ImpactRing
extends Node2D

var radius: float = 8.0
var line_width: float = 5.0
var opacity: float = 1.0
var color: Color = Color("7ee7d8")

func play(target_position: Vector2, target_color: Color, motion: MotionSettings) -> void:
	position = target_position
	color = target_color
	radius = 8.0
	opacity = 1.0
	visible = true
	var tween: Tween = create_tween().set_parallel()
	tween.tween_method(_set_radius, 8.0, 76.0, motion.duration(0.28)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_opacity, 1.0, 0.0, motion.duration(0.28))
	tween.chain().tween_callback(func() -> void: visible = false)

func _set_radius(value: float) -> void:
	radius = value
	queue_redraw()

func _set_opacity(value: float) -> void:
	opacity = value
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(color, opacity), line_width, true)
	draw_arc(Vector2.ZERO, radius * 0.7, 0.0, TAU, 36, Color(color, opacity * 0.45), 2.0, true)
