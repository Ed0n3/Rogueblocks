class_name UpgradeBoardService
extends Resource

const MISSING_STATE_MESSAGE: String = "The Upgrade Board state is unavailable."
const MISSING_PLACEMENT_MESSAGE: String = "No Block placement was provided."
const UNKNOWN_PIECE_MESSAGE: String = "This Block is not available."
const EMPTY_PIECE_MESSAGE: String = "This Block has no cells to place."
const OUTSIDE_BOARD_MESSAGE: String = "The Block must stay inside the Upgrade Board."
const WALL_MESSAGE: String = "Blocks cannot overlap labyrinth walls."
const OUTSIDE_AREA_MESSAGE: String = "The Block must fit entirely inside one upgrade area."
const PLACEMENT_OVERLAP_MESSAGE: String = "This placement overlaps another Block."
const LEGACY_OVERLAP_MESSAGE: String = "This placement overlaps cells reserved by an existing upgrade."
const COMPLETED_AREA_MESSAGE: String = "This upgrade area is already complete."
const INVALID_PLACEMENT_MESSAGE: String = "A staged Block placement is invalid: %s"
const PIECE_TOTAL_MISMATCH_MESSAGE: String = "The staged Blocks do not match the available reserve."
const CONFIRMED_PLACEMENT_CHANGED_MESSAGE: String = "Confirmed Block placements cannot be moved or removed."
const OUTDATED_LAYOUT_MESSAGE: String = "The Upgrade Board layout must be recovered before changes can be confirmed."
const DUPLICATE_PLACEMENT_TOKEN_MESSAGE: String = "A Block placement token is duplicated."
const MISSING_PROFILE_MESSAGE: String = "The profile is unavailable."
const MISSING_INVENTORY_MESSAGE: String = "The Block reserve is unavailable."

var configuration: UpgradeMatrixConfiguration
var rules: UpgradeMatrixConfiguration:
	get:
		return configuration
var layout: UpgradeBoardLayout

func _init(matrix_configuration: UpgradeMatrixConfiguration = null, board_layout: UpgradeBoardLayout = null) -> void:
	configuration = matrix_configuration if matrix_configuration != null else UpgradeMatrixConfiguration.load_default()
	layout = board_layout

func get_placement_cells(placement: UpgradeBoardPlacement) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if placement == null:
		return cells
	var piece: PieceDefinition = placement.piece
	if piece == null:
		return cells
	var rotations: Array[Array] = PieceRotationService.get_unique_rotations(piece)
	if rotations.is_empty():
		return cells
	var rotation_index: int = posmod(placement.rotation_index, rotations.size())
	for cell_value: Variant in rotations[rotation_index]:
		var cell_offset: Vector2i = cell_value as Vector2i
		cells.append(placement.origin + cell_offset)
	return cells

func validate_placement(
	state: UpgradeBoardState,
	placement: UpgradeBoardPlacement,
	legacy_levels: Array[UpgradeLevelState]
) -> UpgradeBoardPlacementResult:
	if state == null:
		return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.MISSING_STATE, MISSING_STATE_MESSAGE)
	var occupied_cells: Dictionary[Vector2i, bool] = _get_placement_cell_lookup(state)
	return _validate_placement_against_cell_lookups(placement, occupied_cells, legacy_levels)

func create_occupied_cell_lookup(state: UpgradeBoardState) -> Dictionary[Vector2i, bool]:
	if state == null:
		return {}
	return _get_placement_cell_lookup(state)

func validate_placement_with_occupied_cells(
	placement: UpgradeBoardPlacement,
	occupied_cells: Dictionary[Vector2i, bool],
	legacy_levels: Array[UpgradeLevelState]
) -> UpgradeBoardPlacementResult:
	return _validate_placement_against_cell_lookups(placement, occupied_cells, legacy_levels)

