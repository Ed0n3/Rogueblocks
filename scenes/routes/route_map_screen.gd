class_name RouteMapScreen
extends Control

signal node_selected(node: RouteNodeState)
signal hub_requested()

const NO_TOUCH_INDEX: int = -1

## Touch movement required before a route-map gesture becomes scrolling instead of a room tap.
@export_range(4.0, 48.0, 1.0) var route_drag_deadzone: float = 12.0
## Preferred width of the generic route-node information panel.
@export_range(280.0, 520.0, 10.0) var node_info_width: float = 380.0
## Space between a held route node and its information panel.
@export_range(0.0, 48.0, 1.0) var node_info_gap: float = 10.0
## Minimum distance retained between the node information panel and the map edges.
@export_range(0.0, 48.0, 1.0) var node_info_edge_margin: float = 12.0

var run_state: RunState
var route_scroll_touch_index: int = NO_TOUCH_INDEX
var route_scroll_start_position: Vector2 = Vector2.ZERO
var route_scroll_start_offset: Vector2i = Vector2i.ZERO
var route_scroll_dragging: bool = false

func start(current_run: RunState) -> void:
	run_state = current_run
	_cancel_node_type_info()
	var current_act: int = _current_act()
	var act_count: int = run_state.route.get_act_count()
	%Header.text = "ROUTE  |  ACT %d" % (current_act + 1)
	%ActProgress.text = "ACT %d OF %d" % [current_act + 1, act_count]
	%HealthBar.max_value = run_state.maximum_health
	%HealthBar.value = run_state.player_health
	%Health.text = "%d / %d" % [run_state.player_health, run_state.maximum_health]
	%Shards.text = "SHARDS  %d" % run_state.shards
	%Score.text = "SCORE  %d" % run_state.score
	_refresh_loadout_counts()
	%Resources.text = "CLEAR %d   RESERVE %d   REROLL %d" % [run_state.emergency_clear_charges, run_state.last_reserve_charges, run_state.reward_rerolls]
	if not %Back.pressed.is_connected(_request_hub):
		%Back.pressed.connect(_request_hub)
	if not %RouteTree.node_selected.is_connected(_select_node):
		%RouteTree.node_selected.connect(_select_node)
	if not %RouteTree.node_type_info_requested.is_connected(_show_node_type_info):
		%RouteTree.node_type_info_requested.connect(_show_node_type_info)
	if not %RouteTree.node_type_info_hidden.is_connected(_hide_node_type_info):
		%RouteTree.node_type_info_hidden.connect(_hide_node_type_info)
	if not %Pieces.pressed.is_connected(_open_pieces):
		%Pieces.pressed.connect(_open_pieces)
	if not %Relics.pressed.is_connected(_open_relics):
		%Relics.pressed.connect(_open_relics)
	if not %Artifacts.pressed.is_connected(_open_artifacts):
		%Artifacts.pressed.connect(_open_artifacts)
	if not run_state.piece_pool_changed.is_connected(_refresh_loadout_counts):
		run_state.piece_pool_changed.connect(_refresh_loadout_counts)
	if not run_state.relics_changed.is_connected(_refresh_loadout_counts):
		run_state.relics_changed.connect(_refresh_loadout_counts)
	if not run_state.run_modifiers_changed.is_connected(_refresh_loadout_counts):
		run_state.run_modifiers_changed.connect(_refresh_loadout_counts)
	if not run_state.artifacts_changed.is_connected(_refresh_loadout_counts):
		run_state.artifacts_changed.connect(_refresh_loadout_counts)
	%RouteTree.setup(run_state.route, current_act)
	call_deferred("_reveal_preferred_route_node")
	%LoadoutDrawer.setup(run_state)
	TutorialService.enter_screen(TutorialScreen.Value.ROUTE, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.ROUTE_AVAILABLE_NODE, %RouteTree, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.ROUTE_PIECE_POOL_BUTTON, %Pieces, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.ROUTE_RELIC_BUTTON, %Relics, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.ROUTE_SHARDS, %Shards, self)
	TutorialService.publish(TutorialEventId.Value.ROUTE_SCREEN_OPENED)
	tree_exiting.connect(_unregister_tutorial_targets, CONNECT_ONE_SHOT)

func _refresh_loadout_counts() -> void:
	var enabled_piece_count: int = 0
	for entry: PiecePoolEntry in run_state.get_current_piece_pool():
		if entry.is_enabled:
			enabled_piece_count += 1
	(%Pieces as LoadoutCounterButton).set_count("%d/%d" % [enabled_piece_count, run_state.maximum_active_piece_pool_size])
	(%Relics as LoadoutCounterButton).set_count(str(run_state.relics.size()))
	(%Artifacts as LoadoutCounterButton).set_count(str(run_state.artifacts.size()))

func _open_pieces() -> void:
	_cancel_node_type_info()
	%LoadoutDrawer.open_tab(RunLoadoutDrawer.Tab.PIECES)

func _open_relics() -> void:
	_cancel_node_type_info()
	%LoadoutDrawer.open_tab(RunLoadoutDrawer.Tab.RELICS)

func _open_artifacts() -> void:
	_cancel_node_type_info()
	%LoadoutDrawer.open_tab(RunLoadoutDrawer.Tab.ARTIFACTS)

