class_name BoardView
extends Control

const BoardTileMapRenderer = preload("res://presentation/board/board_tile_map_renderer.gd")

signal placement_requested(origin: Vector2i)
signal rotation_requested(clockwise: bool)
signal preview_confirmation_changed(available: bool)
signal invalid_placement_attempted()

const TOUCH_SWIPE_THRESHOLD: float = 48.0
const EMPTY_CELL_COLOR: Color = Color("12172a")
const BONUS_CELL_COLOR: Color = Color("24664d")
const CORRUPTED_CELL_COLOR: Color = Color("6b294f")
const LOCKED_CELL_COLOR: Color = Color("292e40")
const TARGET_CELL_COLOR: Color = Color("5c5424")
const ARMORED_CELL_COLOR: Color = Color("7a667b")
const BLOCKER_CELL_COLOR: Color = Color("596579")
const OCCUPIED_CELL_COLOR: Color = Color("319eaa")
const BLOCK_OUTLINE_WIDTH: float = 1.5
const SPECIAL_MARKER_COLOR: Color = Color("d6deea")
const BLOCKER_MARKER_MARGIN_RATIO: float = 0.2
const BLOCKER_MARKER_LINE_WIDTH_RATIO: float = 0.035
const BLOCKER_MARKER_MINIMUM_LINE_WIDTH: float = 1.5
const BLOCKER_MARKER_MAXIMUM_LINE_WIDTH: float = 3.0
const DEFAULT_EFFECT_MARKER_RADIUS_RATIO: float = 0.14
const DEFAULT_EFFECT_MARKER_INSET_RATIO: float = 0.06
const DEFAULT_EFFECT_MARKER_LINE_WIDTH: float = 2.0
const DEFAULT_EFFECT_MARKER_FILL_OPACITY: float = 0.82
const EFFECT_MARKER_BACKDROP_SCALE: float = 1.22
const EFFECT_MARKER_BACKDROP_DARKENING: float = 0.62
const EFFECT_MARKER_GLYPH_LIGHTENING: float = 0.45
const EFFECT_MARKER_GLYPH_SCALE: float = 0.62
const EFFECT_MARKER_MAXIMUM_LINE_WIDTH_RATIO: float = 0.34
const EFFECT_MARKER_OUTLINE_OPACITY: float = 0.9
const EFFECT_MARKER_HEXAGON_SIDE_COUNT: int = 6
const EFFECT_MARKER_CIRCLE_SEGMENTS: int = 16
const EFFECT_MARKER_RECYCLE_ARC_START: float = -PI * 0.72
const EFFECT_MARKER_RECYCLE_ARC_END: float = PI * 1.08
const EFFECT_MARKER_RECYCLE_ARROW_SCALE: float = 0.34
const EFFECT_MARKER_CLOCK_HOUR_HAND_SCALE: float = 0.56
const EFFECT_MARKER_CLOCK_MINUTE_HAND_SCALE: float = 0.44
const DAMAGE_GLYPH_POINTS: Array[Vector2] = [
	Vector2(0.0, -1.0),
	Vector2(0.28, -0.28),
	Vector2(1.0, 0.0),
	Vector2(0.28, 0.28),
	Vector2(0.0, 1.0),
	Vector2(-0.28, 0.28),
	Vector2(-1.0, 0.0),
	Vector2(-0.28, -0.28),
	Vector2(0.0, -1.0)
]
const FRACTURE_GLYPH_POINTS: Array[Vector2] = [
	Vector2(-0.82, -0.92),
	Vector2(-0.18, -0.24),
	Vector2(-0.48, 0.04),
	Vector2(0.12, 0.26),
	Vector2(-0.08, 0.54),
	Vector2(0.72, 0.94)
]

@export var touch_drag_threshold: float = 24.0
@export var visual_settings: CombatVisualSettings

var board: BoardState
var active_piece: PieceInstance
var preview_origin: Vector2i = Vector2i.ZERO
var preview_visible: bool = false
var interaction_enabled: bool = true
var recently_cleared: Array[Vector2i] = []
var tokens: VisualTokens
var placed_overlay_cells: Array[Vector2i] = []
var placement_progress: float = 1.0
var clear_scan_progress: float = 0.0
var clear_effect: ClearResult
var enemy_effect_cells: Array[Vector2i] = []
var enemy_effect_opacity: float = 0.0
var motion: MotionSettings
var invalid_tween: Tween
var visual_offset: Vector2 = Vector2.ZERO:
	set(value):
		visual_offset = value
		queue_redraw()
var touch_active: bool = false
var touch_index: int = -1
var touch_started_msec: int = 0
var touch_start_position: Vector2
var touch_dragged: bool = false
var touch_started_armed: bool = false
var touch_armed: bool = false
var touch_armed_origin: Vector2i = Vector2i(-1, -1)
var touch_anchor_offset: Vector2i = Vector2i.ZERO
var active_rotation_index: int = -1
var touch_confirm_candidate: bool = false
var touch_reposition_candidate: bool = false
var counter_state: ActiveCounterState
var counter_definition: CounterDefinition
var tile_renderer: BoardTileMapRenderer

func _ready() -> void:
	z_index = 1
	_ensure_tile_renderer()
	tokens = load("res://presentation/theme/visual_tokens.tres") as VisualTokens
	if visual_settings == null:
		visual_settings = load("res://content/presentation/combat_visual_settings.tres") as CombatVisualSettings
	motion = MotionSettings.from_saved_settings(SaveService.settings)

