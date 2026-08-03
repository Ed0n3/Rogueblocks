class_name StatusAppliedCondition
extends EventOccurredCondition

@export var status: StatusDefinition

func _init() -> void:
	event_type = TutorialEventId.Value.STATUS_APPLIED

func is_satisfied(context: TutorialContext) -> bool:
	return super.is_satisfied(context) and (status == null or context.current_event.status == status)
