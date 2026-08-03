class_name RunState
extends RefCounted

@export_category("Content")
@export var game_rules: GameRules = preload("res://content/rules/default_game_rules.tres") as GameRules
@export var difficulty: DifficultyDefinition = preload("res://content/difficulties/standard.tres") as DifficultyDefinition

@export_category("Run Tuning")
@export var minimum_active_piece_pool_size: int = 2
@export var maximum_active_piece_pool_size: int = 12
@export var maximum_piece_copies: int = 4
@export var minimum_maximum_health: int = 1
@export var default_player_health: int = 20
@export var percent_divisor: float = 100.0

@export_category("Descriptions")
@export var removed_piece_description: String = "Removed during this run"
@export var unknown_relic_source_description: String = "Unknown source"
@export var always_active_relic_description: String = "Always active"
@export var cross_clear_relic_description: String = "Requires a cross clear"
@export var minimum_lines_relic_description: String = "Requires %d cleared lines"
@export var conditional_relic_description: String = "Conditional trigger"
@export var difficulty_modifier_description_format: String = "%s: %s"

var run_sequence: int = int(Time.get_unix_time_from_system()) * 1000 + Time.get_ticks_msec() % 1000
var seed_value: int = 1
var encounter_index: int = 0
var player_health: int = 0
var maximum_health: int = 0
var score: int = 0
var relics: Array[RelicDefinition] = []
var modifiers: RunModifiers = RunModifiers.new()
var cleared_lines: int = 0
var cleared_cells: int = 0
var cross_clears: int = 0
var perfect_clears: int = 0
var highest_combo: int = 0
var placements: int = 0
var enemies_defeated: int = 0
var elapsed_play_time: float = 0.0
var starting_modifiers: StartingRunModifiers = StartingRunModifiers.new()
var shards: int = 0
var route: GeneratedRoute
var daily_mode: bool = false
var daily_practice: bool = false
var daily_date_key: String
var debug_run: bool = false
var emergency_clear_charges: int = 0
var last_reserve_charges: int = 0
var reward_rerolls: int = 0
var removed_pieces: Array[PieceDefinition] = []
var successful_clear_turns: int = 0
var pending_corrupted_cells: int = 0
var pending_board_size: int = 0
var pending_board_width: int = 0
var pending_board_height: int = 0
var shard_reward_multiplier: float = 1.0
var last_piece: PieceDefinition
var consecutive_piece_count: int = 0
var discarded_piece_count: int = 0
var inventory: ItemInventory = ItemInventory.new()
var player_statuses: StatusCollection = StatusCollection.new()
var player_shield: int = 0
var temporary_item_slot_bonus: int = 0
var item_uses_remaining: int = -1
var bosses_defeated: int = 0
var boss_fragments_earned: int = 0
var pending_profile_fragments: int = 0
var unviewed_pieces: Array[PieceDefinition] = []
var unviewed_relics: Array[RelicDefinition] = []
var relic_acquisition_sources: Array[RelicAcquisitionState] = []
var artifacts: Array[BossArtifactState] = []
var unviewed_artifacts: Array[BossArtifactDefinition] = []
var enemy_selections: Array[EnemySelectionState] = []
var last_normal_enemy: EnemyDefinition
var piece_modifiers: Array[PieceModifierState] = []
var pending_piece_selection_flow: PieceSelectionFlow.Value = PieceSelectionFlow.Value.NONE
var run_mode: RunMode.Value = RunMode.Value.STANDARD
var piece_draft: PieceDraftState
var deck_cards: Array[PieceCardState] = []
var next_piece_card_id: int = 1
var pending_piece_addition: PendingPieceAdditionState

signal piece_pool_changed()
signal relics_changed()
signal run_modifiers_changed()
signal artifacts_changed()
signal piece_modifiers_changed()

func _init() -> void:
	player_health = default_player_health
	maximum_health = default_player_health