func _validate_placement_against_cell_lookups(
	placement: UpgradeBoardPlacement,
	occupied_cells: Dictionary[Vector2i, bool],
	legacy_levels: Array[UpgradeLevelState],
	legacy_cells: Dictionary[Vector2i, bool] = {},
	uses_complete_legacy_lookup: bool = false
) -> UpgradeBoardPlacementResult:
	if placement == null:
		return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.MISSING_PLACEMENT, MISSING_PLACEMENT_MESSAGE)
	if placement.piece == null:
		return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.UNKNOWN_PIECE, UNKNOWN_PIECE_MESSAGE)
	var cells: Array[Vector2i] = get_placement_cells(placement)
	if cells.is_empty():
		return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.EMPTY_PIECE, EMPTY_PIECE_MESSAGE)
	for cell: Vector2i in cells:
		if layout == null or not layout.is_within_bounds(cell):
			return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.OUTSIDE_BOARD, OUTSIDE_BOARD_MESSAGE, cells)
	for cell: Vector2i in cells:
		if layout.is_wall(cell):
			return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.WALL, WALL_MESSAGE, cells)
	var placement_region: UpgradeBoardRegion = layout.get_region_at(cells[0])
	if placement_region == null:
		return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.OUTSIDE_AREA, OUTSIDE_AREA_MESSAGE, cells)
	for cell: Vector2i in cells:
		if layout.get_region_at(cell) != placement_region or not placement_region.has_usable_cell(cell):
			return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.OUTSIDE_AREA, OUTSIDE_AREA_MESSAGE, cells)
	for cell: Vector2i in cells:
		if occupied_cells.has(cell):
			return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.PLACEMENT_OVERLAP, PLACEMENT_OVERLAP_MESSAGE, cells)
	var applicable_legacy_cells: Dictionary[Vector2i, bool] = legacy_cells
	if not uses_complete_legacy_lookup:
		applicable_legacy_cells = _get_legacy_cell_lookup([placement_region], legacy_levels)
	for cell: Vector2i in cells:
		if applicable_legacy_cells.has(cell):
			return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.LEGACY_OVERLAP, LEGACY_OVERLAP_MESSAGE, cells)
	if _is_region_complete(placement_region, occupied_cells, applicable_legacy_cells):
		return UpgradeBoardPlacementResult.rejected(UpgradeBoardPlacementResult.Failure.COMPLETED_AREA, COMPLETED_AREA_MESSAGE, cells)
	var affected_regions: Array[UpgradeBoardRegion] = [placement_region]
	return UpgradeBoardPlacementResult.accepted(placement_region, affected_regions, cells)

func _is_region_complete(
	region: UpgradeBoardRegion,
	occupied_cells: Dictionary[Vector2i, bool],
	legacy_cells: Dictionary[Vector2i, bool]
) -> bool:
	if region == null or region.upgrade == null:
		return false
	if region.upgrade.final_level_requires_full_area:
		return false
	var thresholds: PackedInt32Array = region.get_thresholds(configuration)
	var final_threshold_index: int = mini(region.upgrade.max_level, thresholds.size()) - 1
	if final_threshold_index < 0:
		return false
	var final_threshold: int = thresholds[final_threshold_index]
	var filled_cells: int = 0
	for cell: Vector2i in region.usable_cells:
		if occupied_cells.has(cell) or legacy_cells.has(cell):
			filled_cells += 1
			if filled_cells >= final_threshold:
				return true
	return false

func _get_legacy_cell_lookup(regions: Array[UpgradeBoardRegion], legacy_levels: Array[UpgradeLevelState]) -> Dictionary[Vector2i, bool]:
	var legacy_cell_lookup: Dictionary[Vector2i, bool] = {}
	for region: UpgradeBoardRegion in regions:
		for legacy_cell: Vector2i in get_legacy_cells(region, legacy_levels):
			legacy_cell_lookup[legacy_cell] = true
	return legacy_cell_lookup

func _get_all_legacy_cell_lookup(legacy_levels: Array[UpgradeLevelState]) -> Dictionary[Vector2i, bool]:
	var legacy_cell_lookup: Dictionary[Vector2i, bool] = {}
	if layout == null:
		return legacy_cell_lookup
	for region: UpgradeBoardRegion in layout.regions:
		for legacy_cell: Vector2i in get_legacy_cells(region, legacy_levels):
			legacy_cell_lookup[legacy_cell] = true
	return legacy_cell_lookup

