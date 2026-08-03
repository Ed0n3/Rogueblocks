class_name RelicTriggerEffect
extends Resource

@export var minimum_lines: int = 0
@export var requires_cross_clear: bool = false
@export var requires_perfect_clear: bool = false
@export var shard_reward: int = 0
@export var heal_every_clear_count: int = 0
@export var heal_amount: int = 0
@export var damage_modifiers: Array[DamageModifierDefinition] = []
@export var discard_interval: int = 0
@export var rerolls_per_discard_trigger: int = 0
@export var spawned_blocker_durability: int = 0

func after_clear(context: AfterClearContext) -> void:
	if context.clear_result.line_count < minimum_lines:
		return
	if requires_cross_clear and not context.clear_result.cross_clear:
		return
	if requires_perfect_clear and not context.clear_result.perfect_clear:
		return
	context.run_state.shards += shard_reward
	if heal_every_clear_count > 0 and context.run_state.successful_clear_turns % heal_every_clear_count == 0:
		context.run_state.heal(heal_amount)
