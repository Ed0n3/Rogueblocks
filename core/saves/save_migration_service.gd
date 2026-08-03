class_name SaveMigrationService
extends RefCounted

var migrations: Array[SaveMigration] = [ProfileMigration1To2.new(), ProfileMigration2To3.new(), ProfileMigration3To4.new(), ProfileMigration4To5.new(), ProfileMigration5To6.new(), ProfileMigration6To7.new(), ProfileMigration7To8.new(), ProfileMigration8To9.new()]

func migrate_profile(data: Dictionary) -> Dictionary:
	var current: Dictionary = data.duplicate(true)
	var version: int = int(current.get("version", 1))
	if version > ProfileState.CURRENT_VERSION:
		return {}
	while version < ProfileState.CURRENT_VERSION:
		var migration: SaveMigration = _find_migration(version)
		if migration == null:
			return {}
		current = migration.migrate(current)
		version = migration.get_target_version()
		if int(current.get("version", -1)) != version:
			return {}
		print("Migrated profile save to version %d" % version)
	return current

func _find_migration(source_version: int) -> SaveMigration:
	for migration: SaveMigration in migrations:
		if migration.get_source_version() == source_version:
			return migration
	return null