func set_board(board_state: BoardState) -> void:
	board = board_state
	if active_piece != null:
		_set_preview_origin(preview_origin)
	queue_redraw()

func set_active_piece(piece: PieceInstance) -> void:
	var piece_changed: bool = active_piece != piece
	var anchor_cell: Vector2i = preview_origin + touch_anchor_offset
	var rotation_changed: bool = not piece_changed and piece != null and piece.rotation_index != active_rotation_index
	active_piece = piece
	if piece_changed:
		touch_armed = false
		preview_visible = false
		touch_anchor_offset = _preferred_touch_anchor_offset(Vector2i.ZERO)
		preview_confirmation_changed.emit(false)
	elif rotation_changed:
		touch_anchor_offset = _rotation_touch_anchor_offset(touch_anchor_offset, anchor_cell)
		_set_preview_origin(anchor_cell - touch_anchor_offset)
		touch_armed_origin = preview_origin
		preview_confirmation_changed.emit(can_confirm_preview())
	else:
		preview_confirmation_changed.emit(can_confirm_preview())
	active_rotation_index = piece.rotation_index if piece != null else -1
	queue_redraw()

func arm_preview(candidate: PiecePlacementCandidate) -> void:
	if active_piece == null or candidate == null or not candidate.found:
		return
	active_piece.rotation_index = posmod(candidate.rotation_index, active_piece.unique_rotations.size())
	active_rotation_index = active_piece.rotation_index
	touch_anchor_offset = _preferred_touch_anchor_offset(Vector2i.ZERO)
	_set_preview_origin(candidate.origin)
	preview_visible = true
	touch_armed = true
	touch_armed_origin = preview_origin
	preview_confirmation_changed.emit(can_confirm_preview())
	queue_redraw()

func clamp_preview_to_board() -> void:
	_set_preview_origin(preview_origin)
	preview_confirmation_changed.emit(can_confirm_preview())
	queue_redraw()

func set_counter(state: ActiveCounterState, definition: CounterDefinition) -> void:
	counter_state = state
	counter_definition = definition
	queue_redraw()

func can_confirm_preview() -> bool:
	if board == null or active_piece == null or not preview_visible or not interaction_enabled:
		return false
	var preview_cells: Array[Vector2i] = []
	for offset: Vector2i in active_piece.get_cells():
		preview_cells.append(preview_origin + offset)
	return board.can_place(preview_cells)

func confirm_preview() -> void:
	if can_confirm_preview():
		_commit_preview()
	elif preview_visible:
		invalid_placement_attempted.emit()
		_play_invalid_feedback()

func get_board_rect() -> Rect2:
	if board == null:
		return Rect2()
	var cell_size: float = floorf(minf(size.x / float(board.width), size.y / float(board.height)))
	var board_size: Vector2 = Vector2(board.width, board.height) * cell_size
	return Rect2((size - board_size) * 0.5 + visual_offset, board_size)

func local_position_to_grid(local_position: Vector2) -> Vector2i:
	var rectangle: Rect2 = get_board_rect()
	if rectangle.size.x <= 0.0:
		return Vector2i(-1, -1)
	var cell_size: float = rectangle.size.x / float(board.width)
	return Vector2i(floori((local_position.x - rectangle.position.x) / cell_size), floori((local_position.y - rectangle.position.y) / cell_size))

func grid_position_to_local(grid_position: Vector2i) -> Vector2:
	var rectangle: Rect2 = get_board_rect()
	var cell_size: float = rectangle.size.x / float(board.width)
	return rectangle.position + Vector2(grid_position) * cell_size

func grid_cell_center_to_local(grid_position: Vector2i) -> Vector2:
	var rectangle: Rect2 = get_board_rect()
	var cell_size: float = rectangle.size.x / float(board.width)
	return grid_position_to_local(grid_position) + Vector2.ONE * cell_size * 0.5

func flash_cleared(cells: Array[Vector2i]) -> void:
	recently_cleared = cells.duplicate()
	queue_redraw()
	var tween: Tween = create_tween()
	tween.tween_interval(0.16)
	tween.tween_callback(func() -> void: recently_cleared.clear(); queue_redraw())

func play_placement(result: PlacementResult, motion: MotionSettings) -> void:
	placed_overlay_cells = result.placed_cells.duplicate()
	placement_progress = 0.0
	queue_redraw()
	var tween: Tween = create_tween()
	tween.tween_method(_set_placement_progress, 0.0, 1.0, motion.duration(MotionPresets.PIECE_PLACE_DURATION)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void: placed_overlay_cells.clear(); placement_progress = 1.0; queue_redraw())

func play_clear_effect(result: ClearResult, motion: MotionSettings) -> void:
	clear_effect = result
	recently_cleared = result.cleared_cells.duplicate()
	clear_scan_progress = 0.0
	queue_redraw()
	var tween: Tween = create_tween()
	tween.tween_method(_set_clear_scan_progress, 0.0, 1.0, motion.duration(MotionPresets.LINE_SCAN_DURATION + MotionPresets.LINE_REMOVE_DURATION))
	tween.tween_callback(func() -> void: clear_effect = null; recently_cleared.clear(); clear_scan_progress = 0.0; queue_redraw())