func heal(amount: int) -> void:
	player_health = mini(maximum_health, player_health + amount)

func apply_player_health_damage(amount: int, reserve_health: int) -> int:
	var applied_damage: int = mini(player_health, maxi(0, amount))
	var survival_health: int = clampi(reserve_health, 1, maxi(1, maximum_health))
	if applied_damage > 0 and player_health - applied_damage <= 0 and last_reserve_charges > 0:
		applied_damage = maxi(0, player_health - survival_health)
		last_reserve_charges -= 1
		player_health = survival_health
	else:
		player_health = maxi(0, player_health - applied_damage)
	return applied_damage

func get_selected_enemy(route_node: RouteNodeState) -> EnemyDefinition:
	for selection: EnemySelectionState in enemy_selections:
		if selection.route_node == route_node:
			return selection.enemy
	return null

func record_enemy_selection(route_node: RouteNodeState, enemy: EnemyDefinition, normal_enemy: bool) -> void:
	for existing: EnemySelectionState in enemy_selections:
		if existing.route_node == route_node:
			existing.enemy = enemy
			if normal_enemy:
				last_normal_enemy = enemy
			return
	var selection: EnemySelectionState = EnemySelectionState.new()
	selection.route_node = route_node
	selection.enemy = enemy
	enemy_selections.append(selection)
	if normal_enemy:
		last_normal_enemy = enemy

func heal_percent(amount: float) -> void:
	player_health = mini(maximum_health, player_health + maximum_health * amount / percent_divisor)

func get_current_piece_pool() -> Array[PiecePoolEntry]:
	ensure_active_piece_pool()
	var entries: Array[PiecePoolEntry] = []
	for active_entry: PieceCardState in deck_cards:
		var piece: PieceDefinition = active_entry.piece
		if piece == null:
			continue
		var entry: PiecePoolEntry = PiecePoolEntry.new()
		entry.card_id = active_entry.card_id
		entry.piece = piece
		entry.intrinsic_effect = active_entry.intrinsic_effect
		entry.display_name = piece.display_name
		entry.cells = piece.base_cells.duplicate()
		entry.color = piece.preview_color
		entry.is_enabled = not removed_pieces.has(piece)
		entry.is_new = unviewed_pieces.has(piece)
		entry.unique_rotation_count = PieceRotationService.get_unique_rotations(piece).size()
		entry.can_appear_as_bonus_item = piece.can_appear_as_bonus_item
		entry.source_relics = active_entry.source_relics.duplicate()
		entry.added_act = active_entry.added_act
		entry.is_starting_piece = active_entry.is_starting_piece
		entry.is_temporary = active_entry.is_temporary
		if not entry.is_enabled:
			entry.modifier_descriptions.append(removed_piece_description)
		for state: PieceModifierState in get_piece_modifiers(piece):
			var definition: PieceModifierDefinition = state.definition
			if definition != null:
				entry.modifier_descriptions.append(difficulty_modifier_description_format % [definition.display_name, definition.description])
				entry.modifiers.append(definition)
				entry.modifier_colors.append(definition.visual_definition.accent_color if definition.visual_definition != null else Color.WHITE)
		entries.append(entry)
	entries.sort_custom(func(left: PiecePoolEntry, right: PiecePoolEntry) -> bool:
		var left_size: int = left.cells.size()
		var right_size: int = right.cells.size()
		return left_size < right_size or left_size == right_size and (left.piece.resource_path < right.piece.resource_path or left.piece == right.piece and left.card_id < right.card_id))
	return entries

func ensure_active_piece_pool() -> void:
	ensure_deck_cards()

