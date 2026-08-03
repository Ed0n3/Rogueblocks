class_name PiecePlacedAtCellsCondition
extends PiecePlacedCondition

@export var required_cells: Array[Vector2i] = []

func is_satisfied(context: TutorialContext) -> bool:
	if not super.is_satisfied(context):
		return false
	for cell: Vector2i in required_cells:
		if not context.current_event.cells.has(cell):
			return false
	return true
