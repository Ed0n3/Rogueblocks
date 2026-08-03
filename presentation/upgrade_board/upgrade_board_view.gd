class_name UpgradeBoardView
extends Control

const BoardSwipeGesture = preload("res://presentation/board/board_swipe_gesture.gd")
const BoardTileMapRenderer = preload("res://presentation/board/board_tile_map_renderer.gd")

signal cell_activated(cell: Vector2i)
signal hovered_cell_changed(cell: Vector2i)
signal placement_cell_changed(cell: Vector2i)
signal placement_confirmation_requested()
signal rotation_requested(clockwise: bool)
signal region_selected(region: UpgradeBoardRegion)
signal camera_changed(zoom: float)

const CARDINAL_DIRECTIONS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

var configuration: UpgradeMatrixConfiguration
var interaction: UpgradeMatrixInteractionConfiguration
var presentation: UpgradeMatrixPresentationConfiguration
var layout: UpgradeBoardLayout
var board_state: UpgradeBoardState
var legacy_levels: Array[UpgradeLevelState] = []
var board_service: UpgradeBoardService
var camera_zoom: float = 1.0
var target_zoom: float = 1.0
var camera_pan: Vector2 = Vector2.ZERO
var target_pan: Vector2 = Vector2.ZERO
var camera_initialized: bool = false
var preview_cells: Array[Vector2i] = []
var preview_valid: bool = false
var selected_region: UpgradeBoardRegion
var mouse_drag_active: bool = false
var mouse_dragged: bool = false
var mouse_press_position: Vector2
var mouse_last_position: Vector2
var touch_positions: Dictionary[int, Vector2] = {}
var touch_press_position: Vector2
var touch_dragged: bool = false
var placement_mode_enabled: bool = false
var mouse_drag_button: int = MOUSE_BUTTON_NONE
var tile_renderer: BoardTileMapRenderer
var swipe_gesture: BoardSwipeGesture
var touch_started_on_preview: bool = false
var mouse_started_on_preview: bool = false
var matrix_tile_rebuild_count: int = 0

func _ready() -> void:
	z_index = 1
	_ensure_tile_renderer()
	var default_configuration: UpgradeMatrixConfiguration = UpgradeMatrixConfiguration.load_default()
	interaction = default_configuration.interaction
	presentation = default_configuration.presentation
	swipe_gesture = BoardSwipeGesture.new(interaction.rotation_swipe_distance)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)
	resized.connect(_handle_resize)

func setup(matrix_configuration: UpgradeMatrixConfiguration, board_layout: UpgradeBoardLayout, state: UpgradeBoardState, profile_legacy_levels: Array[UpgradeLevelState], service: UpgradeBoardService) -> void:
	configuration = matrix_configuration if matrix_configuration != null else UpgradeMatrixConfiguration.load_default()
	interaction = configuration.interaction
	presentation = configuration.presentation
	swipe_gesture = BoardSwipeGesture.new(interaction.rotation_swipe_distance)
	layout = board_layout
	board_state = state
	legacy_levels = profile_legacy_levels
	board_service = service
	_rebuild_matrix_tile_map()
	call_deferred("fit_board")
	queue_redraw()

func set_board_state(state: UpgradeBoardState) -> void:
	board_state = state
	_rebuild_matrix_tile_map()
	queue_redraw()

func set_preview(cells: Array[Vector2i], is_valid: bool) -> void:
	preview_cells = cells.duplicate()
	preview_valid = is_valid
	_refresh_preview_tile_map()
	queue_redraw()

func clear_preview() -> void:
	preview_cells.clear()
	_refresh_preview_tile_map()
	queue_redraw()

func set_placement_mode_enabled(enabled: bool) -> void:
	placement_mode_enabled = enabled
	if not enabled:
		mouse_drag_button = MOUSE_BUTTON_NONE

func select_region(region: UpgradeBoardRegion) -> void:
	selected_region = region
	_refresh_selection_tile_map()
	queue_redraw()

