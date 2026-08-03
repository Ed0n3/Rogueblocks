class_name ShopService
extends RefCounted

const BLOCK_CAPSULE: ItemDefinition = preload("res://content/items/block_capsule.tres")

@export_category("Restriction Messages")
@export var stale_relic_message: String = "No longer available"
@export var removed_piece_message: String = "Already removed"
@export var absent_piece_message: String = "Shape not in Block pile"
@export var minimum_piece_pool_message: String = "Minimum Block pile size"

func generate_shop(seed_value: int, route_node: RouteNodeState, run_state: RunState, relic_pool: Array[RelicDefinition]) -> ShopState:
	var state: ShopState = ShopState.new()
	state.route_node = route_node
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value ^ _route_seed(route_node)
	var available: Array[RelicDefinition] = []
	var reward_pool: Array[RelicDefinition] = ContentRegistry.get_reward_pool(run_state)
	for relic: RelicDefinition in relic_pool:
		if relic != null and not relic.elite_defeat_reward_only and reward_pool.has(relic):
			available.append(relic)
	for index: int in mini(3, available.size()):
		var relic: RelicDefinition = available.pop_at(rng.randi_range(0, available.size() - 1))
		var relic_offer: ShopItem = _create_item(relic.display_name, ShopItem.ItemType.RELIC, 25, run_state.starting_modifiers.shop_discount)
		relic_offer.relic = relic
		state.items.append(relic_offer)
	var item_pool: Array[ItemDefinition] = []
	for definition: ItemDefinition in ContentRegistry.items:
		if definition.category != ItemCategory.Value.BONUS_BLOCK and (run_state.player_health < run_state.maximum_health or definition.category != ItemCategory.Value.HEALING_POTION):
			item_pool.append(definition)
	for index: int in mini(2, item_pool.size()):
		var definition: ItemDefinition = item_pool.pop_at(rng.randi_range(0, item_pool.size() - 1))
		var item_offer: ShopItem = _create_item(definition.display_name, ShopItem.ItemType.CONSUMABLE, definition.base_shop_price, run_state.starting_modifiers.shop_discount)
		item_offer.item = definition
		state.items.append(item_offer)
	var bonus_pieces: Array[PieceDefinition] = []
	for piece: PieceDefinition in ContentRegistry.pieces:
		if piece.can_appear_as_bonus_item and (piece.initially_unlocked or run_state.starting_modifiers.unlocked_pieces.has(piece)):
			bonus_pieces.append(piece)
	if not bonus_pieces.is_empty():
		var piece: PieceDefinition = bonus_pieces[rng.randi_range(0, bonus_pieces.size() - 1)]
		var capsule: ShopItem = _create_item("%s Capsule ×%d" % [piece.display_name, piece.bonus_item_charges], ShopItem.ItemType.CONSUMABLE, piece.bonus_item_price, run_state.starting_modifiers.shop_discount)
		capsule.item = BLOCK_CAPSULE
		capsule.piece = piece
		state.items.append(capsule)
	state.items.append(_create_item("Heal 5", ShopItem.ItemType.HEAL, 15, run_state.starting_modifiers.shop_discount))
	var removable: Array[PieceDefinition] = PiecePoolService.new().get_removable_piece_types(run_state)
	if not removable.is_empty():
		var selected_piece: PieceDefinition = removable[rng.randi_range(0, removable.size() - 1)]
		var removal: ShopItem = _create_item("Remove %s" % selected_piece.display_name, ShopItem.ItemType.REMOVE_PIECE, 35, run_state.starting_modifiers.shop_discount)
		removal.piece = selected_piece
		state.items.append(removal)
	return state

func can_purchase(item: ShopItem, run_state: RunState) -> bool:
	return describe_item(item, run_state).can_purchase()

func describe_item(item: ShopItem, run_state: RunState) -> ShopItemViewState:
	var view: ShopItemViewState = ShopItemViewState.new()
	view.item = item
	if item == null:
		view.availability = ShopItemViewState.Availability.UNAVAILABLE
		view.status_text = "Unavailable"
		return view
	_match_item_details(view, run_state)
	if item.purchased:
		view.availability = ShopItemViewState.Availability.PURCHASED
		view.status_text = "Bought"
	elif not view.restriction.is_empty():
		view.availability = ShopItemViewState.Availability.UNAVAILABLE
		view.status_text = view.restriction
	elif run_state.shards < item.final_price:
		view.availability = ShopItemViewState.Availability.UNAFFORDABLE
		view.status_text = "Need %d more Shards" % (item.final_price - run_state.shards)
	else:
		view.availability = ShopItemViewState.Availability.AFFORDABLE
		view.status_text = "Affordable"
	return view

