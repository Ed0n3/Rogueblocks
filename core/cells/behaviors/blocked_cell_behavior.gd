class_name BlockedCellBehavior
extends CellClearBehavior

var armored: bool = false

func _init(is_armored: bool = false) -> void:
	armored = is_armored

func permits_placement(_board: BoardState, _index: int) -> bool:
	return false

func clear_cell(board: BoardState, index: int) -> CellClearOutcome:
	var outcome: CellClearOutcome = CellClearOutcome.new()
	if armored and board.cell_values[index] > 1:
		board.cell_values[index] -= 1
		outcome.removed = false
		return outcome
	board.cells[index] = BoardState.EMPTY
	board.cell_types[index] = CellType.Value.EMPTY
	board.cell_values[index] = 0
	outcome.blocker_destroyed = 1
	return outcome
