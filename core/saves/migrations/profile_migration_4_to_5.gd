class_name ProfileMigration4To5
extends SaveMigration

func get_source_version() -> int:
	return 4

func get_target_version() -> int:
	return 5

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["discovered_items"] = migrated.get("discovered_items", migrated.get("discovered_item_ids", []))
	migrated.erase("discovered_item_ids")
	migrated["total_items_purchased"] = maxi(0, int(migrated.get("total_items_purchased", 0)))
	migrated["total_items_used"] = maxi(0, int(migrated.get("total_items_used", 0)))
	migrated["total_boss_actions_countered"] = maxi(0, int(migrated.get("total_boss_actions_countered", 0)))
	migrated["highest_items_held"] = maxi(0, int(migrated.get("highest_items_held", 0)))
	migrated["version"] = 5
	return migrated
