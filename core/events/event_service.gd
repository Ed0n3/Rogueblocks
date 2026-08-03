class_name EventService
extends RefCounted

class ChoiceRewards extends RefCounted:
	var relic: RelicDefinition
	var unlocked_piece: PieceDefinition
	var removed_piece: PieceDefinition
	var items: Array[ItemDefinition] = []

func select_event(
	seed_value: int,
	route_node: RouteNodeState,
	pool: Array[RunEventDefinition],
	profile: ProfileState = null,
	additional_unlocks: Array[RunEventDefinition] = []
) -> RunEventDefinition:
	var eligible_events: Array[RunEventDefinition] = []
	for event: RunEventDefinition in pool:
		if event.selection_weight > 0.0 and event.is_unlocked(profile, additional_unlocks):
			eligible_events.append(event)
	if eligible_events.is_empty():
		return null
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value ^ route_node.act * 73856093 ^ route_node.column * 19349663 ^ route_node.row * 83492791
	var total: float = 0.0
	for event: RunEventDefinition in eligible_events:
		total += event.selection_weight
	var roll: float = rng.randf_range(0.0, total)
	for event: RunEventDefinition in eligible_events:
		roll -= event.selection_weight
		if roll <= 0.0:
			return event
	return eligible_events.back()

func apply_choice(choice: EventChoiceDefinition, run_state: RunState, rng: RandomNumberGenerator) -> bool:
	if choice == null or rng == null or not choice.is_available(run_state):
		return false
	var reward_rng: RandomNumberGenerator = _clone_rng(rng)
	var rewards: ChoiceRewards = _roll_rewards(choice, run_state, reward_rng)
	var rewarded_inventory: ItemInventory = _prepare_choice_inventory(choice, rewards, run_state)
	if rewarded_inventory == null or not _has_required_rewards(choice, rewards):
		return false
	rng.state = reward_rng.state
	if choice.item_reward_count > 0:
		run_state.inventory = rewarded_inventory
	run_state.shards -= choice.shard_cost
	run_state.shards += choice.shard_reward
	run_state.player_health = maxi(1, run_state.player_health - choice.health_cost)
	run_state.heal(choice.heal_amount)
	if rewards.relic != null:
		rewards.relic.apply(run_state, "Event")
	if rewards.unlocked_piece != null:
		run_state.unlock_piece_for_run(rewards.unlocked_piece)
	if rewards.removed_piece != null:
		run_state.remove_piece_from_pool(rewards.removed_piece)
	_record_discovered_rewards(rewards)
	run_state.pending_corrupted_cells += choice.corrupted_cells_next_encounter
	if choice.board_width_override > 0 or choice.board_height_override > 0:
		run_state.pending_board_width = choice.board_width_override
		run_state.pending_board_height = choice.board_height_override
	elif choice.board_size_override > 0:
		run_state.pending_board_width = choice.board_size_override
		run_state.pending_board_height = choice.board_size_override
	run_state.maximum_health += choice.maximum_health_reward
	run_state.emergency_clear_charges += choice.emergency_clear_reward
	if choice.cleanse_status_count != 0:
		run_state.player_statuses.remove_by_tags([&"negative", &"damage_over_time", &"control", &"curse"], choice.cleanse_status_count)
	run_state.shard_reward_multiplier = maxf(run_state.shard_reward_multiplier, choice.shard_reward_multiplier)
	return true

func can_apply_choice(choice: EventChoiceDefinition, run_state: RunState, rng: RandomNumberGenerator) -> bool:
	if choice == null or rng == null or not choice.is_available(run_state):
		return false
	var reward_rng: RandomNumberGenerator = _clone_rng(rng)
	var rewards: ChoiceRewards = _roll_rewards(choice, run_state, reward_rng)
	if not _has_required_rewards(choice, rewards):
		return false
	return _prepare_choice_inventory(choice, rewards, run_state) != null

