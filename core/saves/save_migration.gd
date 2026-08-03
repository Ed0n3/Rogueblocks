class_name SaveMigration
extends RefCounted

func get_source_version() -> int:
	return 0

func get_target_version() -> int:
	return 0

func migrate(data: Dictionary) -> Dictionary:
	return data.duplicate(true)
