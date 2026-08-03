class_name GeneratedRoute
extends RefCounted

var seed_value: int = 1
var nodes: Array[RouteNodeState] = []
var current_node: RouteNodeState

func get_node_at(act: int, column: int, row: int) -> RouteNodeState:
	for node: RouteNodeState in nodes:
		if node.act == act and node.column == column and node.row == row:
			return node
	return null

func get_nodes_in_column(act: int, column: int) -> Array[RouteNodeState]:
	var result: Array[RouteNodeState] = []
	for node: RouteNodeState in nodes:
		if node.act == act and node.column == column:
			result.append(node)
	result.sort_custom(func(left: RouteNodeState, right: RouteNodeState) -> bool: return left.row < right.row)
	return result

func count_connection_crossings(act: int) -> int:
	var crossing_count: int = 0
	for column: int in maxi(0, get_column_count(act) - 1):
		var sources: Array[RouteNodeState] = get_nodes_in_column(act, column)
		for first_index: int in sources.size():
			for second_index: int in range(first_index + 1, sources.size()):
				var first_source: RouteNodeState = sources[first_index]
				var second_source: RouteNodeState = sources[second_index]
				for first_target: RouteNodeState in first_source.connections:
					if first_target.act != act or first_target.column != column + 1:
						continue
					for second_target: RouteNodeState in second_source.connections:
						if second_target.act == act and second_target.column == column + 1 and first_target.row > second_target.row:
							crossing_count += 1
	return crossing_count

func get_available_nodes() -> Array[RouteNodeState]:
	var result: Array[RouteNodeState] = []
	if current_node == null:
		for node: RouteNodeState in nodes:
			if node.act == 0 and node.column == 0:
				result.append(node)
		return result
	if not current_node.completed:
		return result
	for next: RouteNodeState in current_node.connections:
		if next != null and not next.entered:
			result.append(next)
	return result

func enter_node(node: RouteNodeState) -> bool:
	var available: Array[RouteNodeState] = get_available_nodes()
	if node == null or not available.has(node):
		return false
	node.entered = true
	current_node = node
	return true

func get_act_count() -> int:
	var highest_act: int = -1
	for node: RouteNodeState in nodes:
		highest_act = maxi(highest_act, node.act)
	return highest_act + 1

func get_column_count(act: int) -> int:
	var highest_column: int = -1
	for node: RouteNodeState in nodes:
		if node.act == act:
			highest_column = maxi(highest_column, node.column)
	return highest_column + 1

func get_row_count(act: int) -> int:
	var highest_row: int = -1
	for node: RouteNodeState in nodes:
		if node.act == act:
			highest_row = maxi(highest_row, node.row)
	return highest_row + 1

func to_save_data() -> Dictionary:
	var node_data: Array[Dictionary] = []
	for node: RouteNodeState in nodes:
		node_data.append(node.to_save_data(nodes))
	return {"seed": seed_value, "current_node": nodes.find(current_node), "nodes": node_data}

static func from_save_data(data: Dictionary) -> GeneratedRoute:
	var route: GeneratedRoute = GeneratedRoute.new()
	route.seed_value = int(data.get("seed", 1))
	var saved_nodes: Array = data.get("nodes", []) as Array
	for value: Variant in saved_nodes:
		route.nodes.append(RouteNodeState.from_save_data(value as Dictionary))
	for index: int in mini(saved_nodes.size(), route.nodes.size()):
		var node_data: Dictionary = saved_nodes[index] as Dictionary
		for connection_value: Variant in node_data.get("connections", []) as Array:
			var connection: RouteNodeState
			if connection_value is int or connection_value is float:
				var connection_index: int = int(connection_value)
				connection = route.nodes[connection_index] if connection_index >= 0 and connection_index < route.nodes.size() else null
			elif connection_value is String or connection_value is StringName:
				connection = route._find_legacy_node(StringName(str(connection_value)))
			if connection != null and not route.nodes[index].connections.has(connection):
				route.nodes[index].connections.append(connection)
	var current_index: int = int(data.get("current_node", -1))
	if current_index >= 0 and current_index < route.nodes.size():
		route.current_node = route.nodes[current_index]
	else:
		var legacy_current_node: Variant = data.get("current_node_id", "")
		if legacy_current_node is String or legacy_current_node is StringName:
			route.current_node = route._find_legacy_node(StringName(str(legacy_current_node)))
	return route

func _find_legacy_node(reference: StringName) -> RouteNodeState:
	for node: RouteNodeState in nodes:
		if node.legacy_reference() == reference:
			return node
	return null
