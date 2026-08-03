class_name ArtifactService
extends RefCounted

@export var minimum_draw_count: int = 1
@export var minimum_placement_points: int = 1
@export var minimum_redraw_placement_point_cost: int = 1

func on_encounter_started(run_state: RunState, board: BoardState, rng: RandomNumberGenerator) -> void:
	_resolve(run_state, board, rng, _encounter_started)

func modify_draw_count(run_state: RunState, base_count: int) -> int:
	var context: ArtifactEffectContext = ArtifactEffectContext.new()
	context.run_state = run_state
	context.draw_count = base_count
	for pair: Array in _ordered_effects(run_state):
		context.artifact_state = pair[0] as BossArtifactState
		(pair[1] as BossArtifactEffect).modify_draw_count(context)
	return maxi(minimum_draw_count, context.draw_count)

func modify_placement_economy(
	run_state: RunState,
	base_maximum_placement_points: int,
	base_redraw_placement_point_cost: int,
	base_free_redraws_per_turn: int = 0
) -> ArtifactEffectContext:
	var context: ArtifactEffectContext = ArtifactEffectContext.new()
	context.run_state = run_state
	context.maximum_placement_points = base_maximum_placement_points
	context.redraw_placement_point_cost = base_redraw_placement_point_cost
	context.free_redraws_per_turn = base_free_redraws_per_turn
	for pair: Array in _ordered_effects(run_state):
		context.artifact_state = pair[0] as BossArtifactState
		(pair[1] as BossArtifactEffect).modify_placement_economy(context)
	context.maximum_placement_points = maxi(minimum_placement_points, context.maximum_placement_points)
	context.redraw_placement_point_cost = maxi(minimum_redraw_placement_point_cost, context.redraw_placement_point_cost)
	context.free_redraws_per_turn = maxi(0, context.free_redraws_per_turn)
	return context

func before_piece_placement(run_state: RunState, board: BoardState, rng: RandomNumberGenerator, piece: PieceDefinition) -> void:
	var context: ArtifactEffectContext = _context(run_state, board, rng)
	context.placed_piece = piece
	for pair: Array in _ordered_effects(run_state):
		context.artifact_state = pair[0] as BossArtifactState
		(pair[1] as BossArtifactEffect).before_piece_placement(context)

func after_piece_placement(run_state: RunState, board: BoardState, rng: RandomNumberGenerator, piece: PieceDefinition, source_type: PieceSourceType.Value) -> ArtifactEffectContext:
	var combined: ArtifactEffectContext = ArtifactEffectContext.new()
	combined.run_state = run_state
	combined.board = board
	combined.rng = rng
	combined.placed_piece = piece
	combined.piece_source_type = source_type
	for pair: Array in _ordered_effects(run_state):
		combined.artifact_state = pair[0] as BossArtifactState
		var previous_message: String = combined.activation_message
		(pair[1] as BossArtifactEffect).after_piece_placement(combined)
		if combined.activated and combined.activation_message != previous_message:
			combined.activated_artifact = combined.artifact_state.definition
		if combined.activated and combined.activation_message.is_empty():
			combined.activation_message = combined.artifact_state.definition.display_name
	return combined

func modify_enemy_countdown(run_state: RunState, clear_result: ClearResult, countdown_step: int) -> ArtifactEffectContext:
	var combined: ArtifactEffectContext = ArtifactEffectContext.new()
	combined.run_state = run_state
	combined.clear_result = clear_result
	combined.countdown_step = countdown_step
	for pair: Array in _ordered_effects(run_state):
		combined.artifact_state = pair[0] as BossArtifactState
		var previous_message: String = combined.activation_message
		(pair[1] as BossArtifactEffect).modify_enemy_countdown(combined)
		if combined.activated and combined.activation_message != previous_message:
			combined.activated_artifact = combined.artifact_state.definition
	return combined

func after_line_clear(run_state: RunState, board: BoardState, rng: RandomNumberGenerator, clear_result: ClearResult) -> void:
	var context: ArtifactEffectContext = _context(run_state, board, rng)
	context.clear_result = clear_result
	for pair: Array in _ordered_effects(run_state):
		context.artifact_state = pair[0] as BossArtifactState
		(pair[1] as BossArtifactEffect).after_line_clear(context)

func modify_combo_resolution(run_state: RunState, clear_result: ClearResult, combo_level: int) -> ArtifactEffectContext:
	var combined: ArtifactEffectContext = ArtifactEffectContext.new()
	combined.run_state = run_state
	combined.clear_result = clear_result
	combined.combo_level = combo_level
	for pair: Array in _ordered_effects(run_state):
		combined.artifact_state = pair[0] as BossArtifactState
		var previous_message: String = combined.activation_message
		(pair[1] as BossArtifactEffect).modify_combo_resolution(combined)
		if combined.activated and combined.activation_message != previous_message:
			combined.activated_artifact = combined.artifact_state.definition
	return combined

func on_item_phase(run_state: RunState, board: BoardState, rng: RandomNumberGenerator) -> void:
	var context: ArtifactEffectContext = _context(run_state, board, rng)
	for pair: Array in _ordered_effects(run_state):
		context.artifact_state = pair[0] as BossArtifactState
		(pair[1] as BossArtifactEffect).on_item_phase(context)

func _context(run_state: RunState, board: BoardState, rng: RandomNumberGenerator) -> ArtifactEffectContext:
	var context: ArtifactEffectContext = ArtifactEffectContext.new()
	context.run_state = run_state
	context.board = board
	context.rng = rng
	return context

func _resolve(run_state: RunState, board: BoardState, rng: RandomNumberGenerator, resolver: Callable) -> void:
	for pair: Array in _ordered_effects(run_state):
		var context: ArtifactEffectContext = ArtifactEffectContext.new()
		context.run_state = run_state
		context.artifact_state = pair[0] as BossArtifactState
		context.board = board
		context.rng = rng
		resolver.call(pair[1] as BossArtifactEffect, context)

func _encounter_started(effect: BossArtifactEffect, context: ArtifactEffectContext) -> void:
	effect.on_encounter_started(context)

func _ordered_effects(run_state: RunState) -> Array[Array]:
	var pairs: Array[Array] = []
	for state: BossArtifactState in run_state.artifacts:
		var definition: BossArtifactDefinition = state.definition
		if definition == null:
			continue
		for effect: BossArtifactEffect in definition.effects:
			pairs.append([state, effect])
	pairs.sort_custom(func(left: Array, right: Array) -> bool:
		var left_effect: BossArtifactEffect = left[1] as BossArtifactEffect
		var right_effect: BossArtifactEffect = right[1] as BossArtifactEffect
		if left_effect.priority != right_effect.priority:
			return left_effect.priority < right_effect.priority
		return (left[0] as BossArtifactState).definition.resource_path < (right[0] as BossArtifactState).definition.resource_path)
	return pairs
