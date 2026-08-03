class_name RemoveRandomOccupiedCellsEffect
extends GameplayEffect

@export_range(1, 20, 1) var count: int = 1

func can_apply(context: EffectContext) -> bool:
	return context != null and context.board_state != null and context.rng != null and count > 0

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	result.affected_cells.append_array(context.board_state.remove_random_occupied_cells(count, context.rng))
	result.applied = not result.affected_cells.is_empty()
	return result
