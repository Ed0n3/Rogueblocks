class_name RouteTreeView
extends Control

signal node_selected(node: RouteNodeState)
signal node_type_info_requested(node_type: RouteNodeState.NodeType, anchor_rect: Rect2)
signal node_type_info_hidden()

const ACTIVE_NODE_SCALE: float = 1.0
const BOSS_NODE_SCALE: float = 1.12
const NODE_PULSE_AMOUNT: float = 0.012
const ANIMATION_SPEED: float = 0.42
const CONNECTION_GLOW_RADIUS: float = 8.0
const CONNECTION_MARKER_RADIUS: float = 3.5
const NO_TOUCH_INDEX: int = -1

## Typed texture set used by symbol-only route nodes.
@export var symbol_set: RouteSymbolSet
## Square touch target used by every normal route node.
@export_range(56.0, 96.0, 1.0) var node_extent: float = 72.0
## Horizontal distance between consecutive route columns.
@export_range(110.0, 240.0, 1.0) var column_spacing: float = 170.0
## Vertical distance between lanes in the same route column.
@export_range(76.0, 160.0, 1.0) var row_spacing: float = 82.0
## Empty space retained around the generated route content.
@export var content_padding: Vector2 = Vector2(54.0, 22.0)
## Smallest map surface used when route content is shorter than the viewport.
@export var minimum_map_size: Vector2 = Vector2(900.0, 340.0)
## Time a route node must be held before its generic room-type information appears.
@export_range(0.1, 2.0, 0.05) var touch_hold_duration: float = 0.55
## Touch movement that cancels a node hold and allows route-map scrolling.
@export_range(1.0, 48.0, 1.0) var touch_hold_deadzone: float = 12.0

var route: GeneratedRoute
var act: int = 0
var available_nodes: Array[RouteNodeState] = []
var node_buttons: Dictionary[RouteNodeState, Button] = {}
var animation_phase: float = 0.0
var column_count: int = 1
var node_size: Vector2 = Vector2(72.0, 72.0)
var touch_hold_index: int = NO_TOUCH_INDEX
var touch_hold_start_position: Vector2 = Vector2.ZERO
var touch_hold_started_msec: int = 0
var touch_hold_node: RouteNodeState
var touch_hold_opened: bool = false

func _process(delta: float) -> void:
	animation_phase = fmod(animation_phase + delta * ANIMATION_SPEED, 1.0)
	for node: RouteNodeState in available_nodes:
		if node.act == act and node_buttons.has(node):
			var button: Button = node_buttons[node]
			var base_scale: float = BOSS_NODE_SCALE if node.type == RouteNodeState.NodeType.BOSS else ACTIVE_NODE_SCALE
			var pulse: float = base_scale + sin(animation_phase * TAU) * NODE_PULSE_AMOUNT
			button.scale = Vector2.ONE * pulse
	_process_touch_hold()
	queue_redraw()

func setup(generated_route: GeneratedRoute, displayed_act: int) -> void:
	cancel_touch_hold()
	route = generated_route
	act = displayed_act
	available_nodes = route.get_available_nodes()
	column_count = maxi(1, route.get_column_count(act))
	node_size = Vector2.ONE * node_extent
	for child: Node in get_children():
		child.queue_free()
	node_buttons.clear()
	_update_content_size()
	for node: RouteNodeState in route.nodes:
		if node.act == act:
			_create_node_button(node)
	_update_layout()
	queue_redraw()
	var preferred: Control = preferred_focus_control()
	if preferred != null:
		preferred.grab_focus()

func preferred_focus_control() -> Control:
	if route != null and route.current_node != null and route.current_node.act == act and node_buttons.has(route.current_node):
		return node_buttons[route.current_node]
	for node: RouteNodeState in available_nodes:
		if node.act == act and node_buttons.has(node):
			return node_buttons[node]
	return null

func _create_node_button(node: RouteNodeState) -> void:
	var button: RouteNodeCard = RouteNodeCard.new()
	var symbol: Texture2D = symbol_set.texture_for(node.type) if symbol_set != null else null
	button.custom_minimum_size = node_size
	button.size = node_size
	button.icon = load("res://assets/icons/empty_texture.tres") as Texture2D
	button.configure_type(node.type, _type_color(node.type).lightened(0.5), symbol)
	button.tooltip_text = symbol_set.tooltip_for(node.type) if symbol_set != null else _type_name(node.type)
	button.disabled = not available_nodes.has(node)
	button.add_theme_stylebox_override("normal", _style_for(node, false))
	button.add_theme_stylebox_override("hover", _style_for(node, true))
	button.add_theme_stylebox_override("pressed", _style_for(node, true))
	button.add_theme_stylebox_override("focus", _style_for(node, true))
	button.add_theme_stylebox_override("disabled", _style_for(node, false))
	button.pivot_offset = node_size * 0.5
	button.modulate = _node_modulate(node)
	if node.type == RouteNodeState.NodeType.BOSS:
		button.scale = Vector2.ONE * BOSS_NODE_SCALE
	button.pressed.connect(_emit_node_selected.bind(node))
	add_child(button)
	node_buttons[node] = button