func _roll_rewards(choice: EventChoiceDefinition, run_state: RunState, rng: RandomNumberGenerator) -> ChoiceRewards:
	var rewards: ChoiceRewards = ChoiceRewards.new()
	if choice.relic_reward:
		var relic_pool: Array[RelicDefinition] = ContentRegistry.get_reward_pool(run_state)
		if not relic_pool.is_empty():
			rewards.relic = relic_pool[rng.randi_range(0, relic_pool.size() - 1)]
	if choice.unlock_piece_for_run:
		var locked_pieces: Array[PieceDefinition] = []
		if run_state.deck_cards.size() < run_state.maximum_active_piece_pool_size:
			var pool_service: PiecePoolService = PiecePoolService.new()
			for piece: PieceDefinition in ContentRegistry.pieces:
				if piece.initially_unlocked or run_state.starting_modifiers.unlocked_pieces.has(piece) or run_state.removed_pieces.has(piece):
					continue
				if pool_service.count_piece_copies(run_state, piece) < run_state.maximum_piece_copies:
					locked_pieces.append(piece)
		if not locked_pieces.is_empty():
			rewards.unlocked_piece = locked_pieces[rng.randi_range(0, locked_pieces.size() - 1)]
	if choice.remove_piece_from_pool:
		var removable_pieces: Array[PieceDefinition] = PiecePoolService.new().get_removable_piece_types(run_state)
		if not removable_pieces.is_empty():
			rewards.removed_piece = removable_pieces[rng.randi_range(0, removable_pieces.size() - 1)]
	var pool: Array[ItemDefinition] = []
	for definition: ItemDefinition in ContentRegistry.items:
		if definition.category != ItemCategory.Value.BONUS_BLOCK:
			pool.append(definition)
	for index: int in maxi(0, choice.item_reward_count):
		if pool.is_empty():
			break
		var definition: ItemDefinition = pool[rng.randi_range(0, pool.size() - 1)]
		rewards.items.append(definition)
	return rewards

func _prepare_rewarded_inventory(expected_count: int, definitions: Array[ItemDefinition], run_state: RunState) -> ItemInventory:
	if definitions.size() != expected_count:
		return null
	var inventory: ItemInventory = ItemInventory.from_save_data(run_state.inventory.to_save_data())
	for definition: ItemDefinition in definitions:
		var stack: ItemStack = ItemStack.new()
		stack.definition = definition
		stack.quantity = definition.charges_per_purchase
		if not inventory.add(stack, run_state.starting_modifiers.potion_stack_limit_bonus).added:
			return null
	return inventory

func _prepare_choice_inventory(choice: EventChoiceDefinition, rewards: ChoiceRewards, run_state: RunState) -> ItemInventory:
	if choice.item_reward_count <= 0:
		return run_state.inventory
	return _prepare_rewarded_inventory(choice.item_reward_count, rewards.items, run_state)

func _has_required_rewards(choice: EventChoiceDefinition, rewards: ChoiceRewards) -> bool:
	if choice.relic_reward and rewards.relic == null:
		return false
	if choice.unlock_piece_for_run and rewards.unlocked_piece == null:
		return false
	if choice.remove_piece_from_pool and rewards.removed_piece == null:
		return false
	return true

func _record_discovered_rewards(rewards: ChoiceRewards) -> void:
	var changed: bool = false
	if rewards.relic != null and not SaveService.profile.discovered_relics.has(rewards.relic):
		SaveService.profile.discovered_relics.append(rewards.relic)
		changed = true
	for item: ItemDefinition in rewards.items:
		if item != null and not SaveService.profile.discovered_items.has(item):
			SaveService.profile.discovered_items.append(item)
			changed = true
	if changed:
		SaveService.save_profile()

func _clone_rng(rng: RandomNumberGenerator) -> RandomNumberGenerator:
	var clone: RandomNumberGenerator = RandomNumberGenerator.new()
	clone.seed = rng.seed
	clone.state = rng.state
	return clone
