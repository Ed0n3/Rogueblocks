class_name UpgradeTreeScreen
extends Control

signal back_requested()

enum PlacementSource {
	NONE,
	RESERVE,
	STAGED,
}

const PIECE_CARD_SCENE: PackedScene = preload("res://presentation/upgrade_board/upgrade_board_piece_card.tscn")
const LAYOUT_RECOVERY_MESSAGE: String = "Board layout updated safely. %d confirmed Block%s returned to the reserve and earned upgrades became foundation cells."
const INVALID_STATE_RECOVERY_MESSAGE: String = "Invalid confirmed board data was recovered safely. %d Block%s returned to the reserve and earned upgrades became foundation cells."
const RECOVERY_SAVE_FAILURE_MESSAGE: String = "Board recovery could not be saved. Your profile was restored; reopen the Matrix to retry."

## Complete typed configuration used by the Upgrade Matrix and its foundry.
@export var configuration: UpgradeMatrixConfiguration

var board_rules: UpgradeMatrixConfiguration:
	get:
		return configuration

var layout: UpgradeBoardLayout
var board_service: UpgradeBoardService
var working_state: UpgradeBoardState
var working_inventory: UpgradePieceInventory
var selected_piece: PieceDefinition
var selected_rotation_index: int = 0
var selected_region: UpgradeBoardRegion
var staged_placement_tokens: Array[int] = []
var piece_cards: Dictionary[PieceDefinition, UpgradeBoardPieceCard] = {}
var placement_sequence: int = 0
var leave_after_discard: bool = false
var reserve_touch_index: int = -1
var reserve_touch_start: Vector2
var reserve_touch_horizontal: bool = false
var opening_feedback: String = ""
var placement_candidate: UpgradeBoardPlacement
var placement_candidate_original: UpgradeBoardPlacement
var placement_candidate_valid: bool = false
var placement_candidate_positioned: bool = false
var placement_source: PlacementSource = PlacementSource.NONE
var placement_occupied_cells: Dictionary[Vector2i, bool] = {}

func _ready() -> void:
	if configuration == null:
		configuration = UpgradeMatrixConfiguration.load_default()
	layout = UpgradeBoardLayoutService.new().generate(configuration)
	board_service = UpgradeBoardService.new(configuration, layout)
	_repair_persisted_board()
	_connect_controls()
	_reset_working_copy()
	$Foundry.setup(configuration)
	%BoardView.setup(configuration, layout, working_state, SaveService.profile.upgrade_board_legacy_progress, board_service)
	if not layout.regions.is_empty():
		_select_region(layout.regions[0])
	_refresh_all()
	TutorialService.enter_screen(TutorialScreen.Value.UPGRADES, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.PROGRESSION_UPGRADE_GRID, %BoardView, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.PROGRESSION_UPGRADE_ACTIONS, %Actions, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.PROGRESSION_UPGRADE_DETAILS, %DetailPanel, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.PROGRESSION_UPGRADE_CONFIRM, %Confirm, self)
	TutorialService.publish(TutorialEventId.Value.PERMANENT_UPGRADES_OPENED)
	tree_exiting.connect(_unregister_tutorial_target, CONNECT_ONE_SHOT)

func _repair_persisted_board() -> void:
	var previous_profile_data: Dictionary = SaveService.profile.to_save_data()
	var repair: UpgradeBoardRepairResult = board_service.repair_confirmed_state(SaveService.profile)
	if not repair.repaired:
		return
	if not SaveService.save_profile():
		SaveService.profile = ProfileState.from_save_data(previous_profile_data)
		opening_feedback = RECOVERY_SAVE_FAILURE_MESSAGE
		return
	var plural_suffix: String = "" if repair.returned_piece_count == 1 else "s"
	if repair.cause == UpgradeBoardRepairResult.Cause.LAYOUT_VERSION_MISMATCH:
		opening_feedback = LAYOUT_RECOVERY_MESSAGE % [repair.returned_piece_count, plural_suffix]
	else:
		opening_feedback = INVALID_STATE_RECOVERY_MESSAGE % [repair.returned_piece_count, plural_suffix]

