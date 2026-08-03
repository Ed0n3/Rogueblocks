class_name UIMotion
extends Node

var active_tweens: Dictionary[Control, Tween] = {}
var resting_positions: Dictionary[Control, Vector2] = {}

func register_button(button: BaseButton, motion: MotionSettings) -> void:
	resting_positions[button] = button.position
	button.mouse_entered.connect(_animate_button.bind(button, true, motion))
	button.mouse_exited.connect(_animate_button.bind(button, false, motion))
	button.focus_entered.connect(_animate_button.bind(button, true, motion))
	button.focus_exited.connect(_animate_button.bind(button, false, motion))

func _animate_button(control: Control, hovered: bool, motion: MotionSettings) -> void:
	if active_tweens.has(control) and active_tweens[control].is_valid():
		active_tweens[control].kill()
	control.pivot_offset = control.size * 0.5
	var tween: Tween = control.create_tween().set_parallel()
	active_tweens[control] = tween
	var target_scale: Vector2 = Vector2.ONE if motion.reduced_motion or not hovered else Vector2(1.012, 1.012)
	var resting_position: Vector2 = resting_positions.get(control, control.position) as Vector2
	var target_position: Vector2 = resting_position if not hovered else resting_position + Vector2(0.0, -2.0)
	tween.tween_property(control, "scale", target_scale, motion.duration(MotionPresets.UI_HOVER_DURATION))
	tween.tween_property(control, "position", target_position, motion.duration(MotionPresets.UI_HOVER_DURATION))
