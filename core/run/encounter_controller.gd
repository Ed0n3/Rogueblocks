class_name EncounterController
extends Node

@export_category("Content")
@export var game_rules: GameRules = preload("res://content/rules/default_game_rules.tres") as GameRules
@export var deck_rules: DeckRules = preload("res://content/rules/default_deck_rules.tres") as DeckRules
@export var burn_status: StatusDefinition = preload("res://content/statuses/burn.tres") as StatusDefinition
@export var poison_status: StatusDefinition = preload("res://content/statuses/poison.tres") as StatusDefinition
@export var fortified_status: StatusDefinition = preload("res://content/statuses/fortified.tres") as StatusDefinition
@export var regeneration_status: StatusDefinition = preload("res://content/statuses/regeneration.tres") as StatusDefinition
@export var empowered_venom_status: StatusDefinition = preload("res://content/statuses/empowered_venom.tres") as StatusDefinition
@export var slowed_hands_status: StatusDefinition = preload("res://content/statuses/slowed_hands.tres") as StatusDefinition
@export var electrified_status: StatusDefinition = preload("res://content/statuses/electrified.tres") as StatusDefinition
@export var electrified_block_stun_effect: ApplyStatusEffect = preload("res://content/effects/electrified_block_stun.tres") as ApplyStatusEffect
@export var twin_core_artifact: BossArtifactDefinition = preload("res://content/artifacts/twin_core.tres") as BossArtifactDefinition
@export var vault_artifact: BossArtifactDefinition = preload("res://content/artifacts/vault_shapes.tres") as BossArtifactDefinition
@export var ember_brand_modifier: PieceModifierDefinition = preload("res://content/piece_modifiers/ember_brand.tres") as PieceModifierDefinition
@export var cursed_card_effect: PieceCardEffectDefinition = preload("res://content/card_effects/cursed_fragment.tres") as PieceCardEffectDefinition

@export_category("Encounter Tuning")
@export_range(1, 12, 1) var minimum_draw_count: int = 3
@export var emergency_clear_cell_count: int = 3
@export var perfect_clear_cleanse_count: int = 1
@export var poison_stack_reduction: int = 1
@export var status_duration_reduction: int = 1
@export var burn_reduction_minimum_lines: int = 2
@export var fortified_removal_minimum_lines: int = 3
@export var regeneration_interrupt_damage: int = 6
@export var last_reserve_health: int = 1
@export var minimum_attack_interval: int = 1
@export var minimum_enemy_health: int = 1
@export var empowered_venom_stack_bonus: int = 1
@export var countdown_step_per_turn: int = 1
@export var artifact_status_magnitude: float = 1.0
@export var debug_enemy_damage: int = 10
@export var debug_player_healing: int = 10
@export_range(1, 4, 1) var twin_core_bonus_draw_count: int = 1

@export_category("Messages")
@export var missing_content_error: String = "Cannot start encounter because required gameplay content is unavailable"
@export var vault_stored_message: String = "Vault of Shapes stored %s"
@export var relic_redraw_message: String = "Relic effects generated %d free redraw%s"
@export var plural_suffix: String = "s"
@export var vault_empty_message: String = "The Vault is empty."
@export var special_piece_active_message: String = "Finish the current special Block first."
@export var vault_unavailable_message: String = "The Vault cannot open right now."
@export var vault_piece_unavailable_message: String = "This Vault Block is unavailable."
@export var vault_no_placement_message: String = "This Vault Block has no valid placement."
@export var vault_replaced_card_message: String = "Vault of Shapes replaced the selected Block"
@export var vault_ready_message: String = "Vault Block ready to place."
@export var emergency_clear_message: String = "Emergency clearance removed %d cells"
@export var no_item_uses_message: String = "No item uses remain this turn"
@export var capsule_no_placement_message: String = "This Capsule Block has no valid placement."
@export var capsule_ready_message: String = "Capsule Block ready to place."
@export var player_defeated_message: String = "Your core is destroyed!"
@export var poisoned_block_damage_message: String = "%d poisoned Block%s dealt %d damage"
@export var cleared_lines_message: String = "Cleared %d line(s): +%d score, %d damage"
@export var enemy_healing_message: String = "%s drains momentum and heals %d"
@export var twin_core_no_placement_message: String = "Twin Core had no valid second placement"
@export var enemy_interrupted_message: String = "%s's action was interrupted"
@export var enemy_attack_message: String = "%s attacks for %d"
@export var cursed_card_added_message: String = "Cursed Draft added a volatile Block to your draw pile"
@export var card_effect_message_format: String = "%s: %s"
@export var no_valid_placements_message: String = "No valid placements"
@export var last_reserve_message: String = "Last Reserve prevented defeat"
@export var enemy_phase_message: String = "%s enters %s"
@export var counter_completed_message: String = "Counter completed: %s"
@export var counter_failed_message: String = "Counter failed: %s"
@export var slowed_hands_message: String = "Slowed Hands prevents rotation"
@export var electrified_blocks_message: String = "%d electrified Block%s stunned the player"
@export var player_stunned_message: String = "Electrified ends the player's remaining turn"
@export var enemy_stunned_message: String = "%s is stunned by Electrified"

@export_category("Debug Board")
@export var empty_cell_glyph: String = "."
@export var blocker_cell_glyph: String = "#"
@export var occupied_cell_glyph: String = "X"
@export var board_row_separator: String = ""
@export var board_line_separator: String = "\n"

signal turn_state_changed(previous: TurnState, current: TurnState)
signal hand_changed(cards: Array[PieceCardState], placeable: Array[bool])
signal placement_economy_changed(remaining: int, maximum: int, redraw_cost: int, free_redraws: int)
signal active_piece_changed(piece: PieceInstance)
signal piece_placed(result: PlacementResult)
signal card_effect_resolved(card: PieceCardState, definition: PieceCardEffectDefinition, result: EffectResult)
signal lines_cleared(result: ClearResult)
signal score_awarded(result: ScoreResult)
signal enemy_damaged(result: DamageResult)
signal enemy_attacked(damage: int, blockers: Array[Vector2i])
signal enemy_phase_changed(phase: EnemyPhaseDefinition)
signal status_changed()
signal event_logged(message: String)
signal encounter_won()
signal run_lost(reason: String)
signal safe_point_reached(data: Dictionary)
signal item_used(result: ItemUseResult, slot_index: int)
signal counter_changed(counter: ActiveCounterState, definition: CounterDefinition)
signal artifact_activated(artifact: BossArtifactDefinition, message: String)
signal intent_changed(intent: ResolvedEnemyIntent)
signal special_preview_requested(candidate: PiecePlacementCandidate)

enum TurnState { INITIALIZING, DRAWING_HAND, AWAITING_SELECTION, AWAITING_PLACEMENT, RESOLVING_PLACEMENT, RESOLVING_CLEAR, RESOLVING_DAMAGE, RESOLVING_ENEMY, ENCOUNTER_WON, RUN_LOST, PAUSED }

var state: TurnState = TurnState.INITIALIZING
var rules: GameRules
var board: BoardState
var run_state: RunState
var generator: PieceGenerator
var deck_state: EncounterDeckState
var deck_service: DeckService = DeckService.new()
var hand_placeable: Array[bool] = []
var active_card: PieceCardState
var active_card_index: int = -1
var active_piece: PieceInstance
var enemy: EnemyDefinition
var enemy_health: int = 0
var enemy_maximum_health: int = 0
var enemy_countdown: int = 0
var combo: int = 0
var rerolls: int = 0
var free_rerolls_remaining: int = 0
var maximum_placement_points: int = 4
var placement_points_remaining: int = 4
var redraw_placement_point_cost: int = 1
var free_redraws_remaining_this_turn: int = 0
var current_phase_index: int = 0
var effect_state: EncounterEffectState = EncounterEffectState.new()
var turn_number: int = 0
var active_counter: ActiveCounterState
var active_counter_definition: CounterDefinition
var bonus_placement_mode: bool = false
var bonus_item_slot: int = -1
var normal_piece_before_bonus: PieceInstance
var artifact_service: ArtifactService = ArtifactService.new()
var twin_core_second_placement: bool = false
var selected_enemy_action: EnemyActionDefinition
var resolved_enemy_intent: ResolvedEnemyIntent
var previous_enemy_action: EnemyActionDefinition
var enemy_action_cooldowns: Array[EnemyActionCooldownState] = []
var cursed_draft_pending: bool = false
var enemy_shield_turns_remaining: int = 0
var last_clear_result: ClearResult
var vault_storage_service: VaultStorageService = VaultStorageService.new()
var vault_piece_placement_active: bool = false
var normal_piece_before_vault: PieceInstance
var vault_retrieved_card: PieceCardState
var vault_retrieved_storage_index: int = -1
var vault_retrieval_used_this_turn: bool = false
var last_player_damage_result: DamageResult
var card_effect_service: PieceCardEffectService = PieceCardEffectService.new()
var pending_enemy_step_after_twin: bool = false
var pending_enemy_step_line_count: int = 0
var restoring_from_save: bool = false
var defeat_reason: String