func _connect_controls() -> void:
	%Back.pressed.connect(_request_back)
	%Rotate.pressed.connect(_rotate_selected_piece)
	%Place.pressed.connect(_stage_placement_candidate)
	%Undo.pressed.connect(_cancel_candidate_or_undo)
	%Revert.pressed.connect(_request_revert)
	%Confirm.pressed.connect(_request_confirm)
	%OpenFoundry.pressed.connect($Foundry.open)
	$Foundry.piece_purchased.connect(_handle_foundry_purchase)
	%ConfirmChanges.confirmed.connect(_confirm_changes)
	%DiscardChanges.confirmed.connect(_discard_changes)
	%DiscardChanges.canceled.connect(_cancel_discard_request)
	%FocusRegion.pressed.connect(func() -> void: %BoardView.focus_region(selected_region))
	%ZoomIn.pressed.connect(func() -> void: %BoardView.zoom_at(%BoardView.size * 0.5, configuration.interaction.mouse_wheel_zoom_factor))
	%ZoomOut.pressed.connect(func() -> void: %BoardView.zoom_at(%BoardView.size * 0.5, 1.0 / configuration.interaction.mouse_wheel_zoom_factor))
	%FitBoard.pressed.connect(%BoardView.fit_board)
	%BoardView.cell_activated.connect(_handle_board_cell)
	%BoardView.hovered_cell_changed.connect(_move_candidate_from_hover)
	%BoardView.placement_cell_changed.connect(_move_placement_candidate)
	%BoardView.placement_confirmation_requested.connect(_stage_placement_candidate)
	%BoardView.rotation_requested.connect(_rotate_selected_piece)
	%BoardView.region_selected.connect(_select_region)
	%BoardView.camera_changed.connect(_update_zoom_label)

func _reset_working_copy() -> void:
	working_state = SaveService.profile.upgrade_board_state.duplicate_state()
	working_inventory = SaveService.profile.upgrade_piece_inventory.duplicate_inventory()
	staged_placement_tokens.clear()
	selected_piece = null
	selected_rotation_index = 0
	placement_candidate = null
	placement_candidate_original = null
	placement_candidate_valid = false
	placement_candidate_positioned = false
	placement_source = PlacementSource.NONE
	placement_occupied_cells.clear()
	leave_after_discard = false
	if is_node_ready():
		%BoardView.set_board_state(working_state)
		%BoardView.set_placement_mode_enabled(false)
		%BoardView.clear_preview()

func _refresh_all() -> void:
	_refresh_header()
	_refresh_piece_tray()
	_refresh_region_details()
	_refresh_actions()
	%BoardView.queue_redraw()

func _refresh_header() -> void:
	%FragmentBalance.text = "FRAGMENTS  %d" % SaveService.profile.fragments
	var staged_count: int = staged_placement_tokens.size()
	var activation_count: int = _get_pending_activation_level_count()
	if staged_count > 0 and activation_count > 0:
		%DirtyState.text = "%d PENDING BLOCK%s  •  %d LEVEL%s READY" % [staged_count, "" if staged_count == 1 else "S", activation_count, "" if activation_count == 1 else "S"]
	elif staged_count > 0:
		%DirtyState.text = "%d PENDING BLOCK%s" % [staged_count, "" if staged_count == 1 else "S"]
	elif activation_count > 0:
		%DirtyState.text = "%d FILLED LEVEL%s READY" % [activation_count, "" if activation_count == 1 else "S"]
	else:
		%DirtyState.text = "NO PENDING CHANGES"

func _refresh_piece_tray() -> void:
	for child: Node in %PieceTray.get_children():
		if child != %EmptyReserve:
			%PieceTray.remove_child(child)
			child.queue_free()
	piece_cards.clear()
	var total_quantity: int = working_inventory.get_total_quantity()
	%PieceCount.text = "%d Block%s available" % [total_quantity, "" if total_quantity == 1 else "s"]
	var visible_card_count: int = 0
	for piece: PieceDefinition in ContentRegistry.pieces:
		var quantity: int = working_inventory.get_quantity(piece)
		if quantity <= 0:
			continue
		var card: UpgradeBoardPieceCard = PIECE_CARD_SCENE.instantiate() as UpgradeBoardPieceCard
		card.setup(piece, quantity, configuration.presentation)
		card.selected = piece == selected_piece
		card.piece_selected.connect(_select_piece)
		%PieceTray.add_child(card)
		piece_cards[piece] = card
		visible_card_count += 1
	%EmptyReserve.visible = visible_card_count == 0
	%EmptyReserve.move_to_front()
	if selected_piece != null and working_inventory.get_quantity(selected_piece) <= 0:
		selected_piece = null
		selected_rotation_index = 0
	_update_selected_piece_label()

