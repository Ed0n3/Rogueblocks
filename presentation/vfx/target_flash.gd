class_name TargetFlash
extends TextureRect

var flash_color: Color = Color("ff786f")
var flash_opacity: float = 0.0
var active_tween: Tween

func play(target_rectangle: Rect2, target_color: Color, maximum_opacity: float, duration: float, motion: MotionSettings) -> void:
	if not motion.flashes_enabled:
		return
	finish()
	position = target_rectangle.position
	size = target_rectangle.size
	flash_color = target_color
	flash_opacity = maximum_opacity
	visible = true
	queue_redraw()
	active_tween = create_tween()
	active_tween.tween_method(_set_opacity, maximum_opacity, 0.0, motion.duration(duration))
	active_tween.tween_callback(func() -> void: visible = false)

func finish() -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	flash_opacity = 0.0
	visible = false
	queue_redraw()

func _set_opacity(value: float) -> void:
	flash_opacity = value
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(flash_color, flash_opacity), true)
	draw_rect(Rect2(Vector2.ZERO, size).grow(-2.0), Color(flash_color, flash_opacity * 1.8), false, 2.0)
