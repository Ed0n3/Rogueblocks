class_name UpgradeBoardCategory
extends RefCounted

enum Value {
	RESILIENCE,
	DRAFTING,
	ECONOMY,
	DISCOVERY,
	INVENTORY,
	MASTERY,
}

static func get_display_name(category: Value) -> String:
	match category:
		Value.RESILIENCE:
			return "Resilience"
		Value.DRAFTING:
			return "Drafting"
		Value.ECONOMY:
			return "Economy"
		Value.DISCOVERY:
			return "Discovery"
		Value.INVENTORY:
			return "Inventory"
		Value.MASTERY:
			return "Mastery"
	return "Mastery"
