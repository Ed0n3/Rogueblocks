class_name ProfileStatisticCondition
extends TutorialCondition

enum Statistic { COMPLETED_RUNS, VICTORIES, ITEMS_USED, PURCHASES, COUNTERS_COMPLETED }

@export var statistic: Statistic = Statistic.COMPLETED_RUNS
@export var minimum_value: int = 1

func is_satisfied(_context: TutorialContext) -> bool:
	var value: int = 0
	match statistic:
		Statistic.COMPLETED_RUNS:
			value = SaveService.profile.completed_runs
		Statistic.VICTORIES:
			value = SaveService.profile.victories
		Statistic.ITEMS_USED:
			value = SaveService.profile.total_items_used
		Statistic.PURCHASES:
			value = SaveService.profile.total_items_purchased
		Statistic.COUNTERS_COMPLETED:
			value = SaveService.profile.total_boss_actions_countered
	return value >= minimum_value
