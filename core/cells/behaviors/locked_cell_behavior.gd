class_name LockedCellBehavior
extends CellClearBehavior

func permits_placement(_board: BoardState, _index: int) -> bool:
	return false

func counts_for_line(_board: BoardState, _index: int) -> bool:
	return false

func clear_cell(_board: BoardState, _index: int) -> CellClearOutcome:
	var outcome: CellClearOutcome = CellClearOutcome.new()
	outcome.removed = false
	return outcome

func advance_turn(board: BoardState, index: int, _turn_count: int) -> int:
	board.cell_values[index] -= 1
	if board.cell_values[index] <= 0:
		board.cell_types[index] = CellType.Value.EMPTY
		board.cell_values[index] = 0
	return 0
