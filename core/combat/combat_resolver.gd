class_name CombatResolver
extends RefCounted

static func calculate_damage(context: DamageCalculationContext) -> DamageResult:
	var result: DamageResult = DamageResult.new()
	if context == null:
		return result
	result.target = context.target
	result.base_damage = maxi(0, context.base_damage)
	var damage: float = _record_flat_step(result, context.source, DamageStepKind.Value.BASE, 0.0, float(result.base_damage))
	if context.event_type == DamageEventType.Value.CLEAR:
		damage = _apply_clear_rules(context, result, damage)
	for modifier: DamageModifierInstance in DamageModifierCollector.new().collect(context):
		var resolved: float = modifier.resolved_value(context)
		var before: float = damage
		if modifier.operation == DamageModifierOperation.Value.FLAT:
			damage += resolved
			result.modifier_bonus += roundi(resolved)
		else:
			damage *= resolved
		_record_step(result, modifier.source, DamageStepKind.Value.MODIFIER, modifier.operation, resolved, before, damage)
		_record_source(result, modifier.source)
		if modifier.consume_on_apply and modifier.origin_status != null and not result.consumed_statuses.has(modifier.origin_status):
			result.consumed_statuses.append(modifier.origin_status)
	result.final_damage = maxi(0, roundi(damage))
	return result

static func consume_applied_statuses(context: DamageCalculationContext, result: DamageResult) -> void:
	if context == null or result == null:
		return
	for status: StatusInstance in result.consumed_statuses:
		if context.run_state != null and context.run_state.player_statuses.instances.has(status):
			context.run_state.player_statuses.remove_status(status.definition)
		elif context.encounter_state != null and context.encounter_state.enemy_statuses.instances.has(status):
			context.encounter_state.enemy_statuses.remove_status(status.definition)

static func _apply_clear_rules(context: DamageCalculationContext, result: DamageResult, current_damage: float) -> float:
	if context.clear_result == null or context.rules == null:
		return current_damage
	var clear: ClearResult = context.clear_result
	result.cross_bonus = context.rules.cross_damage_bonus if clear.cross_clear else 0
	result.perfect_clear_bonus = context.rules.perfect_clear_damage_bonus if clear.perfect_clear else 0
	result.combo_bonus = maxi(0, context.combo_level) * maxi(0, context.rules.combo_damage_bonus_per_level)
	result.blocker_penalty = clear.blockers_destroyed
	var damage: float = current_damage
	damage = _record_flat_step(result, context.rules, DamageStepKind.Value.CROSS_CLEAR, damage, float(result.cross_bonus))
	damage = _record_flat_step(result, context.rules, DamageStepKind.Value.PERFECT_CLEAR, damage, float(result.perfect_clear_bonus))
	damage = _record_flat_step(result, context.rules, DamageStepKind.Value.COMBO, damage, float(result.combo_bonus))
	damage = _record_flat_step(result, context.rules, DamageStepKind.Value.BLOCKER_PENALTY, damage, -float(result.blocker_penalty))
	return damage

static func _record_flat_step(result: DamageResult, source: Resource, kind: DamageStepKind.Value, before: float, value: float) -> float:
	var after: float = before + value
	if not is_zero_approx(value) or result.calculation_steps.is_empty():
		_record_step(result, source, kind, DamageModifierOperation.Value.FLAT, value, before, after)
		_record_source(result, source)
	return after

static func _record_step(result: DamageResult, source: Resource, kind: DamageStepKind.Value, operation: DamageModifierOperation.Value, value: float, before: float, after: float) -> void:
	var step: DamageCalculationStep = DamageCalculationStep.new()
	step.source = source
	step.kind = kind
	step.operation = operation
	step.modifier_value = value
	step.damage_before = before
	step.damage_after = after
	result.calculation_steps.append(step)

static func _record_source(result: DamageResult, source: Resource) -> void:
	if source != null and not result.calculation_sources.has(source):
		result.calculation_sources.append(source)
