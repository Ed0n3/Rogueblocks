class_name ShopState
extends RefCounted

var route_node: RouteNodeState
var items: Array[ShopItem] = []
var left: bool = false

func has_only_board_pieces() -> bool:
	if items.is_empty():
		return false
	for item: ShopItem in items:
		if item == null or item.type != ShopItem.ItemType.BOARD_PIECE:
			return false
	return true

func has_board_pieces() -> bool:
	for item: ShopItem in items:
		if item != null and item.type == ShopItem.ItemType.BOARD_PIECE:
			return true
	return false

func to_save_data() -> Dictionary:
	var item_data: Array[Dictionary] = []
	for item: ShopItem in items:
		item_data.append(item.to_save_data())
	return {"route_act": route_node.act if route_node != null else -1, "route_column": route_node.column if route_node != null else -1, "route_row": route_node.row if route_node != null else -1, "items": item_data, "left": left}

static func from_save_data(data: Dictionary, route: GeneratedRoute = null) -> ShopState:
	var state: ShopState = ShopState.new()
	if route != null:
		state.route_node = route.get_node_at(int(data.get("route_act", -1)), int(data.get("route_column", -1)), int(data.get("route_row", -1)))
		if state.route_node == null:
			state.route_node = route._find_legacy_node(StringName(String(data.get("id", ""))))
	state.left = bool(data.get("left", false))
	for value: Variant in data.get("items", []) as Array:
		state.items.append(ShopItem.from_save_data(value as Dictionary))
	return state