func ensure_deck_cards() -> void:
	if not deck_cards.is_empty():
		return
	if piece_draft != null and not piece_draft.is_confirmed:
		return
	if piece_draft != null and not piece_draft.selected_cards().is_empty():
		PiecePoolService.new().initialize_deck(self, piece_draft.selected_cards(), maximum_active_piece_pool_size)
		return
	var starting_pieces: Array[PieceDefinition] = []
	if piece_draft != null:
		_append_available_pieces(starting_pieces, piece_draft.candidate_pieces())
	for piece: PieceDefinition in ContentRegistry.pieces:
		if piece.initially_unlocked or starting_modifiers.unlocked_pieces.has(piece):
			_append_available_piece(starting_pieces, piece)
	var target_size: int = mini(maximum_active_piece_pool_size, maxi(minimum_active_piece_pool_size, piece_draft.required_selection_count if piece_draft != null else starting_pieces.size()))
	PiecePoolService.new().initialize_pool(self, starting_pieces.slice(0, target_size), maximum_active_piece_pool_size)

func allocate_piece_card_id(requested_id: int = 0) -> int:
	if requested_id > 0 and get_deck_card(requested_id) == null:
		next_piece_card_id = maxi(next_piece_card_id, requested_id + 1)
		return requested_id
	while get_deck_card(next_piece_card_id) != null:
		next_piece_card_id += 1
	var allocated_id: int = next_piece_card_id
	next_piece_card_id += 1
	return allocated_id

func get_deck_card(card_id: int) -> PieceCardState:
	for card: PieceCardState in deck_cards:
		if card.card_id == card_id:
			return card
	return null

func _append_available_pieces(target: Array[PieceDefinition], pieces: Array[PieceDefinition]) -> void:
	for piece: PieceDefinition in pieces:
		_append_available_piece(target, piece)

func _append_available_piece(target: Array[PieceDefinition], piece: PieceDefinition) -> void:
	if piece != null and not removed_pieces.has(piece) and not target.has(piece):
		target.append(piece)

func has_piece_modifier(piece: PieceDefinition) -> bool:
	return not get_piece_modifiers(piece).is_empty()

func get_piece_modifiers(piece: PieceDefinition) -> Array[PieceModifierState]:
	var result: Array[PieceModifierState] = []
	for state: PieceModifierState in piece_modifiers:
		if state.target_pieces.has(piece):
			result.append(state)
	return result

func add_piece_modifier(state: PieceModifierState) -> void:
	if state == null or state.definition == null:
		return
	piece_modifiers.append(state)
	piece_modifiers_changed.emit()
	piece_pool_changed.emit()

func expire_piece_modifiers_after_act(completed_act: int) -> void:
	var previous_size: int = piece_modifiers.size()
	piece_modifiers = piece_modifiers.filter(func(state: PieceModifierState) -> bool: return state.expires_after_act < 0 or state.expires_after_act > completed_act)
	if piece_modifiers.size() != previous_size:
		piece_modifiers_changed.emit()
		piece_pool_changed.emit()

func resolve_piece_modifier_selection(definition: PieceModifierDefinition, selected_pieces: Array[PieceDefinition]) -> bool:
	for state: PieceModifierState in piece_modifiers:
		if state.definition != definition or not state.pending_selection:
			continue
		for piece: PieceDefinition in selected_pieces:
			if not state.candidate_pieces.has(piece):
				return false
		state.target_pieces = selected_pieces.duplicate()
		state.pending_selection = false
		piece_modifiers_changed.emit()
		piece_pool_changed.emit()
		return true
	return false

func get_owned_relics() -> Array[OwnedRelicState]:
	var states: Array[OwnedRelicState] = []
	for definition: RelicDefinition in relics:
		var state: OwnedRelicState = _find_owned_relic(states, definition)
		if state != null:
			state.stacks += 1
			continue
		state = OwnedRelicState.new()
		state.definition = definition
		state.display_name = definition.display_name
		state.description = definition.description
		state.is_new = unviewed_relics.has(definition)
		state.source_description = _relic_source(definition)
		state.condition_description = _relic_condition(definition)
		states.append(state)
	states.sort_custom(func(left: OwnedRelicState, right: OwnedRelicState) -> bool: return left.definition.resource_path < right.definition.resource_path)
	return states

