class_name EventOccurredCondition
extends TutorialCondition

@export var event_type: TutorialEventId.Value = TutorialEventId.Value.NONE
@export var required_source: Resource
@export var minimum_int_value: int = -1
@export var require_bool_value: bool = false
@export var expected_bool_value: bool = true

func is_satisfied(context: TutorialContext) -> bool:
	var event: TutorialEvent = context.current_event
	if event == null or event.type != event_type:
		return false
	if required_source != null and event.source != required_source:
		return false
	if minimum_int_value >= 0 and event.int_value < minimum_int_value:
		return false
	return not require_bool_value or event.bool_value == expected_bool_value