func _select_piece(piece: PieceDefinition) -> void:
	_cancel_placement_candidate(false)
	if working_inventory.get_quantity(piece) <= 0:
		return
	selected_piece = piece
	selected_rotation_index = 0
	placement_candidate = UpgradeBoardPlacement.new(piece, Vector2i.ZERO, selected_rotation_index)
	placement_source = PlacementSource.RESERVE
	placement_occupied_cells = board_service.create_occupied_cell_lookup(working_state)
	placement_candidate_positioned = false
	placement_candidate_valid = false
	%BoardView.set_placement_mode_enabled(true)
	%BoardView.clear_preview()
	for card_piece: PieceDefinition in piece_cards:
		piece_cards[card_piece].selected = card_piece == selected_piece
	_update_selected_piece_label()
	_refresh_actions()
#	%Feedback.text = "Move the Block with the pointer or touch, then press PLACE."

func _update_selected_piece_label() -> void:
	var piece: PieceDefinition = selected_piece
	if piece == null:
		%SelectedPiece.text = "Select a Block"
		%Rotate.disabled = true
		return
	var rotations: Array[Array] = PieceRotationService.get_unique_rotations(piece)
	var action: String = "Moving" if placement_source == PlacementSource.STAGED else "Positioning"
	%SelectedPiece.text = "%s %s  •  rotation %d/%d" % [action, piece.display_name, selected_rotation_index + 1, rotations.size()]
	%Rotate.disabled = rotations.size() <= 1

func _rotate_selected_piece(clockwise: bool = true) -> void:
	var piece: PieceDefinition = selected_piece
	if piece == null:
		return
	var rotations: Array[Array] = PieceRotationService.get_unique_rotations(piece)
	if rotations.size() <= 1:
		return
	var direction: int = 1 if clockwise else -1
	selected_rotation_index = posmod(selected_rotation_index + direction, rotations.size())
	if placement_candidate != null:
		placement_candidate.rotation_index = selected_rotation_index
	_update_selected_piece_label()
	_update_placement_candidate_preview()

func _handle_board_cell(cell: Vector2i) -> void:
	if placement_candidate != null:
		_move_placement_candidate(cell)
		return
	var staged_placement: UpgradeBoardPlacement = _find_staged_placement_at(cell)
	if staged_placement != null:
		_begin_staged_placement_edit(staged_placement)
		return
	var region: UpgradeBoardRegion = layout.get_region_at(cell)
	if region != null:
		_select_region(region)

func _move_candidate_from_hover(cell: Vector2i) -> void:
	if placement_candidate != null:
		_move_placement_candidate(cell)

func _move_placement_candidate(cell: Vector2i) -> void:
	if placement_candidate == null:
		return
	if placement_candidate_positioned and placement_candidate.origin == cell:
		return
	placement_candidate.origin = cell
	placement_candidate_positioned = true
	_update_placement_candidate_preview()

func _update_placement_candidate_preview() -> void:
	if placement_candidate == null or not placement_candidate_positioned:
		placement_candidate_valid = false
		%BoardView.clear_preview()
		_refresh_actions()
		return
	var validation: UpgradeBoardPlacementResult = board_service.validate_placement_with_occupied_cells(placement_candidate, placement_occupied_cells, SaveService.profile.upgrade_board_legacy_progress)
	placement_candidate_valid = validation.valid
	%BoardView.set_preview(board_service.get_placement_cells(placement_candidate), validation.valid)
	#%Feedback.text = "Ready to PLACE." if validation.valid else validation.reason
	_refresh_actions()

