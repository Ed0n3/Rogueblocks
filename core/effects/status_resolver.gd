class_name StatusResolver
extends RefCounted

func tick(collection: StatusCollection, phase: StatusTickPhase.Value, context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var ordered: Array[StatusInstance] = collection.instances.duplicate()
	ordered.sort_custom(func(left: StatusInstance, right: StatusInstance) -> bool:
		var left_path: String = left.definition.resource_path if left != null and left.definition != null else String()
		var right_path: String = right.definition.resource_path if right != null and right.definition != null else String()
		return left_path < right_path)
	for instance: StatusInstance in ordered:
		var definition: StatusDefinition = instance.definition
		if definition == null or definition.tick_phase != phase or definition.tick_amount == 0:
			continue
		var amount: int = absi(definition.tick_amount) * instance.stacks
		if definition.tick_amount > 0:
			var damage: DamageEffect = DamageEffect.new()
			damage.target = context.target
			damage.amount = amount
			context.source = definition
			context.damage_event_type = DamageEventType.Value.STATUS_TICK
			result.merge(damage.apply(context))
		else:
			var healing: HealEffect = HealEffect.new()
			healing.target = context.target
			healing.amount = amount
			result.merge(healing.apply(context))
	collection.decrement(phase)
	return result
