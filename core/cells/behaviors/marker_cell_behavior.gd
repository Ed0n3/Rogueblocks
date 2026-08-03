class_name MarkerCellBehavior
extends CellClearBehavior

var cell_type: CellType.Value

func _init(type_value: CellType.Value) -> void:
	cell_type = type_value

func clear_cell(board: BoardState, index: int) -> CellClearOutcome:
	var outcome: CellClearOutcome = super.clear_cell(board, index)
	if cell_type == CellType.Value.BONUS:
		outcome.shard_reward = 3
	elif cell_type == CellType.Value.TARGET:
		outcome.target_cleared = 1
	return outcome

func advance_turn(board: BoardState, index: int, turn_count: int) -> int:
	if cell_type == CellType.Value.CORRUPTED and board.cells[index] != BoardState.EMPTY and turn_count % 3 == 0:
		return 1
	if cell_type == CellType.Value.TARGET and board.cell_values[index] > 0:
		board.cell_values[index] -= 1
		if board.cell_values[index] <= 0:
			board.set_cell(Vector2i(index % board.width, index / board.width), BoardState.EMPTY)
			board.cell_types[index] = CellType.Value.EMPTY
			return 1
	return 0