func _begin_staged_placement_edit(placement: UpgradeBoardPlacement) -> void:
	if placement == null or not staged_placement_tokens.has(placement.placement_token):
		return
	_cancel_placement_candidate(false)
	var placement_index: int = working_state.placements.find(placement)
	if placement_index < 0:
		return
	placement_candidate_original = placement.duplicate_placement()
	placement_candidate = placement.duplicate_placement()
	working_state.placements.remove_at(placement_index)
	working_inventory.add(placement.piece, 1)
	placement_occupied_cells = board_service.create_occupied_cell_lookup(working_state)
	selected_piece = placement.piece
	selected_rotation_index = placement.rotation_index
	placement_source = PlacementSource.STAGED
	placement_candidate_positioned = true
	%BoardView.set_board_state(working_state)
	%BoardView.set_placement_mode_enabled(true)
	_update_selected_piece_label()
	_update_placement_candidate_preview()
	_refresh_piece_tray()
	#%Feedback.text = "Move this staged Block, then press PLACE. Confirmed Blocks cannot be edited."

func _find_staged_placement_at(cell: Vector2i) -> UpgradeBoardPlacement:
	for placement_index: int in range(working_state.placements.size() - 1, -1, -1):
		var placement: UpgradeBoardPlacement = working_state.placements[placement_index]
		if staged_placement_tokens.has(placement.placement_token) and board_service.get_placement_cells(placement).has(cell):
			return placement
	return null

func _stage_placement_candidate() -> void:
	if placement_candidate == null or not placement_candidate_positioned:
		return
	var validation: UpgradeBoardPlacementResult = board_service.validate_placement_with_occupied_cells(placement_candidate, placement_occupied_cells, SaveService.profile.upgrade_board_legacy_progress)
	if not validation.valid:
		placement_candidate_valid = false
		#%Feedback.text = validation.reason
		_refresh_actions()
		return
	if not working_inventory.consume(placement_candidate.piece, 1):
		#%Feedback.text = "This Block is no longer available."
		_cancel_placement_candidate(true)
		return
	if placement_source == PlacementSource.RESERVE:
		placement_sequence += 1
		placement_candidate.placement_token = int(Time.get_unix_time_from_system()) * 1000000 + int(Time.get_ticks_usec() % 1000000) + placement_sequence
		staged_placement_tokens.append(placement_candidate.placement_token)
	working_state.add_placement(placement_candidate.duplicate_placement())
	var placed_piece_name: String = placement_candidate.piece.display_name
	_clear_placement_candidate()
	%BoardView.set_board_state(working_state)
	if validation.region != null:
		_select_region(validation.region)
	#%Feedback.text = "%s staged inside %s." % [placed_piece_name, validation.region.upgrade.display_name]
	_refresh_all()

func _cancel_placement_candidate(refresh_ui: bool = true) -> void:
	if placement_candidate == null:
		return
	if placement_source == PlacementSource.STAGED and placement_candidate_original != null:
		if working_inventory.consume(placement_candidate_original.piece, 1):
			working_state.add_placement(placement_candidate_original.duplicate_placement())
			%BoardView.set_board_state(working_state)
	_clear_placement_candidate()
	if refresh_ui:
		#%Feedback.text = "Placement edit canceled."
		_refresh_all()

func _clear_placement_candidate() -> void:
	placement_candidate = null
	placement_candidate_original = null
	placement_candidate_valid = false
	placement_candidate_positioned = false
	placement_source = PlacementSource.NONE
	placement_occupied_cells.clear()
	selected_piece = null
	selected_rotation_index = 0
	%BoardView.set_placement_mode_enabled(false)
	%BoardView.clear_preview()

func _cancel_candidate_or_undo() -> void:
	if placement_candidate != null:
		_cancel_placement_candidate(true)
	else:
		_undo_last_placement()

func _undo_last_placement() -> void:
	if staged_placement_tokens.is_empty():
		return
	var placement_token: int = staged_placement_tokens.pop_back()
	for index: int in range(working_state.placements.size() - 1, -1, -1):
		var placement: UpgradeBoardPlacement = working_state.placements[index]
		if placement.placement_token != placement_token:
			continue
		working_inventory.add(placement.piece, 1)
		working_state.placements.remove_at(index)
		break
	#%Feedback.text = "Last staged Block returned to the reserve."
	%BoardView.set_board_state(working_state)
	%BoardView.clear_preview()
	_refresh_all()

