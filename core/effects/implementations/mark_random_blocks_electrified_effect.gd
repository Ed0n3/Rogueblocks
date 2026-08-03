class_name MarkRandomBlocksElectrifiedEffect
extends GameplayEffect

@export_range(1, 8, 1) var block_count: int = 1

func can_apply(context: EffectContext) -> bool:
	return context != null and context.board_state != null and context.rng != null

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var total_blocks: int = maxi(1, block_count + context.stack_modifier)
	result.affected_cells = context.board_state.electrify_random_blocks(total_blocks, context.rng)
	result.applied = not result.affected_cells.is_empty()
	return result
