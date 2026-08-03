class_name DamageModifierCollector
extends RefCounted

func collect(context: DamageCalculationContext) -> Array[DamageModifierInstance]:
	var modifiers: Array[DamageModifierInstance] = []
	if context == null:
		return modifiers
	_collect_run_modifiers(context, modifiers)
	_collect_relic_modifiers(context, modifiers)
	_collect_status_modifiers(_attacker_statuses(context), DamageModifierScope.Value.OUTGOING, modifiers)
	_collect_status_modifiers(_target_statuses(context), DamageModifierScope.Value.INCOMING, modifiers)
	modifiers = modifiers.filter(func(modifier: DamageModifierInstance) -> bool: return modifier.applies_to(context))
	modifiers.sort_custom(func(left: DamageModifierInstance, right: DamageModifierInstance) -> bool:
		if left.operation != right.operation:
			return left.operation < right.operation
		if left.priority != right.priority:
			return left.priority < right.priority
		return _source_path(left.source) < _source_path(right.source))
	return modifiers

func _collect_run_modifiers(context: DamageCalculationContext, result: Array[DamageModifierInstance]) -> void:
	if context.attacker != EffectTarget.Value.PLAYER or context.run_state == null:
		return
	for modifier: DamageModifierInstance in context.run_state.modifiers.damage_modifiers:
		if modifier != null and modifier.scope == DamageModifierScope.Value.OUTGOING:
			result.append(modifier.duplicate_instance())

func _collect_relic_modifiers(context: DamageCalculationContext, result: Array[DamageModifierInstance]) -> void:
	if context.attacker != EffectTarget.Value.PLAYER or context.run_state == null:
		return
	for relic: RelicDefinition in context.run_state.relics:
		if relic == null:
			continue
		if relic.effect != null:
			_append_definitions(relic.effect.damage_modifiers, relic, 1, relic.trigger_priority, result)
		if relic.trigger_effect != null:
			_append_trigger_definitions(relic.trigger_effect, relic, result)

func _collect_status_modifiers(collection: StatusCollection, scope: DamageModifierScope.Value, result: Array[DamageModifierInstance]) -> void:
	if collection == null:
		return
	for status: StatusInstance in collection.instances:
		if status.definition == null:
			continue
		for definition: DamageModifierDefinition in status.definition.damage_modifiers:
			if definition != null and definition.scope == scope:
				var modifier: DamageModifierInstance = definition.create_instance(status.definition, status.stacks)
				modifier.origin_status = status
				result.append(modifier)

func _append_definitions(definitions: Array[DamageModifierDefinition], source: Resource, stacks: int, priority: int, result: Array[DamageModifierInstance]) -> void:
	for definition: DamageModifierDefinition in definitions:
		if definition == null:
			continue
		var modifier: DamageModifierInstance = definition.create_instance(source, stacks)
		modifier.priority += priority
		result.append(modifier)

func _append_trigger_definitions(effect: RelicTriggerEffect, source: RelicDefinition, result: Array[DamageModifierInstance]) -> void:
	for definition: DamageModifierDefinition in effect.damage_modifiers:
		if definition == null:
			continue
		var modifier: DamageModifierInstance = definition.create_instance(source)
		modifier.priority += source.trigger_priority
		modifier.minimum_lines = maxi(modifier.minimum_lines, effect.minimum_lines)
		modifier.requires_cross_clear = modifier.requires_cross_clear or effect.requires_cross_clear
		modifier.requires_perfect_clear = modifier.requires_perfect_clear or effect.requires_perfect_clear
		result.append(modifier)

func _attacker_statuses(context: DamageCalculationContext) -> StatusCollection:
	if context.attacker == EffectTarget.Value.PLAYER:
		return context.run_state.player_statuses if context.run_state != null else null
	if context.attacker == EffectTarget.Value.ENEMY:
		return context.encounter_state.enemy_statuses if context.encounter_state != null else null
	return null

func _target_statuses(context: DamageCalculationContext) -> StatusCollection:
	if context.target == EffectTarget.Value.PLAYER:
		return context.run_state.player_statuses if context.run_state != null else null
	if context.target == EffectTarget.Value.ENEMY:
		return context.encounter_state.enemy_statuses if context.encounter_state != null else null
	return null

func _source_path(source: Resource) -> String:
	return source.resource_path if source != null else String()