func _request_confirm() -> void:
	if placement_candidate != null:
		#%Feedback.text = "Press PLACE or CANCEL before confirming permanent changes."
		return
	if not _has_committable_changes():
		return
	var staged_count: int = staged_placement_tokens.size()
	var activation_count: int = _get_pending_activation_level_count()
	if staged_count > 0:
		%ConfirmChanges.dialog_text = "Confirm %d Block placement%s? Confirmed Blocks cannot be moved." % [staged_count, "" if staged_count == 1 else "s"]
		if activation_count > 0:
			%ConfirmChanges.dialog_text += " %d filled upgrade level%s will activate." % [activation_count, "" if activation_count == 1 else "s"]
	else:
		%ConfirmChanges.dialog_text = "Activate %d filled upgrade level%s now that every requirement is met?" % [activation_count, "" if activation_count == 1 else "s"]
	%ConfirmChanges.popup_centered()

func _confirm_changes() -> void:
	if not _has_committable_changes():
		return
	var previous_profile_data: Dictionary = SaveService.profile.to_save_data()
	var result: UpgradeBoardCommitResult = board_service.commit(SaveService.profile, working_state, working_inventory)
	if not result.success:
		#%Feedback.text = result.reason
		return
	if not SaveService.save_profile():
		SaveService.profile = ProfileState.from_save_data(previous_profile_data)
		_reset_working_copy()
		%BoardView.setup(configuration, layout, working_state, SaveService.profile.upgrade_board_legacy_progress, board_service)
		#%Feedback.text = "Changes could not be saved and were reverted."
		_refresh_all()
		return
	var unlocked_count: int = result.unlocked_level_count
	_reset_working_copy()
	%BoardView.setup(configuration, layout, working_state, SaveService.profile.upgrade_board_legacy_progress, board_service)
	var outcomes: PackedStringArray = []
	if result.confirmed_placement_count > 0:
		outcomes.append("%d placement%s confirmed" % [result.confirmed_placement_count, "" if result.confirmed_placement_count == 1 else "s"])
	if unlocked_count > 0:
		outcomes.append("%d upgrade level%s activated" % [unlocked_count, "" if unlocked_count == 1 else "s"])
	#%Feedback.text = " • ".join(outcomes) + "." if not outcomes.is_empty() else "Upgrade Board synchronized."
	_refresh_all()

func _request_revert() -> void:
	if not _has_pending_changes():
		return
	leave_after_discard = false
	%DiscardChanges.popup_centered()

func _request_back() -> void:
	if not _has_pending_changes():
		back_requested.emit()
		return
	leave_after_discard = true
	%DiscardChanges.popup_centered()

func _discard_changes() -> void:
	var should_leave: bool = leave_after_discard
	_reset_working_copy()
	%BoardView.setup(configuration, layout, working_state, SaveService.profile.upgrade_board_legacy_progress, board_service)
	#%Feedback.text = "Pending placements discarded."
	_refresh_all()
	if should_leave:
		back_requested.emit()

func _cancel_discard_request() -> void:
	leave_after_discard = false

func _select_region(region: UpgradeBoardRegion) -> void:
	if region == null:
		return
	selected_region = region
	%BoardView.select_region(region)
	_refresh_region_details()

