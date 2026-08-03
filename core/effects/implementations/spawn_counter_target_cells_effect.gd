class_name SpawnCounterTargetCellsEffect
extends GameplayEffect

@export var cell_type: CellType.Value = CellType.Value.BLOCKER
@export var count: int = 1
@export var cell_value: int = 1

func can_apply(context: EffectContext) -> bool:
	return context != null and context.board_state != null and context.active_counter != null and context.rng != null

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var candidates: Array[Vector2i] = []
	for cell: Vector2i in context.active_counter.target_cells:
		_add_candidate(context.board_state, candidates, cell)
	for row: int in context.active_counter.target_rows:
		for x: int in context.board_state.width:
			_add_candidate(context.board_state, candidates, Vector2i(x, row))
	for column: int in context.active_counter.target_columns:
		for y: int in context.board_state.height:
			_add_candidate(context.board_state, candidates, Vector2i(column, y))
	for index: int in mini(count, candidates.size()):
		var selected: Vector2i = candidates.pop_at(context.rng.randi_range(0, candidates.size() - 1))
		context.board_state.set_special_cell(selected, cell_type, cell_value)
		result.affected_cells.append(selected)
	result.applied = not result.affected_cells.is_empty()
	return result

func _add_candidate(board: BoardState, candidates: Array[Vector2i], cell: Vector2i) -> void:
	if board.is_inside(cell) and board.is_empty(cell) and not candidates.has(cell):
		candidates.append(cell)
