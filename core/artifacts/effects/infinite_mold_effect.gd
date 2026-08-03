class_name InfiniteMoldEffect
extends BossArtifactEffect

@export var block_capsule: ItemDefinition = preload("res://content/items/block_capsule.tres") as ItemDefinition
@export var repetition_count: int = 3
@export var overflow_shards: int = 3
@export var capsule_quantity: int = 1
@export var overflow_message: String = "Infinite Mold overflowed into %d Shards"
@export var created_capsule_message: String = "Infinite Mold created a %s capsule"

func on_encounter_started(context: ArtifactEffectContext) -> void:
	context.artifact_state.last_piece = null
	context.artifact_state.repeat_count = 0

func after_piece_placement(context: ArtifactEffectContext) -> void:
	if context.piece_source_type != PieceSourceType.Value.DRAWN_CARD or context.placed_piece == null:
		return
	if context.artifact_state.last_piece == context.placed_piece:
		context.artifact_state.repeat_count += 1
	else:
		context.artifact_state.last_piece = context.placed_piece
		context.artifact_state.repeat_count = 1
	context.artifact_state.trigger_counter = context.artifact_state.repeat_count
	if context.artifact_state.repeat_count < repetition_count:
		return
	context.artifact_state.repeat_count = 0
	context.artifact_state.trigger_counter = 0
	var stack: ItemStack = ItemStack.new()
	stack.definition = block_capsule
	stack.bonus_piece = context.placed_piece
	stack.quantity = capsule_quantity
	if not context.run_state.inventory.add(stack, context.run_state.starting_modifiers.potion_stack_limit_bonus).added:
		context.run_state.shards += overflow_shards
		context.activation_message = overflow_message % overflow_shards
	else:
		context.activation_message = created_capsule_message % context.placed_piece.display_name
	context.activated = true
