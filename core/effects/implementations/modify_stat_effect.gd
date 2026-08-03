class_name ModifyStatEffect
extends GameplayEffect

@export var status: StatusDefinition
@export var duration_turns: int = 1
@export var stacks: int = 1
@export var magnitude: float = 1.0

func can_apply(context: EffectContext) -> bool:
	return context != null and status != null

func apply(context: EffectContext) -> EffectResult:
	var effect: ApplyStatusEffect = ApplyStatusEffect.new()
	effect.target = target
	effect.status = status
	effect.duration_turns = duration_turns
	effect.stacks = stacks
	effect.magnitude = magnitude
	return effect.apply(context)
