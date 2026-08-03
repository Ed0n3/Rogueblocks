class_name PieceSelectedCondition
extends EventOccurredCondition

@export var choice_index: int = -1

func _init() -> void:
	event_type = TutorialEventId.Value.PIECE_SELECTED

func is_satisfied(context: TutorialContext) -> bool:
	return super.is_satisfied(context) and (choice_index < 0 or context.current_event.int_value == choice_index)
