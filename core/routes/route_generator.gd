class_name RouteGenerator
extends RefCounted

var settings: RouteGenerationSettings

func _init(custom_settings: RouteGenerationSettings = null) -> void:
	var source: RouteGenerationSettings = custom_settings
	if source == null:
		source = load("res://content/rules/route_generation_settings.tres") as RouteGenerationSettings
	settings = source.normalized()

func generate(seed_value: int, challenge_unlocked: bool = false, elite_node_bonus: int = 0) -> GeneratedRoute:
	var route: GeneratedRoute = GeneratedRoute.new()
	route.seed_value = seed_value
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value ^ 0x524F5554
	var previous_boss: RouteNodeState
	for act: int in settings.act_count:
		var column_count: int = rng.randi_range(settings.minimum_columns, settings.maximum_columns)
		var lane_counts: Array[int] = []
		_build_structure(rng, column_count, lane_counts)
		var act_columns: Array[Array] = _create_act_columns(route, act, lane_counts, rng, challenge_unlocked)
		_connect_act_columns(act_columns, rng)
		_apply_fixed_rooms(act_columns, act, rng)
		_ensure_shop_nodes(act_columns, rng)
		_ensure_recovery_nodes(act_columns, rng)
		_spread_special_rooms(act_columns)
		_avoid_connected_danger_repeats(act_columns)
		var first_column: Array = act_columns[0]
		if previous_boss != null:
			for first_value: Variant in first_column:
				_append_connection(previous_boss, first_value as RouteNodeState)
		var boss_column: Array = act_columns.back()
		previous_boss = boss_column[0] as RouteNodeState
	_rebalance_elite_nodes(route, rng, maxi(0, elite_node_bonus))
	return route

func _create_act_columns(
	route: GeneratedRoute,
	act: int,
	lane_counts: Array[int],
	rng: RandomNumberGenerator,
	challenge_unlocked: bool
) -> Array[Array]:
	var act_columns: Array[Array] = []
	for column: int in lane_counts.size():
		var column_nodes: Array[RouteNodeState] = []
		for row: int in lane_counts[column]:
			var node: RouteNodeState = RouteNodeState.new()
			node.act = act
			node.column = column
			node.row = row
			node.type = (
				RouteNodeState.NodeType.BOSS
				if column == lane_counts.size() - 1
				else _pick_type(rng, column, challenge_unlocked)
			)
			column_nodes.append(node)
			route.nodes.append(node)
		act_columns.append(column_nodes)
	return act_columns

func _build_structure(rng: RandomNumberGenerator, column_count: int, lane_counts: Array[int]) -> void:
	var playable_column_count: int = maxi(1, column_count - 1)
	var column: int = 0
	var previous_lanes: int = 0
	while column < playable_column_count:
		var remaining: int = playable_column_count - column
		var corridor_length: int = mini(
			remaining,
			rng.randi_range(settings.minimum_corridor_length, settings.maximum_corridor_length)
		)
		var lanes: int = _next_lane_count(previous_lanes, rng)
		for offset: int in corridor_length:
			lane_counts.append(lanes)
		column += corridor_length
		previous_lanes = lanes
	lane_counts.append(1)

func _next_lane_count(previous_lanes: int, rng: RandomNumberGenerator) -> int:
	if previous_lanes <= 0 or settings.minimum_rows == settings.maximum_rows:
		return rng.randi_range(settings.minimum_rows, settings.maximum_rows)
	var direction: int = -1 if rng.randi_range(0, 1) == 0 else 1
	var candidate: int = previous_lanes + direction
	if candidate < settings.minimum_rows or candidate > settings.maximum_rows:
		candidate = previous_lanes - direction
	return clampi(candidate, settings.minimum_rows, settings.maximum_rows)

func _connect_act_columns(act_columns: Array[Array], rng: RandomNumberGenerator) -> void:
	for column: int in act_columns.size() - 1:
		var source_nodes: Array = act_columns[column]
		var target_nodes: Array = act_columns[column + 1]
		if column + 1 == act_columns.size() - 1:
			_connect_all_to_boss(source_nodes, target_nodes[0] as RouteNodeState)
		else:
			_connect_ordered(source_nodes, target_nodes, rng)

func _connect_ordered(source_nodes: Array, target_nodes: Array, rng: RandomNumberGenerator) -> void:
	for source_index: int in source_nodes.size():
		var target_index: int = _mapped_index(source_index, source_nodes.size(), target_nodes.size())
		_append_connection(source_nodes[source_index] as RouteNodeState, target_nodes[target_index] as RouteNodeState)
	for target_index: int in target_nodes.size():
		var source_index: int = _mapped_index(target_index, target_nodes.size(), source_nodes.size())
		_append_connection(source_nodes[source_index] as RouteNodeState, target_nodes[target_index] as RouteNodeState)
	for source_index: int in source_nodes.size():
		if target_nodes.size() <= 1 or rng.randf() > settings.branch_probability:
			continue
		var primary_target: int = _mapped_index(source_index, source_nodes.size(), target_nodes.size())
		var candidates: Array[int] = []
		if primary_target > 0:
			candidates.append(primary_target - 1)
		if primary_target + 1 < target_nodes.size():
			candidates.append(primary_target + 1)
		if candidates.size() > 1 and rng.randi_range(0, 1) == 1:
			candidates.reverse()
		for candidate: int in candidates:
			if _can_add_ordered_connection(source_nodes, source_index, candidate):
				_append_connection(source_nodes[source_index] as RouteNodeState, target_nodes[candidate] as RouteNodeState)
				break

