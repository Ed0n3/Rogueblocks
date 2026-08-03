class_name DamageModifierDefinition
extends Resource

@export var scope: DamageModifierScope.Value = DamageModifierScope.Value.OUTGOING
@export var operation: DamageModifierOperation.Value = DamageModifierOperation.Value.FLAT
@export var event_type: DamageEventType.Value = DamageEventType.Value.ANY
@export var value: float = 0.0
@export var scaling: DamageModifierScaling.Value = DamageModifierScaling.Value.NONE
@export var priority: int = 0
@export var minimum_lines: int = 0
@export var requires_cross_clear: bool = false
@export var requires_perfect_clear: bool = false
@export var consume_on_apply: bool = false

func create_instance(source: Resource, stacks: int = 1) -> DamageModifierInstance:
	return DamageModifierInstance.from_definition(self, source, stacks)
