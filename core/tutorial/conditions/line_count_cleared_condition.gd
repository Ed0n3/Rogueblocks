class_name LineCountClearedCondition
extends EventOccurredCondition

@export var minimum_lines: int = 1

func _init() -> void:
	event_type = TutorialEventId.Value.LINES_CLEARED

func is_satisfied(context: TutorialContext) -> bool:
	return super.is_satisfied(context) and context.current_event.int_value >= minimum_lines