func get_legacy_cells(region: UpgradeBoardRegion, legacy_levels: Array[UpgradeLevelState]) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if region == null or region.upgrade == null:
		return cells
	var legacy_level: int = _get_level(legacy_levels, region.upgrade)
	if legacy_level <= 0:
		return cells
	var thresholds: PackedInt32Array = region.get_thresholds(configuration)
	var threshold_index: int = mini(legacy_level, thresholds.size()) - 1
	if threshold_index < 0:
		return cells
	var reserved_count: int = mini(thresholds[threshold_index], region.usable_cells.size())
	for index: int in reserved_count:
		cells.append(region.usable_cells[index])
	return cells

func get_region_occupied_cells(
	state: UpgradeBoardState,
	region: UpgradeBoardRegion,
	legacy_levels: Array[UpgradeLevelState]
) -> Array[Vector2i]:
	var occupied: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in get_legacy_cells(region, legacy_levels):
		occupied[cell] = true
	if state != null:
		for placement: UpgradeBoardPlacement in state.placements:
			for cell: Vector2i in get_placement_cells(placement):
				if layout.get_region_at(cell) == region:
					occupied[cell] = true
	var cells: Array[Vector2i] = []
	cells.assign(occupied.keys())
	cells.sort_custom(func(left: Vector2i, right: Vector2i) -> bool: return left.y < right.y or (left.y == right.y and left.x < right.x))
	return cells

func get_region_filled_cells(
	state: UpgradeBoardState,
	region: UpgradeBoardRegion,
	legacy_levels: Array[UpgradeLevelState]
) -> int:
	return get_region_occupied_cells(state, region, legacy_levels).size()

func get_region_level(
	state: UpgradeBoardState,
	region: UpgradeBoardRegion,
	legacy_levels: Array[UpgradeLevelState]
) -> int:
	if region == null:
		return 0
	var filled_cells: int = get_region_filled_cells(state, region, legacy_levels)
	var thresholds: PackedInt32Array = region.get_thresholds(configuration)
	var level: int = 0
	for threshold: int in thresholds:
		if filled_cells < threshold:
			break
		level += 1
	return mini(level, region.upgrade.max_level)

func get_pending_activation_level_count(profile: ProfileState, state: UpgradeBoardState) -> int:
	if profile == null or state == null or layout == null:
		return 0
	var projected_levels: Dictionary[UpgradeDefinition, int] = _resolve_activation_levels(profile, state)
	var pending_level_count: int = 0
	for region: UpgradeBoardRegion in layout.regions:
		var current_level: int = profile.get_upgrade_level(region.upgrade)
		var projected_level: int = int(projected_levels.get(region.upgrade, current_level))
		pending_level_count += maxi(0, projected_level - current_level)
	return pending_level_count

func get_region_activation_requirement(
	profile: ProfileState,
	state: UpgradeBoardState,
	region: UpgradeBoardRegion
) -> ProgressionRequirementResult:
	var progression: ProgressionService = ProgressionService.new(_get_layout_upgrades())
	if profile == null:
		return progression.check_requirements(profile, region.upgrade if region != null else null)
	if state == null or region == null or region.upgrade == null:
		return ProgressionRequirementResult.rejected(ProgressionRequirementResult.Failure.INVALID_UPGRADE, progression.invalid_upgrade_message)
	var current_level: int = profile.get_upgrade_level(region.upgrade)
	var board_level: int = get_region_level(state, region, profile.upgrade_board_legacy_progress)
	if board_level <= current_level:
		return ProgressionRequirementResult.accepted()
	var projected_levels: Dictionary[UpgradeDefinition, int] = _resolve_activation_levels(profile, state)
	if int(projected_levels.get(region.upgrade, current_level)) >= board_level:
		return ProgressionRequirementResult.accepted()
	return progression.check_requirements(profile, region.upgrade, projected_levels)