func pulse_enemy_effect(cells: Array[Vector2i], motion: MotionSettings) -> void:
	enemy_effect_cells = cells.duplicate()
	enemy_effect_opacity = 1.0
	queue_redraw()
	var tween: Tween = create_tween()
	tween.tween_method(_set_enemy_effect_opacity, 1.0, 0.0, motion.duration(0.42))
	tween.tween_callback(func() -> void: enemy_effect_cells.clear(); queue_redraw())

func finish_visual_effects() -> void:
	placed_overlay_cells.clear()
	recently_cleared.clear()
	enemy_effect_cells.clear()
	placement_progress = 1.0
	clear_scan_progress = 0.0
	enemy_effect_opacity = 0.0
	clear_effect = null
	queue_redraw()

func _set_placement_progress(value: float) -> void:
	placement_progress = value
	queue_redraw()

func _set_clear_scan_progress(value: float) -> void:
	clear_scan_progress = value
	queue_redraw()

func _set_enemy_effect_opacity(value: float) -> void:
	enemy_effect_opacity = value
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if board == null or not interaction_enabled:
		return
	if event is InputEventMouseMotion:
		var mouse_position: Vector2 = (event as InputEventMouseMotion).position
		_update_pointer_preview(mouse_position)
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and preview_visible and active_piece != null:
			confirm_preview()
	elif event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if not get_board_rect().has_point(event.position):
			return
		touch_active = true
		touch_index = event.index
		touch_started_msec = Time.get_ticks_msec()
		touch_start_position = event.position
		touch_dragged = false
		var started_near_preview: bool = touch_armed and is_position_near_preview(event.position)
		touch_started_armed = started_near_preview
		touch_reposition_candidate = touch_armed and not started_near_preview
		var touched_cell: Vector2i = local_position_to_grid(event.position)
		var started_on_preview: bool = touch_armed and _preview_contains_cell(touched_cell)
		touch_anchor_offset = _preferred_touch_anchor_offset(Vector2i.ZERO)
		touch_confirm_candidate = started_on_preview and can_confirm_preview()
		if not touch_confirm_candidate and not touch_reposition_candidate:
			_update_pointer_preview(event.position)
			if not touch_armed and not can_confirm_preview():
				touch_started_armed = true
		accept_event()
		return
	if not touch_active or event.index != touch_index:
		return
	if touch_reposition_candidate:
		if not touch_dragged:
			_update_pointer_preview(event.position)
			touch_armed = true
			touch_armed_origin = preview_origin
			preview_confirmation_changed.emit(can_confirm_preview())
	elif not touch_started_armed and touch_dragged:
		preview_visible = false
		preview_confirmation_changed.emit(false)
		queue_redraw()
	elif touch_confirm_candidate and not touch_dragged:
		_commit_preview()
	else:
		_update_pointer_preview(event.position)
		touch_armed = true
		touch_armed_origin = preview_origin
		preview_confirmation_changed.emit(can_confirm_preview())
	touch_active = false
	touch_index = -1
	touch_confirm_candidate = false
	touch_started_armed = false
	touch_reposition_candidate = false
	accept_event()

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if not touch_active or event.index != touch_index:
		return
	touch_dragged = touch_dragged or event.position.distance_to(touch_start_position) >= touch_drag_threshold
	if touch_dragged:
		touch_confirm_candidate = false
	if touch_started_armed:
		_update_pointer_preview(event.position)
	accept_event()

func _update_pointer_preview(local_position: Vector2) -> void:
	touch_anchor_offset = _preferred_touch_anchor_offset(Vector2i.ZERO)
	var anchor_cell: Vector2i = local_position_to_grid(local_position)
	_set_preview_origin(anchor_cell - touch_anchor_offset)
	preview_visible = touch_active or get_board_rect().has_point(local_position)
	preview_confirmation_changed.emit(can_confirm_preview())
	queue_redraw()

func _preview_contains_cell(cell: Vector2i) -> bool:
	if active_piece == null or not preview_visible:
		return false
	for offset: Vector2i in active_piece.get_cells():
		if preview_origin + offset == cell:
			return true
	return false

func is_position_near_preview(local_position: Vector2) -> bool:
	if active_piece == null or not preview_visible:
		return false
	var rectangle: Rect2 = get_board_rect()
	var cell_size: float = rectangle.size.x / float(board.width)
	var bounds: Rect2
	var initialized: bool = false
	for offset: Vector2i in active_piece.get_cells():
		var cell_rectangle: Rect2 = Rect2(grid_position_to_local(preview_origin + offset), Vector2.ONE * cell_size)
		bounds = bounds.merge(cell_rectangle) if initialized else cell_rectangle
		initialized = true
	return initialized and bounds.grow(cell_size * 0.45).has_point(local_position)

func _clamped_touch_origin(raw_origin: Vector2i) -> Vector2i:
	return _clamp_preview_origin(raw_origin)