func _emit_node_selected(node: RouteNodeState) -> void:
	node_selected.emit(node)

func handle_touch(event: InputEventScreenTouch) -> bool:
	if event.pressed:
		if touch_hold_index != NO_TOUCH_INDEX:
			return false
		var node: RouteNodeState = _node_at_global_position(event.position)
		if node == null:
			return false
		touch_hold_index = event.index
		touch_hold_start_position = event.position
		touch_hold_started_msec = Time.get_ticks_msec()
		touch_hold_node = node
		touch_hold_opened = false
		return false
	if event.index != touch_hold_index:
		return false
	var consumed: bool = touch_hold_opened
	cancel_touch_hold()
	return consumed

func handle_touch_drag(event: InputEventScreenDrag) -> void:
	if event.index != touch_hold_index:
		return
	if event.position.distance_to(touch_hold_start_position) >= touch_hold_deadzone:
		cancel_touch_hold()

func cancel_touch_hold() -> void:
	if touch_hold_opened:
		node_type_info_hidden.emit()
	touch_hold_index = NO_TOUCH_INDEX
	touch_hold_start_position = Vector2.ZERO
	touch_hold_started_msec = 0
	touch_hold_node = null
	touch_hold_opened = false

func _process_touch_hold() -> void:
	if touch_hold_index == NO_TOUCH_INDEX or touch_hold_opened or touch_hold_node == null:
		return
	var held_seconds: float = float(Time.get_ticks_msec() - touch_hold_started_msec) / 1000.0
	if held_seconds < touch_hold_duration:
		return
	if not node_buttons.has(touch_hold_node):
		cancel_touch_hold()
		return
	var button: Button = node_buttons[touch_hold_node]
	if not is_instance_valid(button) or not button.is_visible_in_tree():
		cancel_touch_hold()
		return
	touch_hold_opened = true
	node_type_info_requested.emit(touch_hold_node.type, button.get_global_rect())

func _node_at_global_position(global_position: Vector2) -> RouteNodeState:
	for node: RouteNodeState in node_buttons:
		var button: Button = node_buttons[node]
		if is_instance_valid(button) and button.is_visible_in_tree() and button.get_global_rect().has_point(global_position):
			return node
	return null

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_layout()
		queue_redraw()

func _update_content_size() -> void:
	var maximum_lanes: int = 1
	if route != null:
		for column: int in column_count:
			maximum_lanes = maxi(maximum_lanes, route.get_nodes_in_column(act, column).size())
	var route_width: float = (
		content_padding.x * 2.0
		+ node_size.x
		+ column_spacing * float(maxi(0, column_count - 1))
	)
	var route_height: float = (
		content_padding.y * 2.0
		+ node_size.y
		+ row_spacing * float(maxi(0, maximum_lanes - 1))
	)
	custom_minimum_size = Vector2(
		maxf(minimum_map_size.x, route_width),
		maxf(minimum_map_size.y, route_height)
	)

func _update_layout() -> void:
	if route == null or node_buttons.is_empty():
		return
	var drawing_size: Vector2 = _drawing_size()
	for node: RouteNodeState in route.nodes:
		if node.act != act or not node_buttons.has(node):
			continue
		var lanes: int = route.get_nodes_in_column(act, node.column).size()
		var column_height: float = node_size.y + row_spacing * float(maxi(0, lanes - 1))
		var x: float = content_padding.x + column_spacing * float(node.column)
		var y: float = (drawing_size.y - column_height) * 0.5 + row_spacing * float(node.row)
		var button: Button = node_buttons[node]
		button.custom_minimum_size = node_size
		button.size = node_size
		button.pivot_offset = node_size * 0.5
		button.position = Vector2(x, y)

func _drawing_size() -> Vector2:
	return Vector2(
		maxf(size.x, custom_minimum_size.x),
		maxf(size.y, custom_minimum_size.y)
	)

func _draw() -> void:
	if route == null:
		return
	_draw_act_backdrop()
	_draw_column_lanes()
	for source: RouteNodeState in route.nodes:
		if source.act != act or not node_buttons.has(source):
			continue
		for target: RouteNodeState in source.connections:
			if target != null and target.act == act and node_buttons.has(target):
				_draw_connection(source, target)
	_draw_player_marker()

func _draw_act_backdrop() -> void:
	var act_colors: Array[Color] = [
		Color("18314b"),
		Color("302553"),
		Color("4a273d"),
		Color("4d341d"),
	]
	var drawing_size: Vector2 = _drawing_size()
	var act_color: Color = act_colors[clampi(act, 0, act_colors.size() - 1)]
	for ring: int in 5:
		draw_circle(
			Vector2(drawing_size.x * 0.78, drawing_size.y * 0.5),
			260.0 - float(ring) * 42.0,
			Color(act_color, 0.025 + float(ring) * 0.008)
		)
	var boss_center: Vector2 = Vector2(
		content_padding.x + column_spacing * float(maxi(0, column_count - 1)) + node_size.x * 0.5,
		drawing_size.y * 0.5
	)
	var silhouette: PackedVector2Array = PackedVector2Array()
	for index: int in 6:
		silhouette.append(boss_center + Vector2.from_angle(TAU * float(index) / 6.0) * 58.0)
	draw_colored_polygon(silhouette, Color(act_color.lightened(0.35), 0.055))

