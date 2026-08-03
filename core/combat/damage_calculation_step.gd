class_name DamageCalculationStep
extends RefCounted

var source: Resource
var kind: DamageStepKind.Value = DamageStepKind.Value.MODIFIER
var operation: DamageModifierOperation.Value = DamageModifierOperation.Value.FLAT
var modifier_value: float = 0.0
var damage_before: float = 0.0
var damage_after: float = 0.0