func fit_board() -> void:
	if layout == null or interaction == null or size.x <= 0.0 or size.y <= 0.0:
		return
	var board_world_size: Vector2 = Vector2(layout.board_size) * interaction.cell_pixel_size
	var available_size: Vector2 = size - Vector2.ONE * interaction.camera_edge_padding * 2.0
	var fitted_zoom: float = minf(available_size.x / board_world_size.x, available_size.y / board_world_size.y)
	target_zoom = clampf(fitted_zoom, interaction.minimum_zoom, interaction.maximum_zoom)
	target_pan = (size - board_world_size * target_zoom) * 0.5
	camera_zoom = target_zoom
	camera_pan = target_pan
	camera_initialized = true
	_sync_tile_map_transform()
	queue_redraw()
	camera_changed.emit(camera_zoom)

func focus_region(region: UpgradeBoardRegion) -> void:
	if region == null or interaction == null:
		return
	var region_center_world: Vector2 = (Vector2(region.bounds.position) + Vector2(region.bounds.size) * 0.5) * interaction.cell_pixel_size
	target_zoom = clampf(interaction.region_focus_zoom, interaction.minimum_zoom, interaction.maximum_zoom)
	target_pan = size * 0.5 - region_center_world * target_zoom
	_clamp_target_pan()
	camera_changed.emit(target_zoom)

func zoom_at(screen_anchor: Vector2, zoom_factor: float) -> void:
	if interaction == null or not camera_initialized:
		return
	var world_anchor: Vector2 = (screen_anchor - target_pan) / target_zoom
	var next_zoom: float = clampf(target_zoom * zoom_factor, interaction.minimum_zoom, interaction.maximum_zoom)
	target_zoom = next_zoom
	target_pan = screen_anchor - world_anchor * target_zoom
	_clamp_target_pan()
	camera_changed.emit(target_zoom)

func pan_by(screen_delta: Vector2) -> void:
	if not camera_initialized:
		return
	target_pan += screen_delta
	_clamp_target_pan()

func get_world_position_at(screen_position: Vector2, use_target_camera: bool = true) -> Vector2:
	var zoom_value: float = target_zoom if use_target_camera else camera_zoom
	var pan_value: Vector2 = target_pan if use_target_camera else camera_pan
	return (screen_position - pan_value) / maxf(zoom_value, 0.001)

func get_cell_at(screen_position: Vector2) -> Vector2i:
	if interaction == null:
		return Vector2i(-1, -1)
	var world_position: Vector2 = get_world_position_at(screen_position, false)
	return Vector2i(floori(world_position.x / interaction.cell_pixel_size), floori(world_position.y / interaction.cell_pixel_size))

func get_camera_zoom() -> float:
	return target_zoom

func set_camera_immediate(zoom_value: float, pan_value: Vector2) -> void:
	if interaction == null:
		return
	target_zoom = clampf(zoom_value, interaction.minimum_zoom, interaction.maximum_zoom)
	target_pan = pan_value
	_clamp_target_pan()
	camera_zoom = target_zoom
	camera_pan = target_pan
	camera_initialized = true
	_sync_tile_map_transform()
	queue_redraw()

func _process(delta: float) -> void:
	if not camera_initialized:
		return
	var interpolation: float = 1.0 - exp(-interaction.camera_smoothing_speed * delta)
	var previous_zoom: float = camera_zoom
	var previous_pan: Vector2 = camera_pan
	camera_zoom = lerpf(camera_zoom, target_zoom, interpolation)
	camera_pan = camera_pan.lerp(target_pan, interpolation)
	if absf(camera_zoom - target_zoom) < 0.0001:
		camera_zoom = target_zoom
	if camera_pan.distance_squared_to(target_pan) < 0.001:
		camera_pan = target_pan
	if not is_equal_approx(previous_zoom, camera_zoom) or previous_pan != camera_pan:
		_sync_tile_map_transform()
		queue_redraw()