func _draw_column_lanes() -> void:
	var drawing_size: Vector2 = _drawing_size()
	for column: int in column_count:
		var center_x: float = content_padding.x + node_size.x * 0.5 + column_spacing * float(column)
		draw_line(
			Vector2(center_x, content_padding.y * 0.5),
			Vector2(center_x, drawing_size.y - content_padding.y * 0.5),
			Color(0.12, 0.23, 0.32, 0.38),
			1.0
		)

func _draw_connection(source: RouteNodeState, target: RouteNodeState) -> void:
	var source_button: Button = node_buttons[source]
	var target_button: Button = node_buttons[target]
	var start: Vector2 = source_button.position + Vector2(source_button.size.x, source_button.size.y * 0.5)
	var finish: Vector2 = target_button.position + Vector2(0.0, target_button.size.y * 0.5)
	var curve: Curve2D = Curve2D.new()
	var handle: float = minf(54.0, maxf(16.0, (finish.x - start.x) * 0.38))
	curve.add_point(start, Vector2.ZERO, Vector2(handle, 0.0))
	curve.add_point(finish, Vector2(-handle, 0.0), Vector2.ZERO)
	var active_connection: bool = source.completed and available_nodes.has(target)
	var traversed: bool = source.entered and target.entered
	var color: Color = (
		Color("69e0c2")
		if active_connection
		else (Color("438d7d") if traversed else Color(0.2, 0.32, 0.42, 0.7))
	)
	var width: float = 4.0 if active_connection else 2.0
	draw_polyline(curve.tessellate(5, 2.0), color, width, true)
	if active_connection:
		var glow_position: Vector2 = curve.sample_baked(curve.get_baked_length() * animation_phase)
		draw_circle(glow_position, CONNECTION_GLOW_RADIUS, Color(color, 0.12))
		draw_circle(glow_position, CONNECTION_MARKER_RADIUS, color)

func _draw_player_marker() -> void:
	for node: RouteNodeState in route.nodes:
		if node.act != act or not node.entered or node.completed or not node_buttons.has(node):
			continue
		var button: Button = node_buttons[node]
		var center: Vector2 = button.position + Vector2(button.size.x * 0.5, -14.0)
		var bob: float = sin(animation_phase * TAU) * 3.0
		var points: PackedVector2Array = PackedVector2Array([
			center + Vector2(0.0, -8.0 + bob),
			center + Vector2(7.0, bob),
			center + Vector2(0.0, 8.0 + bob),
			center + Vector2(-7.0, bob),
		])
		draw_colored_polygon(points, Color("f1c75b"))

func _style_for(node: RouteNodeState, highlighted: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var base: Color = _type_color(node.type)
	if node.completed:
		base = Color("22594e")
	elif node.entered:
		base = Color("6b5225")
	elif not available_nodes.has(node):
		base = Color("101a27")
	style.bg_color = Color(base.lightened(0.1) if highlighted else base, 0.82)
	style.border_color = Color("8fffe2") if available_nodes.has(node) else base.lightened(0.28)
	style.set_border_width_all(3 if available_nodes.has(node) else 1)
	style.set_corner_radius_all(roundi(node_size.x * 0.5))
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 8 if available_nodes.has(node) else 3
	return style

func _type_color(node_type: RouteNodeState.NodeType) -> Color:
	match node_type:
		RouteNodeState.NodeType.NORMAL_COMBAT:
			return Color("174452")
		RouteNodeState.NodeType.ELITE_COMBAT:
			return Color("66384b")
		RouteNodeState.NodeType.SHOP:
			return Color("16584f")
		RouteNodeState.NodeType.EVENT:
			return Color("493f72")
		RouteNodeState.NodeType.RECOVERY:
			return Color("28543b")
		RouteNodeState.NodeType.CHALLENGE:
			return Color("704a25")
		RouteNodeState.NodeType.BOSS:
			return Color("712f35")
	return Color("174452")

func _node_modulate(node: RouteNodeState) -> Color:
	if available_nodes.has(node):
		return Color.WHITE
	if node.completed:
		return Color(0.68, 0.88, 0.8, 0.82)
	if node.entered:
		return Color(1.0, 0.84, 0.5, 0.9)
	return Color(0.68, 0.74, 0.84, 0.82)

func _type_name(node_type: RouteNodeState.NodeType) -> String:
	return RouteNodeState.NodeType.keys()[int(node_type)].capitalize().replace("_", " ")