func _clamp_preview_origin(raw_origin: Vector2i) -> Vector2i:
	if active_piece == null or board == null:
		return raw_origin
	var cells: Array[Vector2i] = active_piece.get_cells()
	if cells.is_empty():
		return raw_origin
	var minimum: Vector2i = cells[0]
	var maximum: Vector2i = minimum
	for offset: Vector2i in cells:
		minimum.x = mini(minimum.x, offset.x)
		minimum.y = mini(minimum.y, offset.y)
		maximum.x = maxi(maximum.x, offset.x)
		maximum.y = maxi(maximum.y, offset.y)
	var maximum_origin_x: int = board.width - 1 - maximum.x
	var maximum_origin_y: int = board.height - 1 - maximum.y
	if maximum_origin_x < -minimum.x or maximum_origin_y < -minimum.y:
		return Vector2i.ZERO
	return Vector2i(clampi(raw_origin.x, -minimum.x, maximum_origin_x), clampi(raw_origin.y, -minimum.y, maximum_origin_y))

func _set_preview_origin(raw_origin: Vector2i) -> void:
	preview_origin = _clamp_preview_origin(raw_origin)

func _preferred_touch_anchor_offset(reference: Vector2i) -> Vector2i:
	if active_piece == null:
		return Vector2i.ZERO
	var cells: Array[Vector2i] = active_piece.get_cells()
	if cells.is_empty():
		return Vector2i.ZERO
	if reference == Vector2i.ZERO:
		return cells[0]
	var best: Vector2i = cells[0]
	var best_distance: int = absi(best.x - reference.x) + absi(best.y - reference.y)
	for cell: Vector2i in cells:
		var distance: int = absi(cell.x - reference.x) + absi(cell.y - reference.y)
		if distance < best_distance or distance == best_distance and (cell.y < best.y or cell.y == best.y and cell.x < best.x):
			best = cell
			best_distance = distance
	return best

func _rotation_touch_anchor_offset(reference: Vector2i, anchor_cell: Vector2i) -> Vector2i:
	if active_piece == null:
		return Vector2i.ZERO
	var cells: Array[Vector2i] = active_piece.get_cells()
	var preferred_index: int = -1
	if active_rotation_index >= 0 and active_rotation_index < active_piece.unique_rotations.size():
		var previous_cells: Array = active_piece.unique_rotations[active_rotation_index]
		for index: int in previous_cells.size():
			if (previous_cells[index] as Vector2i) == reference:
				preferred_index = index
				break
	if preferred_index >= 0 and preferred_index < cells.size():
		var preferred_offset: Vector2i = cells[preferred_index]
		var preferred_origin: Vector2i = anchor_cell - preferred_offset
		if _clamped_touch_origin(preferred_origin) == preferred_origin:
			return preferred_offset
	var valid_offsets: Array[Vector2i] = []
	for offset: Vector2i in cells:
		var candidate_origin: Vector2i = anchor_cell - offset
		if _clamped_touch_origin(candidate_origin) == candidate_origin:
			valid_offsets.append(offset)
	if valid_offsets.is_empty():
		return _preferred_touch_anchor_offset(reference)
	var best: Vector2i = valid_offsets[0]
	var best_distance: int = absi(best.x - reference.x) + absi(best.y - reference.y)
	for offset: Vector2i in valid_offsets:
		var distance: int = absi(offset.x - reference.x) + absi(offset.y - reference.y)
		if distance < best_distance or distance == best_distance and (offset.y < best.y or offset.y == best.y and offset.x < best.x):
			best = offset
			best_distance = distance
	return best

func _commit_preview() -> void:
	var origin: Vector2i = preview_origin
	touch_armed = false
	preview_visible = false
	preview_confirmation_changed.emit(false)
	queue_redraw()
	placement_requested.emit(origin)

func _play_invalid_feedback() -> void:
	if invalid_tween != null and invalid_tween.is_valid():
		invalid_tween.kill()
	visual_offset = Vector2.ZERO
	invalid_tween = create_tween()
	if motion.reduced_motion:
		invalid_tween.tween_property(self, "modulate", Color("ffb0ad"), motion.duration(0.08))
		invalid_tween.tween_property(self, "modulate", Color.WHITE, motion.duration(0.12))
		return
	invalid_tween.tween_property(self, "visual_offset:x", -5.0, motion.duration(0.04))
	invalid_tween.tween_property(self, "visual_offset:x", 5.0, motion.duration(0.06))
	invalid_tween.tween_property(self, "visual_offset:x", 0.0, motion.duration(0.05))

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		if not touch_active and not touch_armed:
			preview_visible = false
			preview_confirmation_changed.emit(false)
			queue_redraw()
	elif what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if board == null:
		return
	_ensure_tile_renderer()
	var rectangle: Rect2 = get_board_rect()
	var cell_size: float = rectangle.size.x / float(board.width)
	var active_border: Color = tokens.border_active if tokens != null else Color("75d7e8")
	draw_rect(rectangle.grow(8.0), Color("222d4d"), false, 3.0)
	_refresh_combat_tile_map(rectangle, cell_size)
	for y: int in board.height:
		for x: int in board.width:
			var cell: Vector2i = Vector2i(x, y)
			var cell_rectangle: Rect2 = Rect2(grid_position_to_local(cell), Vector2.ONE * cell_size).grow(-1.5)
			var value: int = board.get_cell(cell)
			if value == BoardState.BLOCKER:
				_draw_blocker_marker(Rect2(grid_position_to_local(cell), Vector2.ONE * cell_size))
			elif value >= 0 and not placed_overlay_cells.has(cell):
				_draw_modifier_markers(cell_rectangle, board.get_occupant_modifiers(cell))
				_draw_piece_effect_marker(cell_rectangle, board.get_occupant_card_effect(cell))
	for cell: Vector2i in recently_cleared:
		var clear_rectangle: Rect2 = Rect2(grid_position_to_local(cell), Vector2.ONE * cell_size).grow(-2.0)
		var contraction: float = maxf(0.0, (clear_scan_progress - 0.55) / 0.45)
		clear_rectangle = clear_rectangle.grow(-clear_rectangle.size.x * 0.42 * contraction)
		draw_rect(clear_rectangle, Color(0.51, 0.94, 0.67, 0.82 * (1.0 - contraction)), true)
	_draw_clear_scan(rectangle, cell_size)
	_draw_placement_overlay(cell_size)
	for cell: Vector2i in enemy_effect_cells:
		if board.is_inside(cell):
			draw_rect(Rect2(grid_position_to_local(cell), Vector2.ONE * cell_size).grow(-3.0), Color(1.0, 0.47, 0.44, enemy_effect_opacity * 0.65), false, 4.0)
	_draw_preview_markers(cell_size)
	_draw_counter_overlay(rectangle, cell_size)
	_draw_corner_accents(rectangle, active_border)

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

