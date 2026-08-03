class_name SpawnIgnitedBlocksEffect
extends GameplayEffect

@export var generated_piece: PieceDefinition = preload("res://content/pieces/monomino.tres") as PieceDefinition
@export var fire_visual_modifier: PieceModifierDefinition = preload("res://content/piece_modifiers/item_fire_visual.tres") as PieceModifierDefinition
@export_range(1, 8, 1) var block_count: int = 2
@export_range(1, 8, 1) var burn_duration_turns: int = 2
@export_range(1, 8, 1) var burn_stacks_per_block: int = 1
@export var burn_status: StatusDefinition = preload("res://content/statuses/item_fire_burn.tres") as StatusDefinition

func can_apply(context: EffectContext) -> bool:
	return context != null and context.board_state != null and context.rng != null and context.encounter_state != null and burn_status != null

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var candidates: Array[Vector2i] = []
	for y: int in context.board_state.height:
		for x: int in context.board_state.width:
			var cell: Vector2i = Vector2i(x, y)
			if context.board_state.is_empty(cell):
				candidates.append(cell)
	for _placement_index: int in mini(block_count, candidates.size()):
		var selected_index: int = context.rng.randi_range(0, candidates.size() - 1)
		var selected_cell: Vector2i = candidates.pop_at(selected_index)
		var ignited_block: PieceInstance = PieceInstance.new(generated_piece)
		ignited_block.source_type = PieceSourceType.Value.ARTIFACT_GENERATED
		ignited_block.modifiers = [fire_visual_modifier]
		var placement: PlacementResult = context.board_state.place_piece(selected_cell, ignited_block)
		if placement.success:
			result.affected_cells.append_array(placement.placed_cells)
	if result.affected_cells.is_empty():
		return result
	var burn_stacks: int = result.affected_cells.size() * burn_stacks_per_block
	context.encounter_state.enemy_statuses.apply_status(burn_status, context.source, burn_duration_turns + context.duration_modifier, burn_stacks, context.magnitude_multiplier, context.current_turn)
	result.applied = true
	result.applied_statuses.append(burn_status)
	return result
