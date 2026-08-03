class_name UpgradeBoardCommitResult
extends RefCounted

enum Failure {
	NONE,
	MISSING_PROFILE,
	MISSING_STATE,
	MISSING_INVENTORY,
	INVALID_PLACEMENT,
	PIECE_TOTAL_MISMATCH,
	OUTDATED_LAYOUT,
}

var success: bool
var reason: String
var failure: Failure
var unlocked_upgrades: Array[UpgradeDefinition]
var unlocked_level_count: int
var confirmed_placement_count: int

func _init(
	was_successful: bool = false,
	failure_reason: String = "",
	failure_code: Failure = Failure.NONE,
	new_upgrades: Array[UpgradeDefinition] = [],
	new_level_count: int = 0,
	confirmed_count: int = 0
) -> void:
	success = was_successful
	reason = failure_reason
	failure = failure_code
	unlocked_upgrades = new_upgrades.duplicate()
	unlocked_level_count = maxi(0, new_level_count)
	confirmed_placement_count = maxi(0, confirmed_count)

static func accepted(new_upgrades: Array[UpgradeDefinition], new_level_count: int, confirmed_count: int) -> UpgradeBoardCommitResult:
	return UpgradeBoardCommitResult.new(true, "", Failure.NONE, new_upgrades, new_level_count, confirmed_count)

static func rejected(code: Failure, message: String) -> UpgradeBoardCommitResult:
	return UpgradeBoardCommitResult.new(false, message, code)
