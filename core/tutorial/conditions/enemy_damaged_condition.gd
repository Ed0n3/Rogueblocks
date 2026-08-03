class_name EnemyDamagedCondition
extends EventOccurredCondition

func _init() -> void:
	event_type = TutorialEventId.Value.ENEMY_DAMAGED
	minimum_int_value = 1
