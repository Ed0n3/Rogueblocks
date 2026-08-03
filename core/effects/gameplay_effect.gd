class_name GameplayEffect
extends Resource

@export var target: EffectTarget.Value = EffectTarget.Value.PLAYER
@export var tags: Array[StringName] = []
@export var priority: int = 0
@export var missing_override_error: String = "GameplayEffect.apply must be overridden"

func can_apply(context: EffectContext) -> bool:
	return context != null

func apply(_context: EffectContext) -> EffectResult:
	push_error(missing_override_error)
	return EffectResult.new()