func _refresh_combat_tile_map(rectangle: Rect2, cell_size: float) -> void:
	tile_renderer.clear_all()
	tile_renderer.set_board_transform(rectangle.position, cell_size)
	var poisoned_cells: Array[Vector2i] = []
	var electrified_cells: Array[Vector2i] = []
	for y: int in board.height:
		for x: int in board.width:
			var cell: Vector2i = Vector2i(x, y)
			var value: int = board.get_cell(cell)
			var cell_type: CellType.Value = board.get_cell_type(cell)
			var color: Color = _combat_cell_color(cell, value, cell_type)
			if value >= 0 or value == BoardState.BLOCKER:
				tile_renderer.set_block_tile(cell, BoardTileMapRenderer.LayerBand.OCCUPIED, color)
			else:
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.BACKGROUND, BoardTileMapRenderer.TileStyle.SOLID, color)
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.GRID, BoardTileMapRenderer.TileStyle.OUTLINE, tile_renderer.block_visual_settings.outline_color)
			if board.is_cell_poisoned(cell):
				var poison_color: Color = visual_settings.poisoned_block_color if visual_settings != null else Color("9ee83f")
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.MARKER, BoardTileMapRenderer.TileStyle.DOT, poison_color)
				poisoned_cells.append(cell)
			if board.is_cell_electrified(cell):
				var electrified_color: Color = visual_settings.electrified_block_color if visual_settings != null else Color("33e1ff")
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.MARKER, BoardTileMapRenderer.TileStyle.BOLT, electrified_color)
				electrified_cells.append(cell)
			if cell_type == CellType.Value.BONUS:
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.MARKER, BoardTileMapRenderer.TileStyle.PLUS, Color.WHITE)
			elif cell_type == CellType.Value.TARGET:
				tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.MARKER, BoardTileMapRenderer.TileStyle.TARGET, Color.WHITE)
	tile_renderer.set_status_effect_cells(poisoned_cells, electrified_cells)
	_refresh_preview_tiles()

func _draw_blocker_marker(cell_rectangle: Rect2) -> void:
	var marker_rectangle: Rect2 = cell_rectangle.grow(-cell_rectangle.size.x * BLOCKER_MARKER_MARGIN_RATIO)
	var line_width: float = clampf(cell_rectangle.size.x * BLOCKER_MARKER_LINE_WIDTH_RATIO, BLOCKER_MARKER_MINIMUM_LINE_WIDTH, BLOCKER_MARKER_MAXIMUM_LINE_WIDTH)
	draw_line(marker_rectangle.position, marker_rectangle.end, SPECIAL_MARKER_COLOR, line_width, true)
	draw_line(Vector2(marker_rectangle.end.x, marker_rectangle.position.y), Vector2(marker_rectangle.position.x, marker_rectangle.end.y), SPECIAL_MARKER_COLOR, line_width, true)

func _combat_cell_color(cell: Vector2i, value: int, cell_type: CellType.Value) -> Color:
	if cell_type == CellType.Value.BONUS:
		return BONUS_CELL_COLOR
	if cell_type == CellType.Value.CORRUPTED:
		return CORRUPTED_CELL_COLOR
	if cell_type == CellType.Value.LOCKED:
		return LOCKED_CELL_COLOR
	if cell_type == CellType.Value.TARGET:
		return TARGET_CELL_COLOR
	if cell_type == CellType.Value.ARMORED:
		return ARMORED_CELL_COLOR
	if value == BoardState.BLOCKER:
		return BLOCKER_CELL_COLOR
	if value >= 0:
		return OCCUPIED_CELL_COLOR
	var alternating_lightening: float = 0.012 if (cell.x + cell.y) % 2 == 0 else 0.0
	return EMPTY_CELL_COLOR.lightened(alternating_lightening)

