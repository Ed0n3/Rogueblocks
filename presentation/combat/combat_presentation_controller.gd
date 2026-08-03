class_name CombatPresentationController
extends Node

signal busy_changed(busy: bool)

var enemy_view: EnemyPresentation
var board_view: BoardView
var vfx: VFXLayer
var motion: MotionSettings
var tokens: VisualTokens
var combat_root: Control
var player_target: Control
var visual_settings: CombatVisualSettings
var queue: Array[Callable] = []
var playing: bool = false
var skipping: bool = false

func configure(enemy_presentation: EnemyPresentation, logical_board_view: BoardView, effects: VFXLayer, presentation_root: Control = null, player_hit_target: Control = null) -> void:
	enemy_view = enemy_presentation
	board_view = logical_board_view
	vfx = effects
	combat_root = presentation_root
	player_target = player_hit_target
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	tokens = load("res://presentation/theme/visual_tokens.tres") as VisualTokens
	visual_settings = load("res://content/presentation/combat_visual_settings.tres") as CombatVisualSettings

func enqueue_clear(result: ClearResult) -> void:
	queue.append(_play_clear.bind(result))
	_start_queue()

func enqueue_enemy_damage(result: DamageResult) -> void:
	queue.append(_play_enemy_damage.bind(result))
	_start_queue()

func enqueue_enemy_attack(damage: int, affected_cells: Array[Vector2i]) -> void:
	queue.append(_play_enemy_attack.bind(damage, affected_cells))
	_start_queue()

func enqueue_poisoned_block_damage(result: ClearResult) -> void:
	if result == null or result.poisoned_block_damage <= 0 or result.poison_damage_source_cells.is_empty():
		return
	queue.append(_play_poisoned_block_damage.bind(result.poisoned_block_damage, result.poison_damage_source_cells))
	_start_queue()

func enqueue_enemy_phase_change(phase: EnemyPhaseDefinition) -> void:
	queue.append(_play_enemy_phase_change.bind(phase))
	_start_queue()

func play_enemy_defeat() -> void:
	await wait_until_idle()
	playing = true
	busy_changed.emit(true)
	enemy_view.play_death()
	if motion.duration(0.48) > 0.0:
		await get_tree().create_timer(motion.duration(0.48)).timeout
	else:
		enemy_view.skip_to_final_state()
	playing = false
	busy_changed.emit(false)

func wait_until_idle() -> void:
	while playing or not queue.is_empty():
		await get_tree().process_frame

func skip_to_end() -> void:
	skipping = true
	queue.clear()
	if enemy_view != null:
		enemy_view.skip_to_final_state()
	if board_view != null:
		board_view.finish_visual_effects()
	if vfx != null:
		vfx.clear_effects()
	playing = false
	busy_changed.emit(false)

func _start_queue() -> void:
	if not playing:
		_drain_queue.call_deferred()

func _drain_queue() -> void:
	if playing:
		return
	playing = true
	busy_changed.emit(true)
	while not queue.is_empty() and not skipping:
		var step: Callable = queue.pop_front()
		await step.call()
	skipping = false
	playing = false
	busy_changed.emit(false)

func _play_clear(result: ClearResult) -> void:
	board_view.play_clear_effect(result, motion)
	if result.cross_clear:
		vfx.impact(_board_local_to_global(board_view.size * 0.5), tokens.clear_green)
	if result.perfect_clear:
		var center: Vector2 = _board_local_to_global(board_view.size * 0.5)
		vfx.burst(center, tokens.clear_green, ParticleBurst.Preset.PERFECT_CLEAR)
		vfx.flash(tokens.clear_green, 0.11, 0.22)
		if combat_root != null:
			vfx.shake(combat_root, 5.0, 0.24)
	var duration: float = motion.duration(MotionPresets.LINE_SCAN_DURATION + MotionPresets.LINE_REMOVE_DURATION)
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout

func _play_enemy_damage(result: DamageResult) -> void:
	var damage: DamagePresentationResult = DamagePresentationResult.from_damage_result(result)
	if damage.total_damage <= 0:
		return
	var from: Vector2 = _board_local_to_global(board_view.size * Vector2(0.85, 0.5))
	var to: Vector2 = enemy_view.get_actor_global_rect().get_center()
	vfx.projectile(from, to, tokens.primary_cyan)
	var travel_duration: float = motion.duration(0.34)
	if travel_duration > 0.0:
		await get_tree().create_timer(travel_duration).timeout
	enemy_view.play_hit(damage.total_damage, damage.enemy_maximum_health)
	vfx.impact(to, tokens.damage_coral)
	vfx.burst(to, tokens.damage_coral, ParticleBurst.Preset.ENEMY_HIT)
	var intensity: int = damage.intensity()
	if intensity >= 2:
		vfx.flash(tokens.damage_coral, 0.08, 0.14)
		if combat_root != null:
			vfx.shake(combat_root, 3.0 + float(intensity) * 1.5, 0.18 + float(intensity) * 0.03)
	vfx.floating_value("-%d" % damage.total_damage, to + visual_settings.enemy_damage_number_offset, tokens.damage_coral, CombatValueStyle.Value.ENEMY_DAMAGE, intensity >= 2)
	if damage.shield_damage > 0:
		vfx.floating_value("%d SHIELD" % damage.shield_damage, to + Vector2(-28.0, 4.0), Color("72b8ff"), CombatValueStyle.Value.DETAIL)
	if not damage.source_breakdown.is_empty():
		var names: PackedStringArray = []
		for source: DamageSourcePresentation in damage.source_breakdown:
			names.append(source.display_name.to_upper())
		vfx.floating_value(" + ".join(names), to + visual_settings.enemy_damage_detail_offset, tokens.primary_cyan, CombatValueStyle.Value.DETAIL)
	var hit_duration: float = motion.duration(0.28)
	if hit_duration > 0.0:
		await get_tree().create_timer(hit_duration).timeout