func start_encounter(current_run: RunState, enemy_definition: EnemyDefinition, shared_generator: PieceGenerator) -> bool:
	if not _bind_encounter_context(current_run, enemy_definition, shared_generator):
		return false
	run_state.ensure_deck_cards()
	var stored_vault_card_ids: Array[int] = []
	var stored_vault: BossArtifactState = run_state.get_artifact_state(vault_artifact)
	if stored_vault != null:
		for stored_card: PieceCardState in stored_vault.stored_cards:
			if stored_card != null and stored_card.card_id > 0:
				stored_vault_card_ids.append(stored_card.card_id)
	var available_cards: Array[PieceCardState] = []
	for card: PieceCardState in run_state.deck_cards:
		if card != null and card.piece != null and not run_state.removed_pieces.has(card.piece) and not stored_vault_card_ids.has(card.card_id):
			available_cards.append(card)
	if available_cards.is_empty():
		push_error(missing_content_error)
		return false
	deck_state = deck_service.initialize_encounter(available_cards, generator.rng, deck_rules.shuffle_at_encounter_start)
	vault_storage_service.artifact = vault_artifact
	var legacy_board_size: int = run_state.pending_board_size
	var board_width: int = run_state.pending_board_width if run_state.pending_board_width > 0 else (legacy_board_size if legacy_board_size > 0 else rules.board_width)
	var board_height: int = run_state.pending_board_height if run_state.pending_board_height > 0 else (legacy_board_size if legacy_board_size > 0 else rules.board_height)
	board = BoardState.new(board_width, board_height)
	run_state.pending_board_size = 0
	run_state.pending_board_width = 0
	run_state.pending_board_height = 0
	var difficulty: DifficultyDefinition = _get_difficulty()
	var difficulty_health_multiplier: float = difficulty.enemy_health_multiplier if difficulty != null else 1.0
	enemy_maximum_health = ceili(float(enemy.maximum_health) * difficulty_health_multiplier * _deck_enemy_health_multiplier(available_cards))
	enemy_health = enemy_maximum_health
	current_phase_index = 0
	enemy_countdown = _current_attack_interval()
	combo = 0
	rerolls = run_state.modifiers.reroll_bonus + run_state.starting_modifiers.starting_rerolls_bonus
	free_rerolls_remaining = run_state.starting_modifiers.free_rerolls_per_encounter
	maximum_placement_points = deck_rules.base_placement_points_per_turn
	placement_points_remaining = maximum_placement_points
	redraw_placement_point_cost = deck_rules.redraw_placement_point_cost
	free_redraws_remaining_this_turn = 0
	active_card = null
	active_card_index = -1
	hand_placeable.clear()
	active_counter = null
	active_counter_definition = null
	bonus_placement_mode = false
	bonus_item_slot = -1
	normal_piece_before_bonus = null
	vault_piece_placement_active = false
	normal_piece_before_vault = null
	vault_retrieved_card = null
	vault_retrieved_storage_index = -1
	vault_retrieval_used_this_turn = false
	twin_core_second_placement = false
	pending_enemy_step_after_twin = false
	pending_enemy_step_line_count = 0
	defeat_reason = String()
	turn_number = 0
	effect_state = EncounterEffectState.new()
	effect_state.enemy_health = enemy_health
	effect_state.enemy_maximum_health = enemy_maximum_health
	effect_state.enemy_countdown = enemy_countdown
	effect_state.enemy_base_interval = _current_attack_interval()
	effect_state.player_shield = run_state.player_shield
	effect_state.player_statuses = run_state.player_statuses
	previous_enemy_action = null
	enemy_action_cooldowns.clear()
	cursed_draft_pending = false
	enemy_shield_turns_remaining = 0
	_select_next_enemy_action()
	run_state.item_uses_remaining = rules.base_item_uses_per_turn
	if difficulty != null and difficulty.starting_blockers > 0:
		board.add_blockers(difficulty.starting_blockers, generator.rng)
	if run_state.pending_corrupted_cells > 0:
		var corruption: EnemyActionDefinition = EnemyActionDefinition.new()
		corruption.special_cell_type = CellType.Value.CORRUPTED
		corruption.special_cell_count = run_state.pending_corrupted_cells
		corruption.execute(board, generator.rng)
		run_state.pending_corrupted_cells = 0
	artifact_service.on_encounter_started(run_state, board, generator.rng)
	PieceModifierService.new().reset_encounter(run_state)
	status_changed.emit()
	_generate_turn()
	return true

func restore_encounter(current_run: RunState, enemy_definition: EnemyDefinition, shared_generator: PieceGenerator, data: Dictionary) -> bool:
	if data.is_empty() or not _bind_encounter_context(current_run, enemy_definition, shared_generator):
		return false
	effect_state = EncounterEffectState.new()
	restoring_from_save = true
	var restored: bool = restore_from_save(data)
	restoring_from_save = false
	return restored

func _bind_encounter_context(current_run: RunState, enemy_definition: EnemyDefinition, shared_generator: PieceGenerator) -> bool:
	rules = game_rules
	if current_run == null or enemy_definition == null or shared_generator == null or rules == null or deck_rules == null:
		push_error(missing_content_error)
		return false
	run_state = current_run
	enemy = enemy_definition
	generator = shared_generator
	vault_storage_service.artifact = vault_artifact
	return true

func _deck_enemy_health_multiplier(cards: Array[PieceCardState]) -> float:
	var effect_scaling_weight: float = 0.0
	for card: PieceCardState in cards:
		if card != null and card.intrinsic_effect != null:
			effect_scaling_weight += card.intrinsic_effect.enemy_health_scaling_weight
	var effect_bonus: float = minf(deck_rules.maximum_effect_deck_health_bonus, effect_scaling_weight * deck_rules.enemy_health_bonus_per_effect_weight)
	return deck_rules.base_enemy_health_multiplier + effect_bonus

func select_choice(index: int) -> void:
	if state != TurnState.AWAITING_SELECTION and state != TurnState.AWAITING_PLACEMENT:
		return
	if deck_state == null or index < 0 or index >= deck_state.hand.size() or not hand_placeable[index]:
		return
	if vault_piece_placement_active and index == active_card_index:
		return
	if bonus_placement_mode:
		_clear_bonus_piece_selection()
	elif vault_piece_placement_active:
		_restore_vault_piece_selection()
	active_card_index = index
	active_card = deck_state.hand[index]
	var source_type: PieceSourceType.Value = PieceSourceType.Value.ARTIFACT_SECONDARY if twin_core_second_placement else PieceSourceType.Value.DRAWN_CARD
	active_piece = _create_card_piece_instance(active_card, source_type)
	_set_state(TurnState.AWAITING_PLACEMENT)
	active_piece_changed.emit(active_piece)
	_emit_safe_point()

func select_card(card_id: int) -> void:
	if deck_state == null:
		return
	for index: int in deck_state.hand.size():
		if deck_state.hand[index].card_id == card_id:
			select_choice(index)
			return

func select_next_choice() -> void:
	if deck_state == null or (state != TurnState.AWAITING_SELECTION and state != TurnState.AWAITING_PLACEMENT) or deck_state.hand.size() <= 1:
		return
	for offset: int in deck_state.hand.size():
		var candidate: int = posmod(active_card_index + offset + 1, deck_state.hand.size())
		if hand_placeable[candidate]:
			select_choice(candidate)
			return

func rotate_clockwise() -> void:
	if state == TurnState.AWAITING_PLACEMENT and active_piece != null:
		if not _accept_rotation_press():
			return
		active_piece.rotate_clockwise()
		active_piece_changed.emit(active_piece)
		_emit_safe_point()

func rotate_counterclockwise() -> void:
	if state == TurnState.AWAITING_PLACEMENT and active_piece != null:
		if not _accept_rotation_press():
			return
		active_piece.rotate_counterclockwise()
		active_piece_changed.emit(active_piece)
		_emit_safe_point()

func place(origin: Vector2i) -> void:
	if state != TurnState.AWAITING_PLACEMENT or active_piece == null:
		return
	if placement_points_remaining <= 0 and not bonus_placement_mode and not twin_core_second_placement:
		return
	artifact_service.before_piece_placement(run_state, board, generator.rng, active_piece.definition)
	var result: PlacementResult = board.place_piece(origin, active_piece)
	if not result.success:
		return
	_set_state(TurnState.RESOLVING_PLACEMENT)
	if active_piece.card != null:
		if active_piece.source_type == PieceSourceType.Value.DRAWN_CARD or active_piece.source_type == PieceSourceType.Value.ARTIFACT_SECONDARY:
			deck_service.move_to_in_play(deck_state, active_piece.card.card_id)
		elif vault_piece_placement_active:
			deck_service.put_in_play(deck_state, active_piece.card)
	_resolve_card_placement_effect(active_piece.card)
	var primary_placement: bool = not bonus_placement_mode and not twin_core_second_placement
	if primary_placement and vault_piece_placement_active:
		vault_retrieval_used_this_turn = true
	var artifact_result: ArtifactEffectContext
	if not bonus_placement_mode:
		artifact_result = artifact_service.after_piece_placement(run_state, board, generator.rng, active_piece.definition, active_piece.source_type)
	_clear_vault_piece_selection_tracking()
	if not bonus_placement_mode and run_state.last_piece == active_piece.definition:
		run_state.consecutive_piece_count += 1
	elif not bonus_placement_mode:
		run_state.last_piece = active_piece.definition
		run_state.consecutive_piece_count = 1
	if not bonus_placement_mode and not twin_core_second_placement:
		run_state.placements += 1
	if artifact_result != null:
		if artifact_result.enemy_status != null:
			effect_state.enemy_statuses.apply_status(artifact_result.enemy_status, artifact_result.activated_artifact, artifact_result.enemy_status_duration, artifact_result.enemy_status_stacks, artifact_status_magnitude, turn_number)
		if artifact_result.activated:
			artifact_activated.emit(artifact_result.activated_artifact, artifact_result.activation_message)
			event_logged.emit(artifact_result.activation_message)
	piece_placed.emit(result)
	_resolve_placement(primary_placement)

func _discard_unplayed_hand(vault_retrieval: bool = false) -> void:
	if deck_state == null:
		return
	var vault_can_capture: bool = vault_storage_service.can_capture(run_state, bonus_placement_mode, twin_core_second_placement, vault_retrieval)
	if vault_can_capture and not deck_state.hand.is_empty():
		var captured_card: PieceCardState = deck_state.hand[0]
		if vault_storage_service.capture(run_state, captured_card):
			deck_state.hand.erase(captured_card)
			artifact_activated.emit(vault_artifact, vault_stored_message % captured_card.piece.display_name)
			event_logged.emit(vault_stored_message % captured_card.piece.display_name)
	if not deck_rules.discard_unplayed_cards:
		_refresh_hand_state()
		return
	var discarded_cards: Array[PieceCardState] = deck_service.discard_hand(deck_state)
	_record_discarded_cards(discarded_cards)
	_refresh_hand_state()

func _record_discarded_cards(discarded_cards: Array[PieceCardState]) -> void:
	for card: PieceCardState in discarded_cards:
		if card == null:
			continue
		run_state.discarded_piece_count += 1
		var generated_rerolls: int = RelicTriggerService.new().rerolls_after_discard(run_state)
		if generated_rerolls > 0:
			rerolls += generated_rerolls
			event_logged.emit(relic_redraw_message % [generated_rerolls, plural_suffix if generated_rerolls != 1 else String()])

