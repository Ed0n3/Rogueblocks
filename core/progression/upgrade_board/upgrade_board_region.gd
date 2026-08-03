class_name UpgradeBoardRegion
extends RefCounted

var upgrade: UpgradeDefinition
var category: UpgradeBoardCategory.Value
var bounds: Rect2i
var area_cells: Array[Vector2i]
var wall_cells: Array[Vector2i]
var usable_cells: Array[Vector2i]
var accent_color: Color
var label_cell: Vector2i

var _area_cell_lookup: Dictionary[Vector2i, bool] = {}
var _wall_cell_lookup: Dictionary[Vector2i, bool] = {}
var _usable_cell_lookup: Dictionary[Vector2i, bool] = {}

func _init(
	region_upgrade: UpgradeDefinition = null,
	region_area_cells: Array[Vector2i] = [],
	region_wall_cells: Array[Vector2i] = [],
	region_usable_cells: Array[Vector2i] = [],
	region_accent_color: Color = Color.WHITE,
	region_label_cell: Vector2i = Vector2i.ZERO
) -> void:
	upgrade = region_upgrade
	category = upgrade.category if upgrade != null else UpgradeBoardCategory.Value.MASTERY
	area_cells = region_area_cells.duplicate()
	wall_cells = region_wall_cells.duplicate()
	usable_cells = region_usable_cells.duplicate()
	accent_color = region_accent_color
	label_cell = region_label_cell
	bounds = _calculate_bounds(area_cells)
	for cell: Vector2i in area_cells:
		_area_cell_lookup[cell] = true
	for cell: Vector2i in wall_cells:
		_wall_cell_lookup[cell] = true
	for cell: Vector2i in usable_cells:
		_usable_cell_lookup[cell] = true

func has_area_cell(cell: Vector2i) -> bool:
	return _area_cell_lookup.has(cell)

func has_wall_cell(cell: Vector2i) -> bool:
	return _wall_cell_lookup.has(cell)

func has_usable_cell(cell: Vector2i) -> bool:
	return _usable_cell_lookup.has(cell)

func get_thresholds(configuration: UpgradeMatrixConfiguration) -> PackedInt32Array:
	if upgrade == null:
		return PackedInt32Array()
	return upgrade.resolve_board_level_thresholds(configuration, usable_cells.size())

func _calculate_bounds(cells: Array[Vector2i]) -> Rect2i:
	if cells.is_empty():
		return Rect2i()
	var minimum: Vector2i = cells[0]
	var maximum: Vector2i = cells[0]
	for cell: Vector2i in cells:
		minimum.x = mini(minimum.x, cell.x)
		minimum.y = mini(minimum.y, cell.y)
		maximum.x = maxi(maximum.x, cell.x)
		maximum.y = maxi(maximum.y, cell.y)
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)