func _refresh_region_details() -> void:
	if selected_region == null or board_service == null:
		return
	var upgrade: UpgradeDefinition = selected_region.upgrade
	var thresholds: PackedInt32Array = selected_region.get_thresholds(configuration)
	var filled_cells: int = board_service.get_region_filled_cells(working_state, selected_region, SaveService.profile.upgrade_board_legacy_progress)
	var filled_level: int = board_service.get_region_level(working_state, selected_region, SaveService.profile.upgrade_board_legacy_progress)
	var active_level: int = SaveService.profile.get_upgrade_level(upgrade)
	%RegionCategory.text = "%s AREA  •  %d OPEN CELLS" % [UpgradeBoardCategory.get_display_name(upgrade.category).to_upper(), selected_region.usable_cells.size()]
	%UpgradeName.text = upgrade.display_name
	%UpgradeName.add_theme_color_override("font_color", selected_region.accent_color.lightened(0.22))
	%Level.text = "LEVEL %d / %d" % [active_level, upgrade.max_level]
	%Description.text = upgrade.description
	%RegionProgress.max_value = selected_region.usable_cells.size()
	%RegionProgress.value = filled_cells
	%RegionProgressLabel.text = "%d / %d cells filled  •  %.1f%%" % [filled_cells, selected_region.usable_cells.size(), 100.0 * float(filled_cells) / float(maxi(1, selected_region.usable_cells.size()))]
	var threshold_lines: PackedStringArray = []
	for index: int in thresholds.size():
		var threshold_state: String = ""
		if active_level > index:
			threshold_state = "  ACTIVE"
		elif filled_level > index:
			threshold_state = "  FILLED • PENDING"
		threshold_lines.append("L%d  %d cells%s" % [index + 1, thresholds[index], threshold_state])
	%Thresholds.text = "\n".join(threshold_lines)
	if active_level >= upgrade.max_level:
		%NextLevel.text = "AREA COMPLETE"
	elif filled_level > active_level:
		var requirement: ProgressionRequirementResult = board_service.get_region_activation_requirement(SaveService.profile, working_state, selected_region)
		if requirement.allowed:
			%NextLevel.text = "FILLED • READY TO ACTIVATE WITH CONFIRM"
		else:
			%NextLevel.text = "FILLED • PENDING: %s" % requirement.reason
	else:
		var remaining: int = maxi(0, thresholds[active_level] - filled_cells)
		%NextLevel.text = "%d more cell%s until level %d" % [remaining, "" if remaining == 1 else "s", active_level + 1]

func _refresh_actions() -> void:
	var staged: bool = _has_pending_changes()
	var editing_candidate: bool = placement_candidate != null
	%Place.disabled = not editing_candidate or not placement_candidate_positioned or not placement_candidate_valid
	%Undo.disabled = not editing_candidate and not staged
	%Undo.tooltip_text = "Cancel Move" if editing_candidate else "Undo"
	%Revert.disabled = not staged
	if editing_candidate:
		%Confirm.disabled = true
		%Confirm.tooltip_text = "Confirm Changes"
		return
	var activation_count: int = _get_pending_activation_level_count()
	%Confirm.disabled = not staged and activation_count <= 0
	%Confirm.tooltip_text = "Confirm Changes" if staged else "Activate Upgrades" if activation_count > 0 else "Confirm Changes"

func _handle_foundry_purchase(piece: PieceDefinition) -> void:
	working_inventory.add(piece, 1)
	_refresh_all()

func _update_zoom_label(zoom: float) -> void:
	%ZoomLevel.text = "%d%%" % roundi(zoom * 100.0)

func _has_pending_changes() -> bool:
	return not staged_placement_tokens.is_empty()

func _has_committable_changes() -> bool:
	return _has_pending_changes() or _get_pending_activation_level_count() > 0

func _get_pending_activation_level_count() -> int:
	if board_service == null or working_state == null:
		return 0
	return board_service.get_pending_activation_level_count(SaveService.profile, working_state)

func _unregister_tutorial_target() -> void:
	TutorialService.leave_screen(TutorialScreen.Value.UPGRADES, self)
	TutorialTargetRegistry.unregister_owner(self)

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or $Foundry.visible:
		return
	var scroll: ScrollContainer = %PieceScroll
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and scroll.get_global_rect().has_point(touch.position):
			reserve_touch_index = touch.index
			reserve_touch_start = touch.position
			reserve_touch_horizontal = false
		elif not touch.pressed and touch.index == reserve_touch_index:
			if reserve_touch_horizontal:
				get_viewport().set_input_as_handled()
			_clear_reserve_touch()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != reserve_touch_index:
			return
		var movement: Vector2 = drag.position - reserve_touch_start
		if not reserve_touch_horizontal and movement.length() >= configuration.interaction.reserve_scroll_direction_threshold:
			if absf(movement.x) <= absf(movement.y):
				_clear_reserve_touch()
				return
			reserve_touch_horizontal = true
		if reserve_touch_horizontal:
			scroll.scroll_horizontal -= roundi(drag.relative.x)
			get_viewport().set_input_as_handled()

func _clear_reserve_touch() -> void:
	reserve_touch_index = -1
	reserve_touch_horizontal = false

func _unhandled_input(event: InputEvent) -> void:
	if $Foundry.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_request_back()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rotate_left"):
		_rotate_selected_piece(false)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rotate_right"):
		_rotate_selected_piece(true)
		get_viewport().set_input_as_handled()