func _find_owned_relic(states: Array[OwnedRelicState], definition: RelicDefinition) -> OwnedRelicState:
	for state: OwnedRelicState in states:
		if state.definition == definition:
			return state
	return null

func _relic_source(definition: RelicDefinition) -> String:
	for acquisition: RelicAcquisitionState in relic_acquisition_sources:
		if acquisition.definition == definition:
			return acquisition.source_description
	return unknown_relic_source_description

func add_relic(definition: RelicDefinition, source_description: String = String()) -> void:
	if definition == null:
		return
	var resolved_source_description: String = source_description if not source_description.is_empty() else unknown_relic_source_description
	relics.append(definition)
	if not unviewed_relics.has(definition):
		unviewed_relics.append(definition)
	if not resolved_source_description.is_empty():
		var acquisition: RelicAcquisitionState
		for existing: RelicAcquisitionState in relic_acquisition_sources:
			if existing.definition == definition:
				acquisition = existing
				break
		if acquisition == null:
			acquisition = RelicAcquisitionState.new()
			acquisition.definition = definition
			relic_acquisition_sources.append(acquisition)
		acquisition.source_description = resolved_source_description
	relics_changed.emit()

func unlock_piece_for_run(piece: PieceDefinition) -> void:
	PiecePoolService.new().add_piece(self, piece)

func remove_piece_from_pool(piece: PieceDefinition) -> bool:
	if not PiecePoolService.new().can_remove_piece_type(self, piece):
		return false
	removed_pieces.append(piece)
	for artifact: BossArtifactState in artifacts:
		for index: int in range(artifact.stored_cards.size() - 1, -1, -1):
			var stored_card: PieceCardState = artifact.stored_cards[index]
			if stored_card != null and stored_card.piece == piece:
				artifact.stored_cards.remove_at(index)
	piece_pool_changed.emit()
	return true

func mark_pieces_viewed() -> void:
	unviewed_pieces.clear()
	piece_pool_changed.emit()

func mark_relics_viewed() -> void:
	unviewed_relics.clear()
	relics_changed.emit()

func add_artifact(definition: BossArtifactDefinition, obtained_act: int) -> bool:
	if definition == null or get_artifact_state(definition) != null or artifacts.size() >= game_rules.maximum_active_boss_artifacts:
		return false
	for state: BossArtifactState in artifacts:
		var owned: BossArtifactDefinition = state.definition
		if definition.incompatible_artifacts.has(owned) or owned != null and owned.incompatible_artifacts.has(definition):
			return false
	var artifact: BossArtifactState = BossArtifactState.new()
	artifact.definition = definition
	artifact.obtained_act = maxi(0, obtained_act)
	artifacts.append(artifact)
	unviewed_artifacts.append(definition)
	artifacts_changed.emit()
	return true

func get_artifact_state(definition: BossArtifactDefinition) -> BossArtifactState:
	for state: BossArtifactState in artifacts:
		if state.definition == definition:
			return state
	return null

func mark_artifacts_viewed() -> void:
	unviewed_artifacts.clear()
	artifacts_changed.emit()

func _relic_condition(definition: RelicDefinition) -> String:
	if definition.trigger_effect == null:
		return always_active_relic_description
	if definition.trigger_effect.requires_cross_clear:
		return cross_clear_relic_description
	if definition.trigger_effect.minimum_lines > 0:
		return minimum_lines_relic_description % definition.trigger_effect.minimum_lines
	return conditional_relic_description

