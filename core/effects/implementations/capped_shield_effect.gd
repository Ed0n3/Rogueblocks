class_name CappedShieldEffect
extends ShieldEffect

@export var maximum_total: int = 6

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var current: int = context.encounter_state.player_shield if target == EffectTarget.Value.PLAYER else context.encounter_state.enemy_shield
	result.shield_granted = mini(maxi(0, maximum_total - current), maxi(0, roundi(float(amount) * context.magnitude_multiplier)))
	if target == EffectTarget.Value.PLAYER:
		context.encounter_state.player_shield += result.shield_granted
	else:
		context.encounter_state.enemy_shield += result.shield_granted
	result.applied = result.shield_granted > 0
	return result
