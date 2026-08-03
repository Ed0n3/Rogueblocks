class_name ProfileMigration2To3
extends SaveMigration

func get_source_version() -> int:
	return 2

func get_target_version() -> int:
	return 3

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["fragments"] = migrated.get("fragments", migrated.get("meta_currency", 0))
	migrated["version"] = 3
	return migrated
