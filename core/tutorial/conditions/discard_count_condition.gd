class_name DiscardCountCondition
extends EventOccurredCondition

@export var minimum_discard_count: int = 1

func _init() -> void:
	event_type = TutorialEventId.Value.DISCARD_PILE_CHANGED

func is_satisfied(context: TutorialContext) -> bool:
	return super.is_satisfied(context) and context.current_event.int_value >= minimum_discard_count
