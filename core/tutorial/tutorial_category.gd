class_name TutorialCategory
extends RefCounted

enum Value { BASICS, BOSS_MECHANICS, BOARD_AND_CLEARING, COMBAT, EFFECTS_AND_STATUSES, DISCARD_SYSTEM, ROUTE_AND_SHOPS, ITEMS, PROGRESSION }

static func display_name(category: Value) -> String:
	return String(Value.keys()[int(category)]).capitalize().replace(" And ", " and ")
