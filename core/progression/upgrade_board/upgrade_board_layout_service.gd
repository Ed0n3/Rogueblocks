class_name UpgradeBoardLayoutService
extends Resource

const AREA_SIZE_MESSAGE: String = "Upgrade area %s could not reach its authored size"
const LABYRINTH_SIZE_MESSAGE: String = "Upgrade area %s could not fit its authored labyrinth"
const EMPTY_TERRITORY_GRID_MESSAGE: String = "Upgrade Board territory grid must provide at least one home zone"
const EXCESSIVE_UPGRADE_COUNT_MESSAGE: String = "Upgrade Board has more upgrade resources than authored home zones"
const INVALID_MAPPING_MESSAGE: String = "Upgrade Board mapping contains an invalid entry at index %d"
const ZONE_OUTSIDE_BOARD_MESSAGE: String = "Upgrade Board zone for %s is outside the configured board: %d"
const DUPLICATE_UPGRADE_MESSAGE: String = "Upgrade Board mapping contains duplicate upgrade resource: %s"
const DUPLICATE_ZONE_MESSAGE: String = "Upgrade Board mapping contains duplicate home zone: %d"
const DUPLICATE_AREA_SIZE_MESSAGE: String = "Upgrade Board areas must have distinct sizes: %d"
const INVALID_CAPACITY_MESSAGE: String = "Upgrade area %s has an invalid usable capacity"
const AREA_OUTSIDE_ZONE_MESSAGE: String = "Upgrade area %s does not fit inside its authored home zone"

var configuration: UpgradeMatrixLayoutConfiguration

func generate(matrix_configuration: UpgradeMatrixConfiguration) -> UpgradeBoardLayout:
	var active_configuration: UpgradeMatrixConfiguration = matrix_configuration if matrix_configuration != null else UpgradeMatrixConfiguration.load_default()
	var configuration_errors: PackedStringArray = active_configuration.get_validation_errors()
	if active_configuration.layout == null:
		var invalid_layout: UpgradeBoardLayout = UpgradeBoardLayout.new()
		for configuration_error: String in configuration_errors:
			invalid_layout.add_validation_error(configuration_error)
		return invalid_layout
	configuration = active_configuration.layout
	var layout: UpgradeBoardLayout = UpgradeBoardLayout.new(configuration.board_size)
	for configuration_error: String in configuration_errors:
		layout.add_validation_error(configuration_error)
	if not layout.is_valid():
		return layout
	var region_capacity: int = configuration.get_region_capacity()
	_validate_configuration(configuration, region_capacity, layout)
	if not layout.is_valid():
		return layout
	var ordered_slots: Array[UpgradeBoardRegionSlot] = configuration.region_slots.duplicate()
	ordered_slots.sort_custom(_slot_precedes)
	for region_slot: UpgradeBoardRegionSlot in ordered_slots:
		var zone_bounds: Rect2i = _get_zone_bounds(region_slot.slot_index, configuration)
		var generation_bounds: Rect2i = _get_generation_bounds(zone_bounds, configuration.territory_zone_margin)
		var area_cells: Array[Vector2i] = _generate_area_cells(generation_bounds, region_slot)
		if area_cells.size() != region_slot.area_cell_count:
			layout.add_validation_error(AREA_SIZE_MESSAGE % region_slot.upgrade.display_name)
			return layout
		var wall_count: int = region_slot.area_cell_count - region_slot.usable_cell_count
		var wall_cells: Array[Vector2i] = _generate_labyrinth_wall_cells(area_cells, wall_count, region_slot, configuration)
		if wall_cells.size() != wall_count:
			layout.add_validation_error(LABYRINTH_SIZE_MESSAGE % region_slot.upgrade.display_name)
			return layout
		var usable_cells: Array[Vector2i] = _subtract_cells(area_cells, wall_cells)
		var upgrade: UpgradeDefinition = region_slot.upgrade
		var category: UpgradeBoardCategory.Value = upgrade.category
		var label_cell: Vector2i = _find_label_cell(usable_cells)
		var region_color: Color = active_configuration.presentation.get_category_color(category)
		var region: UpgradeBoardRegion = UpgradeBoardRegion.new(upgrade, area_cells, wall_cells, usable_cells, region_color, label_cell)
		layout.add_region(region)
		if not layout.is_valid():
			return layout
	return layout

