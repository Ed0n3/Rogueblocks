class_name RouteGenerationSettings
extends Resource

## Number of acts generated for a complete route.
@export_range(1, 8) var act_count: int = 4
## Minimum number of room columns generated before each act boss.
@export_range(4, 16) var minimum_columns: int = 8
## Maximum number of room columns generated before each act boss.
@export_range(4, 16) var maximum_columns: int = 10
## Minimum number of lanes used by non-boss route columns.
@export_range(1, 6) var minimum_rows: int = 2
## Maximum number of lanes used by non-boss route columns.
@export_range(1, 6) var maximum_rows: int = 3
## Minimum number of adjacent columns retaining the same lane count.
@export_range(1, 6) var minimum_corridor_length: int = 2
## Maximum number of adjacent columns retaining the same lane count.
@export_range(1, 6) var maximum_corridor_length: int = 4
## Chance for a node to gain one additional ordered path without introducing crossings.
@export_range(0.0, 1.0) var branch_probability: float = 0.25
## Earliest zero-based column eligible for a generated shop.
@export_range(1, 8) var earliest_shop_column: int = 2
## Minimum distance kept between generated shops and the boss column.
@export_range(1, 5) var shop_distance_from_boss: int = 2
## Minimum shops generated in each act after fixed-room rules are applied.
@export_range(0, 4) var minimum_shop_nodes_per_act: int = 1
## Minimum recovery rooms generated in each act after fixed-room rules are applied.
@export_range(0, 12) var minimum_recovery_nodes_per_act: int = 2
## Maximum non-fixed recovery rooms retained in each act.
@export_range(0, 12) var maximum_recovery_nodes_per_act: int = 2
## Earliest one-based stage eligible for a generated recovery room.
@export_range(1, 16) var earliest_recovery_stage: int = 3
## Earliest one-based stage eligible for generated Elite or Challenge rooms.
@export_range(1, 16) var earliest_dangerous_stage: int = 3
## Maximum generated shops in each act. Explicit fixed rooms are never removed.
@export_range(0, 4) var maximum_shop_nodes_per_act: int = 1
## Minimum Elite and Challenge rooms across the complete route.
@export_range(0, 32) var minimum_elite_nodes_per_route: int = 4
## Maximum generated Elite and Challenge rooms across the complete route.
@export_range(0, 32) var maximum_elite_nodes_per_route: int = 6
## Optional deterministic room placements applied before generated room quotas.
@export var fixed_rooms: Array[RouteFixedRoomRule] = []

func normalized() -> RouteGenerationSettings:
	var result: RouteGenerationSettings = duplicate() as RouteGenerationSettings
	result.maximum_columns = maxi(result.minimum_columns, result.maximum_columns)
	result.maximum_corridor_length = maxi(result.minimum_corridor_length, result.maximum_corridor_length)
	result.maximum_rows = maxi(1, result.maximum_rows)
	result.minimum_rows = clampi(result.minimum_rows, 1, result.maximum_rows)
	result.maximum_shop_nodes_per_act = maxi(0, result.maximum_shop_nodes_per_act)
	result.minimum_shop_nodes_per_act = clampi(result.minimum_shop_nodes_per_act, 0, result.maximum_shop_nodes_per_act)
	result.minimum_recovery_nodes_per_act = maxi(0, result.minimum_recovery_nodes_per_act)
	result.maximum_recovery_nodes_per_act = maxi(result.minimum_recovery_nodes_per_act, result.maximum_recovery_nodes_per_act)
	result.earliest_recovery_stage = clampi(result.earliest_recovery_stage, 1, result.maximum_columns - 1)
	result.earliest_dangerous_stage = clampi(result.earliest_dangerous_stage, 1, result.maximum_columns - 1)
	result.minimum_elite_nodes_per_route = maxi(0, result.minimum_elite_nodes_per_route)
	result.maximum_elite_nodes_per_route = maxi(result.minimum_elite_nodes_per_route, result.maximum_elite_nodes_per_route)
	return result
