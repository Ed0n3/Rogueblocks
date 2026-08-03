class_name ItemCategory
extends RefCounted

enum Value { HEALING_POTION, BUFF_POTION, DEBUFF_FLASK, DAMAGE_FLASK, CLEANSING_POTION, DEFENSIVE_POTION, UTILITY_ITEM, BONUS_BLOCK }

static func display_name(value: Value) -> String:
	match value:
		Value.HEALING_POTION:
			return "Integrity Device"
		Value.BUFF_POTION:
			return "Amplifier Device"
		Value.DEBUFF_FLASK:
			return "Disruption Device"
		Value.DAMAGE_FLASK:
			return "Offensive Device"
		Value.CLEANSING_POTION:
			return "Purifier Device"
		Value.DEFENSIVE_POTION:
			return "Defensive Device"
		Value.UTILITY_ITEM:
			return "Utility Device"
		Value.BONUS_BLOCK:
			return "Bonus Block"
	return "Field Device"
