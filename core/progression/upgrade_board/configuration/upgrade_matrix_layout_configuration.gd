class_name UpgradeMatrixLayoutConfiguration
extends Resource

## Dimensions of the permanent Matrix in cells.
@export var board_size: Vector2i = Vector2i(100, 100)
## Number of authored home-zone columns.
@export_range(1, 20, 1) var region_columns: int = 6
## Number of authored home-zone rows.
@export_range(1, 20, 1) var region_rows: int = 5
## Typed definitions that map upgrades to generated Matrix regions.
@export var region_slots: Array[UpgradeBoardRegionSlot] = []
## Empty-cell margin applied inside every authored home zone.
@export_range(0, 8, 1) var territory_zone_margin: int = 1
## Cell spacing used when generating labyrinth wall candidates.
@export_range(2, 20, 1) var labyrinth_wall_spacing: int = 4
## Cell spacing used to leave gates in generated labyrinth walls.
@export_range(2, 20, 1) var labyrinth_gate_spacing: int = 5

@export_category("Shape Generation")
## Neighbor directions used by connected-region generation.
@export var cardinal_directions: Array[Vector2i] = [
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.DOWN,
]
## Growth weight along the short horizontal axis.
@export_range(0.0, 10.0, 0.01) var horizontal_axis_weight: float = 0.35
## Growth weight along the long axis.
@export_range(0.0, 10.0, 0.01) var long_axis_weight: float = 2.4
## Growth weight that keeps diagonal regions near their diagonal axis.
@export_range(0.0, 10.0, 0.01) var diagonal_axis_weight: float = 1.7
## Radial growth weight applied to diagonal regions.
@export_range(0.0, 10.0, 0.01) var diagonal_radius_weight: float = 0.35
## Vertical amplitude of wave-shaped regions.
@export_range(0.0, 2.0, 0.01) var wave_height: float = 0.45
## Frequency of wave-shaped regions.
@export_range(0.0, 10.0, 0.01) var wave_frequency: float = 1.5
## Growth weight toward the generated wave axis.
@export_range(0.0, 10.0, 0.01) var wave_axis_weight: float = 2.0
## Deterministic noise mixed into shape-growth scores.
@export_range(0.0, 2.0, 0.01) var shape_noise_weight: float = 0.18
## Offset between the two arms of corner-shaped regions.
@export_range(0.0, 2.0, 0.01) var corner_arm_offset: float = 0.45
## Number of deterministic start-offset variants per axis.
@export_range(1, 16, 1) var start_offset_variants: int = 3
## Center index of the deterministic start-offset range.
@export_range(0, 15, 1) var start_offset_center: int = 1
## Number of deterministic phase variants for wave regions.
@export_range(1, 32, 1) var wave_phase_variants: int = 7

@export_category("Deterministic Hash")
## X-axis multiplier used by deterministic cell noise.
@export var hash_x_factor: int = 73856093
## Y-axis multiplier used by deterministic cell noise.
@export var hash_y_factor: int = 19349663
## Seed multiplier used by deterministic cell noise.
@export var hash_seed_factor: int = 83492791
## Modulus used to normalize deterministic cell noise.
@export_range(1, 1000000, 1) var hash_modulus: int = 1000

func get_region_capacity() -> int:
	return region_columns * region_rows

