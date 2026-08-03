class_name EnemyActionCooldownState
extends RefCounted

var action: EnemyActionDefinition
var remaining_actions: int = 0

func to_save_data() -> Dictionary:
	return {"action": ContentReferenceCodec.encode(action), "remaining_actions": remaining_actions}

static func from_save_data(data: Dictionary) -> EnemyActionCooldownState:
	var state: EnemyActionCooldownState = EnemyActionCooldownState.new()
	state.action = ContentReferenceCodec.decode_legacy(String(data.get("action", data.get("action_id", ""))), EnemyActionDefinition, ContentRegistry.catalog) as EnemyActionDefinition
	state.remaining_actions = maxi(0, int(data.get("remaining_actions", 0)))
	return state