func _validate_configuration(
	layout_configuration: UpgradeMatrixLayoutConfiguration,
	region_capacity: int,
	layout: UpgradeBoardLayout
) -> void:
	if region_capacity <= 0:
		layout.add_validation_error(EMPTY_TERRITORY_GRID_MESSAGE)
		return
	if layout_configuration.region_slots.size() > region_capacity:
		layout.add_validation_error(EXCESSIVE_UPGRADE_COUNT_MESSAGE)
	for slot_array_index: int in layout_configuration.region_slots.size():
		var region_slot: UpgradeBoardRegionSlot = layout_configuration.region_slots[slot_array_index]
		if region_slot == null or region_slot.upgrade == null or not region_slot.upgrade.is_valid():
			layout.add_validation_error(INVALID_MAPPING_MESSAGE % slot_array_index)
			continue
		if region_slot.slot_index < 0 or region_slot.slot_index >= region_capacity:
			layout.add_validation_error(ZONE_OUTSIDE_BOARD_MESSAGE % [region_slot.upgrade.display_name, region_slot.slot_index])
			continue
		if _count_slots_for_upgrade(layout_configuration.region_slots, region_slot.upgrade) > 1:
			layout.add_validation_error(DUPLICATE_UPGRADE_MESSAGE % region_slot.upgrade.display_name)
		if _count_slots_for_index(layout_configuration.region_slots, region_slot.slot_index) > 1:
			layout.add_validation_error(DUPLICATE_ZONE_MESSAGE % region_slot.slot_index)
		if _count_slots_for_area_size(layout_configuration.region_slots, region_slot.area_cell_count) > 1:
			layout.add_validation_error(DUPLICATE_AREA_SIZE_MESSAGE % region_slot.area_cell_count)
		var upgrade: UpgradeDefinition = region_slot.upgrade
		if region_slot.usable_cell_count < upgrade.max_level or region_slot.usable_cell_count > region_slot.area_cell_count:
			layout.add_validation_error(INVALID_CAPACITY_MESSAGE % region_slot.upgrade.display_name)
		var zone_bounds: Rect2i = _get_zone_bounds(region_slot.slot_index, layout_configuration)
		var generation_bounds: Rect2i = _get_generation_bounds(zone_bounds, layout_configuration.territory_zone_margin)
		if generation_bounds.size.x <= 0 or generation_bounds.size.y <= 0 or region_slot.area_cell_count > generation_bounds.get_area():
			layout.add_validation_error(AREA_OUTSIDE_ZONE_MESSAGE % region_slot.upgrade.display_name)

func _get_zone_bounds(index: int, layout_configuration: UpgradeMatrixLayoutConfiguration) -> Rect2i:
	var column: int = index % layout_configuration.region_columns
	var row: int = index / layout_configuration.region_columns
	var start_x: int = floori(float(column * layout_configuration.board_size.x) / float(layout_configuration.region_columns))
	var end_x: int = floori(float((column + 1) * layout_configuration.board_size.x) / float(layout_configuration.region_columns))
	var start_y: int = floori(float(row * layout_configuration.board_size.y) / float(layout_configuration.region_rows))
	var end_y: int = floori(float((row + 1) * layout_configuration.board_size.y) / float(layout_configuration.region_rows))
	return Rect2i(start_x, start_y, end_x - start_x, end_y - start_y)

func _get_generation_bounds(zone_bounds: Rect2i, margin: int) -> Rect2i:
	var inset: Vector2i = Vector2i.ONE * margin
	return Rect2i(zone_bounds.position + inset, zone_bounds.size - inset * 2)