func _match_item_details(view: ShopItemViewState, run_state: RunState) -> void:
	match view.item.type:
		ShopItem.ItemType.RELIC:
			_describe_relic(view, run_state)
		ShopItem.ItemType.CONSUMABLE:
			_describe_consumable(view, run_state)
		ShopItem.ItemType.HEAL:
			view.category = ShopItemViewState.Category.SERVICE
			view.category_name = "Service"
			view.subtype_name = "Restoration"
			view.rarity_name = "Standard"
			view.description = "Repair 5 Core Integrity."
			view.practical_effect = "Heal 5 health."
			view.comparison = "Health after purchase: %d / %d" % [mini(run_state.maximum_health, run_state.player_health + 5), run_state.maximum_health]
			view.short_summary = "Restore 5 health"
			view.accent_color = Color("7fe0ad")
			if run_state.player_health >= run_state.maximum_health:
				view.restriction = "Full HP"
		ShopItem.ItemType.RETIRED:
			view.restriction = "Retired service"
		ShopItem.ItemType.REMOVE_PIECE:
			_describe_piece_removal(view, run_state)
		ShopItem.ItemType.BOARD_PIECE:
			view.restriction = "Upgrade Board offer"

func _describe_relic(view: ShopItemViewState, run_state: RunState) -> void:
	view.category = ShopItemViewState.Category.RELIC
	view.category_name = "Relic"
	view.subtype_name = "Run modifier"
	view.rarity_name = "Relic"
	view.accent_color = Color("63d9ef")
	var relic: RelicDefinition = view.item.relic
	if relic == null:
		view.restriction = "Unknown relic"
		return
	view.description = relic.description
	view.practical_effect = "Gain this relic for the run."
	view.limitations = "Can stack." if relic.repeatable else "Only one per run."
	view.short_summary = relic.description
	view.comparison = "Owned: %d" % run_state.relics.count(relic)
	if run_state.relics.has(relic) and not relic.consumable and not relic.repeatable:
		view.restriction = "Already owned"
	elif not _is_shop_relic_eligible(relic, run_state):
		view.restriction = stale_relic_message

func _describe_consumable(view: ShopItemViewState, run_state: RunState) -> void:
	var definition: ItemDefinition = view.item.item
	if definition == null:
		view.restriction = "Unknown item"
		return
	view.category = ShopItemViewState.Category.BLOCK_CAPSULE if definition.category == ItemCategory.Value.BONUS_BLOCK else ShopItemViewState.Category.POTION
	view.category_name = "Block Capsule" if view.category == ShopItemViewState.Category.BLOCK_CAPSULE else "Field Device"
	view.subtype_name = ItemCategory.display_name(definition.category)
	view.rarity_name = _rarity_name(definition.rarity)
	view.description = definition.description
	view.practical_effect = "Gain %d charge%s." % [definition.charges_per_purchase, "" if definition.charges_per_purchase == 1 else "s"]
	view.limitations = "Stack limit: %d. %s" % [definition.maximum_stack_size + run_state.starting_modifiers.potion_stack_limit_bonus, "Works outside combat." if definition.can_use_outside_combat else "Combat only."]
	view.short_summary = definition.description
	view.accent_color = definition.accent_color
	view.icon = definition.icon
	view.charge_count = definition.charges_per_purchase
	if view.item.piece != null:
		view.piece = view.item.piece
		if view.piece != null:
			view.charge_count = view.piece.bonus_item_charges
			view.practical_effect = "Gain a %s capsule with %d uses." % [view.piece.display_name, view.charge_count]
	var used_slots: int = _used_inventory_slots(run_state.inventory)
	view.comparison = "Inventory after purchase: %d / %d" % [mini(run_state.inventory.capacity, used_slots + 1), run_state.inventory.capacity]
	if not _inventory_can_accept(view.item, definition, run_state):
		view.restriction = "No inventory space"