func _play_enemy_attack(damage: int, affected_cells: Array[Vector2i]) -> void:
	enemy_view.play_attack()
	var telegraph: float = motion.duration(MotionPresets.ATTACK_TELEGRAPH_DURATION)
	if telegraph > 0.0:
		await get_tree().create_timer(telegraph).timeout
	var from: Vector2 = enemy_view.get_actor_global_rect().get_center()
	var to: Vector2 = _board_local_to_global(board_view.size * Vector2(0.85, 0.48))
	var projectile_launched: bool = false
	if enemy_view.definition.attack_style == EnemyVisualDefinition.AttackVisualStyle.PROJECTILE:
		vfx.projectile(from, to, tokens.damage_coral)
		projectile_launched = true
	elif enemy_view.definition.attack_style == EnemyVisualDefinition.AttackVisualStyle.BOARD_EFFECT and not affected_cells.is_empty():
		for cell: Vector2i in affected_cells:
			var target: Vector2 = _board_local_to_global(board_view.grid_position_to_local(cell) + Vector2(18.0, 18.0))
			vfx.projectile(from, target, enemy_view.definition.accent_color)
		projectile_launched = true
	else:
		vfx.impact(to, tokens.damage_coral)
	if projectile_launched:
		var travel_duration: float = motion.duration(visual_settings.enemy_attack_travel_duration)
		if travel_duration > 0.0:
			await get_tree().create_timer(travel_duration).timeout
	vfx.burst(to, tokens.damage_coral, ParticleBurst.Preset.BLOCKER_DUST if not affected_cells.is_empty() else ParticleBurst.Preset.ENEMY_HIT)
	_play_player_damage_feedback(damage)
	board_view.pulse_enemy_effect(affected_cells, motion)
	var impact_duration: float = motion.duration(0.34)
	if impact_duration > 0.0:
		await get_tree().create_timer(impact_duration).timeout

func _play_poisoned_block_damage(damage: int, source_cells: Array[Vector2i]) -> void:
	var target_position: Vector2 = _player_damage_target_rectangle().get_center()
	for cell: Vector2i in source_cells:
		var source_position: Vector2 = _board_local_to_global(board_view.grid_cell_center_to_local(cell))
		vfx.projectile(source_position, target_position, visual_settings.poisoned_block_color)
	board_view.pulse_enemy_effect(source_cells, motion)
	var travel_duration: float = motion.duration(visual_settings.enemy_attack_travel_duration)
	if travel_duration > 0.0:
		await get_tree().create_timer(travel_duration).timeout
	vfx.impact(target_position, visual_settings.poisoned_block_color)
	vfx.burst(target_position, visual_settings.poisoned_block_color, ParticleBurst.Preset.BLOCKER_DUST)
	_play_player_damage_feedback(damage)
	var impact_duration: float = motion.duration(0.34)
	if impact_duration > 0.0:
		await get_tree().create_timer(impact_duration).timeout

func _play_player_damage_feedback(damage: int) -> void:
	if damage <= 0:
		return
	var target_rectangle: Rect2 = _player_damage_target_rectangle()
	vfx.target_flash(target_rectangle, visual_settings.player_hit_color, visual_settings.player_hit_blink_opacity, visual_settings.player_hit_blink_duration)
	vfx.floating_value("-%d HP" % damage, target_rectangle.get_center() + visual_settings.player_damage_number_offset, tokens.damage_coral, CombatValueStyle.Value.PLAYER_DAMAGE)
	if damage >= visual_settings.heavy_enemy_attack_damage:
		vfx.flash(tokens.damage_coral, 0.07, 0.14)
	if combat_root != null:
		vfx.shake(combat_root, visual_settings.player_hit_shake_strength, visual_settings.player_hit_shake_duration)

func _player_damage_target_rectangle() -> Rect2:
	return player_target.get_global_rect() if player_target != null else board_view.get_global_rect()

func _play_enemy_phase_change(phase: EnemyPhaseDefinition) -> void:
	enemy_view.play_phase_change(phase.display_name_suffix)
	var center: Vector2 = enemy_view.get_actor_global_rect().get_center()
	vfx.impact(center, tokens.enemy_violet)
	vfx.burst(center, tokens.enemy_violet, ParticleBurst.Preset.PERFECT_CLEAR)
	vfx.flash(tokens.enemy_violet, 0.12, 0.22)
	if combat_root != null:
		vfx.shake(combat_root, 6.0, 0.28)
	var duration: float = motion.duration(0.62)
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout

func _board_local_to_global(local_point: Vector2) -> Vector2:
	return board_view.get_global_transform_with_canvas() * local_point