func _can_add_ordered_connection(source_nodes: Array, source_index: int, target_row: int) -> bool:
	for other_index: int in source_nodes.size():
		if other_index == source_index:
			continue
		var other_source: RouteNodeState = source_nodes[other_index] as RouteNodeState
		for connection: RouteNodeState in other_source.connections:
			if other_index < source_index and connection.row > target_row:
				return false
			if other_index > source_index and connection.row < target_row:
				return false
	return true

func _connect_all_to_boss(source_nodes: Array, boss: RouteNodeState) -> void:
	for source_value: Variant in source_nodes:
		_append_connection(source_value as RouteNodeState, boss)

func _apply_fixed_rooms(act_columns: Array[Array], act: int, rng: RandomNumberGenerator) -> void:
	for rule: RouteFixedRoomRule in settings.fixed_rooms:
		if rule == null or not rule.applies_to(act, act_columns.size()):
			continue
		var column_nodes: Array = act_columns[rule.column_index]
		for row: int in rule.selected_rows(column_nodes.size(), rng):
			var node: RouteNodeState = column_nodes[row] as RouteNodeState
			node.type = rule.room_type
			node.fixed_room = true

func _ensure_shop_nodes(act_columns: Array[Array], rng: RandomNumberGenerator) -> void:
	var shops: Array[RouteNodeState] = []
	var removable_shops: Array[RouteNodeState] = []
	for column_nodes: Array in act_columns:
		for node_value: Variant in column_nodes:
			var node: RouteNodeState = node_value as RouteNodeState
			if node.type == RouteNodeState.NodeType.SHOP:
				shops.append(node)
				if not node.fixed_room:
					removable_shops.append(node)
	while shops.size() > settings.maximum_shop_nodes_per_act and not removable_shops.is_empty():
		var removed: RouteNodeState = removable_shops.pop_at(rng.randi_range(0, removable_shops.size() - 1))
		removed.type = RouteNodeState.NodeType.NORMAL_COMBAT
		shops.erase(removed)
	var target_count: int = mini(
		settings.maximum_shop_nodes_per_act,
		maxi(settings.minimum_shop_nodes_per_act, shops.size())
	)
	var candidates: Array[RouteNodeState] = _shop_candidates(act_columns)
	while shops.size() < target_count and not candidates.is_empty():
		var selected: RouteNodeState = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
		selected.type = RouteNodeState.NodeType.SHOP
		shops.append(selected)

func _shop_candidates(act_columns: Array[Array]) -> Array[RouteNodeState]:
	var candidates: Array[RouteNodeState] = []
	var earliest: int = clampi(settings.earliest_shop_column, 1, act_columns.size() - 2)
	var latest: int = clampi(
		act_columns.size() - 1 - settings.shop_distance_from_boss,
		earliest,
		act_columns.size() - 2
	)
	for column: int in range(earliest, latest + 1):
		var column_nodes: Array = act_columns[column]
		for node_value: Variant in column_nodes:
			var node: RouteNodeState = node_value as RouteNodeState
			if (
				not node.fixed_room
				and node.type != RouteNodeState.NodeType.SHOP
				and node.type != RouteNodeState.NodeType.RECOVERY
			):
				candidates.append(node)
	return candidates

func _ensure_recovery_nodes(act_columns: Array[Array], rng: RandomNumberGenerator) -> void:
	var recoveries: Array[RouteNodeState] = []
	var removable_recoveries: Array[RouteNodeState] = []
	var candidates: Array[RouteNodeState] = []
	var earliest_column: int = settings.earliest_recovery_stage - 1
	for column_nodes: Array in act_columns:
		for node_value: Variant in column_nodes:
			var node: RouteNodeState = node_value as RouteNodeState
			if node.type == RouteNodeState.NodeType.RECOVERY:
				recoveries.append(node)
				if not node.fixed_room:
					removable_recoveries.append(node)
			elif (
				node.column >= earliest_column
				and not node.fixed_room
				and node.type != RouteNodeState.NodeType.SHOP
				and node.type != RouteNodeState.NodeType.BOSS
			):
				candidates.append(node)
	while recoveries.size() > settings.maximum_recovery_nodes_per_act and not removable_recoveries.is_empty():
		var excess: RouteNodeState = removable_recoveries.pop_at(rng.randi_range(0, removable_recoveries.size() - 1))
		excess.type = RouteNodeState.NodeType.NORMAL_COMBAT
		recoveries.erase(excess)
		candidates.append(excess)
	while recoveries.size() < settings.minimum_recovery_nodes_per_act and not candidates.is_empty():
		var selected: RouteNodeState = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
		selected.type = RouteNodeState.NodeType.RECOVERY
		recoveries.append(selected)

