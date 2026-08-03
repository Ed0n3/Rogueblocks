class_name RunModifiers
extends RefCounted

var damage_modifiers: Array[DamageModifierInstance] = []
var reroll_bonus: int = 0
var draw_count_bonus: int = 0
var placement_point_bonus: int = 0
var free_redraws_per_turn_bonus: int = 0
var vault_storage_cooldown_reduction: int = 0

func to_save_data() -> Dictionary:
	var saved_damage_modifiers: Array[Dictionary] = []
	for modifier: DamageModifierInstance in damage_modifiers:
		if modifier != null:
			saved_damage_modifiers.append(modifier.to_save_data())
	return {
		"damage_modifiers": saved_damage_modifiers,
		"reroll_bonus": reroll_bonus,
		"draw_count_bonus": draw_count_bonus,
		"placement_point_bonus": placement_point_bonus,
		"free_redraws_per_turn_bonus": free_redraws_per_turn_bonus,
		"vault_storage_cooldown_reduction": vault_storage_cooldown_reduction
	}

static func from_save_data(data: Dictionary) -> RunModifiers:
	var modifiers: RunModifiers = RunModifiers.new()
	for value: Variant in data.get("damage_modifiers", []) as Array:
		modifiers.damage_modifiers.append(DamageModifierInstance.from_save_data(value as Dictionary))
	modifiers.reroll_bonus = int(data.get("reroll_bonus", 0))
	if data.has("draw_count_bonus"):
		modifiers.draw_count_bonus = int(data.get("draw_count_bonus", 0))
	else:
		var legacy_capacity_bonus: int = int(data.get("discard_capacity_bonus", 0))
		var legacy_removal_bonus: int = int(data.get("discard_removal_bonus", 0))
		modifiers.draw_count_bonus = maxi(legacy_capacity_bonus, legacy_removal_bonus)
	modifiers.placement_point_bonus = int(data.get("placement_point_bonus", 0))
	modifiers.free_redraws_per_turn_bonus = maxi(0, int(data.get("free_redraws_per_turn_bonus", 0)))
	modifiers.vault_storage_cooldown_reduction = maxi(0, int(data.get("vault_storage_cooldown_reduction", 0)))
	return modifiers
