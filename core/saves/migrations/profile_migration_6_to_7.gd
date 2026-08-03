class_name ProfileMigration6To7
extends SaveMigration

func get_source_version() -> int:
	return 6

func get_target_version() -> int:
	return 7

func migrate(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	var purchased_levels: Variant = migrated.get("upgrade_progress", migrated.get("purchased_upgrade_levels", {}))
	if not migrated.has("upgrade_progress"):
		migrated["upgrade_progress"] = (purchased_levels as Dictionary).duplicate(true) if purchased_levels is Dictionary else {}
	if not migrated.has("upgrade_board_legacy_progress"):
		migrated["upgrade_board_legacy_progress"] = (purchased_levels as Dictionary).duplicate(true) if purchased_levels is Dictionary else {}
	migrated["upgrade_piece_inventory"] = migrated.get("upgrade_piece_inventory", {})
	var board_state_value: Variant = migrated.get("upgrade_board_state", {})
	var board_state: Dictionary = (board_state_value as Dictionary).duplicate(true) if board_state_value is Dictionary else {}
	var placement_values: Array = board_state.get("placements", []) as Array
	if not board_state.has("layout_version") and placement_values.is_empty():
		board_state["layout_version"] = UpgradeBoardRules.load_default().layout_version
	board_state["placements"] = placement_values
	migrated["upgrade_board_state"] = board_state
	migrated.erase("purchased_upgrade_levels")
	migrated.erase("upgrade_board_legacy_levels")
	migrated.erase("board_shop_receipt_ids")
	migrated["version"] = 7
	return migrated
