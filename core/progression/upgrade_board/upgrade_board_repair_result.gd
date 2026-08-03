class_name UpgradeBoardRepairResult
extends RefCounted

enum Cause {
	NONE,
	LAYOUT_VERSION_MISMATCH,
	INVALID_CONFIRMED_PLACEMENT,
}

var repaired: bool
var cause: Cause
var invalid_reason: String
var returned_piece_count: int
var foundation_upgrade_count: int

func _init(
	was_repaired: bool = false,
	repair_cause: Cause = Cause.NONE,
	placement_failure_reason: String = "",
	returned_count: int = 0,
	foundation_count: int = 0
) -> void:
	repaired = was_repaired
	cause = repair_cause
	invalid_reason = placement_failure_reason
	returned_piece_count = maxi(0, returned_count)
	foundation_upgrade_count = maxi(0, foundation_count)

static func unchanged() -> UpgradeBoardRepairResult:
	return UpgradeBoardRepairResult.new()

static func recovered(
	repair_cause: Cause,
	placement_failure_reason: String,
	returned_count: int,
	foundation_count: int
) -> UpgradeBoardRepairResult:
	return UpgradeBoardRepairResult.new(true, repair_cause, placement_failure_reason, returned_count, foundation_count)
