class_name VFXLayer
extends Control

@export var visual_settings: CombatVisualSettings

var motion: MotionSettings
var rings: Array[ImpactRing] = []
var texts: Array[FloatingText] = []
var projectiles: Array[EnergyProjectile] = []
var bursts: Array[ParticleBurst] = []
var screen_flash: ScreenFlash
@onready var target_flashes: Array[TargetFlash] = [%TargetFlashOne, %TargetFlashTwo]
var shake_tween: Tween
var shake_target: Control
var shake_resting_position: Vector2

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	if visual_settings == null:
		visual_settings = load("res://content/presentation/combat_visual_settings.tres") as CombatVisualSettings
	for index: int in 4:
		var ring: ImpactRing = ImpactRing.new()
		ring.visible = false
		add_child(ring)
		rings.append(ring)
	for index: int in 22:
		var floating: FloatingText = FloatingText.new()
		floating.visible = false
		add_child(floating)
		texts.append(floating)
	for index: int in visual_settings.maximum_projectile_count:
		_create_projectile()
	for index: int in 6:
		var burst: ParticleBurst = ParticleBurst.new()
		burst.visible = false
		burst.set_process(false)
		add_child(burst)
		bursts.append(burst)
	screen_flash = ScreenFlash.new()
	screen_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_flash.visible = false
	add_child(screen_flash)

func global_to_layer(global_point: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * global_point

func global_rect_to_layer(global_rectangle: Rect2) -> Rect2:
	var local_start: Vector2 = global_to_layer(global_rectangle.position)
	var local_end: Vector2 = global_to_layer(global_rectangle.end)
	return Rect2(local_start, local_end - local_start)

func impact(global_position: Vector2, color: Color) -> void:
	var ring: ImpactRing = _available_ring()
	ring.play(global_to_layer(global_position), color, motion)

func floating_value(value: String, global_position: Vector2, color: Color, style: CombatValueStyle.Value = CombatValueStyle.Value.ENEMY_DAMAGE, large: bool = false) -> void:
	var floating: FloatingText = _available_text()
	floating.play(value, global_to_layer(global_position), color, motion, style, visual_settings, large)

func projectile(global_from: Vector2, global_to: Vector2, color: Color) -> void:
	var effect: EnergyProjectile = _available_projectile()
	effect.play(global_to_layer(global_from), global_to_layer(global_to), color, motion)

func burst(global_position: Vector2, color: Color, preset: ParticleBurst.Preset) -> void:
	if not motion.particles_enabled:
		return
	_available_burst().play(global_to_layer(global_position), color, preset, motion)

func target_flash(global_rectangle: Rect2, color: Color, opacity: float, duration: float) -> void:
	var target: TargetFlash = _available_target_flash()
	target.play(global_rect_to_layer(global_rectangle), color, opacity, duration, motion)

func flash(color: Color, opacity: float = 0.12, duration: float = 0.18) -> void:
	screen_flash.play(color, opacity, duration, motion)

func shake(target: Control, strength: float, duration: float) -> void:
	if not motion.screen_shake_enabled or motion.reduced_motion or strength <= 0.0:
		return
	if shake_tween != null and shake_tween.is_valid():
		shake_tween.kill()
		if shake_target != null:
			shake_target.position = shake_resting_position
	shake_target = target
	shake_resting_position = target.position
	var elapsed: float = 0.0
	shake_tween = create_tween()
	shake_tween.tween_method(func(value: float) -> void:
		elapsed = value
		var decay: float = 1.0 - elapsed
		target.position = shake_resting_position + Vector2(sin(elapsed * 91.0), cos(elapsed * 73.0)) * strength * motion.shake_strength * decay,
		0.0, 1.0, motion.duration(duration))
	shake_tween.tween_callback(func() -> void: target.position = shake_resting_position)

func clear_effects() -> void:
	for ring: ImpactRing in rings:
		ring.visible = false
	for floating: FloatingText in texts:
		floating.reset()
	for effect: EnergyProjectile in projectiles:
		effect.visible = false
	for burst_effect: ParticleBurst in bursts:
		burst_effect.finish()
	for target: TargetFlash in target_flashes:
		target.finish()
	if screen_flash != null:
		screen_flash.finish()
	if shake_tween != null and shake_tween.is_valid():
		shake_tween.kill()
	if shake_target != null:
		shake_target.position = shake_resting_position

func _available_ring() -> ImpactRing:
	for ring: ImpactRing in rings:
		if not ring.visible:
			return ring
	return rings[0]

func _available_text() -> FloatingText:
	for floating: FloatingText in texts:
		if not floating.visible:
			return floating
	return texts[0]

func _available_projectile() -> EnergyProjectile:
	for effect: EnergyProjectile in projectiles:
		if not effect.visible:
			return effect
	return _create_projectile()

func _create_projectile() -> EnergyProjectile:
	var projectile: EnergyProjectile = EnergyProjectile.new()
	projectile.visible = false
	add_child(projectile)
	projectiles.append(projectile)
	return projectile

func _available_burst() -> ParticleBurst:
	for burst_effect: ParticleBurst in bursts:
		if not burst_effect.active:
			return burst_effect
	return bursts[0]

func _available_target_flash() -> TargetFlash:
	for target: TargetFlash in target_flashes:
		if not target.visible:
			return target
	return target_flashes[0]
