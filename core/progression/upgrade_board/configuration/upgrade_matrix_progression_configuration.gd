class_name UpgradeMatrixProgressionConfiguration
extends Resource

## Authored Matrix layout version stored in profile data.
@export_range(1, 1000000, 1) var layout_version: int = 3
## Reference region capacity used to scale authored thresholds.
@export_range(1, 1000, 1) var threshold_reference_cell_count: int = 200
## Default cumulative level thresholds at the reference capacity.
@export var default_level_thresholds: PackedInt32Array = PackedInt32Array([20, 50, 90, 140, 200])

func get_default_threshold(level_index: int) -> int:
	if level_index >= 0 and level_index < default_level_thresholds.size():
		return default_level_thresholds[level_index]
	return threshold_reference_cell_count

