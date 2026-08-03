class_name ValidPlacementHoveredCondition
extends EventOccurredCondition

func _init() -> void:
	event_type = TutorialEventId.Value.PLACEMENT_PREVIEW_CHANGED
	require_bool_value = true
	expected_bool_value = true
