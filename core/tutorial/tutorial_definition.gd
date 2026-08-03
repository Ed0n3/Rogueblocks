class_name TutorialDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var category: TutorialCategory.Value = TutorialCategory.Value.BASICS
@export var replay_context: TutorialReplayContext.Value = TutorialReplayContext.Value.COMBAT
@export var priority: int = 0
@export var activation_mode: TutorialActivationMode.Value = TutorialActivationMode.Value.MANUAL
@export var activation_event: TutorialEventId.Value = TutorialEventId.Value.NONE
@export var repeat_policy: TutorialRepeatPolicy.Value = TutorialRepeatPolicy.Value.ONCE_PER_PROFILE
@export var prerequisite_tutorials: Array[TutorialDefinition] = []
@export var availability_conditions: Array[TutorialCondition] = []
@export var steps: Array[TutorialStepDefinition] = []
@export var can_skip: bool = true
@export var can_replay: bool = true
@export var blocks_gameplay: bool = false
@export var mark_complete_on_skip: bool = false
@export var tags: Array[StringName] = []
