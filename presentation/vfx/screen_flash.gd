class_name ScreenFlash
extends ColorRect

var active_tween: Tween

func play(target_color: Color, maximum_opacity: float, duration: float, motion: MotionSettings) -> void:
	if not motion.flashes_enabled:
		return
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	color = Color(target_color, maximum_opacity)
	visible = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	active_tween = create_tween()
	active_tween.tween_property(self, "color:a", 0.0, motion.duration(duration))
	active_tween.tween_callback(func() -> void: visible = false)

func finish() -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	visible = false
	color.a = 0.0

