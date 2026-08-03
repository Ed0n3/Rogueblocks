class_name ProfileMigration8To9
extends SaveMigration

const REDRAW_UID: String = "uid://cxhukibhtn6ox"
const REDRAW_PATH: String = "res://content/upgrades/second_look.tres"
const REDRAW_LEGACY_ID: String = "upgrade_second_look"
const REDRAW_SHORT_ID: String = "second_look"
const CONTROLLED_REDRAW_UID: String = "uid://bqlrosaoedk7i"
const CONTROLLED_REDRAW_PATH: String = "res://content/upgrades/controlled_rotation.tres"
const CONTROLLED_REDRAW_LEGACY_ID: String = "upgrade_controlled_rotation"
const CONTROLLED_REDRAW_SHORT_ID: String = "controlled_rotation"
const EXPANDED_FOUNDATION_UID: String = "uid://cq6qouesjxrjj"
const EXPANDED_FOUNDATION_PATH: String = "res://content/upgrades/expanded_foundation.tres"
const EXPANDED_FOUNDATION_LEGACY_ID: String = "upgrade_expanded_foundation"
const EXPANDED_FOUNDATION_SHORT_ID: String = "expanded_foundation"
const MAXIMUM_REDRAW_LEVEL: int = 4

func get_source_version() -> int:
	return 8

func get_target_version() -> int:
	return 9

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["upgrade_progress"] = _merge_upgrade_progress(migrated.get("upgrade_progress", {}))
	migrated["upgrade_board_legacy_progress"] = _merge_upgrade_progress(migrated.get("upgrade_board_legacy_progress", {}))
	migrated["version"] = 9
	return migrated

func _merge_upgrade_progress(value: Variant) -> Variant:
	if value is Dictionary:
		return _merge_dictionary_progress(value as Dictionary)
	if value is Array:
		return _merge_array_progress(value as Array)
	return value

func _merge_dictionary_progress(progress: Dictionary) -> Dictionary:
	var merged: Dictionary = {}
	var redraw_level: int = 0
	for key: Variant in progress:
		var reference: String = String(key)
		if _is_redraw_reference(reference):
			redraw_level += maxi(0, int(progress[key]))
		elif not _is_expanded_foundation_reference(reference):
			merged[key] = progress[key]
	if redraw_level > 0:
		merged[REDRAW_UID] = mini(MAXIMUM_REDRAW_LEVEL, redraw_level)
	return merged

func _merge_array_progress(progress: Array) -> Array:
	var merged: Array = []
	var redraw_level: int = 0
	for value: Variant in progress:
		if not value is Dictionary:
			merged.append(value)
			continue
		var entry: Dictionary = value as Dictionary
		var reference: String = String(entry.get("upgrade", entry.get("upgrade_id", "")))
		if _is_redraw_reference(reference):
			redraw_level += maxi(0, int(entry.get("level", 0)))
		elif not _is_expanded_foundation_reference(reference):
			merged.append(entry.duplicate(true))
	if redraw_level > 0:
		merged.append({"upgrade": REDRAW_UID, "level": mini(MAXIMUM_REDRAW_LEVEL, redraw_level)})
	return merged

func _is_redraw_reference(reference: String) -> bool:
	match reference:
		REDRAW_UID, REDRAW_PATH, REDRAW_LEGACY_ID, REDRAW_SHORT_ID:
			return true
		CONTROLLED_REDRAW_UID, CONTROLLED_REDRAW_PATH, CONTROLLED_REDRAW_LEGACY_ID, CONTROLLED_REDRAW_SHORT_ID:
			return true
	return false

func _is_expanded_foundation_reference(reference: String) -> bool:
	match reference:
		EXPANDED_FOUNDATION_UID, EXPANDED_FOUNDATION_PATH, EXPANDED_FOUNDATION_LEGACY_ID, EXPANDED_FOUNDATION_SHORT_ID:
			return true
	return false
