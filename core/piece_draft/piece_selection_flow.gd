class_name PieceSelectionFlow
extends RefCounted

enum Value { NONE, COMBAT_REWARD, COMPLETE_NODE, SHOP }

static func from_save_value(value: Variant) -> Value:
	if value is int or value is float:
		return clampi(int(value), Value.NONE, Value.SHOP) as Value
	match String(value):
		"combat_reward":
			return Value.COMBAT_REWARD
		"complete_node":
			return Value.COMPLETE_NODE
		"shop":
			return Value.SHOP
	return Value.NONE
