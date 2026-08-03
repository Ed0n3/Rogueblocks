class_name ShieldEffect
extends GameplayEffect

@export var amount: int = 0

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	result.shield_granted = maxi(0, roundi(float(amount) * context.magnitude_multiplier))
	if target == EffectTarget.Value.PLAYER:
		context.encounter_state.player_shield += result.shield_granted
	else:
		context.encounter_state.enemy_shield += result.shield_granted
	result.applied = result.shield_granted > 0
	return result