func use_vault_piece(stored_index: int = 0) -> SpecialPieceActivationResult:
	var result: SpecialPieceActivationResult = SpecialPieceActivationResult.new()
	var vault: BossArtifactState = run_state.get_artifact_state(vault_artifact)
	if vault == null or stored_index < 0 or stored_index >= vault.stored_cards.size():
		result.status = SpecialPieceActivationStatus.Value.EMPTY
		result.message = vault_empty_message
		return result
	if bonus_placement_mode or vault_piece_placement_active or twin_core_second_placement:
		result.status = SpecialPieceActivationStatus.Value.UNAVAILABLE
		result.message = special_piece_active_message
		return result
	if state != TurnState.AWAITING_PLACEMENT:
		result.status = SpecialPieceActivationStatus.Value.UNAVAILABLE
		result.message = vault_unavailable_message
		return result
	var stored: PieceCardState = vault.stored_cards[stored_index]
	if stored == null or stored.piece == null:
		result.status = SpecialPieceActivationStatus.Value.NO_VALID_PLACEMENT
		result.message = vault_piece_unavailable_message
		return result
	var candidate: PiecePlacementCandidate = board.find_piece_placement(stored.piece)
	if not candidate.found:
		result.status = SpecialPieceActivationStatus.Value.NO_VALID_PLACEMENT
		result.message = vault_no_placement_message
		return result
	normal_piece_before_vault = active_piece
	vault_retrieved_card = stored
	vault_retrieved_storage_index = stored_index
	vault.stored_cards.remove_at(stored_index)
	active_piece = _create_card_piece_instance(stored, PieceSourceType.Value.ARTIFACT_GENERATED)
	active_piece.rotation_index = candidate.rotation_index
	vault_piece_placement_active = true
	active_piece_changed.emit(active_piece)
	_refresh_hand_state()
	special_preview_requested.emit(candidate)
	artifact_activated.emit(vault_artifact, vault_replaced_card_message)
	_emit_safe_point()
	result.status = SpecialPieceActivationStatus.Value.STARTED
	result.message = vault_ready_message
	result.candidate = candidate
	return result

func skip_twin_core_placement() -> bool:
	if not twin_core_second_placement:
		return false
	twin_core_second_placement = false
	var twin: BossArtifactState = run_state.get_artifact_state(twin_core_artifact)
	if twin != null:
		twin.ready = false
	if not _resolve_pending_enemy_step():
		return true
	if _finish_player_stun_after_enemy_step():
		return true
	_continue_player_turn()
	return true

func reroll() -> void:
	redraw_hand()

func can_redraw_hand() -> bool:
	if deck_state == null or deck_state.hand.is_empty():
		return false
	if state != TurnState.AWAITING_SELECTION and state != TurnState.AWAITING_PLACEMENT:
		return false
	if bonus_placement_mode or vault_piece_placement_active or twin_core_second_placement:
		return false
	return current_redraw_placement_point_cost() <= placement_points_remaining

func current_redraw_placement_point_cost() -> int:
	if free_redraws_remaining_this_turn > 0 or free_rerolls_remaining > 0 or rerolls > 0:
		return 0
	return redraw_placement_point_cost

func redraw_hand() -> void:
	if not can_redraw_hand():
		return
	var placement_points_spent: int = 0
	if free_redraws_remaining_this_turn > 0:
		free_redraws_remaining_this_turn -= 1
	elif free_rerolls_remaining > 0:
		free_rerolls_remaining -= 1
	elif rerolls > 0:
		rerolls -= 1
	else:
		placement_points_spent = redraw_placement_point_cost
		placement_points_remaining = maxi(0, placement_points_remaining - placement_points_spent)
	_emit_placement_economy_changed()
	var discarded_cards: Array[PieceCardState] = deck_service.discard_hand(deck_state)
	_record_discarded_cards(discarded_cards)
	active_card = null
	active_card_index = -1
	active_piece = null
	deck_service.draw(deck_state, discarded_cards.size(), generator.rng, deck_rules.maximum_hand_size, deck_rules.reshuffle_discard_when_empty)
	for _spent_point: int in placement_points_spent:
		if not _resolve_enemy_step(ClearResult.new()):
			return
		if _finish_player_stun_after_enemy_step():
			return
	if placement_points_remaining <= 0:
		_finish_player_turn(false)
		return
	_activate_drawn_hand()

func end_player_turn() -> void:
	if state != TurnState.AWAITING_SELECTION and state != TurnState.AWAITING_PLACEMENT:
		return
	if bonus_placement_mode or vault_piece_placement_active or twin_core_second_placement:
		return
	_finish_player_turn(true)

func use_emergency_clearance() -> bool:
	if run_state.emergency_clear_charges <= 0 or state != TurnState.AWAITING_PLACEMENT:
		return false
	var removed: Array[Vector2i] = board.remove_random_occupied_cells(emergency_clear_cell_count, generator.rng)
	if removed.is_empty():
		return false
	run_state.emergency_clear_charges -= 1
	status_changed.emit()
	event_logged.emit(emergency_clear_message % removed.size())
	_emit_safe_point()
	return true

func use_item(slot_index: int) -> ItemUseResult:
	var result: ItemUseResult = ItemUseResult.new()
	if run_state.item_uses_remaining == 0 or state != TurnState.AWAITING_PLACEMENT:
		result.message = no_item_uses_message
		return result
	if slot_index < 0 or slot_index >= run_state.inventory.slots.size() or run_state.inventory.locked_slots.has(slot_index):
		result.message = ItemService.new().invalid_target_message
		return result
	artifact_service.on_item_phase(run_state, board, generator.rng) 
	var context: ItemUseContext = ItemUseContext.new()
	context.slot_index = slot_index
	context.effect_context = _create_effect_context(null, EffectTarget.Value.PLAYER)
	var used_definition: ItemDefinition = run_state.inventory.slots[slot_index].definition if slot_index >= 0 and slot_index < run_state.inventory.slots.size() and run_state.inventory.slots[slot_index] != null else null
	context.effect_context.source = used_definition
	if used_definition != null and used_definition.category == ItemCategory.Value.BONUS_BLOCK:
		if bonus_placement_mode or vault_piece_placement_active or twin_core_second_placement:
			result.message = special_piece_active_message
			return result
		var stack: ItemStack = run_state.inventory.slots[slot_index]
		var piece: PieceDefinition = stack.bonus_piece
		if piece == null:
			result.message = capsule_no_placement_message
			return result
		var candidate: PiecePlacementCandidate = board.find_piece_placement(piece)
		if not candidate.found:
			result.message = capsule_no_placement_message
			return result
		normal_piece_before_bonus = active_piece
		bonus_placement_mode = true
		bonus_item_slot = slot_index
		active_piece = _create_piece_instance(piece, PieceSourceType.Value.BONUS_BLOCK)
		active_piece.rotation_index = candidate.rotation_index
		active_piece_changed.emit(active_piece)
		special_preview_requested.emit(candidate)
		_emit_safe_point()
		result.used = true
		result.message = capsule_ready_message
		return result
	_sync_effect_state_from_controller()
	result = ItemService.new().use_item(run_state.inventory, context)
	_sync_controller_from_effect_state()
	if result.used:
		var damaged_enemy: bool = _process_enemy_effect_damage(result.effect_result, true)
		if run_state.item_uses_remaining > 0:
			run_state.item_uses_remaining -= 1
		if not run_state.debug_run:
			SaveService.profile.total_items_used += 1
			SaveService.save_profile()
		if active_counter != null and active_counter_definition != null:
			if used_definition != null:
				CounterService.new().apply_item_tags(active_counter, active_counter_definition, used_definition.tags)
			_resolve_counter_if_ready()
		if damaged_enemy:
			_check_phase_transition()
		_emit_effect_messages(result.effect_result)
		item_used.emit(result, slot_index)
		_refresh_hand_state()
		status_changed.emit()
		_emit_safe_point()
		if _resolve_lethal_outcome():
			return result
		if _has_player_stun():
			if not _resolve_enemy_step(ClearResult.new()):
				return result
			_finish_player_stun_after_enemy_step()
	return result

func cancel_bonus_placement() -> bool:
	if not bonus_placement_mode:
		return false
	active_piece = normal_piece_before_bonus
	_clear_bonus_piece_selection()
	active_piece_changed.emit(active_piece)
	_emit_safe_point()
	return true

func cancel_vault_placement() -> bool:
	if not vault_piece_placement_active:
		return false
	_restore_vault_piece_selection()
	_refresh_hand_state()
	active_piece_changed.emit(active_piece)
	status_changed.emit()
	_emit_safe_point()
	return true

func _clear_bonus_piece_selection() -> void:
	bonus_placement_mode = false
	bonus_item_slot = -1
	normal_piece_before_bonus = null

func _restore_vault_piece_selection() -> void:
	var vault: BossArtifactState = run_state.get_artifact_state(vault_artifact)
	if vault != null and vault_retrieved_card != null:
		var restored_index: int = clampi(vault_retrieved_storage_index, 0, vault.stored_cards.size())
		vault.stored_cards.insert(restored_index, vault_retrieved_card)
	if normal_piece_before_vault != null:
		active_piece = normal_piece_before_vault
	_clear_vault_piece_selection_tracking()

func _clear_vault_piece_selection_tracking() -> void:
	vault_piece_placement_active = false
	normal_piece_before_vault = null
	vault_retrieved_card = null
	vault_retrieved_storage_index = -1

func set_paused(paused: bool) -> void:
	if paused:
		_set_state(TurnState.PAUSED)
	elif state == TurnState.PAUSED:
		_set_state(TurnState.AWAITING_PLACEMENT if active_piece != null else TurnState.AWAITING_SELECTION)

func debug_damage_enemy() -> void:
	enemy_health = maxi(0, enemy_health - debug_enemy_damage)
	_check_phase_transition()
	status_changed.emit()
	if enemy_health == 0:
		_win_encounter()

func debug_heal_player() -> void:
	run_state.heal(debug_player_healing)
	status_changed.emit()

func debug_clear_board() -> void:
	board.clear_board()
	status_changed.emit()

func debug_print_board() -> void:
	var rows: PackedStringArray = []
	for y: int in board.height:
		var values: PackedStringArray = []
		for x: int in board.width:
			var value: int = board.get_cell(Vector2i(x, y))
			values.append(empty_cell_glyph if value == BoardState.EMPTY else (blocker_cell_glyph if value == BoardState.BLOCKER else occupied_cell_glyph))
		rows.append(board_row_separator.join(values))
	print(board_line_separator.join(rows))

func debug_win_encounter() -> void:
	enemy_health = 0
	status_changed.emit()
	_win_encounter()

func debug_restart_encounter() -> void:
	start_encounter(run_state, enemy, generator)

