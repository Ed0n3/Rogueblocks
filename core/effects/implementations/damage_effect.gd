class_name DamageEffect
extends GameplayEffect

@export var amount: int = 0
@export var ignores_shield: bool = false

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var scaled_amount: int = maxi(0, roundi(float(amount) * context.magnitude_multiplier))
	var calculation_context: DamageCalculationContext = DamageCalculationContext.for_effect(context, scaled_amount)
	calculation_context.target = target
	calculation_context.attacker = EffectTarget.Value.ENEMY if target == EffectTarget.Value.PLAYER else EffectTarget.Value.PLAYER
	var damage: DamageResult = CombatResolver.calculate_damage(calculation_context)
	CombatResolver.consume_applied_statuses(calculation_context, damage)
	var remaining: int = damage.final_damage
	if target == EffectTarget.Value.PLAYER:
		if not ignores_shield:
			result.shield_damage = mini(context.encounter_state.player_shield, remaining)
			context.encounter_state.player_shield -= result.shield_damage
			remaining -= result.shield_damage
		var reserve_charges_before: int = context.run_state.last_reserve_charges
		result.health_damage = context.run_state.apply_player_health_damage(remaining, context.last_reserve_health)
		damage.lethal_damage_prevented = context.run_state.last_reserve_charges < reserve_charges_before
		if damage.lethal_damage_prevented and not context.last_reserve_message.is_empty():
			result.messages.append(context.last_reserve_message)
	else:
		if not ignores_shield:
			result.shield_damage = mini(context.encounter_state.enemy_shield, remaining)
			context.encounter_state.enemy_shield -= result.shield_damage
			remaining -= result.shield_damage
		result.health_damage = mini(context.encounter_state.enemy_health, remaining)
		context.encounter_state.enemy_health -= result.health_damage
	damage.health_damage = result.health_damage
	damage.shield_damage = result.shield_damage
	damage.enemy_maximum_health = context.encounter_state.enemy_maximum_health if target == EffectTarget.Value.ENEMY else context.run_state.maximum_health
	damage.killed_enemy = target == EffectTarget.Value.ENEMY and context.encounter_state.enemy_health <= 0
	result.damage_results.append(damage)
	result.applied = result.health_damage + result.shield_damage > 0 or damage.lethal_damage_prevented
	return result
