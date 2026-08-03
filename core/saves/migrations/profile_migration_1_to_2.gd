class_name ProfileMigration1To2
extends SaveMigration

func get_source_version() -> int:
	return 1

func get_target_version() -> int:
	return 2

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["purchased_upgrade_levels"] = migrated.get("purchased_upgrade_levels", {})
	migrated["version"] = 2
	return migrated
