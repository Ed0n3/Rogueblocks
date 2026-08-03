class_name RewardScreen
extends Control

signal reward_selected()
signal reward_changed(data: Dictionary)

var run_state: RunState
var rewards: Array[RelicDefinition] = []
var generator: PieceGenerator
var attached_items: Array[ItemDefinition] = []
var reward_committed: bool = false

func start(current_run: RunState, generator: PieceGenerator) -> void:
	_configure(current_run, generator)
	_generate_rewards()
	_animate_cards()

func restore(current_run: RunState, generator: PieceGenerator, data: Dictionary) -> bool:
	_configure(current_run, generator)
	rewards.clear()
	attached_items.clear()
	for value: Variant in data.get("rewards", data.get("reward_ids", [])) as Array:
		var reward: RelicDefinition = ContentReferenceCodec.decode_legacy(String(value), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
		if reward == null:
			return false
		rewards.append(reward)
	for value: Variant in data.get("attached_items", data.get("attached_item_ids", [])) as Array:
		attached_items.append(ContentReferenceCodec.decode_legacy(String(value), ItemDefinition, ContentRegistry.catalog) as ItemDefinition)
	while attached_items.size() < rewards.size():
		attached_items.append(null)
	_display_rewards()
	_animate_cards()
	return not rewards.is_empty()

func _configure(current_run: RunState, generator: PieceGenerator) -> void:
	run_state = current_run
	self.generator = generator
	%Reroll.visible = run_state.reward_rerolls > 0
	%Reroll.tooltip_text = "Reroll Rewards (%d remaining)" % run_state.reward_rerolls
	%Reroll.pressed.connect(_reroll_rewards)
	TutorialService.enter_screen(TutorialScreen.Value.REWARD, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.REWARD_FIRST_CARD, %RewardOne, self)
	TutorialService.publish(TutorialEventId.Value.REWARD_SCREEN_OPENED)
	if not tree_exiting.is_connected(_unregister_tutorial_target):
		tree_exiting.connect(_unregister_tutorial_target)

func _animate_cards() -> void:
	var motion: MotionSettings = MotionSettings.from_saved_settings(SaveService.settings)
	var buttons: Array[Button] = [%RewardOne, %RewardTwo, %RewardThree]
	for index: int in buttons.size():
		MotionPresets.pop_in(buttons[index], 0.06 * float(index), motion)

func _generate_rewards() -> void:
	rewards.clear()
	attached_items.clear()
	var pool: Array[RelicDefinition] = ContentRegistry.get_reward_pool(run_state)
	for index: int in mini(3, pool.size()):
		var selected_index: int = generator.rng.randi_range(0, pool.size() - 1)
		rewards.append(pool.pop_at(selected_index))
	for index: int in rewards.size():
		attached_items.append(null)
	var enhanced_indices: Array[int] = []
	while enhanced_indices.size() < mini(2, rewards.size()):
		var index: int = generator.rng.randi_range(0, rewards.size() - 1)
		if not enhanced_indices.has(index):
			enhanced_indices.append(index)
	var item_pool: Array[ItemDefinition] = []
	for item: ItemDefinition in ContentRegistry.items:
		if item.category != ItemCategory.Value.BONUS_BLOCK and item.rarity != ItemRarity.Value.RARE:
			item_pool.append(item)
	for index: int in enhanced_indices:
		if item_pool.is_empty():
			break
		attached_items[index] = item_pool.pop_at(generator.rng.randi_range(0, item_pool.size() - 1))
	_display_rewards()

func _display_rewards() -> void:
	var buttons: Array[Button] = [%RewardOne, %RewardTwo, %RewardThree]
	for index: int in buttons.size():
		if index < rewards.size():
			var attachment: String = "\n\n+ %s" % attached_items[index].display_name if attached_items[index] != null else ""
			buttons[index].text = "%s\n\n%s%s" % [rewards[index].display_name, rewards[index].description, attachment]
			buttons[index].pressed.connect(_select_reward.bind(index))
		else:
			buttons[index].visible = false
	%Summary.text = "Fight %d won\nScore: %d  |  Health: %d / %d" % [run_state.encounter_index + 1, run_state.score, run_state.player_health, run_state.maximum_health]
	if run_state.pending_profile_fragments > 0:
		%Summary.text += "\nBoss reward: +%d Fragments" % run_state.pending_profile_fragments

func _reroll_rewards() -> void:
	if reward_committed or run_state.reward_rerolls <= 0:
		return
	run_state.reward_rerolls -= 1
	for button: Button in [%RewardOne, %RewardTwo, %RewardThree]:
		for connection: Dictionary in button.pressed.get_connections():
			button.pressed.disconnect(connection["callable"] as Callable)
	_generate_rewards()
	%Reroll.visible = run_state.reward_rerolls > 0
	%Reroll.tooltip_text = "Reroll Rewards (%d remaining)" % run_state.reward_rerolls
	reward_changed.emit(to_save_data())

func to_save_data() -> Dictionary:
	var reward_references: Array[String] = []
	var attached_item_references: Array[String] = []
	for reward: RelicDefinition in rewards:
		reward_references.append(ContentReferenceCodec.encode(reward))
	for item: ItemDefinition in attached_items:
		attached_item_references.append(ContentReferenceCodec.encode(item))
	return {"rewards": reward_references, "attached_items": attached_item_references, "selected": reward_committed}

func _select_reward(index: int) -> void:
	var reward: RelicDefinition = rewards[index]
	reward.apply(run_state, "Encounter reward")
	var relic_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.RELIC_OBTAINED)
	relic_event.relic = reward
	TutorialService.publish_event(relic_event)
	var confirmation: String = "%s acquired" % reward.display_name
	if attached_items[index] != null:
		var stack: ItemStack = ItemStack.new()
		stack.definition = attached_items[index]
		stack.quantity = attached_items[index].charges_per_purchase
		var add_result: InventoryAddResult = run_state.inventory.add(stack, run_state.starting_modifiers.potion_stack_limit_bonus)
		if add_result.added or add_result.merged_quantity > 0:
			var item_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.ITEM_ACQUIRED)
			item_event.item = attached_items[index]
			TutorialService.publish_event(item_event)
		if add_result.added:
			confirmation += " + %s" % attached_items[index].display_name
		elif add_result.merged_quantity > 0:
			confirmation += " + %d %s charge(s)" % [add_result.merged_quantity, attached_items[index].display_name]
		else:
			confirmation += " | %s could not fit" % attached_items[index].display_name
		if (add_result.added or add_result.merged_quantity > 0) and not SaveService.profile.discovered_items.has(attached_items[index]):
			SaveService.profile.discovered_items.append(attached_items[index])
	if not SaveService.profile.discovered_relics.has(reward):
		SaveService.profile.discovered_relics.append(reward)
	SaveService.save_profile()
	reward_committed = true
	%Reroll.disabled = true
	reward_changed.emit(to_save_data())
	%Confirmation.text = confirmation
	MotionPresets.pulse(%Confirmation, 1.05, MotionSettings.from_saved_settings(SaveService.settings))
	for button: Button in [%RewardOne, %RewardTwo, %RewardThree]:
		button.disabled = true
	var tween: Tween = create_tween()
	tween.tween_interval(0.65)
	tween.tween_callback(func() -> void: reward_selected.emit())

func _unregister_tutorial_target() -> void:
	TutorialService.leave_screen(TutorialScreen.Value.REWARD, self)
	TutorialTargetRegistry.unregister_owner(self)
