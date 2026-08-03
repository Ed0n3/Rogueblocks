class_name UpgradeLevelState
extends RefCounted

var upgrade: UpgradeDefinition
var level: int = 0

func _init(definition: UpgradeDefinition = null, current_level: int = 0) -> void:
	upgrade = definition
	level = maxi(0, current_level)

func to_save_data() -> Dictionary:
	return {"upgrade": ContentReferenceCodec.encode(upgrade), "level": level}

static func from_save_data(data: Dictionary) -> UpgradeLevelState:
	var definition: UpgradeDefinition = ContentReferenceCodec.decode_legacy(String(data.get("upgrade", data.get("upgrade_id", ""))), UpgradeDefinition, ContentRegistry.catalog) as UpgradeDefinition
	return UpgradeLevelState.new(definition, int(data.get("level", 0)))