func repair_confirmed_state(profile: ProfileState) -> UpgradeBoardRepairResult:
	if profile == null or layout == null or not layout.is_valid():
		return UpgradeBoardRepairResult.unchanged()
	var invalid_reason: String = _get_confirmed_state_invalid_reason(profile)
	var version_matches: bool = profile.upgrade_board_state != null and profile.upgrade_board_state.layout_version == configuration.progression.layout_version
	if version_matches and invalid_reason.is_empty():
		return UpgradeBoardRepairResult.unchanged()
	var returned_piece_count: int = 0
	if profile.upgrade_board_state != null:
		for placement: UpgradeBoardPlacement in profile.upgrade_board_state.placements:
			if placement == null or placement.piece == null:
				continue
			profile.upgrade_piece_inventory.add(placement.piece, 1)
			returned_piece_count += 1
	var foundation_upgrade_count: int = 0
	for progress: UpgradeLevelState in profile.upgrade_progress:
		var purchased_level: int = progress.level
		if purchased_level <= 0:
			continue
		var legacy_level: int = _get_level(profile.upgrade_board_legacy_progress, progress.upgrade)
		_set_level(profile.upgrade_board_legacy_progress, progress.upgrade, maxi(legacy_level, purchased_level))
		foundation_upgrade_count += 1
	profile.upgrade_board_state = UpgradeBoardState.new(configuration.progression.layout_version)
	var cause: UpgradeBoardRepairResult.Cause = UpgradeBoardRepairResult.Cause.LAYOUT_VERSION_MISMATCH
	if version_matches:
		cause = UpgradeBoardRepairResult.Cause.INVALID_CONFIRMED_PLACEMENT
	return UpgradeBoardRepairResult.recovered(cause, invalid_reason, returned_piece_count, foundation_upgrade_count)

func commit(
	profile: ProfileState,
	state: UpgradeBoardState,
	inventory: UpgradePieceInventory
) -> UpgradeBoardCommitResult:
	if profile == null:
		return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.MISSING_PROFILE, MISSING_PROFILE_MESSAGE)
	if state == null:
		return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.MISSING_STATE, MISSING_STATE_MESSAGE)
	if inventory == null:
		return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.MISSING_INVENTORY, MISSING_INVENTORY_MESSAGE)
	if profile.upgrade_board_state.layout_version != configuration.progression.layout_version or state.layout_version != configuration.progression.layout_version:
		return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.OUTDATED_LAYOUT, OUTDATED_LAYOUT_MESSAGE)
	if not _confirmed_placements_are_preserved(profile.upgrade_board_state, state):
		return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.INVALID_PLACEMENT, CONFIRMED_PLACEMENT_CHANGED_MESSAGE)
	if not _piece_totals_match(profile.upgrade_piece_inventory, profile.upgrade_board_state, inventory, state):
		return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.PIECE_TOTAL_MISMATCH, PIECE_TOTAL_MISMATCH_MESSAGE)
	if _has_duplicate_placement_tokens(state.placements):
		return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.INVALID_PLACEMENT, DUPLICATE_PLACEMENT_TOKEN_MESSAGE)
	var validated_state: UpgradeBoardState = UpgradeBoardState.new(configuration.progression.layout_version)
	var occupied_cells: Dictionary[Vector2i, bool] = {}
	var legacy_cells: Dictionary[Vector2i, bool] = _get_all_legacy_cell_lookup(profile.upgrade_board_legacy_progress)
	for placement: UpgradeBoardPlacement in state.placements:
		var placement_result: UpgradeBoardPlacementResult = _validate_placement_against_cell_lookups(placement, occupied_cells, profile.upgrade_board_legacy_progress, legacy_cells, true)
		if not placement_result.valid:
			return UpgradeBoardCommitResult.rejected(UpgradeBoardCommitResult.Failure.INVALID_PLACEMENT, INVALID_PLACEMENT_MESSAGE % placement_result.reason)
		for cell: Vector2i in placement_result.cells:
			occupied_cells[cell] = true
		validated_state.placements.append(placement.duplicate_placement())
	var next_levels: Dictionary[UpgradeDefinition, int] = _resolve_activation_levels(profile, validated_state)
	var unlocked_upgrades: Array[UpgradeDefinition] = []
	var unlocked_level_count: int = 0
	for region: UpgradeBoardRegion in _get_ordered_regions():
		var current_level: int = profile.get_upgrade_level(region.upgrade)
		var next_level: int = int(next_levels.get(region.upgrade, current_level))
		if next_level > current_level:
			unlocked_upgrades.append(region.upgrade)
			unlocked_level_count += next_level - current_level
			_apply_unlock_effects(region.upgrade, profile)
	var confirmed_count: int = maxi(0, validated_state.placements.size() - profile.upgrade_board_state.placements.size())
	profile.upgrade_board_state = validated_state
	profile.upgrade_piece_inventory = inventory.duplicate_inventory()
	profile.upgrade_progress.clear()
	for upgrade: UpgradeDefinition in next_levels:
		profile.upgrade_progress.append(UpgradeLevelState.new(upgrade, next_levels[upgrade]))
	return UpgradeBoardCommitResult.accepted(unlocked_upgrades, unlocked_level_count, confirmed_count)

