class_name TutorialActivationRequest
extends RefCounted

var definition: TutorialDefinition
var event: TutorialEvent
var screen: TutorialScreen.Value = TutorialScreen.Value.NONE
var run_sequence: int = 0
var encounter_sequence: int = -1
var enqueue_sequence: int = 0

func _init(
	tutorial_definition: TutorialDefinition = null,
	trigger_event: TutorialEvent = null,
	current_screen: TutorialScreen.Value = TutorialScreen.Value.NONE,
	current_run_sequence: int = 0,
	current_encounter_sequence: int = -1,
	sequence: int = 0
) -> void:
	definition = tutorial_definition
	event = trigger_event.duplicate_event() if trigger_event != null else null
	screen = current_screen
	run_sequence = current_run_sequence
	encounter_sequence = current_encounter_sequence
	enqueue_sequence = sequence

func is_in_scope(current_screen: TutorialScreen.Value, current_run_sequence: int, current_encounter_sequence: int) -> bool:
	if screen != TutorialScreen.Value.NONE and screen != current_screen:
		return false
	if run_sequence != 0 and run_sequence != current_run_sequence:
		return false
	return encounter_sequence < 0 or encounter_sequence == current_encounter_sequence
