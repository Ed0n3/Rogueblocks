class_name RouteNodeState
extends RefCounted

enum NodeType { NORMAL_COMBAT, ELITE_COMBAT, SHOP, EVENT, RECOVERY, CHALLENGE, BOSS }

var act: int = 0
var column: int = 0
var row: int = 0
var type: NodeType = NodeType.NORMAL_COMBAT
var connections: Array[RouteNodeState] = []
var fixed_room: bool = false
var entered: bool = false
var completed: bool = false

func to_save_data(route_nodes: Array[RouteNodeState]) -> Dictionary:
	var connection_indices: Array[int] = []
	for connection: RouteNodeState in connections:
		var index: int = route_nodes.find(connection)
		if index >= 0:
			connection_indices.append(index)
	return {"act": act, "column": column, "row": row, "type": int(type), "connections": connection_indices, "fixed_room": fixed_room, "entered": entered, "completed": completed}

static func from_save_data(data: Dictionary) -> RouteNodeState:
	var node: RouteNodeState = RouteNodeState.new()
	node.act = int(data.get("act", 0))
	node.column = int(data.get("column", 0))
	node.row = int(data.get("row", 0))
	node.type = int(data.get("type", 0)) as NodeType
	node.fixed_room = bool(data.get("fixed_room", false))
	node.entered = bool(data.get("entered", false))
	node.completed = bool(data.get("completed", false))
	return node

func legacy_reference() -> StringName:
	return StringName("a%d_c%d_r%d" % [act, column, row])
