class_name EnemySelectionState
extends RefCounted

var route_node: RouteNodeState
var enemy: EnemyDefinition

func to_save_data(route: GeneratedRoute) -> Dictionary:
	return {"route_node": route.nodes.find(route_node) if route != null else -1, "enemy": ContentReferenceCodec.encode(enemy)}

static func from_save_data(data: Dictionary, route: GeneratedRoute) -> EnemySelectionState:
	var state: EnemySelectionState = EnemySelectionState.new()
	var node_index: int = int(data.get("route_node", -1))
	if route != null and node_index >= 0 and node_index < route.nodes.size():
		state.route_node = route.nodes[node_index]
	elif route != null:
		state.route_node = route._find_legacy_node(StringName(String(data.get("route_node_id", ""))))
	state.enemy = ContentReferenceCodec.decode_legacy(String(data.get("enemy", data.get("enemy_id", ""))), EnemyDefinition, ContentRegistry.catalog) as EnemyDefinition
	return state
