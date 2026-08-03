class_name UpgradeBoardLayout
extends RefCounted

const OUTSIDE_BOARD_MESSAGE: String = "Upgrade area cell is outside the %dx%d board: %s"
const OVERLAP_MESSAGE: String = "Upgrade areas overlap at cell %s"

var board_size: Vector2i
var regions: Array[UpgradeBoardRegion] = []
var walls: Dictionary[Vector2i, bool] = {}
var validation_errors: Array[String] = []

var _regions_by_cell: Dictionary[Vector2i, UpgradeBoardRegion] = {}

func _init(layout_board_size: Vector2i = Vector2i.ZERO) -> void:
	board_size = layout_board_size

func add_region(region: UpgradeBoardRegion) -> void:
	if region == null:
		return
	for cell: Vector2i in region.area_cells:
		if not is_within_bounds(cell):
			add_validation_error(OUTSIDE_BOARD_MESSAGE % [board_size.x, board_size.y, cell])
			return
		if _regions_by_cell.has(cell):
			add_validation_error(OVERLAP_MESSAGE % cell)
			return
	regions.append(region)
	for cell: Vector2i in region.area_cells:
		_regions_by_cell[cell] = region
	for cell: Vector2i in region.wall_cells:
		walls[cell] = true

func add_validation_error(message: String) -> void:
	validation_errors.append(message)
	push_error(message)

func is_valid() -> bool:
	return validation_errors.is_empty()

func get_region_at(cell: Vector2i) -> UpgradeBoardRegion:
	return _regions_by_cell.get(cell) as UpgradeBoardRegion

func is_wall(cell: Vector2i) -> bool:
	return walls.has(cell)

func is_placeable(cell: Vector2i) -> bool:
	if not is_within_bounds(cell):
		return false
	var region: UpgradeBoardRegion = get_region_at(cell)
	return region != null and region.has_usable_cell(cell)

func get_region(upgrade: UpgradeDefinition) -> UpgradeBoardRegion:
	for region: UpgradeBoardRegion in regions:
		if region.upgrade == upgrade:
			return region
	return null

func is_within_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < board_size.x and cell.y < board_size.y
