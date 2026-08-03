class_name StartingRunModifiers
extends RefCounted

@export_category("Modifier Limits")
@export var minimum_starting_rerolls: int = 0
@export var maximum_starting_rerolls: int = 4
@export var minimum_draw_count_bonus: int = -1
@export var maximum_draw_count_bonus: int = 3
@export var maximum_shop_discount: float = 0.25
@export var minimum_fragment_reward_multiplier: float = 1.0
@export var maximum_fragment_reward_multiplier: float = 1.5
@export var maximum_emergency_clear_charges: int = 2
@export var maximum_last_reserve_charges: int = 1
@export var maximum_free_rerolls: int = 1
@export var maximum_item_slot_bonus: int = 3
@export var maximum_potion_stack_limit_bonus: int = 2
@export var maximum_starting_common_potions: int = 2
@export var maximum_draft_candidate_bonus: int = 3
@export var maximum_draft_selection_bonus: int = 1
@export var maximum_elite_nodes_per_route_bonus: int = 8

var maximum_health_bonus: int = 0
var starting_health_bonus: int = 0
var starting_rerolls_bonus: int = 0
var starting_run_currency: int = 0
var draw_count_bonus: int = 0
var starting_reward_choices: int = 0
var reward_rerolls: int = 0
var shop_discount: float = 0.0
var fragment_reward_multiplier: float = 1.0
var emergency_board_clear_charges: int = 0
var encounter_healing: int = 0
var last_reserve_charges: int = 0
var free_rerolls_per_encounter: int = 0
var item_slot_bonus: int = 0
var potion_stack_limit_bonus: int = 0
var starting_common_potions: int = 0
var damage_modifiers: Array[DamageModifierInstance] = []
var draft_candidate_count_bonus: int = 0
var draft_selection_count_bonus: int = 0
var guarantee_small_draft_candidate: bool = false
var elite_nodes_per_route_bonus: int = 0
var unlocked_pieces: Array[PieceDefinition] = []
var unlocked_relics: Array[RelicDefinition] = []
var unlocked_enemies: Array[EnemyDefinition] = []
var unlocked_events: Array[RunEventDefinition] = []
var unlocked_route_node_types: Array[RouteNodeState.NodeType] = []

func to_save_data() -> Dictionary:
	var saved_damage_modifiers: Array[Dictionary] = []
	for modifier: DamageModifierInstance in damage_modifiers:
		if modifier != null:
			saved_damage_modifiers.append(modifier.to_save_data())
	return {
		"maximum_health_bonus": maximum_health_bonus,
		"starting_health_bonus": starting_health_bonus,
		"starting_rerolls_bonus": starting_rerolls_bonus,
		"starting_run_currency": starting_run_currency,
		"draw_count_bonus": draw_count_bonus,
		"starting_reward_choices": starting_reward_choices,
		"reward_rerolls": reward_rerolls,
		"shop_discount": shop_discount,
		"fragment_reward_multiplier": fragment_reward_multiplier,
		"emergency_board_clear_charges": emergency_board_clear_charges,
		"encounter_healing": encounter_healing,
		"last_reserve_charges": last_reserve_charges,
		"free_rerolls_per_encounter": free_rerolls_per_encounter,
		"item_slot_bonus": item_slot_bonus,
		"potion_stack_limit_bonus": potion_stack_limit_bonus,
		"starting_common_potions": starting_common_potions,
		"damage_modifiers": saved_damage_modifiers,
		"draft_candidate_count_bonus": draft_candidate_count_bonus,
		"draft_selection_count_bonus": draft_selection_count_bonus,
		"guarantee_small_draft_candidate": guarantee_small_draft_candidate,
		"elite_nodes_per_route_bonus": elite_nodes_per_route_bonus,
		"unlocked_pieces": _resources_to_references(unlocked_pieces),
		"unlocked_relics": _resources_to_references(unlocked_relics),
		"unlocked_enemies": _resources_to_references(unlocked_enemies),
		"unlocked_events": _resources_to_references(unlocked_events),
		"unlocked_route_node_types": unlocked_route_node_types.duplicate()
	}