func _get_confirmed_state_invalid_reason(profile: ProfileState) -> String:
	if profile.upgrade_board_state == null:
		return MISSING_STATE_MESSAGE
	if _has_duplicate_placement_tokens(profile.upgrade_board_state.placements):
		return DUPLICATE_PLACEMENT_TOKEN_MESSAGE
	var occupied_cells: Dictionary[Vector2i, bool] = {}
	var legacy_cells: Dictionary[Vector2i, bool] = _get_all_legacy_cell_lookup(profile.upgrade_board_legacy_progress)
	for placement: UpgradeBoardPlacement in profile.upgrade_board_state.placements:
		var validation: UpgradeBoardPlacementResult = _validate_placement_against_cell_lookups(placement, occupied_cells, profile.upgrade_board_legacy_progress, legacy_cells, true)
		if not validation.valid:
			return validation.reason
		for cell: Vector2i in validation.cells:
			occupied_cells[cell] = true
	return String()

func _get_placement_cell_lookup(state: UpgradeBoardState) -> Dictionary[Vector2i, bool]:
	var occupied: Dictionary[Vector2i, bool] = {}
	for placement: UpgradeBoardPlacement in state.placements:
		for cell: Vector2i in get_placement_cells(placement):
			occupied[cell] = true
	return occupied

func _piece_totals_match(
	current_inventory: UpgradePieceInventory,
	current_state: UpgradeBoardState,
	candidate_inventory: UpgradePieceInventory,
	candidate_state: UpgradeBoardState
) -> bool:
	var current_totals: Dictionary[PieceDefinition, int] = _get_piece_totals(current_inventory, current_state)
	var candidate_totals: Dictionary[PieceDefinition, int] = _get_piece_totals(candidate_inventory, candidate_state)
	for piece: PieceDefinition in current_totals:
		if current_totals[piece] != int(candidate_totals.get(piece, 0)):
			return false
	for piece: PieceDefinition in candidate_totals:
		if candidate_totals[piece] != int(current_totals.get(piece, 0)):
			return false
	return true

func _get_piece_totals(inventory: UpgradePieceInventory, state: UpgradeBoardState) -> Dictionary[PieceDefinition, int]:
	var totals: Dictionary[PieceDefinition, int] = {}
	for stack: UpgradePieceStack in inventory.stacks:
		totals[stack.piece] = int(totals.get(stack.piece, 0)) + stack.quantity
	for placement: UpgradeBoardPlacement in state.placements:
		totals[placement.piece] = int(totals.get(placement.piece, 0)) + 1
	return totals

func _confirmed_placements_are_preserved(current_state: UpgradeBoardState, candidate_state: UpgradeBoardState) -> bool:
	var ordered_candidates: Array[UpgradeBoardPlacement] = []
	for candidate: UpgradeBoardPlacement in candidate_state.placements:
		if candidate != null:
			ordered_candidates.append(candidate)
	ordered_candidates.sort_custom(_placement_identity_precedes)
	for current: UpgradeBoardPlacement in current_state.placements:
		if current == null or not _contains_placement_identity(ordered_candidates, current):
			return false
	return true

func _has_duplicate_placement_tokens(placements: Array[UpgradeBoardPlacement]) -> bool:
	var placements_with_tokens: Array[UpgradeBoardPlacement] = []
	for placement: UpgradeBoardPlacement in placements:
		if placement != null and placement.placement_token != 0:
			placements_with_tokens.append(placement)
	placements_with_tokens.sort_custom(_placement_token_precedes)
	for index: int in range(1, placements_with_tokens.size()):
		if placements_with_tokens[index - 1].placement_token == placements_with_tokens[index].placement_token:
			return true
	return false

