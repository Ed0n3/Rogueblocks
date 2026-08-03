class_name RemoveStatusEffect
extends GameplayEffect

@export var status: StatusDefinition

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var collection: StatusCollection = context.encounter_state.player_statuses if target == EffectTarget.Value.PLAYER else context.encounter_state.enemy_statuses
	result.applied = collection.remove_status(status)
	if result.applied:
		result.removed_statuses.append(status)
	return result
