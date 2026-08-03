class_name ScreenIsOpenCondition
extends TutorialCondition

@export var screen: TutorialScreen.Value = TutorialScreen.Value.NONE

func is_satisfied(context: TutorialContext) -> bool:
	return context.screen == screen or context.current_event != null and context.current_event.type == TutorialEventId.Value.SCREEN_OPENED and context.current_event.screen == screen
