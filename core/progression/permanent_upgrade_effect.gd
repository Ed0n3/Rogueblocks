class_name PermanentUpgradeEffect
extends Resource

@export var maximum_health_per_level: int = 0
@export var starting_health_per_level: int = 0
@export var rerolls_per_level: int = 0
@export var shards_per_level: int = 0
@export var draw_count_per_level: int = 0
@export var reward_rerolls_per_level: int = 0
@export var shop_discount_per_level: float = 0.0
@export var fragment_multiplier_per_level: float = 0.0
@export var emergency_clear_charges_per_level: int = 0
@export var encounter_healing_per_level: int = 0
@export var last_reserve_charges_per_level: int = 0
@export var free_rerolls_per_level: int = 0
@export var item_slots_per_level: int = 0
@export var potion_stack_limit_per_level: int = 0
@export var starting_common_potions_per_level: int = 0
@export var damage_modifiers: Array[DamageModifierDefinition] = []
@export var draft_candidates_per_level: int = 0
@export var draft_selections_per_level: int = 0
@export var guarantee_small_draft_candidate: bool = false
@export var elite_nodes_per_route_per_level: int = 0

func apply_to_starting_modifiers(modifiers: StartingRunModifiers, purchased_level: int, source: UpgradeDefinition = null) -> void:
	modifiers.maximum_health_bonus += maximum_health_per_level * purchased_level
	modifiers.starting_health_bonus += starting_health_per_level * purchased_level
	modifiers.starting_rerolls_bonus += rerolls_per_level * purchased_level
	modifiers.starting_run_currency += shards_per_level * purchased_level
	modifiers.draw_count_bonus += draw_count_per_level * purchased_level
	modifiers.reward_rerolls += reward_rerolls_per_level * purchased_level
	modifiers.shop_discount += shop_discount_per_level * float(purchased_level)
	modifiers.fragment_reward_multiplier += fragment_multiplier_per_level * float(purchased_level)
	modifiers.emergency_board_clear_charges += emergency_clear_charges_per_level * purchased_level
	modifiers.encounter_healing += encounter_healing_per_level * purchased_level
	modifiers.last_reserve_charges += last_reserve_charges_per_level * purchased_level
	modifiers.free_rerolls_per_encounter += free_rerolls_per_level * purchased_level
	modifiers.item_slot_bonus += item_slots_per_level * purchased_level
	modifiers.potion_stack_limit_bonus += potion_stack_limit_per_level * purchased_level
	modifiers.starting_common_potions += starting_common_potions_per_level * purchased_level
	for definition: DamageModifierDefinition in damage_modifiers:
		if definition != null:
			modifiers.damage_modifiers.append(definition.create_instance(source, purchased_level))
	modifiers.draft_candidate_count_bonus += draft_candidates_per_level * purchased_level
	modifiers.draft_selection_count_bonus += draft_selections_per_level * purchased_level
	modifiers.guarantee_small_draft_candidate = modifiers.guarantee_small_draft_candidate or guarantee_small_draft_candidate
	modifiers.elite_nodes_per_route_bonus += elite_nodes_per_route_per_level * purchased_level
