class_name UpgradeBoardPlacementResult
extends RefCounted

enum Failure {
	NONE,
	MISSING_STATE,
	MISSING_PLACEMENT,
	UNKNOWN_PIECE,
	EMPTY_PIECE,
	OUTSIDE_BOARD,
	WALL,
	OUTSIDE_AREA,
	PLACEMENT_OVERLAP,
	LEGACY_OVERLAP,
	COMPLETED_AREA,
}

var valid: bool
var reason: String
var failure: Failure
var region: UpgradeBoardRegion
var affected_regions: Array[UpgradeBoardRegion]
var cells: Array[Vector2i]

func _init(
	is_valid: bool = false,
	failure_reason: String = "",
	failure_code: Failure = Failure.NONE,
	placement_region: UpgradeBoardRegion = null,
	placement_regions: Array[UpgradeBoardRegion] = [],
	placement_cells: Array[Vector2i] = []
) -> void:
	valid = is_valid
	reason = failure_reason
	failure = failure_code
	region = placement_region
	affected_regions = placement_regions.duplicate()
	cells = placement_cells.duplicate()

static func accepted(placement_region: UpgradeBoardRegion, placement_regions: Array[UpgradeBoardRegion], placement_cells: Array[Vector2i]) -> UpgradeBoardPlacementResult:
	return UpgradeBoardPlacementResult.new(true, "", Failure.NONE, placement_region, placement_regions, placement_cells)

static func rejected(code: Failure, message: String, placement_cells: Array[Vector2i] = []) -> UpgradeBoardPlacementResult:
	return UpgradeBoardPlacementResult.new(false, message, code, null, [], placement_cells)
