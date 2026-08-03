class_name HealEffect
extends GameplayEffect

@export var amount: int = 0

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var requested: int = maxi(0, roundi(float(amount) * context.magnitude_multiplier))
	if target == EffectTarget.Value.PLAYER:
		result.healing = mini(requested, context.run_state.maximum_health - context.run_state.player_health)
		context.run_state.player_health += result.healing
	else:
		result.healing = mini(requested, context.encounter_state.enemy_maximum_health - context.encounter_state.enemy_health)
		context.encounter_state.enemy_health += result.healing
	result.applied = result.healing > 0
	return result