func apply_starting_modifiers(modifier_snapshot: StartingRunModifiers, base_health: int) -> void:
	starting_modifiers = StartingRunModifiers.from_save_data(modifier_snapshot.to_save_data())
	maximum_health = base_health + starting_modifiers.maximum_health_bonus
	player_health = mini(maximum_health, base_health + starting_modifiers.starting_health_bonus)
	shards = starting_modifiers.starting_run_currency
	emergency_clear_charges = starting_modifiers.emergency_board_clear_charges
	last_reserve_charges = starting_modifiers.last_reserve_charges
	reward_rerolls = starting_modifiers.reward_rerolls
	modifiers.damage_modifiers.clear()
	for modifier: DamageModifierInstance in starting_modifiers.damage_modifiers:
		modifiers.damage_modifiers.append(modifier.duplicate_instance())
	inventory = ItemInventory.new(game_rules.base_item_slots + starting_modifiers.item_slot_bonus, game_rules.maximum_item_slots)
	if not daily_mode:
		_grant_starting_potions(starting_modifiers.starting_common_potions)

func _grant_starting_potions(count: int) -> void:
	var granted: int = 0
	for definition: ItemDefinition in ContentRegistry.items:
		if granted >= count:
			return
		if definition.rarity != ItemRarity.Value.COMMON or definition.category == ItemCategory.Value.BONUS_BLOCK:
			continue
		var stack: ItemStack = ItemStack.new()
		stack.definition = definition
		stack.quantity = 1
		if inventory.add(stack, starting_modifiers.potion_stack_limit_bonus).added:
			granted += 1

func to_save_data() -> Dictionary:
	return {
		"run_sequence": run_sequence,
		"seed": seed_value,
		"encounter_index": encounter_index,
		"player_health": player_health,
		"maximum_health": maximum_health,
		"score": score,
		"relics": _relic_definitions_to_data(relics),
		"cleared_lines": cleared_lines,
		"cleared_cells": cleared_cells,
		"cross_clears": cross_clears,
		"perfect_clears": perfect_clears,
		"highest_combo": highest_combo,
		"placements": placements,
		"enemies_defeated": enemies_defeated,
		"elapsed_play_time": elapsed_play_time,
		"starting_modifiers": starting_modifiers.to_save_data(),
		"shards": shards,
		"route": route.to_save_data() if route != null else {},
		"difficulty": ContentReferenceCodec.encode(difficulty),
		"daily_mode": daily_mode,
		"daily_practice": daily_practice,
		"daily_date_key": daily_date_key,
		"debug_run": debug_run,
		"emergency_clear_charges": emergency_clear_charges,
		"last_reserve_charges": last_reserve_charges,
		"reward_rerolls": reward_rerolls,
		"removed_pieces": PieceModifierState._encode_pieces(removed_pieces),
		"successful_clear_turns": successful_clear_turns,
		"pending_corrupted_cells": pending_corrupted_cells,
		"pending_board_size": pending_board_size,
		"pending_board_width": pending_board_width,
		"pending_board_height": pending_board_height,
		"shard_reward_multiplier": shard_reward_multiplier,
		"last_piece": ContentReferenceCodec.encode(last_piece),
		"consecutive_piece_count": consecutive_piece_count,
		"discarded_piece_count": discarded_piece_count,
		"inventory": inventory.to_save_data(),
		"player_statuses": player_statuses.to_save_data(),
		"player_shield": player_shield,
		"temporary_item_slot_bonus": temporary_item_slot_bonus,
		"item_uses_remaining": item_uses_remaining,
		"bosses_defeated": bosses_defeated,
		"boss_fragments_earned": boss_fragments_earned,
		"pending_profile_fragments": pending_profile_fragments,
		"unviewed_pieces": PieceModifierState._encode_pieces(unviewed_pieces),
		"unviewed_relics": _relic_definitions_to_data(unviewed_relics),
		"relic_acquisition_sources": _relic_sources_to_data(),
		"artifacts": _artifacts_to_data(),
		"unviewed_artifacts": _artifact_definitions_to_data(unviewed_artifacts),
		"enemy_selections": _enemy_selections_to_data(),
		"last_normal_enemy": ContentReferenceCodec.encode(last_normal_enemy),
		"piece_modifiers": _piece_modifiers_to_data(),
		"pending_piece_selection_flow": int(pending_piece_selection_flow),
		"run_mode": int(run_mode),
		"piece_draft": piece_draft.to_save_data() if piece_draft != null else {},
		"deck_cards": _deck_cards_to_data(),
		"next_piece_card_id": next_piece_card_id,
		"maximum_active_piece_pool_size": maximum_active_piece_pool_size,
		"maximum_piece_copies": maximum_piece_copies,
		"pending_piece_addition": pending_piece_addition.to_save_data() if pending_piece_addition != null else {},
		"modifiers": modifiers.to_save_data()
	}

