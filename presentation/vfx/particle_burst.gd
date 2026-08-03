class_name ParticleBurst
extends Node2D

enum Preset { CELL_FRAGMENTS, CYAN_ENERGY, ENEMY_HIT, REWARD_SPARKLES, BLOCKER_DUST, PERFECT_CLEAR }

class ParticleVisual extends RefCounted:
	var position: Vector2
	var velocity: Vector2
	var size: float
	var life: float
	var maximum_life: float
	var rotation: float
	var angular_velocity: float

var particles: Array[ParticleVisual] = []
var color: Color = Color("7ee7d8")
var active: bool = false

func play(origin: Vector2, target_color: Color, preset: Preset, motion: MotionSettings) -> void:
	position = origin
	color = target_color
	particles.clear()
	var base_count: int = 28 if preset == Preset.PERFECT_CLEAR else 16
	var count: int = maxi(1, roundi(float(base_count) * motion.particle_density))
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = Time.get_ticks_usec()
	for index: int in count:
		var angle: float = random.randf_range(-PI, PI)
		var speed: float = random.randf_range(55.0, 150.0 if preset == Preset.PERFECT_CLEAR else 105.0)
		var particle: ParticleVisual = ParticleVisual.new()
		particle.position = Vector2.ZERO
		particle.velocity = Vector2.from_angle(angle) * speed
		particle.size = random.randf_range(2.0, 5.5)
		particle.maximum_life = random.randf_range(0.28, 0.58)
		particle.life = particle.maximum_life
		particle.rotation = random.randf_range(0.0, TAU)
		particle.angular_velocity = random.randf_range(-5.0, 5.0)
		particles.append(particle)
	active = motion.particles_enabled and motion.particle_density > 0.0
	visible = active
	set_process(active)
	queue_redraw()

func finish() -> void:
	particles.clear()
	active = false
	visible = false
	set_process(false)
	queue_redraw()

func _process(delta: float) -> void:
	var any_alive: bool = false
	for particle: ParticleVisual in particles:
		particle.life = maxf(0.0, particle.life - delta)
		if particle.life <= 0.0:
			continue
		particle.velocity += Vector2(0.0, 90.0) * delta
		particle.position += particle.velocity * delta
		particle.rotation += particle.angular_velocity * delta
		any_alive = true
	if not any_alive:
		finish()
	else:
		queue_redraw()

func _draw() -> void:
	for particle: ParticleVisual in particles:
		if particle.life <= 0.0:
			continue
		var opacity: float = particle.life / particle.maximum_life
		var half_size: float = particle.size * 0.5
		var points: PackedVector2Array = PackedVector2Array([
			particle.position + Vector2.from_angle(particle.rotation) * particle.size,
			particle.position + Vector2.from_angle(particle.rotation + PI * 0.5) * half_size,
			particle.position + Vector2.from_angle(particle.rotation + PI) * particle.size,
			particle.position + Vector2.from_angle(particle.rotation + PI * 1.5) * half_size
		])
		draw_colored_polygon(points, Color(color, opacity))