func _generate_area_cells(bounds: Rect2i, slot: UpgradeBoardRegionSlot) -> Array[Vector2i]:
	var selected: Dictionary[Vector2i, bool] = {}
	var frontier: Array[Vector2i] = []
	var frontier_lookup: Dictionary[Vector2i, bool] = {}
	var start_cell: Vector2i = _get_start_cell(bounds, slot.generation_seed)
	selected[start_cell] = true
	_add_frontier_neighbors(start_cell, bounds, selected, frontier, frontier_lookup)
	while selected.size() < slot.area_cell_count and not frontier.is_empty():
		var best_index: int = _find_best_frontier_index(frontier, bounds, slot)
		var next_cell: Vector2i = frontier.pop_at(best_index)
		frontier_lookup.erase(next_cell)
		selected[next_cell] = true
		_add_frontier_neighbors(next_cell, bounds, selected, frontier, frontier_lookup)
	var cells: Array[Vector2i] = []
	cells.assign(selected.keys())
	_sort_cells(cells)
	return cells

func _get_start_cell(bounds: Rect2i, seed: int) -> Vector2i:
	var offset_x: int = posmod(seed, configuration.start_offset_variants) - configuration.start_offset_center
	var offset_y: int = posmod(seed / configuration.start_offset_variants, configuration.start_offset_variants) - configuration.start_offset_center
	var center: Vector2i = bounds.position + bounds.size / 2 + Vector2i(offset_x, offset_y)
	center.x = clampi(center.x, bounds.position.x, bounds.end.x - 1)
	center.y = clampi(center.y, bounds.position.y, bounds.end.y - 1)
	return center

func _add_frontier_neighbors(
	cell: Vector2i,
	bounds: Rect2i,
	selected: Dictionary[Vector2i, bool],
	frontier: Array[Vector2i],
	frontier_lookup: Dictionary[Vector2i, bool]
) -> void:
	for direction: Vector2i in configuration.cardinal_directions:
		var neighbor: Vector2i = cell + direction
		if not bounds.has_point(neighbor) or selected.has(neighbor) or frontier_lookup.has(neighbor):
			continue
		frontier.append(neighbor)
		frontier_lookup[neighbor] = true

func _find_best_frontier_index(frontier: Array[Vector2i], bounds: Rect2i, slot: UpgradeBoardRegionSlot) -> int:
	var best_index: int = 0
	var best_score: float = _get_shape_score(frontier[0], bounds, slot)
	for index: int in range(1, frontier.size()):
		var score: float = _get_shape_score(frontier[index], bounds, slot)
		if score < best_score:
			best_index = index
			best_score = score
	return best_index

