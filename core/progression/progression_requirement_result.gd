class_name ProgressionRequirementResult
extends RefCounted

enum Failure {
	NONE,
	MISSING_PROFILE,
	INVALID_UPGRADE,
	PREREQUISITE,
	VICTORIES,
	DIFFICULTY,
	MUTUAL_EXCLUSIVITY,
}

var allowed: bool
var failure: Failure
var reason: String
var prerequisite_upgrade: UpgradeDefinition
var required_value: int
var current_value: int
var conflicting_upgrade: UpgradeDefinition

func _init(
	was_allowed: bool = false,
	failure_code: Failure = Failure.NONE,
	failure_reason: String = "",
	required_upgrade: UpgradeDefinition = null,
	minimum_value: int = 0,
	actual_value: int = 0,
	conflict: UpgradeDefinition = null
) -> void:
	allowed = was_allowed
	failure = failure_code
	reason = failure_reason
	prerequisite_upgrade = required_upgrade
	required_value = minimum_value
	current_value = actual_value
	conflicting_upgrade = conflict

static func accepted() -> ProgressionRequirementResult:
	return ProgressionRequirementResult.new(true)

static func rejected(
	code: Failure,
	message: String,
	required_upgrade: UpgradeDefinition = null,
	minimum_value: int = 0,
	actual_value: int = 0,
	conflict: UpgradeDefinition = null
) -> ProgressionRequirementResult:
	return ProgressionRequirementResult.new(false, code, message, required_upgrade, minimum_value, actual_value, conflict)
