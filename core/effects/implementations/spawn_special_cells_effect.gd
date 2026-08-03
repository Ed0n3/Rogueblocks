class_name SpawnSpecialCellsEffect
extends GameplayEffect

@export var cell_type: CellType.Value = CellType.Value.BLOCKER
@export var count: int = 1
@export var cell_value: int = 1

func can_apply(context: EffectContext) -> bool:
	return context != null and context.board_state != null and context.rng != null and count > 0

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var candidates: Array[Vector2i] = []
	for y: int in context.board_state.height:
		for x: int in context.board_state.width:
			var cell: Vector2i = Vector2i(x, y)
			if context.board_state.is_empty(cell):
				candidates.append(cell)
	for index: int in mini(count, candidates.size()):
		var cell: Vector2i = candidates.pop_at(context.rng.randi_range(0, candidates.size() - 1))
		context.board_state.set_special_cell(cell, cell_type, cell_value)
		result.affected_cells.append(cell)
	result.applied = not result.affected_cells.is_empty()
	return result
