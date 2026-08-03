class_name StatusCollection
extends RefCounted

var instances: Array[StatusInstance] = []

func apply_status(definition: StatusDefinition, source: Resource = null, duration: int = 0, stacks: int = 1, magnitude: float = 1.0, turn: int = 0) -> StatusInstance:
	var applied_duration: int = maxi(1, definition.default_duration_turns if duration <= 0 else duration)
	if definition.maximum_duration_turns > 0:
		applied_duration = mini(applied_duration, definition.maximum_duration_turns)
	var existing: StatusInstance = get_status(definition)
	if existing != null and definition.stacking_rule != StatusStackingRule.Value.INDEPENDENT_INSTANCES:
		if definition.stacking_rule == StatusStackingRule.Value.REFRESH_DURATION:
			existing.remaining_turns = maxi(existing.remaining_turns, applied_duration)
		elif definition.stacking_rule == StatusStackingRule.Value.ADD_DURATION:
			existing.remaining_turns += applied_duration
		elif definition.stacking_rule == StatusStackingRule.Value.ADD_STACKS:
			existing.stacks = mini(definition.maximum_stacks, existing.stacks + stacks)
		elif definition.stacking_rule == StatusStackingRule.Value.ADD_STACKS_AND_REFRESH:
			existing.stacks = mini(definition.maximum_stacks, existing.stacks + stacks)
			existing.remaining_turns = maxi(existing.remaining_turns, applied_duration)
		elif definition.stacking_rule == StatusStackingRule.Value.REPLACE_IF_STRONGER and magnitude > existing.magnitude:
			existing.magnitude = magnitude
			existing.remaining_turns = applied_duration
		if definition.maximum_duration_turns > 0:
			existing.remaining_turns = mini(existing.remaining_turns, definition.maximum_duration_turns)
		return existing
	var instance: StatusInstance = StatusInstance.new()
	instance.definition = definition
	instance.source = source
	instance.remaining_turns = applied_duration
	instance.stacks = mini(definition.maximum_stacks, maxi(1, stacks))
	instance.magnitude = magnitude
	instance.applied_turn = turn
	instances.append(instance)
	return instance

func get_status(definition: StatusDefinition) -> StatusInstance:
	for instance: StatusInstance in instances:
		if instance.definition == definition:
			return instance
	return null

func remove_status(definition: StatusDefinition) -> bool:
	for index: int in instances.size():
		if instances[index].definition == definition:
			instances.remove_at(index)
			return true
	return false

func has_control_effect(control_effect: StatusControlEffect.Value) -> bool:
	for instance: StatusInstance in instances:
		if instance.definition != null and instance.definition.control_effect == control_effect:
			return true
	return false

func consume_control_effect(control_effect: StatusControlEffect.Value) -> Array[StatusDefinition]:
	var consumed: Array[StatusDefinition] = []
	for index: int in range(instances.size() - 1, -1, -1):
		var definition: StatusDefinition = instances[index].definition
		if definition != null and definition.control_effect == control_effect:
			consumed.append(definition)
			instances.remove_at(index)
	consumed.sort_custom(func(left: StatusDefinition, right: StatusDefinition) -> bool:
		return left.resource_path < right.resource_path)
	return consumed

func remove_by_tags(tags: Array[StringName], maximum: int = -1) -> Array[StatusDefinition]:
	var removed: Array[StatusDefinition] = []
	var ordered: Array[StatusInstance] = instances.duplicate()
	ordered.sort_custom(func(left: StatusInstance, right: StatusInstance) -> bool:
		var left_path: String = left.definition.resource_path if left != null and left.definition != null else String()
		var right_path: String = right.definition.resource_path if right != null and right.definition != null else String()
		return left_path < right_path)
	for instance: StatusInstance in ordered:
		var definition: StatusDefinition = instance.definition
		if definition != null and _has_any_tag(definition.tags, tags):
			remove_status(definition)
			removed.append(definition)
			if maximum > 0 and removed.size() >= maximum:
				break
	return removed

func decrement(phase: StatusTickPhase.Value) -> Array[StatusDefinition]:
	var expired: Array[StatusDefinition] = []
	for index: int in range(instances.size() - 1, -1, -1):
		var definition: StatusDefinition = instances[index].definition
		if definition != null and definition.duration_phase == phase:
			instances[index].remaining_turns -= 1
			if instances[index].remaining_turns <= 0:
				expired.append(definition)
				instances.remove_at(index)
	return expired

func to_save_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for instance: StatusInstance in instances:
		data.append(instance.to_save_data())
	return data

static func from_save_data(data: Array) -> StatusCollection:
	var collection: StatusCollection = StatusCollection.new()
	for value: Variant in data:
		var instance: StatusInstance = StatusInstance.from_save_data(value as Dictionary)
		if instance.definition != null and instance.remaining_turns > 0:
			if instance.definition.maximum_duration_turns > 0:
				instance.remaining_turns = mini(instance.remaining_turns, instance.definition.maximum_duration_turns)
			collection.instances.append(instance)
	return collection

static func _has_any_tag(available: Array[StringName], wanted: Array[StringName]) -> bool:
	for tag: StringName in wanted:
		if available.has(tag):
			return true
	return false