func debug_toggle_ember_for_active_piece() -> void:
	if active_piece == null or active_piece.definition == null:
		return
	for state: PieceModifierState in run_state.piece_modifiers:
		if state.definition == ember_brand_modifier and state.target_pieces.has(active_piece.definition):
			run_state.piece_modifiers.erase(state)
			run_state.piece_modifiers_changed.emit()
			active_piece.modifiers.erase(ember_brand_modifier)
			active_piece_changed.emit(active_piece)
			return
	var state: PieceModifierState = PieceModifierState.new()
	state.definition = ember_brand_modifier
	state.target_pieces = [active_piece.definition]
	run_state.add_piece_modifier(state)
	active_piece.modifiers.append(ember_brand_modifier)
	active_piece_changed.emit(active_piece)

func _resolve_placement(primary_placement: bool) -> void:
	_sync_effect_state_from_controller()
	_set_state(TurnState.RESOLVING_CLEAR)
	var clear: ClearResult = board.resolve_completed_lines()
	last_clear_result = clear
	_resolve_card_clear_effects(clear)
	artifact_service.after_line_clear(run_state, board, generator.rng, clear)
	var combo_artifact_result: ArtifactEffectContext = artifact_service.modify_combo_resolution(run_state, clear, combo)
	if combo_artifact_result.activated:
		artifact_activated.emit(combo_artifact_result.activated_artifact, combo_artifact_result.activation_message)
		event_logged.emit(combo_artifact_result.activation_message)
	if clear.line_count > 0:
		combo += 1
		run_state.successful_clear_turns += 1
		var combo_level: int = combo - 1
		var score: ScoreResult = ScoreService.calculate(clear, combo_level, rules)
		score.final_score = roundi(float(score.final_score) * _piece_score_multiplier(clear))
		var damage_context: DamageCalculationContext = DamageCalculationContext.for_clear(run_state, effect_state, clear, combo_level, rules)
		var damage: DamageResult = CombatResolver.calculate_damage(damage_context)
		CombatResolver.consume_applied_statuses(damage_context, damage)
		RelicTriggerService.new().resolve_after_clear(AfterClearContext.new(run_state, clear))
		var affinity_result: PieceModifierTriggerResult = PieceModifierService.new().resolve_after_clear(run_state, clear, _create_effect_context(null, EffectTarget.Value.ENEMY))
		_sync_controller_from_effect_state()
		damage.bonus_damage += affinity_result.health_damage + affinity_result.shield_damage
		damage.final_damage += damage.bonus_damage
		damage.sources.append_array(affinity_result.sources)
		for bonus_result: DamageResult in affinity_result.damage_results:
			damage.append_calculation(bonus_result)
		for message: String in affinity_result.messages:
			event_logged.emit(message)
		run_state.score += score.final_score
		run_state.shards += floori(float(clear.shard_reward) * run_state.shard_reward_multiplier)
		_apply_player_damage(clear.player_damage, enemy)
		if clear.poisoned_block_damage > 0:
			event_logged.emit(poisoned_block_damage_message % [clear.poisoned_block_count, plural_suffix if clear.poisoned_block_count != 1 else String(), clear.poisoned_block_damage])
		run_state.cleared_lines += clear.line_count
		run_state.cleared_cells += clear.cleared_cell_count
		run_state.cross_clears += 1 if clear.cross_clear else 0
		run_state.perfect_clears += 1 if clear.perfect_clear else 0
		run_state.highest_combo = maxi(run_state.highest_combo, combo)
		if clear.perfect_clear:
			run_state.player_statuses.remove_status(burn_status)
			var poison_instance: StatusInstance = run_state.player_statuses.get_status(poison_status)
			if poison_instance != null:
				poison_instance.stacks -= poison_stack_reduction
				if poison_instance.stacks <= 0:
					run_state.player_statuses.remove_status(poison_status)
			_cleanse_player_status(perfect_clear_cleanse_count)
			if run_state.player_statuses.instances.is_empty():
				run_state.player_shield += rules.perfect_clear_shield
				effect_state.player_shield = run_state.player_shield
		if clear.cross_clear:
			_reduce_negative_status_duration(rules.cross_status_duration_reduction)
		if clear.line_count >= burn_reduction_minimum_lines:
			_reduce_status_duration(run_state.player_statuses, burn_status, status_duration_reduction)
		if clear.line_count >= fortified_removal_minimum_lines:
			effect_state.enemy_statuses.remove_status(fortified_status)
		_apply_electrified_block_stun(clear)
		lines_cleared.emit(clear)
		if active_counter != null and active_counter_definition != null:
			CounterService.new().apply_clear(active_counter, active_counter_definition, clear)
		score_awarded.emit(score)
		_set_state(TurnState.RESOLVING_DAMAGE)
		if enemy.shield_clear_response != null:
			effect_state.enemy_shield = enemy.shield_clear_response.remaining_shield(effect_state.enemy_shield, clear)
		var main_damage: int = damage.final_damage - damage.bonus_damage
		var shield_damage: int = mini(effect_state.enemy_shield, main_damage)
		effect_state.enemy_shield -= shield_damage
		var health_damage: int = main_damage - shield_damage
		enemy_health = maxi(0, enemy_health - health_damage)
		damage.shield_damage = shield_damage + affinity_result.shield_damage
		damage.health_damage = health_damage + affinity_result.health_damage
		damage.enemy_maximum_health = enemy_maximum_health
		damage.cross_clear = clear.cross_clear
		damage.perfect_clear = clear.perfect_clear
		damage.killed_enemy = enemy_health <= 0
		if damage.health_damage >= regeneration_interrupt_damage:
			effect_state.enemy_statuses.remove_status(regeneration_status)
		if active_counter != null and active_counter_definition != null:
			CounterService.new().apply_damage(active_counter, active_counter_definition, damage.health_damage, damage.shield_damage)
			counter_changed.emit(active_counter, active_counter_definition)
			_resolve_counter_if_ready()
		_check_phase_transition()
		enemy_damaged.emit(damage)
		event_logged.emit(cleared_lines_message % [clear.line_count, score.final_score, damage.final_damage])
	else:
		if not combo_artifact_result.preserve_combo:
			combo = 0
		if enemy_health > 0 and not bonus_placement_mode and enemy.heal_on_no_clear > 0:
			enemy_health = mini(enemy_maximum_health, enemy_health + enemy.heal_on_no_clear)
			event_logged.emit(enemy_healing_message % [enemy.display_name, enemy.heal_on_no_clear])
	if bonus_placement_mode:
		_finish_bonus_placement()
		return
	if enemy_shield_turns_remaining > 0:
		enemy_shield_turns_remaining -= 1
		if enemy_shield_turns_remaining == 0:
			effect_state.enemy_shield = 0
	_apply_player_damage(board.advance_special_cells(run_state.placements), enemy)
	_sync_effect_state_from_controller()
	_tick_statuses(StatusTickPhase.Value.AFTER_PLACEMENT)
	_resolve_counter_if_ready()
	_sync_controller_from_effect_state()
	status_changed.emit()
	if primary_placement:
		placement_points_remaining = maxi(0, placement_points_remaining - 1)
		_emit_placement_economy_changed()
		var twin: BossArtifactState = run_state.get_artifact_state(twin_core_artifact)
		if twin != null and twin.ready:
			pending_enemy_step_after_twin = true
			pending_enemy_step_line_count = clear.line_count
	if run_state.player_health <= 0:
		pending_enemy_step_after_twin = false
		_resolve_lethal_outcome()
		return
	if enemy_health <= 0:
		pending_enemy_step_after_twin = false
		if placement_points_remaining <= 0:
			_finish_player_turn(false)
		else:
			_resolve_lethal_outcome()
		return
	if primary_placement and not pending_enemy_step_after_twin and not _resolve_enemy_step(clear):
		return
	if _has_player_stun() and (placement_points_remaining > 0 or pending_enemy_step_after_twin or twin_core_second_placement):
		if not _resolve_pending_enemy_step():
			return
		_finish_player_stun_after_enemy_step()
		return
	if not twin_core_second_placement and _begin_twin_core_second_placement():
		return
	if twin_core_second_placement:
		twin_core_second_placement = false
		var twin: BossArtifactState = run_state.get_artifact_state(twin_core_artifact)
		if twin != null:
			twin.ready = false
	if not _resolve_pending_enemy_step():
		return
	if _finish_player_stun_after_enemy_step():
		return
	_continue_player_turn()

func _piece_score_multiplier(clear: ClearResult) -> float:
	var multiplier: float = 1.0
	for state: PieceModifierState in run_state.piece_modifiers:
		if is_equal_approx(state.score_multiplier, 1.0):
			continue
		var contributed: bool = clear.piece_contributions.any(func(contribution: PieceClearContribution) -> bool: return state.target_pieces.has(contribution.piece))
		if contributed:
			multiplier *= state.score_multiplier
	return multiplier

func _begin_twin_core_second_placement() -> bool:
	var twin: BossArtifactState = run_state.get_artifact_state(twin_core_artifact)
	if twin == null or not twin.ready or bonus_placement_mode or deck_state == null:
		return false
	_refresh_hand_state()
	if not hand_placeable.has(true):
		deck_service.draw(deck_state, twin_core_bonus_draw_count, generator.rng, deck_rules.maximum_hand_size, deck_rules.reshuffle_discard_when_empty)
		_refresh_hand_state()
	if not hand_placeable.has(true):
		twin.ready = false
		event_logged.emit(twin_core_no_placement_message)
		return false
	twin_core_second_placement = true
	active_piece = null
	active_card = null
	active_card_index = -1
	_set_state(TurnState.AWAITING_SELECTION)
	hand_changed.emit(deck_state.hand, hand_placeable)
	select_choice(hand_placeable.find(true))
	status_changed.emit()
	_emit_safe_point()
	return true

func _finish_bonus_placement() -> void:
	_sync_effect_state_from_controller()
	_tick_statuses(StatusTickPhase.Value.AFTER_PLACEMENT)
	run_state.inventory.consume(bonus_item_slot)
	if run_state.item_uses_remaining > 0:
		run_state.item_uses_remaining -= 1
	if not run_state.debug_run:
		SaveService.profile.total_items_used += 1
		SaveService.save_profile()
	var result: ItemUseResult = ItemUseResult.new()
	result.used = true
	result.consumed = true
	item_used.emit(result, bonus_item_slot)
	bonus_placement_mode = false
	bonus_item_slot = -1
	active_piece = normal_piece_before_bonus
	normal_piece_before_bonus = null
	_sync_controller_from_effect_state()
	status_changed.emit()
	if _resolve_lethal_outcome():
		return
	if _has_player_stun():
		var stun_step_resolved: bool = _resolve_pending_enemy_step() if pending_enemy_step_after_twin else _resolve_enemy_step(last_clear_result if last_clear_result != null else ClearResult.new())
		if not stun_step_resolved:
			return
		_finish_player_stun_after_enemy_step()
		return
	_set_state(TurnState.AWAITING_PLACEMENT)
	active_piece_changed.emit(active_piece)
	_emit_safe_point()

