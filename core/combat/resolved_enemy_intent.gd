class_name ResolvedEnemyIntent
extends RefCounted

var action: EnemyActionDefinition
var display_name: String
var description: String
var action_tags: Array[StringName] = []
var turns_remaining: int = 1
var direct_damage: int = 0
var shield_amount: int = 0
var healing_amount: int = 0
var applied_statuses: Array[StatusDefinition] = []
var affected_cell_count: int = 0
var counter_definition: CounterDefinition
var icon_type: EnemyIntentIcon.Value = EnemyIntentIcon.Value.DAMAGE
var accent_color: Color = Color("ff786f")

func to_save_data() -> Dictionary:
	return {"action": ContentReferenceCodec.encode(action), "turns_remaining": turns_remaining}
