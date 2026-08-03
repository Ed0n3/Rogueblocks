class_name MarkRandomBlocksPoisonedEffect
extends GameplayEffect

@export_range(1, 8, 1) var block_count: int = 1
@export_range(1, 20, 1) var damage_on_clear: int = 2

func can_apply(context: EffectContext) -> bool:
	return context != null and context.board_state != null and context.rng != null

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var total_blocks: int = maxi(1, block_count + context.stack_modifier)
	result.affected_cells = context.board_state.poison_random_blocks(total_blocks, damage_on_clear, context.rng)
	result.applied = not result.affected_cells.is_empty()
	return result