func _spread_special_rooms(act_columns: Array[Array]) -> void:
	for column_nodes: Array in act_columns:
		var seen_types: Array[RouteNodeState.NodeType] = []
		for node_value: Variant in column_nodes:
			var node: RouteNodeState = node_value as RouteNodeState
			if not _is_repeat_sensitive(node.type):
				continue
			if seen_types.has(node.type) and not node.fixed_room:
				node.type = RouteNodeState.NodeType.NORMAL_COMBAT
			else:
				seen_types.append(node.type)

func _avoid_connected_danger_repeats(act_columns: Array[Array]) -> void:
	for column: int in range(1, act_columns.size() - 1):
		var source_nodes: Array = act_columns[column - 1]
		var target_nodes: Array = act_columns[column]
		for target_value: Variant in target_nodes:
			var target: RouteNodeState = target_value as RouteNodeState
			if target.fixed_room or not _is_repeat_sensitive(target.type):
				continue
			for source_value: Variant in source_nodes:
				var source: RouteNodeState = source_value as RouteNodeState
				if source.connections.has(target) and source.type == target.type:
					target.type = RouteNodeState.NodeType.NORMAL_COMBAT
					break

func _is_repeat_sensitive(node_type: RouteNodeState.NodeType) -> bool:
	return (
		node_type == RouteNodeState.NodeType.ELITE_COMBAT
		or node_type == RouteNodeState.NodeType.EVENT
		or node_type == RouteNodeState.NodeType.CHALLENGE
	)

func _rebalance_elite_nodes(route: GeneratedRoute, rng: RandomNumberGenerator, elite_node_bonus: int) -> void:
	var elite_nodes: Array[RouteNodeState] = []
	var removable_elites: Array[RouteNodeState] = []
	var candidates: Array[RouteNodeState] = []
	var fixed_elite_count: int = 0
	for node: RouteNodeState in route.nodes:
		if node.type == RouteNodeState.NodeType.ELITE_COMBAT or node.type == RouteNodeState.NodeType.CHALLENGE:
			elite_nodes.append(node)
			if node.fixed_room:
				fixed_elite_count += 1
			else:
				removable_elites.append(node)
		elif (
			node.type == RouteNodeState.NodeType.NORMAL_COMBAT
			and not node.fixed_room
			and node.column >= settings.earliest_dangerous_stage - 1
		):
			candidates.append(node)
	var baseline_count: int = maxi(
		fixed_elite_count,
		clampi(
			elite_nodes.size(),
			settings.minimum_elite_nodes_per_route,
			settings.maximum_elite_nodes_per_route
		)
	)
	while elite_nodes.size() > baseline_count and not removable_elites.is_empty():
		var removed: RouteNodeState = removable_elites.pop_at(rng.randi_range(0, removable_elites.size() - 1))
		removed.type = RouteNodeState.NodeType.NORMAL_COMBAT
		elite_nodes.erase(removed)
		candidates.append(removed)
	while elite_nodes.size() < baseline_count and not candidates.is_empty():
		var required: RouteNodeState = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
		required.type = RouteNodeState.NodeType.ELITE_COMBAT
		elite_nodes.append(required)
	var target_count: int = mini(
		settings.maximum_elite_nodes_per_route + elite_node_bonus,
		baseline_count + elite_node_bonus
	)
	while elite_nodes.size() < target_count and not candidates.is_empty():
		var promoted: RouteNodeState = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
		promoted.type = RouteNodeState.NodeType.ELITE_COMBAT
		elite_nodes.append(promoted)

func _pick_type(
	rng: RandomNumberGenerator,
	column: int,
	challenge_unlocked: bool
) -> RouteNodeState.NodeType:
	if column == 0:
		return RouteNodeState.NodeType.NORMAL_COMBAT
	var types: Array[RouteNodeState.NodeType] = [
		RouteNodeState.NodeType.NORMAL_COMBAT,
		RouteNodeState.NodeType.NORMAL_COMBAT,
		RouteNodeState.NodeType.NORMAL_COMBAT,
		RouteNodeState.NodeType.EVENT,
	]
	if column >= settings.earliest_recovery_stage - 1:
		types.append(RouteNodeState.NodeType.RECOVERY)
	if column >= settings.earliest_dangerous_stage - 1:
		types.append(RouteNodeState.NodeType.ELITE_COMBAT)
		if challenge_unlocked:
			types.append(RouteNodeState.NodeType.CHALLENGE)
	return types[rng.randi_range(0, types.size() - 1)]

func _mapped_index(index: int, source_count: int, target_count: int) -> int:
	if source_count <= 1 or target_count <= 1:
		return 0
	return clampi(
		roundi(float(index) * float(target_count - 1) / float(source_count - 1)),
		0,
		target_count - 1
	)

func _append_connection(source: RouteNodeState, target: RouteNodeState) -> void:
	if source != null and target != null and not source.connections.has(target):
		source.connections.append(target)
