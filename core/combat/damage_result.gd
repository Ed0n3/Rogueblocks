class_name DamageResult
extends RefCounted

var base_damage: int = 0
var cross_bonus: int = 0
var perfect_clear_bonus: int = 0
var combo_bonus: int = 0
var modifier_bonus: int = 0
var blocker_penalty: int = 0
var final_damage: int = 0
var health_damage: int = 0
var shield_damage: int = 0
var bonus_damage: int = 0
var sources: Array[PieceModifierDefinition] = []
var enemy_maximum_health: int = 1
var cross_clear: bool = false
var perfect_clear: bool = false
var killed_enemy: bool = false
var calculation_steps: Array[DamageCalculationStep] = []
var calculation_sources: Array[Resource] = []
var consumed_statuses: Array[StatusInstance] = []
var target: EffectTarget.Value = EffectTarget.Value.ENEMY
var lethal_damage_prevented: bool = false

func append_calculation(other: DamageResult) -> void:
	if other == null:
		return
	calculation_steps.append_array(other.calculation_steps)
	for source: Resource in other.calculation_sources:
		if source != null and not calculation_sources.has(source):
			calculation_sources.append(source)
	for status: StatusInstance in other.consumed_statuses:
		if status != null and not consumed_statuses.has(status):
			consumed_statuses.append(status)
