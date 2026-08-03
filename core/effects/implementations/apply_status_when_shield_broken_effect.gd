class_name ApplyStatusWhenShieldBrokenEffect
extends ApplyStatusEffect

func can_apply(context: EffectContext) -> bool:
	return super.can_apply(context) and context.encounter_state.enemy_shield <= 0
