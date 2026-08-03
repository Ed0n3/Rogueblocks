class_name EnemyPresentation
extends Control

signal animation_finished()

@export_range(1.0, 2.0, 0.05) var actor_scale_multiplier: float = 1.5

@onready var actor: EnemyActor = %Actor
@onready var shadow: Polygon2D = %Shadow
@onready var glow: Polygon2D = %Glow
@onready var shield_overlay: Polygon2D = %ShieldOverlay
@onready var backdrop: TextureRect = %Backdrop

var definition: EnemyVisualDefinition
var motion: MotionSettings
var idle_tween: Tween
var action_tween: Tween
var death_started: bool = false
var phase_transitioning: bool = false
var base_actor_position: Vector2
var base_shadow_scale: Vector2
var flash_material: ShaderMaterial
var dissolve_material: ShaderMaterial
var visual_settings: CombatVisualSettings
var background_material: ShaderMaterial

func _ready() -> void:
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	visual_settings = load("res://content/presentation/combat_visual_settings.tres") as CombatVisualSettings
	background_material = backdrop.material.duplicate() as ShaderMaterial
	backdrop.material = background_material
	background_material.set_shader_parameter("animation_strength", 0.0 if motion.reduced_motion else 1.0)

func configure(enemy: EnemyDefinition, visual: EnemyVisualDefinition = null) -> void:
	definition = visual if visual != null else _fallback_definition(enemy)
	flash_material = ShaderMaterial.new()
	flash_material.shader = load("res://presentation/shaders/enemy_effects.gdshader") as Shader
	_reset_effect_shader()
	flash_material.set_shader_parameter("flash_color", visual_settings.enemy_hit_color if visual_settings != null else definition.hit_color)
	dissolve_material = ShaderMaterial.new()
	dissolve_material.shader = load("res://presentation/shaders/sprite_dissolve.gdshader") as Shader
	dissolve_material.set_shader_parameter("dissolve_progress", 0.0)
	dissolve_material.set_shader_parameter("edge_color", definition.accent_color)
	dissolve_material.set_shader_parameter("seed", float(absi(enemy.resource_path.hash()) % 997) + 1.0)
	actor.material = flash_material
	actor.configure(enemy, definition.sprite, definition.accent_color)
	actor.modulate = Color.WHITE
	shadow.modulate = Color.WHITE
	glow.color = Color(definition.accent_color, 0.16)
	background_material.set_shader_parameter("accent_color", definition.accent_color)
	background_material.set_shader_parameter("pulse_strength", 0.2)
	glow.modulate = Color.WHITE
	death_started = false
	phase_transitioning = false
	_layout_visuals(false)
	start_idle()

func set_combat_state(intent: ResolvedEnemyIntent, shield: int, statuses: StatusCollection) -> void:
	if definition == null:
		return
	_reset_status_shader()
	shield_overlay.visible = shield > 0
	if shield > 0:
		shield_overlay.color = Color(definition.accent_color, clampf(0.18 + float(shield) * 0.012, 0.18, 0.4))
		shield_overlay.scale = Vector2.ONE * (0.95 + minf(0.12, float(shield) * 0.006))
		flash_material.set_shader_parameter("shield_strength", clampf(0.16 + float(shield) * 0.012, 0.16, 0.36))
		flash_material.set_shader_parameter("shield_color", definition.accent_color)
	var aura_color: Color = definition.accent_color
	var aura_alpha: float = 0.16
	var aura_priority: int = -1
	if intent != null:
		aura_color = intent.accent_color
		aura_alpha = 0.28 if intent.turns_remaining <= 1 else 0.2
	if statuses != null:
		for instance: StatusInstance in statuses.instances:
			var status: StatusDefinition = instance.definition
			if status == null or status.visual_definition == null or not status.visual_definition.applies_to_enemy:
				continue
			_apply_status_visual(status.visual_definition, instance.stacks)
			if status.visual_definition.priority > aura_priority:
				aura_priority = status.visual_definition.priority
				aura_color = status.visual_definition.primary_color
				aura_alpha = 0.3
	glow.color = Color(aura_color, aura_alpha)
	background_material.set_shader_parameter("accent_color", aura_color)
	background_material.set_shader_parameter("pulse_strength", clampf(aura_alpha + (0.12 if intent != null and intent.turns_remaining <= 1 else 0.0), 0.18, 0.55))

func get_actor_global_rect() -> Rect2:
	return actor.get_global_rect()

func get_effect_strength(channel: StatusVisualChannel.Value) -> float:
	return StatusVisualMaterialDriver.effect_strength(flash_material, channel)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready() and definition != null:
		_layout_visuals.call_deferred(true)

