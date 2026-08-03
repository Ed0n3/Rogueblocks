class_name ProfileMigration7To8
extends SaveMigration

func get_source_version() -> int:
	return 7

func get_target_version() -> int:
	return 8

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var ranked_attempt_dates: Array[String] = []
	for value: Variant in migrated.get("ranked_daily_attempt_dates", []) as Array:
		var date_key: String = String(value)
		if not date_key.is_empty() and not ranked_attempt_dates.has(date_key):
			ranked_attempt_dates.append(date_key)
	for value: Variant in migrated.get("daily_history", []) as Array:
		var entry: Dictionary = value as Dictionary
		var date_key: String = String(entry.get("date", ""))
		if not bool(entry.get("practice", false)) and not date_key.is_empty() and not ranked_attempt_dates.has(date_key):
			ranked_attempt_dates.append(date_key)
	migrated["ranked_daily_attempt_dates"] = ranked_attempt_dates
	migrated["version"] = 8
	return migrated