func _draw() -> void:
	if layout == null or interaction == null or presentation == null or board_state == null or board_service == null or not camera_initialized:
		return
	_sync_tile_map_transform()
	draw_set_transform(camera_pan, 0.0, Vector2.ONE * camera_zoom)
	var visible_cells: Rect2i = _visible_cell_bounds()
	_draw_region_labels(visible_cells)
	_draw_board_border()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _ensure_tile_renderer() -> void:
	if tile_renderer != null and is_instance_valid(tile_renderer):
		return
	tile_renderer = get_node_or_null("TileMapRenderer") as BoardTileMapRenderer
	if tile_renderer != null:
		return
	var renderer_scene: PackedScene = load("res://presentation/board/board_tile_map_renderer.tscn") as PackedScene
	tile_renderer = renderer_scene.instantiate() as BoardTileMapRenderer
	tile_renderer.name = "TileMapRenderer"
	add_child(tile_renderer)

func _sync_tile_map_transform() -> void:
	if tile_renderer != null and interaction != null:
		tile_renderer.set_board_transform(camera_pan, interaction.cell_pixel_size, camera_zoom)

func _rebuild_matrix_tile_map() -> void:
	_ensure_tile_renderer()
	if tile_renderer == null or layout == null or interaction == null or presentation == null or board_state == null or board_service == null:
		return
	matrix_tile_rebuild_count += 1
	tile_renderer.clear_all()
	var placement_colors: Dictionary[Vector2i, Color] = _placement_colors()
	var legacy_cells: Dictionary[Vector2i, Color] = _legacy_cell_colors()
	for y: int in layout.board_size.y:
		for x: int in layout.board_size.x:
			var cell: Vector2i = Vector2i(x, y)
			var region: UpgradeBoardRegion = layout.get_region_at(cell)
			tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.BACKGROUND, BoardTileMapRenderer.TileStyle.SOLID, presentation.neutral_cell_color)
			if region == null:
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.GRID, BoardTileMapRenderer.TileStyle.OUTLINE, presentation.neutral_grid_color)
			else:
				var region_grid_color: Color = Color(region.accent_color, presentation.region_grid_alpha)
				if layout.is_wall(cell):
					tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.WALL, BoardTileMapRenderer.TileStyle.INSET, presentation.wall_color)
					tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.WALL, BoardTileMapRenderer.TileStyle.OUTLINE, Color(region.accent_color, presentation.wall_accent_alpha))
				else:
					tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.AREA, BoardTileMapRenderer.TileStyle.INSET, Color(region.accent_color, presentation.region_fill_alpha))
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.GRID, BoardTileMapRenderer.TileStyle.OUTLINE, region_grid_color)
			if legacy_cells.has(cell):
				tile_renderer.set_block_tile(cell, BoardTileMapRenderer.LayerBand.OCCUPIED, Color(legacy_cells[cell], presentation.legacy_fill_alpha))
			elif placement_colors.has(cell):
				tile_renderer.set_block_tile(cell, BoardTileMapRenderer.LayerBand.OCCUPIED, Color(placement_colors[cell], presentation.placement_fill_alpha))
	for region: UpgradeBoardRegion in layout.regions:
		for cell: Vector2i in region.area_cells:
			for direction: Vector2i in CARDINAL_DIRECTIONS:
				if layout.get_region_at(cell + direction) != region:
					tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.AREA, _edge_style(direction), Color(region.accent_color, presentation.region_border_alpha))
	_refresh_selection_tile_map()
	_refresh_preview_tile_map()
	_sync_tile_map_transform()

func _refresh_selection_tile_map() -> void:
	if tile_renderer == null:
		return
	tile_renderer.clear_band(BoardTileMapRenderer.LayerBand.SELECTION)
	if selected_region == null or layout == null:
		return
	var selection_color: Color = selected_region.accent_color.lightened(presentation.selected_region_lighten_amount)
	for cell: Vector2i in selected_region.area_cells:
		for direction: Vector2i in CARDINAL_DIRECTIONS:
			if layout.get_region_at(cell + direction) != selected_region:
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.SELECTION, _edge_style(direction), selection_color)

