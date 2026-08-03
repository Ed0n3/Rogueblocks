class_name ScreenTransitionController
extends RefCounted

static func enter(screen: Control, settings: MotionSettings) -> Tween:
	var resting_position: Vector2 = screen.position
	screen.modulate.a = 0.0
	if not settings.reduced_motion:
		screen.position = resting_position + Vector2(0.0, 12.0)
	var tween: Tween = screen.create_tween().set_parallel()
	tween.tween_property(screen, "modulate:a", 1.0, settings.duration(MotionPresets.SCREEN_TRANSITION_DURATION))
	tween.tween_property(screen, "position", resting_position, settings.duration(MotionPresets.SCREEN_TRANSITION_DURATION)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return tween

static func modal_enter(modal: Control, settings: MotionSettings) -> Tween:
	modal.modulate.a = 0.0
	modal.scale = Vector2.ONE if settings.reduced_motion else Vector2(0.96, 0.96)
	modal.pivot_offset = modal.size * 0.5
	var tween: Tween = modal.create_tween().set_parallel()
	tween.tween_property(modal, "modulate:a", 1.0, settings.duration(0.22))
	tween.tween_property(modal, "scale", Vector2.ONE, settings.duration(0.22)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween

