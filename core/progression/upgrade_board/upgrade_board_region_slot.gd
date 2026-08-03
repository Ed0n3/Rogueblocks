class_name UpgradeBoardRegionSlot
extends Resource

enum Shape {
	ROUND,
	HORIZONTAL,
	VERTICAL,
	DIAGONAL_DOWN,
	DIAGONAL_UP,
	CROSS,
	CORNER,
	WAVE,
}

## Upgrade advanced by filling this generated region.
@export var upgrade: UpgradeDefinition
## Row-major home-zone index inside the configured region grid.
@export var slot_index: int = -1
## Total number of cells generated for this region, including walls.
@export_range(1, 1000, 1) var area_cell_count: int = 170
## Number of placeable cells retained after wall generation.
@export_range(1, 1000, 1) var usable_cell_count: int = 140
## Procedural contour profile used to grow this region.
@export var shape: Shape = Shape.ROUND
## Stable seed used by deterministic contour and wall generation.
@export var generation_seed: int = 1
