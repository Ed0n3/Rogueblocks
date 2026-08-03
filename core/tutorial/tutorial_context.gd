class_name TutorialContext
extends RefCounted

var current_event: TutorialEvent
var screen: TutorialScreen.Value = TutorialScreen.Value.NONE
var run_state: RunState
var encounter_controller: EncounterController
var board_view: BoardView
var active_tutorial: TutorialDefinition
var active_step: TutorialStepDefinition
var presentation_command: TutorialPresentationAction.Command
var presentation_target: TutorialTarget