func _refresh_preview_tiles() -> void:
	if not preview_visible or active_piece == null:
		return
	var cells_to_place: Array[Vector2i] = []
	for offset: Vector2i in active_piece.get_cells():
		cells_to_place.append(preview_origin + offset)
	var valid: bool = board.can_place(cells_to_place)
	var default_fill: Color = Color(0.25, 0.9, 0.55, 0.5) if valid else Color(1.0, 0.25, 0.3, 0.45)
	var invalid_marker_color: Color = Color("ff6570")
	for offset: Vector2i in active_piece.get_cells():
		var cell: Vector2i = preview_origin + offset
		if not board.is_inside(cell):
			continue
		tile_renderer.set_block_tile(cell, BoardTileMapRenderer.LayerBand.PREVIEW, _preview_cell_fill(offset, valid, default_fill))
		if not valid:
			tile_renderer.set_tile(cell, BoardTileMapRenderer.LayerBand.MARKER, BoardTileMapRenderer.TileStyle.CROSS, Color(invalid_marker_color, 0.7))

func _draw_preview_markers(cell_size: float) -> void:
	if not preview_visible or active_piece == null:
		return
	var cells_to_place: Array[Vector2i] = []
	for offset: Vector2i in active_piece.get_cells():
		cells_to_place.append(preview_origin + offset)
	if not board.can_place(cells_to_place):
		return
	for offset: Vector2i in active_piece.get_cells():
		var cell: Vector2i = preview_origin + offset
		if board.is_inside(cell):
			var rectangle: Rect2 = Rect2(grid_position_to_local(cell), Vector2.ONE * cell_size).grow(-6.0)
			_draw_modifier_markers(rectangle, active_piece.modifiers, 0.7)

func _draw_counter_overlay(rectangle: Rect2, cell_size: float) -> void:
	if counter_state == null or counter_state.resolved:
		return
	var color: Color = Color(1.0, 0.45, 0.38, 0.62)
	for row: int in counter_state.target_rows:
		var band: Rect2 = Rect2(rectangle.position.x, rectangle.position.y + float(row) * cell_size, rectangle.size.x, cell_size)
		draw_rect(band.grow(-2.0), Color(color, 0.12), true)
		draw_rect(band.grow(-2.0), color, false, 3.0)
	for column: int in counter_state.target_columns:
		var band: Rect2 = Rect2(rectangle.position.x + float(column) * cell_size, rectangle.position.y, cell_size, rectangle.size.y)
		draw_rect(band.grow(-2.0), Color(color, 0.12), true)
		draw_rect(band.grow(-2.0), color, false, 3.0)
	for cell: Vector2i in counter_state.target_cells:
		if board.is_inside(cell):
			var target: Rect2 = Rect2(grid_position_to_local(cell), Vector2.ONE * cell_size).grow(-5.0)
			draw_rect(target, color, false, 3.0)
			draw_circle(target.get_center(), 3.0, color)

func _draw_placement_overlay(cell_size: float) -> void:
	for index: int in placed_overlay_cells.size():
		var cell: Vector2i = placed_overlay_cells[index]
		if not board.is_inside(cell):
			continue
		var stagger: float = float(index) * 0.08
		var local_progress: float = clampf((placement_progress - stagger) / maxf(0.01, 1.0 - stagger), 0.0, 1.0)
		var scale_factor: float = lerpf(0.78, 1.0, minf(1.0, local_progress * 1.2))
		if local_progress > 0.72:
			scale_factor = lerpf(1.08, 1.0, (local_progress - 0.72) / 0.28)
		var center: Vector2 = grid_position_to_local(cell) + Vector2.ONE * cell_size * 0.5
		var overlay_size: Vector2 = Vector2.ONE * cell_size * scale_factor
		var overlay: Rect2 = Rect2(center - overlay_size * 0.5, overlay_size)
		PieceDrawing.draw_block_rectangle(self, overlay, Color("46c7c5"), tile_renderer.block_visual_settings.outline_color, BLOCK_OUTLINE_WIDTH, tile_renderer.block_visual_settings)
		_draw_piece_effect_marker(overlay, board.get_occupant_card_effect(cell), local_progress)

func _draw_clear_scan(rectangle: Rect2, cell_size: float) -> void:
	if clear_effect == null:
		return
	for row: int in clear_effect.completed_rows:
		var y: float = rectangle.position.y + (float(row) + 0.5) * cell_size
		var x: float = rectangle.position.x + rectangle.size.x * clear_scan_progress
		draw_line(Vector2(rectangle.position.x, y), Vector2(x, y), Color("82f0ac"), 4.0, true)
	for column: int in clear_effect.completed_columns:
		var x: float = rectangle.position.x + (float(column) + 0.5) * cell_size
		var y: float = rectangle.position.y + rectangle.size.y * clear_scan_progress
		draw_line(Vector2(x, rectangle.position.y), Vector2(x, y), Color("82f0ac"), 4.0, true)

func _draw_corner_accents(rectangle: Rect2, color: Color) -> void:
	var length: float = 18.0
	var positions: Array[Vector2] = [rectangle.position, Vector2(rectangle.end.x, rectangle.position.y), rectangle.end, Vector2(rectangle.position.x, rectangle.end.y)]
	draw_line(positions[0] - Vector2(6.0, 6.0), positions[0] + Vector2(length, -6.0), color, 3.0)
	draw_line(positions[0] - Vector2(6.0, 6.0), positions[0] + Vector2(-6.0, length), color, 3.0)
	draw_line(positions[1] + Vector2(6.0, -6.0), positions[1] + Vector2(-length, -6.0), color, 3.0)
	draw_line(positions[1] + Vector2(6.0, -6.0), positions[1] + Vector2(6.0, length), color, 3.0)
	draw_line(positions[2] + Vector2(6.0, 6.0), positions[2] + Vector2(-length, 6.0), color, 3.0)
	draw_line(positions[2] + Vector2(6.0, 6.0), positions[2] + Vector2(6.0, -length), color, 3.0)
	draw_line(positions[3] + Vector2(-6.0, 6.0), positions[3] + Vector2(length, 6.0), color, 3.0)
	draw_line(positions[3] + Vector2(-6.0, 6.0), positions[3] + Vector2(-6.0, -length), color, 3.0)

