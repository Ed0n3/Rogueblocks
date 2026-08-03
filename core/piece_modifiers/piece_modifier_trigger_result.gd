class_name PieceModifierTriggerResult
extends RefCounted

var health_damage: int = 0
var shield_damage: int = 0
var healing: int = 0
var shield_granted: int = 0
var sources: Array[PieceModifierDefinition] = []
var messages: Array[String] = []
var damage_results: Array[DamageResult] = []

func merge_effect(source: PieceModifierDefinition, effect_result: EffectResult) -> void:
	health_damage += effect_result.health_damage
	shield_damage += effect_result.shield_damage
	healing += effect_result.healing
	shield_granted += effect_result.shield_granted
	messages.append_array(effect_result.messages)
	damage_results.append_array(effect_result.damage_results)
	if effect_result.applied and not sources.has(source):
		sources.append(source)
