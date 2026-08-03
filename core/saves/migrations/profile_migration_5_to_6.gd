class_name ProfileMigration5To6
extends SaveMigration

func get_source_version() -> int:
	return 5

func get_target_version() -> int:
	return 6

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["tutorial_progress"] = migrated.get("tutorial_progress", {})
	migrated["version"] = 6
	return migrated
