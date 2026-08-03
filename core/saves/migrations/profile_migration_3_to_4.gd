class_name ProfileMigration3To4
extends SaveMigration

func get_source_version() -> int:
	return 3

func get_target_version() -> int:
	return 4

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["unlocked_pieces"] = migrated.get("unlocked_pieces", migrated.get("unlocked_piece_ids", []))
	migrated["unlocked_relics"] = migrated.get("unlocked_relics", migrated.get("unlocked_relic_ids", []))
	migrated["unlocked_enemies"] = migrated.get("unlocked_enemies", migrated.get("unlocked_enemy_ids", []))
	migrated["unlocked_events"] = migrated.get("unlocked_events", migrated.get("unlocked_event_ids", []))
	migrated.erase("unlocked_piece_ids")
	migrated.erase("unlocked_relic_ids")
	migrated.erase("unlocked_enemy_ids")
	migrated.erase("unlocked_event_ids")
	migrated["version"] = 4
	return migrated