static func from_save_data(data: Dictionary) -> RunState:
	var run: RunState = RunState.new()
	run.run_sequence = int(data.get("run_sequence", String(data.get("run_id", "")).hash() if data.has("run_id") else run.run_sequence))
	run.seed_value = int(data.get("seed", 1))
	run.encounter_index = maxi(0, int(data.get("encounter_index", 0)))
	run.player_health = int(data.get("player_health", 0))
	run.maximum_health = maxi(run.minimum_maximum_health, int(data.get("maximum_health", run.maximum_health)))
	run.score = maxi(0, int(data.get("score", 0)))
	for relic_value: Variant in data.get("relics", data.get("relic_ids", [])) as Array:
		var relic: RelicDefinition = ContentReferenceCodec.decode_legacy(String(relic_value), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
		if relic != null:
			run.relics.append(relic)
	run.cleared_lines = maxi(0, int(data.get("cleared_lines", 0)))
	run.cleared_cells = maxi(0, int(data.get("cleared_cells", 0)))
	run.cross_clears = maxi(0, int(data.get("cross_clears", 0)))
	run.perfect_clears = maxi(0, int(data.get("perfect_clears", 0)))
	run.highest_combo = maxi(0, int(data.get("highest_combo", 0)))
	run.placements = maxi(0, int(data.get("placements", 0)))
	run.enemies_defeated = maxi(0, int(data.get("enemies_defeated", 0)))
	run.elapsed_play_time = maxf(0.0, float(data.get("elapsed_play_time", 0.0)))
	run.starting_modifiers = StartingRunModifiers.from_save_data(data.get("starting_modifiers", {}) as Dictionary)
	run.shards = maxi(0, int(data.get("shards", 0)))
	var route_data: Dictionary = data.get("route", {}) as Dictionary
	run.route = GeneratedRoute.from_save_data(route_data) if not route_data.is_empty() else null
	if run.route != null and run.route.current_node == null:
		run.route.current_node = run.route._find_legacy_node(StringName(String(data.get("current_route_node_id", ""))))
	var default_difficulty: DifficultyDefinition = run.difficulty
	var fallback_difficulty_reference: String = ContentReferenceCodec.encode(default_difficulty)
	run.difficulty = ContentReferenceCodec.decode_legacy(String(data.get("difficulty", data.get("difficulty_id", fallback_difficulty_reference))), DifficultyDefinition, ContentRegistry.catalog) as DifficultyDefinition
	if run.difficulty == null:
		run.difficulty = default_difficulty
	run.daily_mode = bool(data.get("daily_mode", false))
	run.daily_practice = bool(data.get("daily_practice", false))
	run.daily_date_key = String(data.get("daily_date_key", ""))
	run.debug_run = bool(data.get("debug_run", false))
	run.emergency_clear_charges = maxi(0, int(data.get("emergency_clear_charges", 0)))
	run.last_reserve_charges = maxi(0, int(data.get("last_reserve_charges", 0)))
	run.reward_rerolls = maxi(0, int(data.get("reward_rerolls", 0)))
	run.removed_pieces = PieceModifierState._decode_pieces(data.get("removed_pieces", data.get("removed_piece_ids", [])) as Array)
	run.successful_clear_turns = maxi(0, int(data.get("successful_clear_turns", 0)))
	run.pending_corrupted_cells = maxi(0, int(data.get("pending_corrupted_cells", 0)))
	run.pending_board_size = maxi(0, int(data.get("pending_board_size", 0)))
	run.pending_board_width = maxi(0, int(data.get("pending_board_width", 0)))
	run.pending_board_height = maxi(0, int(data.get("pending_board_height", 0)))
	run.shard_reward_multiplier = maxf(1.0, float(data.get("shard_reward_multiplier", 1.0)))
	run.last_piece = ContentReferenceCodec.decode_legacy(String(data.get("last_piece", data.get("last_piece_id", ""))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
	run.consecutive_piece_count = maxi(0, int(data.get("consecutive_piece_count", 0)))
	run.discarded_piece_count = maxi(0, int(data.get("discarded_piece_count", 0)))
	run.inventory = ItemInventory.from_save_data(data.get("inventory", {}) as Dictionary) if data.has("inventory") else ItemInventory.new()
	if not ContentRegistry.items.is_empty():
		for index: int in run.inventory.slots.size():
			var stack: ItemStack = run.inventory.slots[index]
			if stack != null and stack.definition == null:
				run.shards += stack.quantity * run.game_rules.unknown_item_shard_compensation
				run.inventory.slots[index] = null
	run.player_statuses = StatusCollection.from_save_data(data.get("player_statuses", []) as Array)
	run.player_shield = maxi(0, int(data.get("player_shield", 0)))
	run.temporary_item_slot_bonus = maxi(0, int(data.get("temporary_item_slot_bonus", 0)))
	run.item_uses_remaining = maxi(-1, int(data.get("item_uses_remaining", -1)))
	run.bosses_defeated = maxi(0, int(data.get("bosses_defeated", run._completed_boss_count())))
	run.boss_fragments_earned = maxi(0, int(data.get("boss_fragments_earned", 0)))
	run.pending_profile_fragments = maxi(0, int(data.get("pending_profile_fragments", 0)))
	run.unviewed_pieces = PieceModifierState._decode_pieces(data.get("unviewed_pieces", data.get("unviewed_piece_ids", [])) as Array)
	for relic_value: Variant in data.get("unviewed_relics", data.get("unviewed_relic_ids", [])) as Array:
		var relic: RelicDefinition = ContentReferenceCodec.decode_legacy(String(relic_value), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
		if relic != null:
			run.unviewed_relics.append(relic)
	var source_data: Array = data.get("relic_acquisition_sources", []) as Array
	for source_value: Variant in source_data:
		run.relic_acquisition_sources.append(RelicAcquisitionState.from_save_data(source_value as Dictionary))
	var legacy_sources: Dictionary = data.get("relic_source_descriptions", {}) as Dictionary
	for key: Variant in legacy_sources:
		var legacy_source: RelicAcquisitionState = RelicAcquisitionState.new()
		legacy_source.definition = ContentReferenceCodec.decode_legacy(String(key), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
		legacy_source.source_description = String(legacy_sources[key])
		run.relic_acquisition_sources.append(legacy_source)
	for artifact_value: Variant in data.get("artifacts", []) as Array:
		var artifact: BossArtifactState = BossArtifactState.from_save_data(artifact_value as Dictionary)
		if artifact.definition != null:
			run.artifacts.append(artifact)
	for artifact_reference: Variant in data.get("unviewed_artifacts", data.get("unviewed_artifact_ids", [])) as Array:
		var unviewed_artifact: BossArtifactDefinition = ContentReferenceCodec.decode_legacy(String(artifact_reference), BossArtifactDefinition, ContentRegistry.catalog) as BossArtifactDefinition
		if unviewed_artifact != null:
			run.unviewed_artifacts.append(unviewed_artifact)
	for selection_value: Variant in data.get("enemy_selections", []) as Array:
		run.enemy_selections.append(EnemySelectionState.from_save_data(selection_value as Dictionary, run.route))
	run.last_normal_enemy = ContentReferenceCodec.decode_legacy(String(data.get("last_normal_enemy", data.get("last_normal_enemy_id", ""))), EnemyDefinition, ContentRegistry.catalog) as EnemyDefinition
	run.pending_piece_selection_flow = PieceSelectionFlow.from_save_value(data.get("pending_piece_selection_flow", PieceSelectionFlow.Value.NONE))
	run.run_mode = clampi(int(data.get("run_mode", RunMode.Value.STANDARD)), RunMode.Value.STANDARD, RunMode.Value.DEBUG) as RunMode.Value
	var draft_data: Dictionary = data.get("piece_draft", {}) as Dictionary
	run.piece_draft = PieceDraftState.from_save_data(draft_data) if not draft_data.is_empty() else null
	run.maximum_active_piece_pool_size = maxi(run.minimum_active_piece_pool_size, int(data.get("maximum_active_piece_pool_size", run.maximum_active_piece_pool_size)))
	run.maximum_piece_copies = maxi(1, int(data.get("maximum_piece_copies", run.maximum_piece_copies)))
	var pending_addition_data: Dictionary = data.get("pending_piece_addition", {}) as Dictionary
	run.pending_piece_addition = PendingPieceAdditionState.from_save_data(pending_addition_data) if not pending_addition_data.is_empty() else null
	var saved_deck_cards: Array = data.get("deck_cards", data.get("active_piece_pool_entries", [])) as Array
	for entry_value: Variant in saved_deck_cards:
		var active_entry: ActivePiecePoolEntry = ActivePiecePoolEntry.from_save_data(entry_value as Dictionary, run.route)
		if active_entry.piece != null:
			active_entry.card_id = run.allocate_piece_card_id(active_entry.card_id)
			run.deck_cards.append(active_entry)
	run.next_piece_card_id = maxi(run.next_piece_card_id, int(data.get("next_piece_card_id", run.next_piece_card_id)))
	run.ensure_active_piece_pool()
	for state_value: Variant in data.get("piece_modifiers", []) as Array:
		var piece_modifier: PieceModifierState = PieceModifierState.from_save_data(state_value as Dictionary)
		if piece_modifier.definition != null:
			run.piece_modifiers.append(piece_modifier)
	var modifier_data: Dictionary = data.get("modifiers", {}) as Dictionary
	run.modifiers = RunModifiers.from_save_data(modifier_data)
	if run.modifiers.damage_modifiers.is_empty():
		for modifier: DamageModifierInstance in run.starting_modifiers.damage_modifiers:
			run.modifiers.damage_modifiers.append(modifier.duplicate_instance())
	return run

func _completed_boss_count() -> int:
	if route == null:
		return 0
	var count: int = 0
	for node: RouteNodeState in route.nodes:
		if node != null and node.type == RouteNodeState.NodeType.BOSS and node.completed:
			count += 1
	return count

func _deck_cards_to_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for card: PieceCardState in deck_cards:
		data.append(card.to_save_data(route))
	return data

func _relic_sources_to_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for acquisition: RelicAcquisitionState in relic_acquisition_sources:
		data.append(acquisition.to_save_data())
	return data

func _artifacts_to_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for artifact: BossArtifactState in artifacts:
		data.append(artifact.to_save_data())
	return data

func _artifact_definitions_to_data(definitions: Array[BossArtifactDefinition]) -> Array[String]:
	var data: Array[String] = []
	for definition: BossArtifactDefinition in definitions:
		data.append(ContentReferenceCodec.encode(definition))
	return data

func _relic_definitions_to_data(definitions: Array[RelicDefinition]) -> Array[String]:
	var data: Array[String] = []
	for definition: RelicDefinition in definitions:
		data.append(ContentReferenceCodec.encode(definition))
	return data

func _enemy_selections_to_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for selection: EnemySelectionState in enemy_selections:
		data.append(selection.to_save_data(route))
	return data

func _piece_modifiers_to_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for state: PieceModifierState in piece_modifiers:
		data.append(state.to_save_data())
	return data
