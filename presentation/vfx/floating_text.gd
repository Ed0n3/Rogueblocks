class_name FloatingText
extends Label

var active_tween: Tween

func play(value: String, start_position: Vector2, text_color: Color, motion: MotionSettings, style: CombatValueStyle.Value, settings: CombatVisualSettings, large: bool = false) -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	text = value
	custom_minimum_size = Vector2(220.0, 42.0)
	size = custom_minimum_size
	position = start_position - size * 0.5
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	scale = Vector2.ONE
	rotation = 0.0
	modulate = text_color
	modulate.a = 1.0
	var normal_size: int = settings.normal_damage_font_size if settings != null else 25
	var large_size: int = settings.large_damage_font_size if settings != null else 34
	add_theme_font_size_override("font_size", large_size if large or motion.larger_combat_text else normal_size)
	add_theme_constant_override("outline_size", 4 if style != CombatValueStyle.Value.DETAIL else 2)
	add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.07, 0.9))
	if style == CombatValueStyle.Value.BLOCKED:
		text = "BLOCKED"
	visible = true
	var rise: float = settings.damage_number_rise if settings != null else 48.0
	var duration: float = settings.damage_number_duration if settings != null else 0.55
	active_tween = create_tween().set_parallel()
	active_tween.tween_property(self, "position:y", position.y - rise, motion.duration(duration)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "modulate:a", 0.0, motion.duration(duration)).set_delay(motion.duration(0.16))
	active_tween.chain().tween_callback(func() -> void: visible = false)

func reset() -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	text = ""
	scale = Vector2.ONE
	rotation = 0.0
	modulate = Color.WHITE
	custom_minimum_size = Vector2.ZERO
	visible = false
