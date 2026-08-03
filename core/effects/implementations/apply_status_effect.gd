class_name ApplyStatusEffect
extends GameplayEffect

@export var ward_status: StatusDefinition = preload("res://content/statuses/ward.tres") as StatusDefinition
@export var ward_prevented_message: String = "Ward prevented %s"
@export var status: StatusDefinition
@export var duration_turns: int = 0
@export var stacks: int = 1
@export var magnitude: float = 1.0

func can_apply(context: EffectContext) -> bool:
	return context != null and status != null and context.encounter_state != null

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var collection: StatusCollection = context.encounter_state.player_statuses if target == EffectTarget.Value.PLAYER else context.encounter_state.enemy_statuses
	if target == EffectTarget.Value.PLAYER and status.category != StatusCategory.Value.POSITIVE and status.is_cleansable and collection.get_status(ward_status) != null:
		collection.remove_status(ward_status)
		result.applied = true
		result.messages.append(ward_prevented_message % status.display_name)
		return result
	collection.apply_status(status, context.source, duration_turns + context.duration_modifier, stacks + context.stack_modifier, magnitude * context.magnitude_multiplier, context.current_turn)
	result.applied = true
	result.applied_statuses.append(status)
	return result