func _contains_placement_identity(ordered_placements: Array[UpgradeBoardPlacement], target: UpgradeBoardPlacement) -> bool:
	var lower_bound: int = 0
	var upper_bound: int = ordered_placements.size()
	while lower_bound < upper_bound:
		var midpoint: int = lower_bound + ((upper_bound - lower_bound) >> 1)
		var candidate: UpgradeBoardPlacement = ordered_placements[midpoint]
		if _placements_match(candidate, target):
			return true
		if _placement_identity_precedes(candidate, target):
			lower_bound = midpoint + 1
		else:
			upper_bound = midpoint
	return false

func _placements_match(left: UpgradeBoardPlacement, right: UpgradeBoardPlacement) -> bool:
	return left != null and right != null and left.placement_token == right.placement_token and left.piece == right.piece and left.origin == right.origin and left.rotation_index == right.rotation_index

func _placement_token_precedes(left: UpgradeBoardPlacement, right: UpgradeBoardPlacement) -> bool:
	return left.placement_token < right.placement_token

func _placement_identity_precedes(left: UpgradeBoardPlacement, right: UpgradeBoardPlacement) -> bool:
	if left.placement_token != right.placement_token:
		return left.placement_token < right.placement_token
	if left.piece != right.piece:
		return left.piece.resource_path < right.piece.resource_path
	if left.origin.y != right.origin.y:
		return left.origin.y < right.origin.y
	if left.origin.x != right.origin.x:
		return left.origin.x < right.origin.x
	return left.rotation_index < right.rotation_index

func _apply_unlock_effects(upgrade: UpgradeDefinition, profile: ProfileState) -> void:
	for effect: PermanentUpgradeEffect in upgrade.effects:
		if effect is UnlockContentEffect:
			(effect as UnlockContentEffect).apply_to_profile(profile)

func _resolve_activation_levels(
	profile: ProfileState,
	state: UpgradeBoardState
) -> Dictionary[UpgradeDefinition, int]:
	var projected_levels: Dictionary[UpgradeDefinition, int] = {}
	if profile == null:
		return projected_levels
	for progress: UpgradeLevelState in profile.upgrade_progress:
		projected_levels[progress.upgrade] = progress.level
	if state == null or layout == null:
		return projected_levels
	var progression: ProgressionService = ProgressionService.new(_get_layout_upgrades())
	var activation_changed: bool = true
	while activation_changed:
		activation_changed = false
		for region: UpgradeBoardRegion in _get_ordered_regions():
			var upgrade: UpgradeDefinition = region.upgrade
			var current_level: int = int(projected_levels.get(upgrade, profile.get_upgrade_level(upgrade)))
			var board_level: int = get_region_level(state, region, profile.upgrade_board_legacy_progress)
			var eligible_level: int = mini(upgrade.max_level, maxi(current_level, board_level))
			if eligible_level <= current_level:
				continue
			var requirement: ProgressionRequirementResult = progression.check_requirements(profile, upgrade, projected_levels)
			if not requirement.allowed:
				continue
			projected_levels[upgrade] = eligible_level
			activation_changed = true
	return projected_levels

func _get_ordered_regions() -> Array[UpgradeBoardRegion]:
	var ordered_regions: Array[UpgradeBoardRegion] = []
	if layout == null:
		return ordered_regions
	ordered_regions = layout.regions.duplicate()
	ordered_regions.sort_custom(_region_upgrade_precedes)
	return ordered_regions

func _get_layout_upgrades() -> Array[UpgradeDefinition]:
	var board_upgrades: Array[UpgradeDefinition] = []
	for region: UpgradeBoardRegion in _get_ordered_regions():
		if region.upgrade != null:
			board_upgrades.append(region.upgrade)
	return board_upgrades

func _region_upgrade_precedes(left: UpgradeBoardRegion, right: UpgradeBoardRegion) -> bool:
	return left.upgrade.resource_path < right.upgrade.resource_path

func _get_level(levels: Array[UpgradeLevelState], upgrade: UpgradeDefinition) -> int:
	for progress: UpgradeLevelState in levels:
		if progress.upgrade == upgrade:
			return progress.level
	return 0

func _set_level(levels: Array[UpgradeLevelState], upgrade: UpgradeDefinition, level: int) -> void:
	for progress: UpgradeLevelState in levels:
		if progress.upgrade == upgrade:
			progress.level = level
			return
	levels.append(UpgradeLevelState.new(upgrade, level))
