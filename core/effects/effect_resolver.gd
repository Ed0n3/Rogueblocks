class_name EffectResolver
extends RefCounted

func resolve(effects: Array[GameplayEffect], context: EffectContext) -> EffectResult:
	var ordered: Array[GameplayEffect] = effects.duplicate()
	ordered.sort_custom(func(left: GameplayEffect, right: GameplayEffect) -> bool:
		return left.priority < right.priority if left.priority != right.priority else left.resource_path < right.resource_path)
	var result: EffectResult = EffectResult.new()
	for effect: GameplayEffect in ordered:
		if effect != null and effect.can_apply(context):
			result.merge(effect.apply(context))
	return result
