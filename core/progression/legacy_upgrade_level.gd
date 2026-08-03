class_name LegacyUpgradeLevel
extends RefCounted

var reference: StringName
var level: int = 0

func _init(legacy_reference: StringName = StringName(), current_level: int = 0) -> void:
	reference = legacy_reference
	level = maxi(0, current_level)

func to_save_data() -> Dictionary:
	return {"reference": String(reference), "level": level}

static func from_save_data(data: Dictionary) -> LegacyUpgradeLevel:
	return LegacyUpgradeLevel.new(StringName(String(data.get("reference", ""))), int(data.get("level", 0)))
