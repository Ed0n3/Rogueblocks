class_name CellClearBehavior
extends RefCounted

func permits_placement(board: BoardState, index: int) -> bool:
	return board.cells[index] == BoardState.EMPTY

func counts_for_line(board: BoardState, index: int) -> bool:
	return board.cells[index] != BoardState.EMPTY

func clear_cell(board: BoardState, index: int) -> CellClearOutcome:
	var outcome: CellClearOutcome = CellClearOutcome.new()
	board.cells[index] = BoardState.EMPTY
	board.cell_types[index] = CellType.Value.EMPTY
	board.cell_values[index] = 0
	return outcome

func advance_turn(_board: BoardState, _index: int, _turn_count: int) -> int:
	return 0
