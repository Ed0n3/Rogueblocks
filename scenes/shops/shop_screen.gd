class_name ShopScreen
extends Control

signal left_shop()
signal shop_changed()

const CARD_SCENE: PackedScene = preload("res://presentation/cards/shop_item_card.tscn")

@export var touch_scroll_direction_threshold: float = 12.0

var run_state: RunState
var state: ShopState
var service: ShopService = ShopService.new()
var selected_item: ShopItem
var cards: Array[ShopItemCard] = []
var scroll_touch_index: int = -1
var scroll_touch_start: Vector2
var scroll_touch_vertical: bool = false

func start(current_run: RunState, shop_state: ShopState) -> void:
	run_state = current_run
	state = shop_state
	if not %Leave.pressed.is_connected(_leave):
		%Leave.pressed.connect(_leave)
	if not %Buy.pressed.is_connected(_purchase_selected):
		%Buy.pressed.connect(_purchase_selected)
	_refresh()
	TutorialService.enter_screen(TutorialScreen.Value.SHOP, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.SHOP_OFFER_GRID, %Scroll, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.SHOP_DETAIL_PANEL, $Margin/Layout/Content/DetailPanel, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.SHOP_BUY_BUTTON, %Buy, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.SHOP_SHARDS, %Shards, self)
	TutorialService.publish(TutorialEventId.Value.SHOP_SCREEN_OPENED)
	tree_exiting.connect(_unregister_tutorial_targets, CONNECT_ONE_SHOT)

func _refresh() -> void:
	_refresh_status()
	_clear_inventory()
	for item: ShopItem in state.items:
		var view: ShopItemViewState = service.describe_item(item, run_state)
		var card: ShopItemCard = CARD_SCENE.instantiate() as ShopItemCard
		card.setup(view)
		card.preview_requested.connect(_preview_item)
		card.pressed.connect(_select_item.bind(item))
		_grid_for(view.category).add_child(card)
		cards.append(card)
		MotionPresets.pop_in(card, 0.035 * float(cards.size() - 1), MotionSettings.from_saved_settings(SaveService.settings))
	_refresh_category_visibility()
	if selected_item == null or not state.items.has(selected_item):
		selected_item = _first_available_item()
	_update_selection()
	if not cards.is_empty() and is_inside_tree():
		cards[0].grab_focus()

func _refresh_status() -> void:
	var used_slots: int = 0
	for stack: ItemStack in run_state.inventory.slots:
		used_slots += 1 if stack != null else 0
	%Shards.text = "SHARDS  %d" % run_state.shards
	%Health.text = "HEALTH  %d / %d" % [run_state.player_health, run_state.maximum_health]
	%Inventory.text = "ITEMS  %d / %d" % [used_slots, run_state.inventory.capacity]
	%Relics.text = "RELICS  %d" % run_state.relics.size()

func _clear_inventory() -> void:
	cards.clear()
	for grid: GridContainer in [%RelicGrid, %PotionGrid, %CapsuleGrid, %ServiceGrid]:
		for child: Node in grid.get_children():
			grid.remove_child(child)
			child.queue_free()

func _grid_for(category: ShopItemViewState.Category) -> GridContainer:
	match category:
		ShopItemViewState.Category.RELIC:
			return %RelicGrid
		ShopItemViewState.Category.POTION:
			return %PotionGrid
		ShopItemViewState.Category.BLOCK_CAPSULE:
			return %CapsuleGrid
		_:
			return %ServiceGrid

func _refresh_category_visibility() -> void:
	%RelicHeader.visible = %RelicGrid.get_child_count() > 0
	%RelicGrid.visible = %RelicHeader.visible
	%PotionHeader.visible = %PotionGrid.get_child_count() > 0
	%PotionGrid.visible = %PotionHeader.visible
	%CapsuleHeader.visible = %CapsuleGrid.get_child_count() > 0
	%CapsuleGrid.visible = %CapsuleHeader.visible
	%ServiceHeader.visible = %ServiceGrid.get_child_count() > 0
	%ServiceGrid.visible = %ServiceHeader.visible

func _first_available_item() -> ShopItem:
	for item: ShopItem in state.items:
		if not item.purchased:
			return item
	return state.items[0] if not state.items.is_empty() else null

func _preview_item(item: ShopItem) -> void:
	_update_detail(service.describe_item(item, run_state), item == selected_item)

func _select_item(item: ShopItem) -> void:
	selected_item = item
	_update_selection()
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.SHOP_OFFER_SELECTED)
	event.item = item.item
	event.relic = item.relic
	event.piece = item.piece
	event.int_value = item.final_price
	TutorialService.publish_event(event)

func _update_selection() -> void:
	for card: ShopItemCard in cards:
		card.selected = card.view_state.item == selected_item
	if selected_item == null:
		_show_empty_detail()
	else:
		_update_detail(service.describe_item(selected_item, run_state), true)