func _get_shape_score(cell: Vector2i, bounds: Rect2i, slot: UpgradeBoardRegionSlot) -> float:
	var center: Vector2 = Vector2(bounds.position) + Vector2(bounds.size) * 0.5
	var half_size: Vector2 = Vector2(bounds.size) * 0.5
	var normalized: Vector2 = (Vector2(cell) + Vector2.ONE * 0.5 - center) / Vector2(maxf(half_size.x, 1.0), maxf(half_size.y, 1.0))
	var x_squared: float = normalized.x * normalized.x
	var y_squared: float = normalized.y * normalized.y
	var score: float
	match slot.shape:
		UpgradeBoardRegionSlot.Shape.HORIZONTAL:
			score = x_squared * configuration.horizontal_axis_weight + y_squared * configuration.long_axis_weight
		UpgradeBoardRegionSlot.Shape.VERTICAL:
			score = x_squared * configuration.long_axis_weight + y_squared * configuration.horizontal_axis_weight
		UpgradeBoardRegionSlot.Shape.DIAGONAL_DOWN:
			score = pow(normalized.x - normalized.y, 2.0) * configuration.diagonal_axis_weight + (x_squared + y_squared) * configuration.diagonal_radius_weight
		UpgradeBoardRegionSlot.Shape.DIAGONAL_UP:
			score = pow(normalized.x + normalized.y, 2.0) * configuration.diagonal_axis_weight + (x_squared + y_squared) * configuration.diagonal_radius_weight
		UpgradeBoardRegionSlot.Shape.CROSS:
			var horizontal_score: float = x_squared * configuration.horizontal_axis_weight + y_squared * configuration.long_axis_weight
			var vertical_score: float = x_squared * configuration.long_axis_weight + y_squared * configuration.horizontal_axis_weight
			score = minf(horizontal_score, vertical_score)
		UpgradeBoardRegionSlot.Shape.CORNER:
			var horizontal_arm: float = pow(normalized.x + configuration.corner_arm_offset, 2.0) * configuration.horizontal_axis_weight + y_squared * configuration.long_axis_weight
			var vertical_arm: float = x_squared * configuration.long_axis_weight + pow(normalized.y - configuration.corner_arm_offset, 2.0) * configuration.horizontal_axis_weight
			score = minf(horizontal_arm, vertical_arm)
		UpgradeBoardRegionSlot.Shape.WAVE:
			var wave_phase: float = float(posmod(slot.generation_seed, configuration.wave_phase_variants))
			var wave_target: float = sin(normalized.x * PI * configuration.wave_frequency + wave_phase) * configuration.wave_height
			score = pow(normalized.y - wave_target, 2.0) * configuration.wave_axis_weight + x_squared * configuration.horizontal_axis_weight
		_:
			score = x_squared + y_squared
	return score + _get_cell_noise(cell, slot.generation_seed) * configuration.shape_noise_weight

func _generate_labyrinth_wall_cells(
	area_cells: Array[Vector2i],
	requested_count: int,
	slot: UpgradeBoardRegionSlot,
	layout_configuration: UpgradeMatrixLayoutConfiguration
) -> Array[Vector2i]:
	var walls: Array[Vector2i] = []
	if requested_count <= 0:
		return walls
	var area_lookup: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in area_cells:
		area_lookup[cell] = true
	var vertical_candidates: Array[Vector2i] = []
	var horizontal_candidates: Array[Vector2i] = []
	var fallback_candidates: Array[Vector2i] = []
	for cell: Vector2i in area_cells:
		if not _is_strict_area_interior(cell, area_lookup):
			continue
		var vertical_wall_position: int = posmod(cell.x + slot.generation_seed, layout_configuration.labyrinth_wall_spacing)
		var vertical_gate_position: int = posmod(cell.y + slot.generation_seed, layout_configuration.labyrinth_gate_spacing)
		var horizontal_wall_position: int = posmod(cell.y + slot.generation_seed, layout_configuration.labyrinth_wall_spacing)
		var horizontal_gate_position: int = posmod(cell.x + slot.generation_seed, layout_configuration.labyrinth_gate_spacing)
		var vertical_wall: bool = vertical_wall_position == 0 and vertical_gate_position != 0
		var horizontal_wall: bool = horizontal_wall_position == 0 and horizontal_gate_position != 0
		if vertical_wall:
			vertical_candidates.append(cell)
		if horizontal_wall:
			horizontal_candidates.append(cell)
		if not vertical_wall and not horizontal_wall:
			fallback_candidates.append(cell)
	var prefer_vertical: bool = slot.shape in [UpgradeBoardRegionSlot.Shape.VERTICAL, UpgradeBoardRegionSlot.Shape.DIAGONAL_DOWN, UpgradeBoardRegionSlot.Shape.CORNER]
	_sort_wall_candidates(vertical_candidates, true, slot.generation_seed)
	_sort_wall_candidates(horizontal_candidates, false, slot.generation_seed)
	fallback_candidates.sort_custom(func(left: Vector2i, right: Vector2i) -> bool: return _get_cell_noise(left, slot.generation_seed) < _get_cell_noise(right, slot.generation_seed))
	var primary: Array[Vector2i] = vertical_candidates if prefer_vertical else horizontal_candidates
	var secondary: Array[Vector2i] = horizontal_candidates if prefer_vertical else vertical_candidates
	_append_unique_cells(walls, primary, requested_count)
	_append_unique_cells(walls, secondary, requested_count)
	_append_unique_cells(walls, fallback_candidates, requested_count)
	_sort_cells(walls)
	return walls