func _layout_visuals(resume_idle: bool) -> void:
	if definition == null or size.x <= 0.0 or size.y <= 0.0:
		return
	_stop_tween(idle_tween)
	actor.set_anchors_preset(Control.PRESET_TOP_LEFT)
	actor.size = Vector2(maxf(80.0, size.x - 32.0), maxf(80.0, size.y - 20.0))
	actor.position = (size - actor.size) * 0.5 + definition.sprite_offset
	actor.scale = _actor_scale()
	actor.pivot_offset = actor.size * definition.pivot_ratio
	base_actor_position = actor.position
	shadow.scale = definition.shadow_size / Vector2(170.0, 34.0)
	shadow.position = Vector2(size.x * 0.5 + definition.sprite_offset.x, size.y * 0.82) + definition.shadow_offset
	base_shadow_scale = shadow.scale
	glow.position = size * Vector2(0.5, 0.48)
	var glow_scale: float = minf(size.x, size.y) / 310.0
	glow.scale = Vector2.ONE * glow_scale
	shield_overlay.position = glow.position
	shield_overlay.scale = Vector2.ONE * glow_scale
	if resume_idle and not death_started and not phase_transitioning:
		start_idle()

func start_idle() -> void:
	_stop_tween(idle_tween)
	if definition == null or death_started or phase_transitioning or not motion.idle_motion_enabled:
		return
	idle_tween = create_tween().set_loops()
	idle_tween.tween_property(actor, "position:y", base_actor_position.y - definition.idle_height, motion.duration(definition.idle_duration * 0.5)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.parallel().tween_property(actor, "rotation", deg_to_rad(definition.idle_rotation_degrees), motion.duration(definition.idle_duration * 0.5)).set_trans(Tween.TRANS_SINE)
	idle_tween.parallel().tween_property(shadow, "scale", base_shadow_scale * Vector2(0.88, 0.82), motion.duration(definition.idle_duration * 0.5)).set_trans(Tween.TRANS_SINE)
	idle_tween.parallel().tween_property(shadow, "modulate:a", 0.5, motion.duration(definition.idle_duration * 0.5))
	idle_tween.tween_property(actor, "position:y", base_actor_position.y, motion.duration(definition.idle_duration * 0.5)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.parallel().tween_property(actor, "rotation", deg_to_rad(-definition.idle_rotation_degrees), motion.duration(definition.idle_duration * 0.5)).set_trans(Tween.TRANS_SINE)
	idle_tween.parallel().tween_property(shadow, "scale", base_shadow_scale, motion.duration(definition.idle_duration * 0.5)).set_trans(Tween.TRANS_SINE)
	idle_tween.parallel().tween_property(shadow, "modulate:a", 0.75, motion.duration(definition.idle_duration * 0.5))

func play_hit(damage: int, maximum_health: int = 0) -> void:
	_stop_actions()
	var ratio: float = float(damage) / float(maxi(1, maximum_health)) if maximum_health > 0 else (0.2 if damage >= 8 else 0.1)
	var strength: float = 1.65 if ratio >= 0.35 else (1.4 if ratio >= 0.2 else (1.15 if ratio >= 0.08 else 0.85))
	action_tween = create_tween()
	var flash_strength: float = visual_settings.enemy_hit_flash_strength if visual_settings != null else 1.0
	var flash_duration: float = visual_settings.enemy_hit_flash_duration if visual_settings != null else 0.17
	action_tween.tween_property(flash_material, "shader_parameter/flash_amount", flash_strength, motion.duration(0.05))
	if not motion.reduced_motion:
		action_tween.parallel().tween_property(actor, "position:x", base_actor_position.x + definition.recoil_distance * strength, motion.duration(MotionPresets.HIT_RECOIL_DURATION)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		action_tween.parallel().tween_property(actor, "scale", Vector2(0.92, 1.08) * definition.sprite_scale * actor_scale_multiplier, motion.duration(MotionPresets.HIT_RECOIL_DURATION))
	action_tween.tween_property(flash_material, "shader_parameter/flash_amount", 0.0, motion.duration(maxf(0.01, flash_duration - 0.05)))
	action_tween.parallel().tween_property(actor, "position", base_actor_position, motion.duration(0.18)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	action_tween.parallel().tween_property(actor, "scale", _actor_scale(), motion.duration(0.18))
	action_tween.finished.connect(start_idle)

func play_attack() -> void:
	_stop_actions()
	action_tween = create_tween()
	action_tween.tween_property(actor, "modulate", definition.attack_color, motion.duration(MotionPresets.ATTACK_TELEGRAPH_DURATION))
	if not motion.reduced_motion:
		action_tween.parallel().tween_property(actor, "position:x", base_actor_position.x + 12.0, motion.duration(MotionPresets.ATTACK_TELEGRAPH_DURATION)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		action_tween.tween_property(actor, "position:x", base_actor_position.x - definition.lunge_distance, motion.duration(MotionPresets.ATTACK_LUNGE_DURATION)).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	action_tween.tween_property(actor, "modulate", Color.WHITE, motion.duration(MotionPresets.ATTACK_RETURN_DURATION))
	action_tween.parallel().tween_property(actor, "position", base_actor_position, motion.duration(MotionPresets.ATTACK_RETURN_DURATION)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	action_tween.finished.connect(start_idle)

func play_phase_change(title: String) -> void:
	if phase_transitioning or death_started:
		return
	phase_transitioning = true
	_stop_actions()
	action_tween = create_tween()
	action_tween.tween_property(flash_material, "shader_parameter/flash_amount", 0.8, motion.duration(0.1))
	action_tween.tween_property(flash_material, "shader_parameter/flash_amount", 0.0, motion.duration(0.2))
	glow.modulate.a = 0.2
	action_tween.tween_property(glow, "modulate:a", 1.0, motion.duration(0.3))
	if not motion.reduced_motion:
		action_tween.parallel().tween_property(actor, "scale", _actor_scale() * 1.08, motion.duration(0.3)).set_trans(Tween.TRANS_BACK)
	action_tween.tween_interval(motion.duration(0.08))
	action_tween.tween_property(glow, "modulate:a", 0.35, motion.duration(0.24))
	action_tween.parallel().tween_property(actor, "scale", _actor_scale(), motion.duration(0.24))
	action_tween.finished.connect(func() -> void: phase_transitioning = false; start_idle(); animation_finished.emit())

func play_death() -> void:
	if death_started:
		return
	death_started = true
	_stop_actions()
	actor.material = dissolve_material
	action_tween = create_tween()
	action_tween.tween_property(dissolve_material, "shader_parameter/dissolve_progress", 0.12, motion.duration(0.07))
	if not motion.reduced_motion:
		action_tween.tween_property(actor, "position:y", base_actor_position.y - 24.0, motion.duration(0.35)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	action_tween.parallel().tween_property(actor, "modulate:a", 0.0, motion.duration(0.42))
	action_tween.parallel().tween_property(dissolve_material, "shader_parameter/dissolve_progress", 1.0, motion.duration(0.42))
	action_tween.parallel().tween_property(shadow, "scale", Vector2.ZERO, motion.duration(0.42))
	action_tween.parallel().tween_property(shadow, "modulate:a", 0.0, motion.duration(0.42))
	action_tween.finished.connect(func() -> void: animation_finished.emit())

func skip_to_final_state() -> void:
	_stop_tween(action_tween)
	_stop_tween(idle_tween)
	actor.position = base_actor_position
	actor.scale = _actor_scale() if definition != null else Vector2.ONE
	actor.modulate = Color(1.0, 1.0, 1.0, 0.0 if death_started else 1.0)
	if flash_material != null:
		flash_material.set_shader_parameter("flash_amount", 0.0)
	if death_started and dissolve_material != null:
		dissolve_material.set_shader_parameter("dissolve_progress", 1.0)
	animation_finished.emit()

func _stop_actions() -> void:
	_stop_tween(idle_tween)
	_stop_tween(action_tween)

func _stop_tween(tween: Tween) -> void:
	if tween != null and tween.is_valid():
		tween.kill()

func _actor_scale() -> Vector2:
	return Vector2.ONE * definition.sprite_scale * actor_scale_multiplier

func _reset_effect_shader() -> void:
	if flash_material == null:
		return
	flash_material.set_shader_parameter("flash_amount", 0.0)
	_reset_status_shader()

func _reset_status_shader() -> void:
	StatusVisualMaterialDriver.reset(flash_material)

func _apply_status_visual(visual: StatusVisualDefinition, stacks: int) -> void:
	StatusVisualMaterialDriver.apply(flash_material, visual, stacks, motion.reduced_motion)

func _fallback_definition(enemy: EnemyDefinition) -> EnemyVisualDefinition:
	var visual: EnemyVisualDefinition = EnemyVisualDefinition.new()
	var hue: float = float(absi(enemy.resource_path.hash()) % 1000) / 1000.0
	visual.accent_color = Color.from_hsv(hue, 0.45, 0.95)
	visual.attack_style = EnemyVisualDefinition.AttackVisualStyle.BOARD_EFFECT if enemy.blocker_count > 0 else EnemyVisualDefinition.AttackVisualStyle.MELEE
	return visual