func _update_detail(view: ShopItemViewState, is_selected: bool) -> void:
	%DetailIcon.setup(view)
	%ItemName.text = view.item.display_name
	%Category.text = "%s  /  %s" % [view.category_name.to_upper(), view.subtype_name.to_upper()]
	%Price.text = "%d SHARDS" % view.item.final_price
	%Rarity.text = view.rarity_name.to_upper()
	%Description.text = view.description
	%PracticalEffect.text = view.practical_effect
	%Limitations.text = view.limitations
	%Limitations.visible = not view.limitations.is_empty()
	%Comparison.text = view.comparison
	%Comparison.visible = not view.comparison.is_empty()
	%PurchaseStatus.text = view.status_text.to_upper()
	%PurchaseStatus.add_theme_color_override("font_color", _status_color(view.availability))
	%Buy.disabled = not view.can_purchase() or not is_selected
	%Buy.tooltip_text = _buy_text(view, is_selected)

func _show_empty_detail() -> void:
	%ItemName.text = "NO STOCK"
	%Category.text = "NO OFFERS"
	%Price.text = ""
	%Rarity.text = ""
	%Description.text = "The exchange is empty."
	%PracticalEffect.text = ""
	%Limitations.text = ""
	%Comparison.text = ""
	%PurchaseStatus.text = ""
	%Buy.disabled = true
	%Buy.tooltip_text = "Unavailable"

func _buy_text(view: ShopItemViewState, is_selected: bool) -> String:
	if not is_selected:
		return "SELECT TO BUY"
	match view.availability:
		ShopItemViewState.Availability.AFFORDABLE:
			return "BUY FOR %d SHARDS" % view.item.final_price
		ShopItemViewState.Availability.UNAFFORDABLE:
			return "NOT ENOUGH SHARDS"
		ShopItemViewState.Availability.PURCHASED:
			return "BOUGHT"
		_:
			return "UNAVAILABLE"

func _status_color(availability: ShopItemViewState.Availability) -> Color:
	match availability:
		ShopItemViewState.Availability.AFFORDABLE:
			return Color("82e6c6")
		ShopItemViewState.Availability.UNAFFORDABLE:
			return Color("e98a72")
		ShopItemViewState.Availability.UNAVAILABLE:
			return Color("e8b965")
		_:
			return Color("8293aa")

func _purchase_selected() -> void:
	if selected_item != null and service.purchase(selected_item, run_state):
		var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.SHOP_PURCHASE_COMPLETED)
		event.item = selected_item.item
		event.relic = selected_item.relic
		event.piece = selected_item.piece
		event.int_value = selected_item.final_price
		TutorialService.publish_event(event)
		if selected_item.type == ShopItem.ItemType.RELIC:
			var relic_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.RELIC_OBTAINED)
			relic_event.relic = selected_item.relic
			TutorialService.publish_event(relic_event)
		elif selected_item.type == ShopItem.ItemType.CONSUMABLE:
			var item_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.ITEM_ACQUIRED)
			item_event.item = selected_item.item
			TutorialService.publish_event(item_event)
			if selected_item.piece != null:
				var bonus_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.BONUS_BLOCK_ACQUIRED)
				bonus_event.piece = selected_item.piece
				TutorialService.publish_event(bonus_event)
		_refresh()
		shop_changed.emit()

func _unregister_tutorial_targets() -> void:
	TutorialService.leave_screen(TutorialScreen.Value.SHOP, self)
	TutorialTargetRegistry.unregister_owner(self)

func _leave() -> void:
	state.left = true
	left_shop.emit()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var scroll: ScrollContainer = %Scroll
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and scroll.get_global_rect().has_point(touch.position):
			scroll_touch_index = touch.index
			scroll_touch_start = touch.position
			scroll_touch_vertical = false
		elif not touch.pressed and touch.index == scroll_touch_index:
			if scroll_touch_vertical:
				get_viewport().set_input_as_handled()
			_clear_scroll_touch()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != scroll_touch_index:
			return
		var movement: Vector2 = drag.position - scroll_touch_start
		if not scroll_touch_vertical and movement.length() >= touch_scroll_direction_threshold:
			if absf(movement.y) <= absf(movement.x):
				_clear_scroll_touch()
				return
			scroll_touch_vertical = true
		if scroll_touch_vertical:
			scroll.scroll_vertical -= roundi(drag.relative.y)
			get_viewport().set_input_as_handled()

func _clear_scroll_touch() -> void:
	scroll_touch_index = -1
	scroll_touch_vertical = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_leave()
		get_viewport().set_input_as_handled()
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.physical_keycode == KEY_W or key_event.physical_keycode == KEY_A:
		_move_card_focus(-1)
	elif key_event.physical_keycode == KEY_S or key_event.physical_keycode == KEY_D:
		_move_card_focus(1)

func _move_card_focus(direction: int) -> void:
	if cards.is_empty():
		return
	var focused: Control = get_viewport().gui_get_focus_owner()
	var current_index: int = cards.find(focused)
	var next_index: int = posmod(current_index + direction, cards.size()) if current_index >= 0 else 0
	cards[next_index].grab_focus()
	_preview_item(cards[next_index].view_state.item)
	get_viewport().set_input_as_handled()
