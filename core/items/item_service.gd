class_name ItemService
extends RefCounted

@export_category("Messages")
@export var invalid_target_message: String = "Invalid item target"
@export var unavailable_message: String = "Item unavailable during this phase"

func use_item(inventory: ItemInventory, context: ItemUseContext) -> ItemUseResult:
	var result: ItemUseResult = ItemUseResult.new()
	if context == null or context.effect_context == null or context.slot_index < 0 or context.slot_index >= inventory.slots.size() or inventory.locked_slots.has(context.slot_index):
		result.message = invalid_target_message
		return result
	var stack: ItemStack = inventory.slots[context.slot_index]
	var definition: ItemDefinition = stack.definition if stack != null else null
	if definition == null:
		result.message = unavailable_message
		return result
	context.effect_context.source = definition
	result.effect_result = EffectResolver.new().resolve(definition.effects, context.effect_context)
	result.used = result.effect_result.applied
	if result.used or definition.consume_on_failed_use:
		result.consumed = inventory.consume(context.slot_index)
	return result
