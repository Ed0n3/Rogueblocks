class_name RunEventDefinition
extends Resource

@export var title: String
@export_multiline var description: String
@export var initially_unlocked: bool = true
@export var selection_weight: float = 1.0
@export var choices: Array[EventChoiceDefinition] = []

func is_unlocked(profile: ProfileState, additional_unlocks: Array[RunEventDefinition] = []) -> bool:
	return initially_unlocked or profile != null and profile.unlocked_events.has(self) or additional_unlocks.has(self)