func _resolve_enemy_step(clear_result: ClearResult) -> bool:
	_set_state(TurnState.RESOLVING_ENEMY)
	_sync_effect_state_from_controller()
	effect_state.enemy_base_interval = _current_attack_interval()
	if effect_state.enemy_statuses.has_control_effect(StatusControlEffect.Value.STUN):
		effect_state.enemy_statuses.consume_control_effect(StatusControlEffect.Value.STUN)
		_sync_controller_from_effect_state()
		event_logged.emit(enemy_stunned_message % enemy.display_name)
		status_changed.emit()
		return true
	var countdown_result: ArtifactEffectContext = artifact_service.modify_enemy_countdown(run_state, clear_result, countdown_step_per_turn)
	enemy_countdown -= countdown_result.countdown_step
	if countdown_result.activated:
		artifact_activated.emit(countdown_result.activated_artifact, countdown_result.activation_message)
		event_logged.emit(countdown_result.activation_message)
	var enemy_action_executed: bool = false
	if enemy_countdown <= 0:
		var action_countered: bool = active_counter != null and active_counter.is_completed
		if active_counter != null and not active_counter.resolved:
			if not active_counter.is_completed:
				active_counter.is_failed = true
			_resolve_counter_if_ready()
			if _resolve_lethal_outcome():
				return false
		if action_countered:
			enemy_countdown = _current_attack_interval()
			event_logged.emit(enemy_interrupted_message % enemy.display_name)
		else:
			var action_result: EnemyActionResult = _execute_enemy_attack()
			enemy_action_executed = true
			var attack_source: Resource = selected_enemy_action if selected_enemy_action != null else enemy
			var attack_damage: DamageResult = _apply_player_damage(action_result.player_damage, attack_source, DamageEventType.Value.ENEMY_ATTACK)
			action_result.player_damage = attack_damage.final_damage
			enemy_health = mini(enemy_maximum_health, enemy_health + action_result.enemy_healing)
			enemy_countdown = _current_attack_interval()
			enemy_attacked.emit(action_result.player_damage, action_result.affected_cells)
			event_logged.emit(enemy_attack_message % [enemy.display_name, action_result.player_damage])
		previous_enemy_action = selected_enemy_action
		EnemyActionSelector.new().advance_cooldowns(enemy_action_cooldowns, selected_enemy_action)
		active_counter = null
		active_counter_definition = null
		_sync_effect_state_from_controller()
		_select_next_enemy_action()
		_ensure_active_counter()
	status_changed.emit()
	if _resolve_lethal_outcome():
		return false
	if enemy_action_executed:
		_tick_statuses(StatusTickPhase.Value.AFTER_ENEMY_ACTION)
		if _resolve_lethal_outcome():
			return false
	return true

func _resolve_pending_enemy_step() -> bool:
	if not pending_enemy_step_after_twin:
		return true
	var pending_clear: ClearResult = ClearResult.new()
	pending_clear.line_count = pending_enemy_step_line_count
	pending_enemy_step_after_twin = false
	pending_enemy_step_line_count = 0
	return _resolve_enemy_step(pending_clear)

func _continue_player_turn() -> void:
	if state == TurnState.ENCOUNTER_WON or state == TurnState.RUN_LOST:
		return
	if placement_points_remaining <= 0 or deck_state == null or deck_state.hand.is_empty():
		_finish_player_turn(placement_points_remaining > 0)
		return
	active_piece = null
	active_card = null
	active_card_index = -1
	_refresh_hand_state()
	_set_state(TurnState.AWAITING_SELECTION)
	active_piece_changed.emit(null)
	if hand_placeable.has(true):
		select_choice(hand_placeable.find(true))
	else:
		if _resolve_unplayable_hand():
			return
		_emit_safe_point()

func _finish_player_turn(resolve_pass_step: bool) -> void:
	if state == TurnState.ENCOUNTER_WON or state == TurnState.RUN_LOST:
		return
	if resolve_pass_step and placement_points_remaining > 0:
		var had_player_stun_before_step: bool = _has_player_stun()
		placement_points_remaining = 0
		_emit_placement_economy_changed()
		if not _resolve_enemy_step(ClearResult.new()):
			return
		if had_player_stun_before_step and _has_player_stun():
			_cancel_twin_core_for_stun()
			_consume_player_stun()
	else:
		placement_points_remaining = 0
		_emit_placement_economy_changed()
	vault_storage_service.advance_primary_turn(run_state)
	_discard_unplayed_hand(vault_retrieval_used_this_turn)
	vault_retrieval_used_this_turn = false
	_discard_in_play_cards()
	_sync_effect_state_from_controller()
	_tick_statuses(StatusTickPhase.Value.END_PLAYER_TURN)
	if enemy_health > 0:
		_advance_counter()
	_sync_controller_from_effect_state()
	status_changed.emit()
	if _resolve_lethal_outcome():
		return
	_generate_turn()

func _generate_turn() -> void:
	turn_number += 1
	run_state.item_uses_remaining = rules.base_item_uses_per_turn
	_reset_placement_economy()
	_tick_statuses(StatusTickPhase.Value.START_PLAYER_TURN)
	if _resolve_lethal_outcome():
		return
	if _has_player_stun():
		if not _resolve_enemy_step(ClearResult.new()):
			return
		_finish_player_stun_after_enemy_step()
		return
	_ensure_active_counter()
	_set_state(TurnState.DRAWING_HAND)
	active_piece = null
	active_card = null
	active_card_index = -1
	if cursed_draft_pending:
		_inject_cursed_card()
	deck_service.draw(deck_state, _current_draw_count(), generator.rng, deck_rules.maximum_hand_size, deck_rules.reshuffle_discard_when_empty)
	_activate_drawn_hand()

func _inject_cursed_card() -> void:
	cursed_draft_pending = false
	if run_state.deck_cards.is_empty() or cursed_card_effect == null:
		return
	var source_card: PieceCardState = run_state.deck_cards[generator.rng.randi_range(0, run_state.deck_cards.size() - 1)]
	if source_card == null or source_card.piece == null:
		return
	var cursed_card: PieceCardState = PieceCardState.new()
	cursed_card.card_id = run_state.allocate_piece_card_id()
	cursed_card.piece = source_card.piece
	cursed_card.intrinsic_effect = cursed_card_effect
	cursed_card.origin = PieceCardState.Origin.TEMPORARY
	cursed_card.is_temporary = true
	deck_service.put_on_top_of_draw_pile(deck_state, cursed_card)
	event_logged.emit(cursed_card_added_message)

func _current_draw_count() -> int:
	var difficulty: DifficultyDefinition = _get_difficulty()
	var difficulty_modifier: int = difficulty.draw_count_modifier if difficulty != null else 0
	var base_count: int = deck_rules.base_draw_count + run_state.starting_modifiers.draw_count_bonus + run_state.modifiers.draw_count_bonus - enemy.draw_count_penalty + difficulty_modifier
	return maxi(minimum_draw_count, artifact_service.modify_draw_count(run_state, base_count))

func _reset_placement_economy() -> void:
	var economy: ArtifactEffectContext = _current_placement_economy()
	maximum_placement_points = maxi(1, economy.maximum_placement_points)
	placement_points_remaining = maximum_placement_points
	redraw_placement_point_cost = maxi(0, economy.redraw_placement_point_cost)
	free_redraws_remaining_this_turn = maxi(0, economy.free_redraws_per_turn)
	_emit_placement_economy_changed()

func _current_placement_economy() -> ArtifactEffectContext:
	var base_maximum: int = deck_rules.base_placement_points_per_turn + run_state.modifiers.placement_point_bonus
	var base_free_redraws: int = run_state.modifiers.free_redraws_per_turn_bonus
	return artifact_service.modify_placement_economy(run_state, base_maximum, deck_rules.redraw_placement_point_cost, base_free_redraws)

func _emit_placement_economy_changed() -> void:
	placement_economy_changed.emit(placement_points_remaining, maximum_placement_points, current_redraw_placement_point_cost(), free_redraws_remaining_this_turn)

func _activate_drawn_hand() -> void:
	_refresh_hand_state()
	_set_state(TurnState.AWAITING_SELECTION)
	if hand_placeable.has(true):
		select_choice(hand_placeable.find(true))
	else:
		active_piece = null
		active_card = null
		active_card_index = -1
		active_piece_changed.emit(null)
		if _resolve_unplayable_hand():
			return
	if not run_state.debug_run:
		for card: PieceCardState in deck_state.hand:
			if card.piece != null and not SaveService.profile.discovered_pieces.has(card.piece):
				SaveService.profile.discovered_pieces.append(card.piece)
		SaveService.save_profile()
	_emit_safe_point()

func _has_placeable_piece_in_deck() -> bool:
	for card: PieceCardState in deck_state.all_cards():
		if card != null and card.piece != null and board.can_place_piece_anywhere(card.piece):
			return true
	return false

func _resolve_unplayable_hand() -> bool:
	if hand_placeable.has(true):
		return false
	if not _has_placeable_piece_in_deck():
		_lose_run(no_valid_placements_message)
		return true
	if not can_redraw_hand():
		_finish_player_turn(true)
		return true
	return false

func _refresh_hand_state() -> void:
	hand_placeable.clear()
	if deck_state == null:
		var empty_hand: Array[PieceCardState] = []
		hand_changed.emit(empty_hand, hand_placeable)
		return
	for card: PieceCardState in deck_state.hand:
		hand_placeable.append(card != null and card.piece != null and board.can_place_piece_anywhere(card.piece))
	active_card_index = deck_state.hand.find(active_card) if active_card != null else -1
	hand_changed.emit(deck_state.hand, hand_placeable)

func _emit_safe_point() -> void:
	if restoring_from_save or board == null or deck_state == null or enemy == null:
		return
	safe_point_reached.emit(to_save_data())