func _preview_cell_fill(offset: Vector2i, valid: bool, default_fill: Color) -> Color:
	if valid and offset == touch_anchor_offset and visual_settings != null:
		return Color(visual_settings.preview_anchor_color, maxf(default_fill.a, 0.72))
	return default_fill

func get_board_effect_markers(modifiers: Array[PieceModifierDefinition]) -> Array[PieceModifierDefinition]:
	var definitions: Array[PieceModifierDefinition] = []
	for definition: PieceModifierDefinition in modifiers:
		if definition != null and definition.has_board_effect_marker():
			definitions.append(definition)
	definitions.sort_custom(func(left: PieceModifierDefinition, right: PieceModifierDefinition) -> bool:
		if left.visual_definition.board_overlay_priority == right.visual_definition.board_overlay_priority:
			return left.priority > right.priority
		return left.visual_definition.board_overlay_priority > right.visual_definition.board_overlay_priority)
	var limit: int = visual_settings.maximum_cell_markers if visual_settings != null else 2
	if definitions.size() > limit:
		definitions.resize(limit)
	return definitions

func _draw_modifier_markers(rectangle: Rect2, modifiers: Array[PieceModifierDefinition], opacity: float = 1.0) -> void:
	var definitions: Array[PieceModifierDefinition] = get_board_effect_markers(modifiers)
	for index: int in definitions.size():
		_draw_modifier_marker(rectangle, definitions[index].visual_definition, index, definitions.size(), opacity)

func _draw_modifier_marker(rectangle: Rect2, visual: PieceModifierVisualDefinition, index: int, marker_count: int, opacity: float) -> void:
	var line_width: float = minf(visual_settings.marker_line_width if visual_settings != null else 2.4, rectangle.size.x * 0.08)
	var marker_radius: float = rectangle.size.x * (0.2 if marker_count == 1 else 0.16)
	var center_offset: float = rectangle.size.x * 0.2
	var center: Vector2 = rectangle.get_center()
	if marker_count > 1:
		center.x += -center_offset if index == 0 else center_offset
	var color: Color = Color(visual.accent_color, opacity)
	var fill_opacity: float = visual_settings.marker_fill_opacity if visual_settings != null else 0.16
	draw_circle(center, marker_radius * 1.22, Color(visual.accent_color.darkened(0.52), fill_opacity * opacity), true)
	draw_circle(center, marker_radius * 1.22, Color(color, opacity * 0.7), false, line_width, true)
	match visual.marker_style:
		PieceModifierMarkerStyle.Value.FLAME:
			var flame: PackedVector2Array = PackedVector2Array([
				center + Vector2(-marker_radius * 0.48, marker_radius * 0.7),
				center + Vector2(-marker_radius * 0.18, -marker_radius * 0.08),
				center + Vector2(marker_radius * 0.04, -marker_radius * 0.72),
				center + Vector2(marker_radius * 0.5, marker_radius * 0.02),
				center + Vector2(marker_radius * 0.36, marker_radius * 0.7)
			])
			draw_polyline(flame, color, line_width, true)
		PieceModifierMarkerStyle.Value.BUBBLES:
			draw_circle(center + Vector2(-marker_radius * 0.3, marker_radius * 0.18), marker_radius * 0.28, color, false, line_width, true)
			draw_circle(center + Vector2(marker_radius * 0.27, -marker_radius * 0.3), marker_radius * 0.2, color, false, line_width, true)
		PieceModifierMarkerStyle.Value.FRACTURE:
			var crack: PackedVector2Array = PackedVector2Array([
				center + Vector2(-marker_radius * 0.65, -marker_radius * 0.75),
				center + Vector2(-marker_radius * 0.12, -marker_radius * 0.15),
				center + Vector2(-marker_radius * 0.35, marker_radius * 0.08),
				center + Vector2(marker_radius * 0.1, marker_radius * 0.24),
				center + Vector2(marker_radius * 0.6, marker_radius * 0.75)
			])
			draw_polyline(crack, color, line_width, true)
		PieceModifierMarkerStyle.Value.HEX:
			var points: PackedVector2Array = PackedVector2Array()
			for point_index: int in 7:
				var angle: float = TAU * float(point_index) / 6.0
				points.append(center + Vector2(cos(angle), sin(angle)) * marker_radius * 0.68)
			draw_polyline(points, color, line_width, true)
		PieceModifierMarkerStyle.Value.DAMAGE:
			draw_line(center + Vector2(-marker_radius * 0.62, 0.0), center + Vector2(marker_radius * 0.62, 0.0), color, line_width, true)
			draw_line(center + Vector2(0.0, -marker_radius * 0.62), center + Vector2(0.0, marker_radius * 0.62), color, line_width, true)
			draw_circle(center, marker_radius * 0.22, color, false, line_width, true)
		_:
			draw_line(center + Vector2(-marker_radius * 0.58, marker_radius * 0.58), center + Vector2(marker_radius * 0.58, -marker_radius * 0.58), color, line_width, true)