func _describe_piece_removal(view: ShopItemViewState, run_state: RunState) -> void:
	view.category = ShopItemViewState.Category.SERVICE
	view.category_name = "Service"
	view.subtype_name = "Block pile editing"
	view.rarity_name = "Specialized"
	view.accent_color = Color("a6b5c8")
	view.piece = view.item.piece
	if view.piece == null:
		view.restriction = "No Block available"
		return
	view.description = "Remove every %s piece from this run's Block pile." % view.piece.display_name
	view.practical_effect = "All copies of this shape are disabled for the rest of the run."
	var pool_service: PiecePoolService = PiecePoolService.new()
	var active_copies: int = pool_service.count_enabled_piece_copies(run_state, view.piece)
	view.comparison = "Active copies: %d -> 0" % active_copies
	view.short_summary = "Remove shape from Block pile"
	if run_state.removed_pieces.has(view.piece):
		view.restriction = removed_piece_message
	elif active_copies == 0:
		view.restriction = absent_piece_message
	elif not pool_service.can_remove_piece_type(run_state, view.piece):
		view.restriction = minimum_piece_pool_message

func _inventory_can_accept(item: ShopItem, definition: ItemDefinition, run_state: RunState) -> bool:
	var probe: ItemInventory = ItemInventory.from_save_data(run_state.inventory.to_save_data())
	var stack: ItemStack = ItemStack.new()
	stack.definition = definition
	stack.quantity = definition.charges_per_purchase
	stack.bonus_piece = item.piece
	if item.piece != null:
		var piece: PieceDefinition = item.piece
		stack.quantity = piece.bonus_item_charges if piece != null else definition.charges_per_purchase
	return probe.add(stack, run_state.starting_modifiers.potion_stack_limit_bonus).added

func _used_inventory_slots(inventory: ItemInventory) -> int:
	var used: int = 0
	for stack: ItemStack in inventory.slots:
		used += 1 if stack != null else 0
	return used

func _rarity_name(rarity: ItemRarity.Value) -> String:
	var names: Array[String] = ["Common", "Uncommon", "Rare"]
	return names[int(rarity)]

func _is_shop_relic_eligible(relic: RelicDefinition, run_state: RunState) -> bool:
	return relic != null and not relic.elite_defeat_reward_only and ContentRegistry.get_reward_pool(run_state).has(relic)

func purchase(item: ShopItem, run_state: RunState) -> bool:
	if not can_purchase(item, run_state):
		return false
	if item.type == ShopItem.ItemType.CONSUMABLE:
		var definition: ItemDefinition = item.item
		var stack: ItemStack = ItemStack.new()
		stack.definition = definition
		stack.quantity = definition.charges_per_purchase
		stack.bonus_piece = item.piece
		if item.piece != null:
			var piece: PieceDefinition = item.piece
			stack.quantity = piece.bonus_item_charges if piece != null else definition.charges_per_purchase
		if not run_state.inventory.add(stack, run_state.starting_modifiers.potion_stack_limit_bonus).added:
			return false
	run_state.shards -= item.final_price
	item.purchased = true
	if item.type == ShopItem.ItemType.RELIC:
		var relic: RelicDefinition = item.relic
		if relic != null:
			relic.apply(run_state, "Shop")
			if not SaveService.profile.discovered_relics.has(relic):
				SaveService.profile.discovered_relics.append(relic)
	elif item.type == ShopItem.ItemType.HEAL:
		run_state.heal(5)
	elif item.type == ShopItem.ItemType.REMOVE_PIECE and item.piece != null:
		run_state.remove_piece_from_pool(item.piece)
	if item.type == ShopItem.ItemType.CONSUMABLE:
		SaveService.profile.total_items_purchased += 1
		if not SaveService.profile.discovered_items.has(item.item):
			SaveService.profile.discovered_items.append(item.item)
	if item.type == ShopItem.ItemType.RELIC or item.type == ShopItem.ItemType.CONSUMABLE:
		SaveService.save_profile()
	return true

func _create_item(display_name: String, type: ShopItem.ItemType, price: int, discount: float) -> ShopItem:
	var item: ShopItem = ShopItem.new()
	item.display_name = display_name
	item.type = type
	item.base_price = price
	item.final_price = maxi(1, floori(float(price) * (1.0 - discount)))
	return item

func _route_seed(route_node: RouteNodeState) -> int:
	if route_node == null:
		return 0
	return route_node.act * 73856093 ^ route_node.column * 19349663 ^ route_node.row * 83492791