func _apply_player_damage(amount: int, source: Resource = null, event_type: DamageEventType.Value = DamageEventType.Value.DIRECT_EFFECT) -> DamageResult:
	var effect_context: EffectContext = _create_effect_context(source, EffectTarget.Value.PLAYER)
	effect_context.damage_event_type = event_type
	var damage_context: DamageCalculationContext = DamageCalculationContext.for_effect(effect_context, amount)
	var result: DamageResult = CombatResolver.calculate_damage(damage_context)
	result.target = EffectTarget.Value.PLAYER
	CombatResolver.consume_applied_statuses(damage_context, result)
	last_player_damage_result = result
	var remaining: int = result.final_damage
	if remaining <= 0:
		return result
	var absorbed: int = mini(run_state.player_shield, remaining)
	run_state.player_shield -= absorbed
	remaining -= absorbed
	result.shield_damage = absorbed
	if remaining <= 0:
		return result
	var reserve_charges_before: int = run_state.last_reserve_charges
	result.health_damage = run_state.apply_player_health_damage(remaining, last_reserve_health)
	result.lethal_damage_prevented = run_state.last_reserve_charges < reserve_charges_before
	if result.lethal_damage_prevented:
		event_logged.emit(last_reserve_message)
	return result

func to_save_data() -> Dictionary:
	var artifact_states: Array[Dictionary] = []
	for artifact: BossArtifactState in run_state.artifacts:
		artifact_states.append(artifact.to_save_data())
	var cooldown_data: Array[Dictionary] = []
	for cooldown: EnemyActionCooldownState in enemy_action_cooldowns:
		cooldown_data.append(cooldown.to_save_data())
	return {
		"board": board.to_save_data(),
		"deck_state": deck_state.to_save_data(run_state.route),
		"active_card_id": active_card.card_id if active_card != null else 0,
		"rotation_index": active_piece.rotation_index if active_piece != null else 0,
		"enemy": ContentReferenceCodec.encode(enemy),
		"enemy_health": enemy_health,
		"enemy_maximum_health": enemy_maximum_health,
		"enemy_countdown": enemy_countdown,
		"enemy_shield": effect_state.enemy_shield,
		"enemy_shield_turns_remaining": enemy_shield_turns_remaining,
		"enemy_statuses": effect_state.enemy_statuses.to_save_data(),
		"active_counter": active_counter.to_save_data() if active_counter != null else {},
		"combo": combo,
		"rerolls": rerolls,
		"free_rerolls_remaining": free_rerolls_remaining,
		"maximum_placement_points": maximum_placement_points,
		"placement_points_remaining": placement_points_remaining,
		"redraw_placement_point_cost": redraw_placement_point_cost,
		"free_redraws_remaining_this_turn": free_redraws_remaining_this_turn,
		"current_phase_index": current_phase_index,
		"turn_number": turn_number,
		"twin_core_second_placement": twin_core_second_placement,
		"artifact_states": artifact_states,
		"state": int(state),
		"defeat_reason": defeat_reason if state == TurnState.RUN_LOST else String(),
		"selected_enemy_action": ContentReferenceCodec.encode(selected_enemy_action),
		"previous_enemy_action": ContentReferenceCodec.encode(previous_enemy_action),
		"enemy_action_cooldowns": cooldown_data,
		"cursed_draft_pending": cursed_draft_pending,
		"bonus_placement_mode": bonus_placement_mode,
		"bonus_item_slot": bonus_item_slot,
		"bonus_piece": ContentReferenceCodec.encode(active_piece.definition) if bonus_placement_mode and active_piece != null else "",
		"normal_piece_rotation": normal_piece_before_bonus.rotation_index if normal_piece_before_bonus != null else 0,
		"vault_piece_placement_active": vault_piece_placement_active,
		"vault_normal_piece": ContentReferenceCodec.encode(normal_piece_before_vault.definition) if normal_piece_before_vault != null else "",
		"vault_normal_piece_rotation": normal_piece_before_vault.rotation_index if normal_piece_before_vault != null else 0,
		"vault_retrieved_card": vault_retrieved_card.to_save_data() if vault_retrieved_card != null else {},
		"vault_retrieved_storage_index": vault_retrieved_storage_index,
		"vault_retrieval_used_this_turn": vault_retrieval_used_this_turn,
		"pending_enemy_step_after_twin": pending_enemy_step_after_twin,
		"pending_enemy_step_line_count": pending_enemy_step_line_count
	}