func _sort_wall_candidates(cells: Array[Vector2i], vertical: bool, seed: int) -> void:
	cells.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		var left_primary: int = posmod((left.x if vertical else left.y) + seed, configuration.board_size.x)
		var right_primary: int = posmod((right.x if vertical else right.y) + seed, configuration.board_size.x)
		if left_primary != right_primary:
			return left_primary < right_primary
		return left.y < right.y if vertical else left.x < right.x)

func _append_unique_cells(target: Array[Vector2i], source: Array[Vector2i], maximum_count: int) -> void:
	for cell: Vector2i in source:
		if target.size() >= maximum_count:
			return
		if not target.has(cell):
			target.append(cell)

func _is_strict_area_interior(cell: Vector2i, area_lookup: Dictionary[Vector2i, bool]) -> bool:
	for direction: Vector2i in configuration.cardinal_directions:
		if not area_lookup.has(cell + direction):
			return false
	return true

func _subtract_cells(area_cells: Array[Vector2i], wall_cells: Array[Vector2i]) -> Array[Vector2i]:
	var wall_lookup: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in wall_cells:
		wall_lookup[cell] = true
	var usable_cells: Array[Vector2i] = []
	for cell: Vector2i in area_cells:
		if not wall_lookup.has(cell):
			usable_cells.append(cell)
	_sort_cells(usable_cells)
	return usable_cells

func _find_label_cell(usable_cells: Array[Vector2i]) -> Vector2i:
	if usable_cells.is_empty():
		return Vector2i.ZERO
	var centroid: Vector2 = Vector2.ZERO
	var usable_lookup: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in usable_cells:
		centroid += Vector2(cell)
		usable_lookup[cell] = true
	centroid /= float(usable_cells.size())
	var label_cell: Vector2i = usable_cells[0]
	var best_score: float = INF
	for cell: Vector2i in usable_cells:
		var neighbor_count: int = 0
		for direction: Vector2i in configuration.cardinal_directions:
			if usable_lookup.has(cell + direction):
				neighbor_count += 1
		var score: float = Vector2(cell).distance_squared_to(centroid) - float(neighbor_count)
		if score < best_score:
			label_cell = cell
			best_score = score
	return label_cell

func _get_cell_noise(cell: Vector2i, seed: int) -> float:
	var hash_value: int = posmod(cell.x * configuration.hash_x_factor + cell.y * configuration.hash_y_factor + seed * configuration.hash_seed_factor, configuration.hash_modulus)
	return float(hash_value) / float(configuration.hash_modulus)

func _sort_cells(cells: Array[Vector2i]) -> void:
	cells.sort_custom(func(left: Vector2i, right: Vector2i) -> bool: return left.y < right.y or (left.y == right.y and left.x < right.x))

func _count_slots_for_upgrade(region_slots: Array[UpgradeBoardRegionSlot], upgrade: UpgradeDefinition) -> int:
	var count: int = 0
	for region_slot: UpgradeBoardRegionSlot in region_slots:
		if region_slot != null and region_slot.upgrade == upgrade:
			count += 1
	return count

func _count_slots_for_index(region_slots: Array[UpgradeBoardRegionSlot], slot_index: int) -> int:
	var count: int = 0
	for region_slot: UpgradeBoardRegionSlot in region_slots:
		if region_slot != null and region_slot.slot_index == slot_index:
			count += 1
	return count

func _count_slots_for_area_size(region_slots: Array[UpgradeBoardRegionSlot], area_cell_count: int) -> int:
	var count: int = 0
	for region_slot: UpgradeBoardRegionSlot in region_slots:
		if region_slot != null and region_slot.area_cell_count == area_cell_count:
			count += 1
	return count

func _slot_precedes(left: UpgradeBoardRegionSlot, right: UpgradeBoardRegionSlot) -> bool:
	return left.slot_index < right.slot_index
