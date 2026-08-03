class_name DispelEffect
extends GameplayEffect

@export var maximum_removed: int = 1

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	for instance: StatusInstance in context.encounter_state.enemy_statuses.instances.duplicate():
		if result.removed_statuses.size() >= maximum_removed:
			break
		if instance.definition == null or instance.definition.category != StatusCategory.Value.POSITIVE:
			continue
		context.encounter_state.enemy_statuses.remove_status(instance.definition)
		result.removed_statuses.append(instance.definition)
	result.applied = not result.removed_statuses.is_empty()
	return result
