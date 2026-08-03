class_name DelayEnemyAttackEffect
extends GameplayEffect

@export var placements: int = 1
@export var maximum_over_base: int = 2

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var previous: int = context.encounter_state.enemy_countdown
	context.encounter_state.enemy_countdown = mini(context.encounter_state.enemy_base_interval + maximum_over_base, previous + placements)
	result.countdown_change = context.encounter_state.enemy_countdown - previous
	result.applied = result.countdown_change > 0
	return result
