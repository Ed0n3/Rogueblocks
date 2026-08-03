class_name DamageModifierInstance
extends RefCounted

var source: Resource
var scope: DamageModifierScope.Value = DamageModifierScope.Value.OUTGOING
var operation: DamageModifierOperation.Value = DamageModifierOperation.Value.FLAT
var event_type: DamageEventType.Value = DamageEventType.Value.ANY
var value: float = 0.0
var scaling: DamageModifierScaling.Value = DamageModifierScaling.Value.NONE
var priority: int = 0
var minimum_lines: int = 0
var requires_cross_clear: bool = false
var requires_perfect_clear: bool = false
var consume_on_apply: bool = false
var stacks: int = 1
var origin_status: StatusInstance

func applies_to(context: DamageCalculationContext) -> bool:
	if context == null or event_type != DamageEventType.Value.ANY and event_type != context.event_type:
		return false
	var clear: ClearResult = context.clear_result
	if minimum_lines > 0 and (clear == null or clear.line_count < minimum_lines):
		return false
	if requires_cross_clear and (clear == null or not clear.cross_clear):
		return false
	if requires_perfect_clear and (clear == null or not clear.perfect_clear):
		return false
	return true

func resolved_value(context: DamageCalculationContext) -> float:
	if operation == DamageModifierOperation.Value.MULTIPLY:
		return value
	var factor: int = maxi(1, stacks)
	if scaling == DamageModifierScaling.Value.CLEARED_LINES:
		factor *= context.clear_result.line_count if context.clear_result != null else 0
	elif scaling == DamageModifierScaling.Value.COMBO_LEVEL:
		factor *= maxi(0, context.combo_level)
	elif scaling == DamageModifierScaling.Value.DESTROYED_BLOCKERS:
		factor *= context.clear_result.blockers_destroyed if context.clear_result != null else 0
	return value * float(factor)

func duplicate_instance() -> DamageModifierInstance:
	var copy: DamageModifierInstance = DamageModifierInstance.new()
	copy.source = source
	copy.scope = scope
	copy.operation = operation
	copy.event_type = event_type
	copy.value = value
	copy.scaling = scaling
	copy.priority = priority
	copy.minimum_lines = minimum_lines
	copy.requires_cross_clear = requires_cross_clear
	copy.requires_perfect_clear = requires_perfect_clear
	copy.consume_on_apply = consume_on_apply
	copy.stacks = stacks
	copy.origin_status = origin_status
	return copy

func to_save_data() -> Dictionary:
	return {
		"source": ContentReferenceCodec.encode(source),
		"scope": int(scope),
		"operation": int(operation),
		"event_type": int(event_type),
		"value": value,
		"scaling": int(scaling),
		"priority": priority,
		"minimum_lines": minimum_lines,
		"requires_cross_clear": requires_cross_clear,
		"requires_perfect_clear": requires_perfect_clear,
		"consume_on_apply": consume_on_apply,
		"stacks": stacks
	}

static func from_definition(definition: DamageModifierDefinition, source: Resource, stacks: int = 1) -> DamageModifierInstance:
	var instance: DamageModifierInstance = DamageModifierInstance.new()
	instance.source = source
	instance.scope = definition.scope
	instance.operation = definition.operation
	instance.event_type = definition.event_type
	instance.value = definition.value
	instance.scaling = definition.scaling
	instance.priority = definition.priority
	instance.minimum_lines = definition.minimum_lines
	instance.requires_cross_clear = definition.requires_cross_clear
	instance.requires_perfect_clear = definition.requires_perfect_clear
	instance.consume_on_apply = definition.consume_on_apply
	instance.stacks = maxi(1, stacks)
	return instance

static func from_save_data(data: Dictionary) -> DamageModifierInstance:
	var instance: DamageModifierInstance = DamageModifierInstance.new()
	var source_reference: String = String(data.get("source", ""))
	instance.source = load(source_reference) as Resource if not source_reference.is_empty() else null
	instance.scope = clampi(int(data.get("scope", DamageModifierScope.Value.OUTGOING)), DamageModifierScope.Value.OUTGOING, DamageModifierScope.Value.INCOMING) as DamageModifierScope.Value
	instance.operation = clampi(int(data.get("operation", DamageModifierOperation.Value.FLAT)), DamageModifierOperation.Value.FLAT, DamageModifierOperation.Value.MULTIPLY) as DamageModifierOperation.Value
	instance.event_type = clampi(int(data.get("event_type", DamageEventType.Value.ANY)), DamageEventType.Value.ANY, DamageEventType.Value.STATUS_TICK) as DamageEventType.Value
	instance.value = float(data.get("value", 0.0))
	instance.scaling = clampi(int(data.get("scaling", DamageModifierScaling.Value.NONE)), DamageModifierScaling.Value.NONE, DamageModifierScaling.Value.DESTROYED_BLOCKERS) as DamageModifierScaling.Value
	instance.priority = int(data.get("priority", 0))
	instance.minimum_lines = maxi(0, int(data.get("minimum_lines", 0)))
	instance.requires_cross_clear = bool(data.get("requires_cross_clear", false))
	instance.requires_perfect_clear = bool(data.get("requires_perfect_clear", false))
	instance.consume_on_apply = bool(data.get("consume_on_apply", false))
	instance.stacks = maxi(1, int(data.get("stacks", 1)))
	return instance