func restore_from_save(data: Dictionary) -> bool:
	var saved_state: TurnState = clampi(int(data.get("state", int(TurnState.AWAITING_PLACEMENT))), int(TurnState.INITIALIZING), int(TurnState.PAUSED)) as TurnState
	var terminal_state: bool = saved_state == TurnState.ENCOUNTER_WON or saved_state == TurnState.RUN_LOST
	defeat_reason = String(data.get("defeat_reason", player_defeated_message if saved_state == TurnState.RUN_LOST else String()))
	var restored_board: BoardState = BoardState.from_save_data(data.get("board", {}) as Dictionary)
	if restored_board == null:
		return false
	board = restored_board
	for artifact_value: Variant in data.get("artifact_states", []) as Array:
		var artifact_data: Dictionary = artifact_value as Dictionary
		var restored_artifact: BossArtifactState = BossArtifactState.from_save_data(artifact_data)
		var artifact_state: BossArtifactState = run_state.get_artifact_state(restored_artifact.definition)
		if artifact_state != null:
			artifact_state.apply_save_data(artifact_data)
	var saved_deck_state: Dictionary = data.get("deck_state", {}) as Dictionary
	deck_state = EncounterDeckState.from_save_data(saved_deck_state, run_state.route) if not saved_deck_state.is_empty() else _restore_legacy_deck_state(data)
	if deck_state == null or deck_state.all_cards().is_empty():
		return false
	var active_card_id: int = int(data.get("active_card_id", 0))
	active_card = deck_state.find_card(active_card_id) if active_card_id > 0 else null
	if active_card == null and not data.has("active_card_id") and not deck_state.hand.is_empty():
		var legacy_active_index: int = clampi(int(data.get("active_choice_index", 0)), 0, deck_state.hand.size() - 1)
		active_card = deck_state.hand[legacy_active_index]
	active_card_index = deck_state.hand.find(active_card)
	bonus_placement_mode = bool(data.get("bonus_placement_mode", false))
	bonus_item_slot = int(data.get("bonus_item_slot", -1))
	vault_piece_placement_active = bool(data.get("vault_piece_placement_active", false))
	var retrieved_card_data: Dictionary = data.get("vault_retrieved_card", {}) as Dictionary
	vault_retrieved_card = PieceCardState.from_save_data(retrieved_card_data) if not retrieved_card_data.is_empty() else null
	if vault_retrieved_card == null:
		var retrieved_piece_reference: String = String(data.get("vault_retrieved_piece", data.get("vault_retrieved_piece_id", "")))
		var retrieved_piece: PieceDefinition = ContentReferenceCodec.decode_legacy(retrieved_piece_reference, PieceDefinition, ContentRegistry.catalog) as PieceDefinition
		if retrieved_piece != null:
			vault_retrieved_card = PieceCardState.new()
			vault_retrieved_card.piece = retrieved_piece
			vault_retrieved_card.origin = PieceCardState.Origin.MIGRATED
	vault_retrieved_storage_index = int(data.get("vault_retrieved_storage_index", -1))
	vault_retrieval_used_this_turn = bool(data.get("vault_retrieval_used_this_turn", false))
	enemy_maximum_health = maxi(minimum_enemy_health, int(data.get("enemy_maximum_health", enemy_maximum_health)))
	var minimum_restored_enemy_health: int = 0 if saved_state == TurnState.ENCOUNTER_WON else minimum_enemy_health
	enemy_health = clampi(int(data.get("enemy_health", enemy_maximum_health)), minimum_restored_enemy_health, enemy_maximum_health)
	enemy_countdown = maxi(minimum_attack_interval, int(data.get("enemy_countdown", enemy.attack_interval)))
	effect_state.enemy_health = enemy_health
	effect_state.enemy_maximum_health = enemy_maximum_health
	effect_state.enemy_countdown = enemy_countdown
	effect_state.enemy_shield = maxi(0, int(data.get("enemy_shield", 0)))
	enemy_shield_turns_remaining = maxi(0, int(data.get("enemy_shield_turns_remaining", 0)))
	effect_state.enemy_statuses = StatusCollection.from_save_data(data.get("enemy_statuses", []) as Array)
	effect_state.player_statuses = run_state.player_statuses
	effect_state.player_shield = run_state.player_shield
	current_phase_index = clampi(int(data.get("current_phase_index", 0)), 0, maxi(0, enemy.phases.size() - 1))
	effect_state.enemy_base_interval = _current_attack_interval()
	var previous_reference: String = String(data.get("previous_enemy_action", data.get("previous_enemy_action_id", "")))
	previous_enemy_action = ContentReferenceCodec.decode(previous_reference, EnemyActionDefinition) as EnemyActionDefinition
	if previous_enemy_action == null:
		previous_enemy_action = _find_legacy_enemy_action(previous_reference)
	var selected_reference: String = String(data.get("selected_enemy_action", data.get("selected_enemy_action_id", "")))
	selected_enemy_action = ContentReferenceCodec.decode(selected_reference, EnemyActionDefinition) as EnemyActionDefinition
	if selected_enemy_action == null:
		selected_enemy_action = _find_legacy_enemy_action(selected_reference)
	enemy_action_cooldowns.clear()
	for cooldown_value: Variant in data.get("enemy_action_cooldowns", []) as Array:
		var cooldown: EnemyActionCooldownState = EnemyActionCooldownState.from_save_data(cooldown_value as Dictionary)
		if cooldown.action == null:
			cooldown.action = _find_legacy_enemy_action(String((cooldown_value as Dictionary).get("action_id", "")))
		if cooldown.action != null:
			enemy_action_cooldowns.append(cooldown)
	cursed_draft_pending = bool(data.get("cursed_draft_pending", false))
	if selected_enemy_action == null:
		_select_next_enemy_action()
	else:
		resolved_enemy_intent = EnemyActionSelector.new().resolve_intent(selected_enemy_action, enemy_countdown)
		intent_changed.emit(resolved_enemy_intent)
	turn_number = maxi(0, int(data.get("turn_number", 0)))
	twin_core_second_placement = bool(data.get("twin_core_second_placement", false))
	pending_enemy_step_after_twin = bool(data.get("pending_enemy_step_after_twin", false))
	pending_enemy_step_line_count = maxi(0, int(data.get("pending_enemy_step_line_count", 0)))
	active_counter = null
	active_counter_definition = null
	var counter_data: Dictionary = data.get("active_counter", {}) as Dictionary
	if not counter_data.is_empty():
		active_counter = ActiveCounterState.from_save_data(counter_data)
		active_counter_definition = active_counter.definition
	combo = maxi(0, int(data.get("combo", 0)))
	rerolls = maxi(0, int(data.get("rerolls", 0)))
	free_rerolls_remaining = maxi(0, int(data.get("free_rerolls_remaining", 0)))
	var economy: ArtifactEffectContext = _current_placement_economy()
	maximum_placement_points = maxi(1, int(data.get("maximum_placement_points", economy.maximum_placement_points)))
	placement_points_remaining = clampi(int(data.get("placement_points_remaining", maximum_placement_points)), 0, maximum_placement_points)
	redraw_placement_point_cost = maxi(0, int(data.get("redraw_placement_point_cost", economy.redraw_placement_point_cost)))
	free_redraws_remaining_this_turn = maxi(0, int(data.get("free_redraws_remaining_this_turn", data.get("free_redraws_remaining", economy.free_redraws_per_turn))))
	if rules.base_item_uses_per_turn < 0:
		run_state.item_uses_remaining = -1
	active_piece = null
	if active_card != null:
		if bonus_placement_mode:
			normal_piece_before_bonus = _create_card_piece_instance(active_card, PieceSourceType.Value.DRAWN_CARD)
			normal_piece_before_bonus.rotation_index = posmod(int(data.get("normal_piece_rotation", 0)), normal_piece_before_bonus.unique_rotations.size())
			var bonus_piece: PieceDefinition = ContentReferenceCodec.decode_legacy(String(data.get("bonus_piece", data.get("bonus_piece_id", ""))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
			if bonus_piece == null:
				bonus_placement_mode = false
				bonus_item_slot = -1
				active_piece = normal_piece_before_bonus
				normal_piece_before_bonus = null
			else:
				active_piece = _create_piece_instance(bonus_piece, PieceSourceType.Value.BONUS_BLOCK)
		elif vault_piece_placement_active and vault_retrieved_card != null:
			normal_piece_before_vault = _create_card_piece_instance(active_card, PieceSourceType.Value.DRAWN_CARD)
			normal_piece_before_vault.rotation_index = posmod(int(data.get("vault_normal_piece_rotation", 0)), normal_piece_before_vault.unique_rotations.size())
			active_piece = _create_card_piece_instance(vault_retrieved_card, PieceSourceType.Value.ARTIFACT_GENERATED)
		else:
			var restored_source: PieceSourceType.Value = PieceSourceType.Value.ARTIFACT_SECONDARY if twin_core_second_placement else PieceSourceType.Value.DRAWN_CARD
			active_piece = _create_card_piece_instance(active_card, restored_source)
		active_piece.rotation_index = posmod(int(data.get("rotation_index", 0)), active_piece.unique_rotations.size())
	state = saved_state if terminal_state else TurnState.AWAITING_PLACEMENT if active_piece != null else TurnState.AWAITING_SELECTION
	_refresh_hand_state()
	if not terminal_state and active_piece == null and _resolve_unplayable_hand():
		return true
	active_piece_changed.emit(active_piece)
	_emit_placement_economy_changed()
	counter_changed.emit(active_counter, active_counter_definition)
	status_changed.emit()
	return true

func _restore_legacy_deck_state(data: Dictionary) -> EncounterDeckState:
	var restored: EncounterDeckState = deck_service.initialize_encounter(run_state.deck_cards, generator.rng, false)
	var legacy_choices: Array = data.get("choices", []) as Array
	if legacy_choices.is_empty():
		deck_service.draw(restored, _current_draw_count(), generator.rng, deck_rules.maximum_hand_size, deck_rules.reshuffle_discard_when_empty)
		return restored
	var desired_pieces: Array[PieceDefinition] = []
	for value: Variant in legacy_choices:
		var desired_piece: PieceDefinition = ContentReferenceCodec.decode_legacy(String(value), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
		if desired_piece != null:
			desired_pieces.append(desired_piece)
	for piece: PieceDefinition in desired_pieces:
		var matching_card: PieceCardState
		for card: PieceCardState in restored.draw_pile:
			if card.piece == piece:
				matching_card = card
				break
		if matching_card != null:
			restored.draw_pile.erase(matching_card)
			restored.hand.append(matching_card)
	deck_service.draw(restored, maxi(0, _current_draw_count() - restored.hand.size()), generator.rng, deck_rules.maximum_hand_size, deck_rules.reshuffle_discard_when_empty)
	return restored

func _execute_enemy_attack() -> EnemyActionResult:
	var result: EnemyActionResult
	if selected_enemy_action != null:
		_sync_effect_state_from_controller()
		var context: EffectContext = _create_effect_context(selected_enemy_action, EffectTarget.Value.PLAYER)
		context.damage_event_type = DamageEventType.Value.ENEMY_ATTACK
		var empowered_venom: bool = selected_enemy_action.consumes_empowered_venom and effect_state.enemy_statuses.get_status(empowered_venom_status) != null
		context.stack_modifier = empowered_venom_stack_bonus if empowered_venom else 0
		result = selected_enemy_action.execute_with_context(board, generator.rng, context)
		if selected_enemy_action.shield_duration_placements > 0 and effect_state.enemy_shield > 0:
			enemy_shield_turns_remaining = selected_enemy_action.shield_duration_placements
		if empowered_venom:
			effect_state.enemy_statuses.remove_status(empowered_venom_status)
		if selected_enemy_action.schedules_cursed_draft:
			cursed_draft_pending = true
		_sync_controller_from_effect_state()
	elif not enemy.phases.is_empty() and current_phase_index < enemy.phases.size():
		var phase: EnemyPhaseDefinition = enemy.phases[current_phase_index]
		if not phase.action_pattern.is_empty():
			result = phase.action_pattern[run_state.placements % phase.action_pattern.size()].execute(board, generator.rng)
	if result == null:
		result = EnemyActionResult.new()
		result.player_damage = enemy.direct_damage
		result.affected_cells = board.add_blockers(enemy.blocker_count, generator.rng)
	RelicTriggerService.new().apply_spawned_blocker_durability(run_state, board, result.affected_cells)
	return result

func _current_attack_interval() -> int:
	var base_interval: int = enemy.attack_interval
	if not enemy.phases.is_empty() and current_phase_index < enemy.phases.size():
		base_interval = enemy.phases[current_phase_index].attack_interval
	var difficulty: DifficultyDefinition = _get_difficulty()
	return maxi(minimum_attack_interval, base_interval + (difficulty.attack_interval_modifier if difficulty != null else 0))

func _get_difficulty() -> DifficultyDefinition:
	return run_state.difficulty

func _check_phase_transition() -> void:
	if enemy_health <= 0 or enemy.phases.is_empty():
		return
	while current_phase_index + 1 < enemy.phases.size():
		var next_phase: EnemyPhaseDefinition = enemy.phases[current_phase_index + 1]
		var health_percent: float = float(enemy_health) / float(enemy_maximum_health)
		if health_percent > next_phase.health_threshold_percent:
			return
		current_phase_index += 1
		active_counter = null
		active_counter_definition = null
		enemy_countdown = _current_attack_interval()
		_sync_effect_state_from_controller()
		_select_next_enemy_action()
		_ensure_active_counter()
		enemy_phase_changed.emit(next_phase)
		for action: EnemyActionDefinition in next_phase.phase_start_actions:
			var result: EnemyActionResult = action.execute(board, generator.rng)
			_apply_player_damage(result.player_damage, action, DamageEventType.Value.ENEMY_ATTACK)
			enemy_health = mini(enemy_maximum_health, enemy_health + result.enemy_healing)
		_sync_effect_state_from_controller()
		event_logged.emit(enemy_phase_message % [enemy.display_name, next_phase.display_name_suffix])
		status_changed.emit()
		if run_state.player_health <= 0 or enemy_health <= 0:
			return

func _win_encounter() -> void:
	defeat_reason = String()
	_set_state(TurnState.ENCOUNTER_WON)
	run_state.enemies_defeated += 1
	encounter_won.emit()

func _lose_run(reason: String) -> void:
	defeat_reason = reason
	_set_state(TurnState.RUN_LOST)
	run_lost.emit(reason)

func _resolve_lethal_outcome() -> bool:
	if run_state.player_health <= 0:
		_lose_run(player_defeated_message)
		return true
	if enemy_health <= 0:
		run_state.player_statuses.consume_control_effect(StatusControlEffect.Value.STUN)
		_win_encounter()
		return true
	return false

func _set_state(next_state: TurnState) -> void:
	var previous: TurnState = state
	state = next_state
	turn_state_changed.emit(previous, state)

func _create_effect_context(source: Resource, target: EffectTarget.Value) -> EffectContext:
	var context: EffectContext = EffectContext.new()
	context.source = source
	context.target = target
	context.current_turn = turn_number
	context.encounter = enemy
	context.run_seed = run_state.seed_value
	context.board_state = board
	context.run_state = run_state
	context.encounter_state = effect_state
	context.rng = generator.rng
	context.deck_state = deck_state
	context.maximum_hand_size = deck_rules.maximum_hand_size
	context.active_counter = active_counter
	context.last_reserve_health = last_reserve_health
	context.last_reserve_message = last_reserve_message
	return context

func _sync_effect_state_from_controller() -> void:
	effect_state.enemy_health = enemy_health
	effect_state.enemy_maximum_health = enemy_maximum_health
	effect_state.enemy_countdown = enemy_countdown
	effect_state.enemy_base_interval = _current_attack_interval()
	effect_state.player_shield = run_state.player_shield
	effect_state.player_statuses = run_state.player_statuses

func _sync_controller_from_effect_state() -> void:
	enemy_health = effect_state.enemy_health
	enemy_countdown = effect_state.enemy_countdown
	run_state.player_shield = effect_state.player_shield
	run_state.player_statuses = effect_state.player_statuses

func _tick_statuses(phase: StatusTickPhase.Value) -> EffectResult:
	_sync_effect_state_from_controller()
	var player_context: EffectContext = _create_effect_context(null, EffectTarget.Value.PLAYER)
	var result: EffectResult = StatusResolver.new().tick(effect_state.player_statuses, phase, player_context)
	var enemy_context: EffectContext = _create_effect_context(null, EffectTarget.Value.ENEMY)
	var enemy_result: EffectResult = StatusResolver.new().tick(effect_state.enemy_statuses, phase, enemy_context)
	result.merge(enemy_result)
	_sync_controller_from_effect_state()
	var damaged_enemy: bool = _process_enemy_effect_damage(enemy_result, true)
	_emit_effect_messages(result)
	_resolve_counter_if_ready()
	if damaged_enemy:
		_check_phase_transition()
	return result

func _apply_electrified_block_stun(clear: ClearResult) -> void:
	if clear == null or clear.electrified_block_count <= 0 or electrified_block_stun_effect == null:
		return
	_sync_effect_state_from_controller()
	var context: EffectContext = _create_effect_context(enemy, EffectTarget.Value.PLAYER)
	var result: EffectResult = electrified_block_stun_effect.apply(context)
	_sync_controller_from_effect_state()
	_emit_effect_messages(result)
	if result.applied_statuses.has(electrified_status):
		event_logged.emit(electrified_blocks_message % [clear.electrified_block_count, plural_suffix if clear.electrified_block_count != 1 else String()])

func _has_player_stun() -> bool:
	return run_state != null and run_state.player_statuses.has_control_effect(StatusControlEffect.Value.STUN)

func _consume_player_stun() -> void:
	if run_state == null:
		return
	var consumed: Array[StatusDefinition] = run_state.player_statuses.consume_control_effect(StatusControlEffect.Value.STUN)
	if consumed.is_empty():
		return
	effect_state.player_statuses = run_state.player_statuses
	event_logged.emit(player_stunned_message)
	status_changed.emit()

func _finish_player_stun_after_enemy_step() -> bool:
	if not _has_player_stun():
		return false
	_cancel_twin_core_for_stun()
	_consume_player_stun()
	_finish_player_turn(false)
	return true

func _cancel_twin_core_for_stun() -> void:
	pending_enemy_step_after_twin = false
	pending_enemy_step_line_count = 0
	twin_core_second_placement = false
	var twin: BossArtifactState = run_state.get_artifact_state(twin_core_artifact)
	if twin != null:
		twin.ready = false

func _cleanse_player_status(maximum: int) -> void:
	var removed: int = 0
	for instance: StatusInstance in effect_state.player_statuses.instances.duplicate():
		if removed >= maximum:
			return
		var definition: StatusDefinition = instance.definition
		if definition == null or not definition.is_cleansable or definition.category == StatusCategory.Value.POSITIVE:
			continue
		effect_state.player_statuses.remove_status(definition)
		removed += 1

func _reduce_negative_status_duration(amount: int) -> void:
	for instance: StatusInstance in effect_state.player_statuses.instances:
		var definition: StatusDefinition = instance.definition
		if definition != null and definition.is_cleansable and definition.category != StatusCategory.Value.POSITIVE:
			instance.remaining_turns -= amount
			if instance.remaining_turns <= 0:
				effect_state.player_statuses.remove_status(definition)
			return

func _reduce_status_duration(collection: StatusCollection, status: StatusDefinition, amount: int) -> void:
	var instance: StatusInstance = collection.get_status(status)
	if instance == null:
		return
	instance.remaining_turns -= amount
	if instance.remaining_turns <= 0:
		collection.remove_status(status)

func _ensure_active_counter() -> void:
	if active_counter != null:
		return
	var action: EnemyActionDefinition = _current_action_definition()
	if action == null or action.counter_definition == null:
		active_counter = null
		active_counter_definition = null
		return
	active_counter_definition = action.counter_definition
	active_counter = CounterService.new().create(active_counter_definition, enemy, board, generator.rng)
	counter_changed.emit(active_counter, active_counter_definition)

func _advance_counter() -> void:
	if active_counter == null or active_counter_definition == null or active_counter.resolved:
		return
	CounterService.new().advance_deadline(active_counter)
	_resolve_counter_if_ready()

func _resolve_counter_if_ready() -> void:
	if active_counter == null or active_counter_definition == null or active_counter.resolved:
		return
	if not active_counter.is_completed and not active_counter.is_failed:
		return
	_sync_effect_state_from_controller()
	var completed: bool = active_counter.is_completed
	if completed:
		effect_state.enemy_countdown = _current_attack_interval()
	var result: EffectResult = CounterService.new().resolve(active_counter, active_counter_definition, _create_effect_context(active_counter_definition, EffectTarget.Value.PLAYER))
	if completed:
		if not run_state.debug_run:
			SaveService.profile.total_boss_actions_countered += 1
			SaveService.save_profile()
		event_logged.emit(counter_completed_message % active_counter_definition.display_name)
	else:
		event_logged.emit(counter_failed_message % active_counter_definition.display_name)
	_sync_controller_from_effect_state()
	var damaged_enemy: bool = _process_enemy_effect_damage(result, false)
	_emit_effect_messages(result)
	counter_changed.emit(active_counter, active_counter_definition)
	if damaged_enemy:
		_check_phase_transition()

func _current_action_definition() -> EnemyActionDefinition:
	if selected_enemy_action != null:
		return selected_enemy_action
	if enemy.phases.is_empty() or current_phase_index >= enemy.phases.size():
		return null
	var pattern: Array[EnemyActionDefinition] = enemy.phases[current_phase_index].action_pattern
	return pattern[run_state.placements % pattern.size()] if not pattern.is_empty() else null

func _select_next_enemy_action() -> void:
	if enemy == null or generator == null:
		return
	selected_enemy_action = EnemyActionSelector.new().select_action(enemy, current_phase_index, effect_state, board, generator.rng, previous_enemy_action, enemy_action_cooldowns)
	if selected_enemy_action == null:
		resolved_enemy_intent = _create_legacy_intent()
		intent_changed.emit(resolved_enemy_intent)
		return
	resolved_enemy_intent = EnemyActionSelector.new().resolve_intent(selected_enemy_action, enemy_countdown)
	intent_changed.emit(resolved_enemy_intent)

func _create_legacy_intent() -> ResolvedEnemyIntent:
	var intent: ResolvedEnemyIntent = ResolvedEnemyIntent.new()
	intent.display_name = enemy.legacy_blocker_intent_name if enemy.blocker_count > 0 else enemy.legacy_direct_intent_name
	intent.description = enemy.legacy_blocker_intent_description if enemy.blocker_count > 0 else enemy.legacy_direct_intent_description
	intent.action_tags = enemy.legacy_intent_action_tags.duplicate()
	intent.turns_remaining = enemy_countdown
	intent.direct_damage = enemy.direct_damage
	intent.affected_cell_count = enemy.blocker_count
	intent.icon_type = EnemyIntentIcon.Value.BLOCKER if enemy.blocker_count > 0 else EnemyIntentIcon.Value.DAMAGE
	return intent

func _find_legacy_enemy_action(reference: String) -> EnemyActionDefinition:
	return ContentReferenceCodec.decode_legacy(reference, EnemyActionDefinition, ContentRegistry.catalog) as EnemyActionDefinition

func _accept_rotation_press() -> bool:
	if run_state.player_statuses.get_status(slowed_hands_status) != null:
		event_logged.emit(slowed_hands_message)
		return false
	return true

func _resolve_card_placement_effect(card: PieceCardState) -> void:
	if card == null or card.intrinsic_effect == null:
		return
	_sync_effect_state_from_controller()
	var result: EffectResult = card_effect_service.resolve_placement(card, _create_effect_context(card.intrinsic_effect, EffectTarget.Value.ENEMY))
	_apply_card_effect_result(card, result)

func _resolve_card_clear_effects(clear: ClearResult) -> void:
	var contributions: Array[PieceClearContribution] = clear.piece_contributions.duplicate()
	contributions.sort_custom(func(left: PieceClearContribution, right: PieceClearContribution) -> bool:
		var left_priority: int = left.card.intrinsic_effect.priority if left.card != null and left.card.intrinsic_effect != null else 0
		var right_priority: int = right.card.intrinsic_effect.priority if right.card != null and right.card.intrinsic_effect != null else 0
		return left_priority < right_priority if left_priority != right_priority else left.piece_instance_id < right.piece_instance_id)
	for contribution: PieceClearContribution in contributions:
		var card: PieceCardState = contribution.card
		if card == null or card.intrinsic_effect == null:
			continue
		var result: EffectResult = card_effect_service.resolve_clear(card, contribution, clear, _create_effect_context(card.intrinsic_effect, EffectTarget.Value.ENEMY))
		_apply_card_effect_result(card, result)

func _apply_card_effect_result(card: PieceCardState, result: EffectResult) -> void:
	if card == null or card.intrinsic_effect == null or result == null or not result.applied:
		return
	_sync_controller_from_effect_state()
	var damaged_enemy: bool = _process_enemy_effect_damage(result, true)
	_resolve_counter_if_ready()
	if damaged_enemy:
		_check_phase_transition()
	card_effect_resolved.emit(card, card.intrinsic_effect, result)
	_emit_effect_messages(result)
	event_logged.emit(card_effect_message_format % [card.intrinsic_effect.display_name, card.intrinsic_effect.description])
	_refresh_hand_state()
	status_changed.emit()

func _process_enemy_effect_damage(result: EffectResult, progress_counter: bool) -> bool:
	if result == null:
		return false
	var health_damage: int = 0
	var shield_damage: int = 0
	for damage: DamageResult in result.damage_results:
		if damage != null and damage.target == EffectTarget.Value.ENEMY:
			health_damage += damage.health_damage
			shield_damage += damage.shield_damage
			damage.enemy_maximum_health = enemy_maximum_health
			damage.killed_enemy = enemy_health <= 0
			enemy_damaged.emit(damage)
	if health_damage <= 0 and shield_damage <= 0:
		return false
	if health_damage >= regeneration_interrupt_damage:
		effect_state.enemy_statuses.remove_status(regeneration_status)
	if progress_counter and active_counter != null and active_counter_definition != null:
		CounterService.new().apply_damage(active_counter, active_counter_definition, health_damage, shield_damage)
		counter_changed.emit(active_counter, active_counter_definition)
	return true

func _emit_effect_messages(result: EffectResult) -> void:
	if result == null:
		return
	for message: String in result.messages:
		if not message.is_empty():
			event_logged.emit(message)

func _discard_in_play_cards() -> void:
	if deck_state == null:
		return
	var played_cards: Array[PieceCardState] = deck_state.in_play.duplicate()
	for card: PieceCardState in played_cards:
		deck_service.discard_in_play(deck_state, card.card_id)
	_refresh_hand_state()

func _create_card_piece_instance(card: PieceCardState, source_type: PieceSourceType.Value) -> PieceInstance:
	var piece: PieceInstance = _create_piece_instance(card.piece if card != null else null, source_type)
	piece.bind_card(card)
	return piece

func _create_piece_instance(definition: PieceDefinition, source_type: PieceSourceType.Value) -> PieceInstance:
	var piece: PieceInstance = PieceInstance.new(definition)
	piece.source_type = source_type
	if run_state == null:
		return piece
	for state: PieceModifierState in run_state.get_piece_modifiers(definition):
		if not piece.modifiers.has(state.definition):
			piece.modifiers.append(state.definition)
	return piece
