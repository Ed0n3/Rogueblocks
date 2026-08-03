class_name RelicEffect
extends Resource

@export var maximum_health_bonus: int = 0
@export var healing: int = 0
@export var damage_modifiers: Array[DamageModifierDefinition] = []
@export var reroll_bonus: int = 0
@export var draw_count_bonus: int = 0
@export var placement_point_bonus: int = 0
@export var free_redraws_per_turn_bonus: int = 0

func apply(run_state: RunState, _source_relic: RelicDefinition = null) -> void:
	run_state.maximum_health += maximum_health_bonus
	run_state.modifiers.reroll_bonus += reroll_bonus
	run_state.modifiers.draw_count_bonus += draw_count_bonus
	run_state.modifiers.placement_point_bonus += placement_point_bonus
	run_state.modifiers.free_redraws_per_turn_bonus += free_redraws_per_turn_bonus
	run_state.heal(healing)
