class_name TutorialArchiveCard
extends Button

signal replay_requested(tutorial: TutorialDefinition)

var tutorial: TutorialDefinition

func _ready() -> void:
	pressed.connect(func() -> void: replay_requested.emit(tutorial))

func configure(definition: TutorialDefinition, progress: TutorialProgress) -> void:
	tutorial = definition
	var completed: bool = progress.completed_tutorials.has(definition)
	var skipped: bool = progress.skipped_tutorials.has(definition)
	var status: String = "COMPLETED" if completed else ("SKIPPED" if skipped else "AVAILABLE")
	text = "%s\n%s\n%s" % [definition.display_name.to_upper(), definition.description, status]
	tooltip_text = "Replay %s" % definition.display_name
	disabled = not definition.can_replay
