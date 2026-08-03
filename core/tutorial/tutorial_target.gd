class_name TutorialTarget
extends Resource

@export var target_type: TutorialTargetType.Value = TutorialTargetType.Value.UI_CONTROL
@export var target_key: TutorialTargetKey.Value = TutorialTargetKey.Value.NONE
@export var board_cells: Array[Vector2i] = []
@export var board_row: int = -1
@export var board_column: int = -1
@export var padding: float = 8.0
@export var follow_target: bool = true
