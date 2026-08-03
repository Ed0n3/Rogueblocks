class_name ActivePiecePoolSizeCondition
extends TutorialCondition

@export var minimum_size: int = 6

func is_satisfied(context: TutorialContext) -> bool:
	return context.run_state != null and context.run_state.deck_cards.size() >= minimum_size
