class_name TutorialPresentationAction
extends TutorialAction

enum Command { SHOW_SPOTLIGHT, HIDE_SPOTLIGHT, SHOW_POINTER, HIDE_POINTER, HIGHLIGHT_CELLS, CLEAR_HIGHLIGHTS, SAVE_CHECKPOINT }

@export var command: Command = Command.SHOW_SPOTLIGHT
@export var target: TutorialTarget

func execute(context: TutorialContext) -> void:
	context.presentation_command = command
	context.presentation_target = target
	if command == Command.SAVE_CHECKPOINT:
		TutorialService.save_runtime()
	else:
		TutorialService.presentation_action_requested.emit(self)

func undo(context: TutorialContext) -> void:
	var inverse: TutorialPresentationAction = TutorialPresentationAction.new()
	match command:
		Command.SHOW_SPOTLIGHT:
			inverse.command = Command.HIDE_SPOTLIGHT
		Command.HIDE_SPOTLIGHT:
			inverse.command = Command.SHOW_SPOTLIGHT
		Command.SHOW_POINTER:
			inverse.command = Command.HIDE_POINTER
		Command.HIDE_POINTER:
			inverse.command = Command.SHOW_POINTER
		Command.HIGHLIGHT_CELLS:
			inverse.command = Command.CLEAR_HIGHLIGHTS
		_:
			return
	inverse.target = target
	context.presentation_command = inverse.command
	context.presentation_target = inverse.target
	TutorialService.presentation_action_requested.emit(inverse)
