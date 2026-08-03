class_name TutorialStepDefinition
extends Resource

@export var step_type: TutorialStepType.Value = TutorialStepType.Value.MESSAGE
@export var title: String
@export_multiline var body: String
@export var speaker_name: String
@export var target: TutorialTarget
## Additional controls or board areas that remain interactive while input is restricted to this step.
@export var additional_input_targets: Array[TutorialTarget] = []
@export var completion_conditions: Array[TutorialCondition] = []
@export var entry_actions: Array[TutorialAction] = []
@export var completion_actions: Array[TutorialAction] = []
@export var exit_actions: Array[TutorialAction] = []
@export var input_mode: TutorialInputMode.Value = TutorialInputMode.Value.NORMAL_GAMEPLAY
@export var allowed_input_actions: Array[StringName] = []
@export var message_position: TutorialMessagePosition.Value = TutorialMessagePosition.Value.AUTO
@export var wait_for_player_confirmation: bool = false
@export var auto_advance_delay: float = 0.0
@export var skippable: bool = true
@export var fallback_timeout: float = 0.0
@export var fallback_step: TutorialStepDefinition