func _draw_piece_effect_marker(rectangle: Rect2, effect: PieceCardEffectDefinition, opacity: float = 1.0) -> void:
	if effect == null:
		return
	var radius_ratio: float = visual_settings.piece_effect_marker_radius_ratio if visual_settings != null else DEFAULT_EFFECT_MARKER_RADIUS_RATIO
	var inset_ratio: float = visual_settings.piece_effect_marker_inset_ratio if visual_settings != null else DEFAULT_EFFECT_MARKER_INSET_RATIO
	var configured_line_width: float = visual_settings.piece_effect_marker_line_width if visual_settings != null else DEFAULT_EFFECT_MARKER_LINE_WIDTH
	var fill_opacity: float = visual_settings.piece_effect_marker_fill_opacity if visual_settings != null else DEFAULT_EFFECT_MARKER_FILL_OPACITY
	var radius: float = rectangle.size.x * radius_ratio
	var inset: float = rectangle.size.x * inset_ratio
	var center: Vector2 = Vector2(rectangle.end.x - inset - radius, rectangle.position.y + inset + radius)
	var line_width: float = minf(configured_line_width, radius * EFFECT_MARKER_MAXIMUM_LINE_WIDTH_RATIO)
	var accent: Color = Color(effect.accent_color, opacity)
	var glyph_color: Color = Color(effect.accent_color.lightened(EFFECT_MARKER_GLYPH_LIGHTENING), opacity)
	draw_circle(center, radius * EFFECT_MARKER_BACKDROP_SCALE, Color(effect.accent_color.darkened(EFFECT_MARKER_BACKDROP_DARKENING), fill_opacity * opacity), true)
	draw_circle(center, radius * EFFECT_MARKER_BACKDROP_SCALE, Color(accent, EFFECT_MARKER_OUTLINE_OPACITY * opacity), false, line_width, true)
	_draw_piece_effect_glyph(center, radius * EFFECT_MARKER_GLYPH_SCALE, effect.marker_style, glyph_color, line_width)

func _draw_piece_effect_glyph(center: Vector2, radius: float, marker_style: PieceEffectMarkerStyle.Value, color: Color, line_width: float) -> void:
	match marker_style:
		PieceEffectMarkerStyle.Value.DAMAGE:
			_draw_normalized_glyph(center, radius, DAMAGE_GLYPH_POINTS, color, line_width)
		PieceEffectMarkerStyle.Value.SHIELD:
			var shield_points: PackedVector2Array = PackedVector2Array()
			for point_index: int in EFFECT_MARKER_HEXAGON_SIDE_COUNT + 1:
				var angle: float = -PI * 0.5 + TAU * float(point_index) / float(EFFECT_MARKER_HEXAGON_SIDE_COUNT)
				shield_points.append(center + Vector2(cos(angle), sin(angle)) * radius)
			draw_polyline(shield_points, color, line_width, true)
		PieceEffectMarkerStyle.Value.HEAL:
			draw_line(center + Vector2(-radius, 0.0), center + Vector2(radius, 0.0), color, line_width, true)
			draw_line(center + Vector2(0.0, -radius), center + Vector2(0.0, radius), color, line_width, true)
		PieceEffectMarkerStyle.Value.RECYCLE:
			draw_arc(center, radius, EFFECT_MARKER_RECYCLE_ARC_START, EFFECT_MARKER_RECYCLE_ARC_END, EFFECT_MARKER_CIRCLE_SEGMENTS, color, line_width, true)
			var arrow_tip: Vector2 = center + Vector2(cos(EFFECT_MARKER_RECYCLE_ARC_END), sin(EFFECT_MARKER_RECYCLE_ARC_END)) * radius
			var arrow_size: float = radius * EFFECT_MARKER_RECYCLE_ARROW_SCALE
			draw_colored_polygon(PackedVector2Array([
				arrow_tip,
				arrow_tip + Vector2(-arrow_size, -arrow_size),
				arrow_tip + Vector2(arrow_size, -arrow_size)
			]), color)
		PieceEffectMarkerStyle.Value.DELAY:
			draw_circle(center, radius, color, false, line_width, true)
			draw_line(center, center + Vector2(0.0, -radius * EFFECT_MARKER_CLOCK_HOUR_HAND_SCALE), color, line_width, true)
			draw_line(center, center + Vector2(radius * EFFECT_MARKER_CLOCK_MINUTE_HAND_SCALE, 0.0), color, line_width, true)
		PieceEffectMarkerStyle.Value.FRACTURE:
			_draw_normalized_glyph(center, radius, FRACTURE_GLYPH_POINTS, color, line_width)
		PieceEffectMarkerStyle.Value.CURSE:
			draw_line(center + Vector2(-radius, -radius), center + Vector2(radius, radius), color, line_width, true)
			draw_line(center + Vector2(radius, -radius), center + Vector2(-radius, radius), color, line_width, true)
		_:
			draw_circle(center, radius, color, true)

func _draw_normalized_glyph(center: Vector2, radius: float, points: Array[Vector2], color: Color, line_width: float) -> void:
	var scaled_points: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		scaled_points.append(center + point * radius)
	draw_polyline(scaled_points, color, line_width, true)
