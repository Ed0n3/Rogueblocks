class_name MotionPresets
extends RefCounted

const UI_HOVER_DURATION: float = 0.12
const UI_PRESS_DURATION: float = 0.08
const CARD_ENTER_DURATION: float = 0.24
const SCREEN_TRANSITION_DURATION: float = 0.32
const PIECE_PLACE_DURATION: float = 0.16
const LINE_SCAN_DURATION: float = 0.18
const LINE_REMOVE_DURATION: float = 0.2
const HIT_RECOIL_DURATION: float = 0.12
const ATTACK_TELEGRAPH_DURATION: float = 0.34
const ATTACK_LUNGE_DURATION: float = 0.11
const ATTACK_RETURN_DURATION: float = 0.24

static func pop_in(control: Control, delay: float = 0.0, settings: MotionSettings = null) -> Tween:
	var motion: MotionSettings = settings if settings != null else MotionSettings.new()
	control.modulate.a = 0.0
	control.scale = Vector2.ONE if motion.reduced_motion else Vector2(0.96, 0.96)
	control.pivot_offset = control.size * 0.5
	var tween: Tween = control.create_tween().set_parallel()
	tween.tween_property(control, "modulate:a", 1.0, motion.duration(CARD_ENTER_DURATION)).set_delay(motion.duration(delay))
	tween.tween_property(control, "scale", Vector2.ONE, motion.duration(CARD_ENTER_DURATION)).set_delay(motion.duration(delay)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween

static func fade_out(control: CanvasItem, duration: float, settings: MotionSettings = null) -> Tween:
	var motion: MotionSettings = settings if settings != null else MotionSettings.new()
	var tween: Tween = control.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, motion.duration(duration))
	return tween

static func pulse(control: CanvasItem, strength: float, settings: MotionSettings = null) -> Tween:
	var motion: MotionSettings = settings if settings != null else MotionSettings.new()
	var tween: Tween = control.create_tween()
	if control is Control and not motion.reduced_motion:
		var target: Control = control as Control
		target.pivot_offset = target.size * 0.5
		tween.tween_property(target, "scale", Vector2.ONE * strength, motion.duration(0.08))
		tween.tween_property(target, "scale", Vector2.ONE, motion.duration(0.14)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(control, "modulate:a", 0.65, motion.duration(0.08))
		tween.tween_property(control, "modulate:a", 1.0, motion.duration(0.14))
	return tween