static func from_save_data(data: Dictionary) -> StartingRunModifiers:
	var modifiers: StartingRunModifiers = StartingRunModifiers.new()
	modifiers.maximum_health_bonus = maxi(0, int(data.get("maximum_health_bonus", 0)))
	modifiers.starting_health_bonus = maxi(0, int(data.get("starting_health_bonus", 0)))
	modifiers.starting_rerolls_bonus = clampi(int(data.get("starting_rerolls_bonus", 0)), modifiers.minimum_starting_rerolls, modifiers.maximum_starting_rerolls)
	modifiers.starting_run_currency = maxi(0, int(data.get("starting_run_currency", 0)))
	var saved_draw_count_bonus: int = int(data.get("draw_count_bonus", data.get("normal_offer_count_bonus", 0)))
	modifiers.draw_count_bonus = clampi(saved_draw_count_bonus, modifiers.minimum_draw_count_bonus, modifiers.maximum_draw_count_bonus)
	modifiers.starting_reward_choices = maxi(0, int(data.get("starting_reward_choices", 0)))
	modifiers.reward_rerolls = maxi(0, int(data.get("reward_rerolls", 0)))
	modifiers.shop_discount = clampf(float(data.get("shop_discount", 0.0)), 0.0, modifiers.maximum_shop_discount)
	modifiers.fragment_reward_multiplier = clampf(float(data.get("fragment_reward_multiplier", modifiers.minimum_fragment_reward_multiplier)), modifiers.minimum_fragment_reward_multiplier, modifiers.maximum_fragment_reward_multiplier)
	modifiers.emergency_board_clear_charges = clampi(int(data.get("emergency_board_clear_charges", 0)), 0, modifiers.maximum_emergency_clear_charges)
	modifiers.encounter_healing = maxi(0, int(data.get("encounter_healing", 0)))
	modifiers.last_reserve_charges = clampi(int(data.get("last_reserve_charges", 0)), 0, modifiers.maximum_last_reserve_charges)
	modifiers.free_rerolls_per_encounter = clampi(int(data.get("free_rerolls_per_encounter", 0)), 0, modifiers.maximum_free_rerolls)
	modifiers.item_slot_bonus = clampi(int(data.get("item_slot_bonus", 0)), 0, modifiers.maximum_item_slot_bonus)
	modifiers.potion_stack_limit_bonus = clampi(int(data.get("potion_stack_limit_bonus", 0)), 0, modifiers.maximum_potion_stack_limit_bonus)
	modifiers.starting_common_potions = clampi(int(data.get("starting_common_potions", 0)), 0, modifiers.maximum_starting_common_potions)
	for value: Variant in data.get("damage_modifiers", []) as Array:
		modifiers.damage_modifiers.append(DamageModifierInstance.from_save_data(value as Dictionary))
	modifiers.draft_candidate_count_bonus = clampi(int(data.get("draft_candidate_count_bonus", 0)), 0, modifiers.maximum_draft_candidate_bonus)
	modifiers.draft_selection_count_bonus = clampi(int(data.get("draft_selection_count_bonus", 0)), 0, modifiers.maximum_draft_selection_bonus)
	modifiers.guarantee_small_draft_candidate = bool(data.get("guarantee_small_draft_candidate", false))
	modifiers.elite_nodes_per_route_bonus = clampi(int(data.get("elite_nodes_per_route_bonus", 0)), 0, modifiers.maximum_elite_nodes_per_route_bonus)
	modifiers.unlocked_pieces = _references_to_pieces(data.get("unlocked_pieces", data.get("unlocked_piece_ids", [])) as Array)
	modifiers.unlocked_relics = _references_to_relics(data.get("unlocked_relics", data.get("unlocked_relic_ids", [])) as Array)
	modifiers.unlocked_enemies = _references_to_enemies(data.get("unlocked_enemies", data.get("unlocked_enemy_ids", [])) as Array)
	modifiers.unlocked_events = _references_to_events(data.get("unlocked_events", data.get("unlocked_event_ids", [])) as Array)
	for value: Variant in data.get("unlocked_route_node_types", []) as Array:
		modifiers.unlocked_route_node_types.append(clampi(int(value), RouteNodeState.NodeType.NORMAL_COMBAT, RouteNodeState.NodeType.BOSS) as RouteNodeState.NodeType)
	if data.get("unlocked_route_node_ids", []) as Array != []:
		modifiers.unlocked_route_node_types.append(RouteNodeState.NodeType.CHALLENGE)
	return modifiers

static func _resources_to_references(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Resource in values:
		result.append(ContentReferenceCodec.encode(value))
	return result

static func _references_to_pieces(values: Array) -> Array[PieceDefinition]:
	var result: Array[PieceDefinition] = []
	for value: Variant in values:
		var definition: PieceDefinition = ContentReferenceCodec.decode_legacy(String(value), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
		if definition != null and not result.has(definition):
			result.append(definition)
	return result

static func _references_to_relics(values: Array) -> Array[RelicDefinition]:
	var result: Array[RelicDefinition] = []
	for value: Variant in values:
		var definition: RelicDefinition = ContentReferenceCodec.decode_legacy(String(value), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
		if definition != null and not result.has(definition):
			result.append(definition)
	return result

static func _references_to_enemies(values: Array) -> Array[EnemyDefinition]:
	var result: Array[EnemyDefinition] = []
	for value: Variant in values:
		var definition: EnemyDefinition = ContentReferenceCodec.decode_legacy(String(value), EnemyDefinition, ContentRegistry.catalog) as EnemyDefinition
		if definition != null and not result.has(definition):
			result.append(definition)
	return result

static func _references_to_events(values: Array) -> Array[RunEventDefinition]:
	var result: Array[RunEventDefinition] = []
	for value: Variant in values:
		var definition: RunEventDefinition = ContentReferenceCodec.decode_legacy(String(value), RunEventDefinition, ContentRegistry.catalog) as RunEventDefinition
		if definition != null and not result.has(definition):
			result.append(definition)
	return result