func _refresh_preview_tile_map() -> void:
	if tile_renderer == null or presentation == null:
		return
	tile_renderer.clear_band(BoardTileMapRenderer.LayerBand.PREVIEW)
	tile_renderer.clear_band(BoardTileMapRenderer.LayerBand.MARKER)
	var preview_color: Color = presentation.valid_preview_color if preview_valid else presentation.invalid_preview_color
	var preview_alpha: float = presentation.preview_valid_alpha if preview_valid else presentation.preview_invalid_alpha
	for cell: Vector2i in preview_cells:
		tile_renderer.set_block_tile(cell, BoardTileMapRenderer.LayerBand.PREVIEW, Color(preview_color, preview_alpha))
		if not preview_valid:
			tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.MARKER, BoardTileMapRenderer.TileStyle.CROSS, Color(preview_color, presentation.invalid_preview_marker_alpha))

func _edge_style(direction: Vector2i) -> BoardTileMapRenderer.TileStyle:
	if direction == Vector2i.UP:
		return BoardTileMapRenderer.TileStyle.EDGE_UP
	if direction == Vector2i.RIGHT:
		return BoardTileMapRenderer.TileStyle.EDGE_RIGHT
	if direction == Vector2i.DOWN:
		return BoardTileMapRenderer.TileStyle.EDGE_DOWN
	return BoardTileMapRenderer.TileStyle.EDGE_LEFT

func get_tile_map_renderer() -> BoardTileMapRenderer:
	_ensure_tile_renderer()
	return tile_renderer

func get_matrix_tile_rebuild_count() -> int:
	return matrix_tile_rebuild_count

func _draw_board_border() -> void:
	var board_rectangle: Rect2 = Rect2(Vector2.ZERO, Vector2(layout.board_size) * interaction.cell_pixel_size)
	draw_rect(board_rectangle, presentation.neutral_grid_color, false, presentation.region_border_width)

func _draw_region_labels(visible_cells: Rect2i) -> void:
	if camera_zoom < presentation.region_label_zoom_threshold:
		return
	for region: UpgradeBoardRegion in layout.regions:
		if not visible_cells.has_point(region.label_cell):
			continue
		var region_rectangle: Rect2 = Rect2(Vector2(region.bounds.position) * interaction.cell_pixel_size, Vector2(region.bounds.size) * interaction.cell_pixel_size)
		var label_position: Vector2 = Vector2(region_rectangle.position.x, float(region.label_cell.y + 1) * interaction.cell_pixel_size)
		draw_string(get_theme_font("font"), label_position, region.upgrade.display_name.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, region_rectangle.size.x, presentation.label_font_size, Color(region.accent_color, presentation.region_label_alpha))

func _placement_colors() -> Dictionary[Vector2i, Color]:
	var colors: Dictionary[Vector2i, Color] = {}
	for placement: UpgradeBoardPlacement in board_state.placements:
		var piece: PieceDefinition = placement.piece
		if piece == null:
			continue
		for cell: Vector2i in board_service.get_placement_cells(placement):
			colors[cell] = piece.preview_color
	return colors

func _legacy_cell_colors() -> Dictionary[Vector2i, Color]:
	var colors: Dictionary[Vector2i, Color] = {}
	for region: UpgradeBoardRegion in layout.regions:
		for cell: Vector2i in board_service.get_legacy_cells(region, legacy_levels):
			colors[cell] = region.accent_color
	return colors

func _visible_cell_bounds() -> Rect2i:
	var world_minimum: Vector2 = get_world_position_at(Vector2.ZERO, false)
	var world_maximum: Vector2 = get_world_position_at(size, false)
	var minimum_cell: Vector2i = Vector2i(floori(world_minimum.x / interaction.cell_pixel_size) - 1, floori(world_minimum.y / interaction.cell_pixel_size) - 1)
	var maximum_cell: Vector2i = Vector2i(ceili(world_maximum.x / interaction.cell_pixel_size) + 1, ceili(world_maximum.y / interaction.cell_pixel_size) + 1)
	minimum_cell.x = clampi(minimum_cell.x, 0, layout.board_size.x)
	minimum_cell.y = clampi(minimum_cell.y, 0, layout.board_size.y)
	maximum_cell.x = clampi(maximum_cell.x, minimum_cell.x, layout.board_size.x)
	maximum_cell.y = clampi(maximum_cell.y, minimum_cell.y, layout.board_size.y)
	return Rect2i(minimum_cell, maximum_cell - minimum_cell)

