class_name GrantBonusPieceEffect
extends GameplayEffect

@export var block_capsule: ItemDefinition = preload("res://content/items/block_capsule.tres") as ItemDefinition
@export var piece: PieceDefinition
@export var charges: int = 1

func can_apply(context: EffectContext) -> bool:
	return context != null and context.run_state != null and piece != null

func apply(context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	var stack: ItemStack = ItemStack.new()
	stack.definition = block_capsule
	stack.bonus_piece = piece
	stack.quantity = maxi(1, charges)
	result.applied = context.run_state.inventory.add(stack).added
	return result