func _request_hub() -> void:
	_cancel_node_type_info()
	hub_requested.emit()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var touch: InputEventScreenTouch = event as InputEventScreenTouch
	if touch != null:
		if touch.pressed and %Back.get_global_rect().has_point(touch.position):
			_cancel_node_type_info()
			hub_requested.emit()
			get_viewport().set_input_as_handled()
			return
		var node_info_consumed: bool = _handle_node_type_info_touch(touch)
		_handle_route_scroll_touch(touch)
		if node_info_consumed:
			get_viewport().set_input_as_handled()
		return
	var drag: InputEventScreenDrag = event as InputEventScreenDrag
	if drag != null:
		%RouteTree.handle_touch_drag(drag)
		_handle_route_scroll_drag(drag)

func _handle_node_type_info_touch(event: InputEventScreenTouch) -> bool:
	if event.pressed:
		var route_scroll: ScrollContainer = %RouteScroll
		if %LoadoutDrawer.visible or not route_scroll.get_global_rect().has_point(event.position):
			%RouteTree.cancel_touch_hold()
			return false
	return %RouteTree.handle_touch(event)

func _handle_route_scroll_touch(event: InputEventScreenTouch) -> void:
	var scroll: ScrollContainer = %RouteScroll
	if event.pressed:
		if scroll.get_global_rect().has_point(event.position):
			route_scroll_touch_index = event.index
			route_scroll_start_position = event.position
			route_scroll_start_offset = Vector2i(scroll.scroll_horizontal, scroll.scroll_vertical)
			route_scroll_dragging = false
		return
	if event.index != route_scroll_touch_index:
		return
	if route_scroll_dragging:
		get_viewport().set_input_as_handled()
	_reset_route_scroll_touch()

func _handle_route_scroll_drag(event: InputEventScreenDrag) -> void:
	if event.index != route_scroll_touch_index:
		return
	var displacement: Vector2 = event.position - route_scroll_start_position
	if not route_scroll_dragging and displacement.length() < route_drag_deadzone:
		return
	route_scroll_dragging = true
	var scroll: ScrollContainer = %RouteScroll
	scroll.scroll_horizontal = route_scroll_start_offset.x - roundi(displacement.x)
	scroll.scroll_vertical = route_scroll_start_offset.y - roundi(displacement.y)
	get_viewport().set_input_as_handled()

func _reset_route_scroll_touch() -> void:
	route_scroll_touch_index = NO_TOUCH_INDEX
	route_scroll_start_position = Vector2.ZERO
	route_scroll_start_offset = Vector2i.ZERO
	route_scroll_dragging = false

func _show_node_type_info(node_type: RouteNodeState.NodeType, anchor_global_rect: Rect2) -> void:
	var presentation: RouteSymbolSet = %RouteTree.symbol_set
	if presentation == null:
		return
	var info_panel: PanelContainer = %NodeTypeInfo
	var map_layer: Control = $Margin/Layout/Panel/MapLayer as Control
	%NodeTypeInfoIcon.texture = presentation.texture_for(node_type)
	%NodeTypeInfoTitle.text = presentation.title_for(node_type)
	%NodeTypeInfoDescription.text = presentation.description_for(node_type)
	info_panel.custom_minimum_size.x = minf(
		node_info_width,
		maxf(0.0, map_layer.size.x - node_info_edge_margin * 2.0)
	)
	info_panel.visible = true
	info_panel.reset_size()
	var info_size: Vector2 = info_panel.get_combined_minimum_size()
	info_panel.size = info_size
	var map_global_rect: Rect2 = map_layer.get_global_rect()
	var anchor_rect: Rect2 = Rect2(anchor_global_rect.position - map_global_rect.position, anchor_global_rect.size)
	var target_x: float = clampf(
		anchor_rect.get_center().x - info_size.x * 0.5,
		node_info_edge_margin,
		maxf(node_info_edge_margin, map_layer.size.x - info_size.x - node_info_edge_margin)
	)
	var target_y: float = anchor_rect.position.y - info_size.y - node_info_gap
	if target_y < node_info_edge_margin:
		target_y = anchor_rect.end.y + node_info_gap
	target_y = clampf(
		target_y,
		node_info_edge_margin,
		maxf(node_info_edge_margin, map_layer.size.y - info_size.y - node_info_edge_margin)
	)
	info_panel.position = Vector2(target_x, target_y)

func _hide_node_type_info() -> void:
	%NodeTypeInfo.visible = false

func _cancel_node_type_info() -> void:
	%RouteTree.cancel_touch_hold()
	_hide_node_type_info()

func _reveal_preferred_route_node() -> void:
	var preferred: Control = %RouteTree.preferred_focus_control()
	if preferred == null:
		return
	var scroll: ScrollContainer = %RouteScroll
	var preferred_center: Vector2 = preferred.position + preferred.size * 0.5
	scroll.scroll_horizontal = roundi(preferred_center.x - scroll.size.x * 0.5)
	scroll.scroll_vertical = roundi(preferred_center.y - scroll.size.y * 0.5)

func _select_node(node: RouteNodeState) -> void:
	_cancel_node_type_info()
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.ROUTE_NODE_SELECTED)
	event.route_node = node
	TutorialService.publish_event(event)
	node_selected.emit(node)

func _unregister_tutorial_targets() -> void:
	TutorialService.leave_screen(TutorialScreen.Value.ROUTE, self)
	TutorialTargetRegistry.unregister_owner(self)

func _current_act() -> int:
	if run_state.route.current_node == null:
		return 0
	var current: RouteNodeState = run_state.route.current_node
	if current == null:
		return 0
	return mini(run_state.route.get_act_count() - 1, current.act + (1 if current.completed and current.type == RouteNodeState.NodeType.BOSS else 0))