func _gui_input(event: InputEvent) -> void:
	if layout == null or interaction == null:
		return
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)
	elif event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)
	elif event is InputEventMagnifyGesture:
		var magnify: InputEventMagnifyGesture = event as InputEventMagnifyGesture
		zoom_at(magnify.position, magnify.factor)
		accept_event()
	elif event is InputEventPanGesture:
		var pan_gesture: InputEventPanGesture = event as InputEventPanGesture
		pan_by(-pan_gesture.delta * interaction.trackpad_pan_multiplier)
		accept_event()

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		zoom_at(event.position, interaction.mouse_wheel_zoom_factor)
		accept_event()
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		zoom_at(event.position, 1.0 / interaction.mouse_wheel_zoom_factor)
		accept_event()
		return
	if event.button_index != MOUSE_BUTTON_LEFT and event.button_index != MOUSE_BUTTON_MIDDLE:
		return
	if event.pressed:
		mouse_drag_active = true
		mouse_drag_button = event.button_index
		mouse_dragged = false
		mouse_press_position = event.position
		mouse_last_position = event.position
		mouse_started_on_preview = placement_mode_enabled and event.button_index == MOUSE_BUTTON_LEFT and is_position_near_preview(event.position)
		if placement_mode_enabled and event.button_index == MOUSE_BUTTON_LEFT:
			placement_cell_changed.emit(get_cell_at(event.position))
	else:
		if event.button_index == MOUSE_BUTTON_LEFT and mouse_drag_active and not mouse_dragged:
			if mouse_started_on_preview:
				placement_confirmation_requested.emit()
			else:
				_activate_position(event.position)
		mouse_drag_active = false
		mouse_dragged = false
		mouse_drag_button = MOUSE_BUTTON_NONE
		mouse_started_on_preview = false
	accept_event()

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	var cell: Vector2i = get_cell_at(event.position)
	if not mouse_drag_active or mouse_drag_button == MOUSE_BUTTON_LEFT:
		hovered_cell_changed.emit(cell)
	if not mouse_drag_active:
		return
	if not mouse_dragged and event.position.distance_to(mouse_press_position) >= interaction.drag_start_distance:
		mouse_dragged = true
	if mouse_dragged:
		if not placement_mode_enabled or mouse_drag_button != MOUSE_BUTTON_LEFT:
			pan_by(event.position - mouse_last_position)
		mouse_last_position = event.position
		accept_event()

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		touch_positions[event.index] = event.position
		if touch_positions.size() == 1:
			touch_press_position = event.position
			touch_dragged = false
			touch_started_on_preview = placement_mode_enabled and is_position_near_preview(event.position)
			swipe_gesture.begin(event.index, event.position, placement_mode_enabled and not touch_started_on_preview)
		else:
			touch_dragged = true
			swipe_gesture.reset()
	else:
		var completed_swipe: bool = swipe_gesture.finish(event.index, event.position)
		var was_single_tap: bool = touch_positions.size() == 1 and touch_positions.has(event.index) and not touch_dragged and not completed_swipe
		touch_positions.erase(event.index)
		if completed_swipe:
			rotation_requested.emit(true)
		elif was_single_tap:
			if touch_started_on_preview:
				placement_confirmation_requested.emit()
			else:
				_activate_position(event.position)
		if touch_positions.size() == 1:
			touch_press_position = touch_positions.values()[0] as Vector2
			touch_dragged = true
		elif touch_positions.is_empty():
			touch_dragged = false
			touch_started_on_preview = false
	accept_event()

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if not touch_positions.has(event.index):
		return
	var previous_positions: Dictionary[int, Vector2] = touch_positions.duplicate()
	touch_positions[event.index] = event.position
	if touch_positions.size() >= 2:
		swipe_gesture.reset()
		_apply_pinch(previous_positions)
		touch_dragged = true
	else:
		if swipe_gesture.update(event.index, event.position):
			touch_dragged = event.position.distance_to(touch_press_position) >= interaction.drag_start_distance
			accept_event()
			return
		if not touch_dragged and event.position.distance_to(touch_press_position) >= interaction.drag_start_distance:
			touch_dragged = true
		if touch_dragged:
			if placement_mode_enabled:
				placement_cell_changed.emit(get_cell_at(event.position))
			else:
				pan_by(event.relative)
	accept_event()

