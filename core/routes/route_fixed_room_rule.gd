class_name RouteFixedRoomRule
extends Resource

enum RowPlacement { TOP, CENTER, BOTTOM, RANDOM, ENTIRE_COLUMN }

const ALL_ACTS: int = -1

## Enables this fixed-room rule without removing it from the route settings.
@export var enabled: bool = true
## Act receiving the fixed room, or -1 to apply the rule to every act.
@export_range(-1, 7, 1) var act_index: int = ALL_ACTS
## Zero-based route column receiving the fixed room.
@export_range(0, 15, 1) var column_index: int = 2
## Room type placed by this rule. Boss rooms remain reserved for the final column.
@export var room_type: RouteNodeState.NodeType = RouteNodeState.NodeType.EVENT
## Lane selection used when the configured column contains multiple rooms.
@export var row_placement: RowPlacement = RowPlacement.CENTER

func applies_to(act: int, column_count: int) -> bool:
	return (
		enabled
		and (act_index == ALL_ACTS or act_index == act)
		and column_index >= 0
		and column_index < column_count - 1
		and room_type != RouteNodeState.NodeType.BOSS
	)

func selected_rows(row_count: int, rng: RandomNumberGenerator) -> PackedInt32Array:
	var safe_row_count: int = maxi(1, row_count)
	if row_placement == RowPlacement.ENTIRE_COLUMN:
		return PackedInt32Array(range(safe_row_count))
	if row_placement == RowPlacement.TOP:
		return PackedInt32Array([0])
	if row_placement == RowPlacement.BOTTOM:
		return PackedInt32Array([safe_row_count - 1])
	if row_placement == RowPlacement.RANDOM:
		return PackedInt32Array([rng.randi_range(0, safe_row_count - 1)])
	return PackedInt32Array([(safe_row_count - 1) / 2])
