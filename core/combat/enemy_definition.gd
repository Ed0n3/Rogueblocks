class_name EnemyDefinition
extends Resource

enum EncounterRole { NORMAL, ELITE, BOSS }

@export var display_name: String
@export var initially_unlocked: bool = true
@export var maximum_health: int = 12
@export var attack_interval: int = 4
@export var direct_damage: int = 2
@export var blocker_count: int = 0
@export var draw_count_penalty: int = 0
@export var phases: Array[EnemyPhaseDefinition] = []
@export var heal_on_no_clear: int = 0
@export var minimum_act: int = 0
@export var maximum_act: int = 0
@export var encounter_role: EncounterRole = EncounterRole.NORMAL
@export var mechanic_tier: int = 0
@export var selection_weight: float = 1.0
@export var possible_actions: Array[EnemyActionDefinition] = []
@export var fallback_action: EnemyActionDefinition
@export var visual: EnemyVisualDefinition
@export var shield_clear_response: ShieldClearResponse

@export_group("Legacy Intent")
@export var legacy_blocker_intent_name: String = "Blocker Drop"
@export_multiline var legacy_blocker_intent_description: String = "Places blockers and deals damage."
@export var legacy_direct_intent_name: String = "Direct Attack"
@export_multiline var legacy_direct_intent_description: String = "Deals direct damage."
@export var legacy_intent_action_tags: Array[StringName] = [&"attack"]

func is_valid() -> bool:
	return not display_name.is_empty() and maximum_health > 0 and attack_interval > 0 and minimum_act >= 0 and maximum_act >= minimum_act

func is_available_in_act(act: int) -> bool:
	return act >= minimum_act and act <= maximum_act

func is_unlocked(profile: ProfileState, additional_unlocks: Array[EnemyDefinition] = []) -> bool:
	return initially_unlocked or profile != null and profile.unlocked_enemies.has(self) or additional_unlocks.has(self)