func _apply_pinch(previous_positions: Dictionary[int, Vector2]) -> void:
	var indices: Array[int] = []
	indices.assign(touch_positions.keys())
	if indices.size() < 2 or not previous_positions.has(indices[0]) or not previous_positions.has(indices[1]):
		return
	var previous_first: Vector2 = previous_positions[indices[0]]
	var previous_second: Vector2 = previous_positions[indices[1]]
	var current_first: Vector2 = touch_positions[indices[0]]
	var current_second: Vector2 = touch_positions[indices[1]]
	var previous_distance: float = maxf(previous_first.distance_to(previous_second), interaction.minimum_pinch_distance)
	var current_distance: float = maxf(current_first.distance_to(current_second), interaction.minimum_pinch_distance)
	var previous_midpoint: Vector2 = (previous_first + previous_second) * 0.5
	var current_midpoint: Vector2 = (current_first + current_second) * 0.5
	var world_anchor: Vector2 = get_world_position_at(previous_midpoint)
	target_zoom = clampf(target_zoom * current_distance / previous_distance, interaction.minimum_zoom, interaction.maximum_zoom)
	target_pan = current_midpoint - world_anchor * target_zoom
	_clamp_target_pan()
	camera_changed.emit(target_zoom)

func _activate_position(position: Vector2) -> void:
	var cell: Vector2i = get_cell_at(position)
	if cell.x < 0 or cell.y < 0 or cell.x >= layout.board_size.x or cell.y >= layout.board_size.y:
		return
	var region: UpgradeBoardRegion = layout.get_region_at(cell)
	if region != null:
		select_region(region)
		region_selected.emit(region)
	cell_activated.emit(cell)

func is_position_near_preview(position: Vector2) -> bool:
	if preview_cells.is_empty() or interaction == null:
		return false
	var world_position: Vector2 = get_world_position_at(position, false)
	var proximity: float = interaction.cell_pixel_size * interaction.preview_hit_padding_ratio
	for cell: Vector2i in preview_cells:
		var rectangle: Rect2 = Rect2(Vector2(cell) * interaction.cell_pixel_size, Vector2.ONE * interaction.cell_pixel_size).grow(proximity)
		if rectangle.has_point(world_position):
			return true
	return false

func _clamp_target_pan() -> void:
	if layout == null or interaction == null:
		return
	var scaled_board_size: Vector2 = Vector2(layout.board_size) * interaction.cell_pixel_size * target_zoom
	target_pan.x = _clamp_axis(target_pan.x, size.x, scaled_board_size.x)
	target_pan.y = _clamp_axis(target_pan.y, size.y, scaled_board_size.y)

func _clamp_axis(value: float, viewport_extent: float, board_extent: float) -> float:
	if board_extent + interaction.camera_edge_padding * 2.0 <= viewport_extent:
		return clampf(value, interaction.camera_edge_padding, viewport_extent - board_extent - interaction.camera_edge_padding)
	var minimum: float = viewport_extent - board_extent - interaction.camera_edge_padding
	var maximum: float = interaction.camera_edge_padding
	return clampf(value, minimum, maximum)

func _handle_resize() -> void:
	if not camera_initialized:
		fit_board()
	else:
		_clamp_target_pan()
		camera_pan = target_pan
		_sync_tile_map_transform()
		queue_redraw()
