class_name CleanseEffect
extends GameplayEffect

@export var maximum_removed: int = 1
@export var remove_all: bool = false
@export var required_tags: Array[StringName] = [&"negative", &"damage_over_time", &"control", &"curse"]

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var maximum: int = -1 if remove_all else maximum_removed
	result.removed_statuses = context.encounter_state.player_statuses.remove_by_tags(required_tags, maximum)
	result.applied = not result.removed_statuses.is_empty()
	return result
