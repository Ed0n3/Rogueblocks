class_name MotionSettings
extends Resource

@export_range(0.0, 2.0) var animation_speed: float = 1.0
@export var reduced_motion: bool = false
@export var screen_shake_enabled: bool = true
@export var particles_enabled: bool = true
@export var flashes_enabled: bool = true
@export var idle_motion_enabled: bool = true
@export_range(0.0, 1.0) var shake_strength: float = 1.0
@export_range(0.0, 1.0) var particle_density: float = 1.0
@export var larger_combat_text: bool = false

static func from_saved_settings(settings: GameSettings) -> MotionSettings:
	var motion: MotionSettings = MotionSettings.new()
	motion.animation_speed = settings.combat_animation_speed
	motion.reduced_motion = settings.reduced_motion
	motion.screen_shake_enabled = settings.screen_shake
	motion.particles_enabled = settings.particle_density > 0.0
	motion.flashes_enabled = settings.flashes_enabled
	motion.idle_motion_enabled = not motion.reduced_motion
	motion.particle_density = settings.particle_density
	motion.larger_combat_text = settings.larger_combat_text
	return motion

func duration(base_duration: float) -> float:
	if animation_speed <= 0.0:
		return 0.0
	var reduction: float = 0.35 if reduced_motion else 1.0
	return base_duration * reduction / animation_speed
