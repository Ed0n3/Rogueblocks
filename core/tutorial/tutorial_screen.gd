class_name TutorialScreen
extends RefCounted

enum Value { NONE, HUB, DRAFT, ROUTE, COMBAT, REWARD, ARTIFACT, SHOP, UPGRADES }

static func from_legacy(reference: StringName) -> Value:
	var keys: Array = Value.keys()
	var index: int = keys.find(String(reference).to_upper())
	return index as Value if index >= 0 else Value.NONE
