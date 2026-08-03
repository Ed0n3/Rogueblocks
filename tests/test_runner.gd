extends Node

const SPAWN_IGNITED_BLOCKS_EFFECT_SCRIPT: Script = preload("res://core/effects/implementations/spawn_ignited_blocks_effect.gd")
const REMOVE_RANDOM_OCCUPIED_CELLS_EFFECT_SCRIPT: Script = preload("res://core/effects/implementations/remove_random_occupied_cells_effect.gd")
const ARCHITECT_ENEMY: EnemyDefinition = preload("res://content/enemies/bosses/architect.tres")
const TRAINING_SLIME_ENEMY: EnemyDefinition = preload("res://content/enemies/training_slime.tres")
const ARCHITECT_HAND_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/architect_hand.tres")
const INFINITE_MOLD_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/infinite_mold.tres")
const MOMENTUM_LATTICE_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/momentum_lattice.tres")
const TIMEKEEPER_GEAR_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/timekeeper_gear.tres")
const TWIN_CORE_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/twin_core.tres")
const VAULT_SHAPES_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/vault_shapes.tres")
const WARDEN_PRISM_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/warden_prism.tres")
const CLOSED_LOOP_HOPPER_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/closed_loop_hopper.tres")
const OVERCLOCKED_FEED_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/overclocked_feed.tres")
const DOMINO_PIECE: PieceDefinition = preload("res://content/pieces/domino.tres")
const TET_I_PIECE: PieceDefinition = preload("res://content/pieces/tet_i.tres")
const TET_L_PIECE: PieceDefinition = preload("res://content/pieces/tet_l.tres")
const TET_O_PIECE: PieceDefinition = preload("res://content/pieces/tet_o.tres")
const TET_S_PIECE: PieceDefinition = preload("res://content/pieces/tet_s.tres")
const TET_Z_PIECE: PieceDefinition = preload("res://content/pieces/tet_z.tres")
const TRI_I_PIECE: PieceDefinition = preload("res://content/pieces/tri_i.tres")
const MONOMINO_PIECE: PieceDefinition = preload("res://content/pieces/monomino.tres")
const FRACTURE_MODIFIER: PieceModifierDefinition = preload("res://content/piece_modifiers/fracture_rune.tres")
const VENOM_GEOMETRY_MODIFIER: PieceModifierDefinition = preload("res://content/piece_modifiers/venom_geometry.tres")
const EMBER_BRAND_MODIFIER: PieceModifierDefinition = preload("res://content/piece_modifiers/ember_brand.tres")
const GUARDIAN_PATTERN_MODIFIER: PieceModifierDefinition = preload("res://content/piece_modifiers/guardian_pattern.tres")
const FRACTURE_RELIC: RelicDefinition = preload("res://content/relics/fracture_rune.tres")
const GUARDIAN_RELIC: RelicDefinition = preload("res://content/relics/guardian_pattern.tres")
const CURATORS_CHOICE_RELIC: RelicDefinition = preload("res://content/relics/curators_choice.tres")
const VAULT_ACCELERATOR_RELIC: RelicDefinition = preload("res://content/relics/vault_accelerator.tres")
const FIFTH_GEAR_RELIC: RelicDefinition = preload("res://content/relics/fifth_gear.tres")
const TWIN_SPOOL_RECYCLER_RELIC: RelicDefinition = preload("res://content/relics/twin_spool_recycler.tres")
const SHARP_LINES_RELIC: RelicDefinition = preload("res://content/relics/sharp_lines.tres")
const TWIN_PREFERENCE_RELIC: RelicDefinition = preload("res://content/relics/twin_preference.tres")
const SHAPE_SUPPRESSOR_RELIC: RelicDefinition = preload("res://content/relics/shape_suppressor.tres")
const SMALL_SHAPE_CACHE_RELIC: RelicDefinition = preload("res://content/relics/small_shape_cache.tres")
const BLOCK_CAPSULE_ITEM: ItemDefinition = preload("res://content/items/block_capsule.tres")
const STRENGTH_TONIC_ITEM: ItemDefinition = preload("res://content/items/strength_tonic.tres")
const BARRIER_POTION_ITEM: ItemDefinition = preload("res://content/items/barrier_potion.tres")
const BOMB_FLASK_ITEM: ItemDefinition = preload("res://content/items/bomb_flask.tres")
const GUIDED_ONBOARDING_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/onboarding/guided_onboarding.tres")
const ROUTE_BASICS_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/contextual/route_basics.tres")
const SHOP_BASICS_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/contextual/shop_basics.tres")
const RELICS_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/contextual/relics.tres")
const BOSS_ARTIFACTS_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/bosses/artifacts.tres")
const PERMANENT_PROGRESSION_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/progression/permanent_progression.tres")
const UPGRADE_MATRIX_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/progression/upgrade_matrix.tres")
const HUB_OVERVIEW_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/progression/hub_overview.tres")
const ENEMY_ACTIONS_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/combat/enemy_actions.tres")
const DIFFICULTY_DAILY_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/progression/difficulty_daily.tres")
const ITEMS_INVENTORY_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/items/items_inventory.tres")
const STARTING_PIECE_DRAFT_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/progression/starting_piece_draft.tres")
const HOSTILE_DIFFICULTY: DifficultyDefinition = preload("res://content/difficulties/hostile.tres")
const MASON_ENEMY: EnemyDefinition = preload("res://content/enemies/mason.tres")
const KINETIC_IMPACT_EFFECT: PieceCardEffectDefinition = preload("res://content/card_effects/kinetic_impact.tres")
const PRISM_GUARD_EFFECT: PieceCardEffectDefinition = preload("res://content/card_effects/prism_guard.tres")
const REPAIR_GLYPH_EFFECT: PieceCardEffectDefinition = preload("res://content/card_effects/repair_glyph.tres")
const RECLAIM_LOOP_EFFECT: PieceCardEffectDefinition = preload("res://content/card_effects/reclaim_loop.tres")
const CURSED_FRAGMENT_EFFECT: PieceCardEffectDefinition = preload("res://content/card_effects/cursed_fragment.tres")
const FRACTURE_TRACE_EFFECT: PieceCardEffectDefinition = preload("res://content/card_effects/fracture_trace.tres")
const CRACKED_STATUS: StatusDefinition = preload("res://content/statuses/cracked.tres")
const VULNERABLE_STATUS: StatusDefinition = preload("res://content/statuses/vulnerable.tres")
const ELECTRIFIED_STATUS: StatusDefinition = preload("res://content/statuses/electrified.tres")
const STANDARD_BACK_BUTTON_MINIMUM_SIZE: Vector2 = Vector2(104.0, 44.0)

var checks: TestAssertions = TestAssertions.new()

func _ready() -> void:
	print("Running rotations")
	_test_rotations()
	print("Running placement")
	_test_board_placement()
	print("Running ignited Blocks")
	_test_ignited_blocks()
	print("Running grid scrubber")
	_test_grid_scrubber()
	print("Running poisoned Blocks")
	await _test_poisoned_blocks()
	print("Running electrified Blocks")
	await _test_electrified_blocks()
	print("Running clears")
	_test_line_clears()
	print("Running deck draw, discard, retrieval, and effects")
	_test_deck_drawing()
	_test_piece_card_effects()
	print("Running generation")
	_test_generation()
	print("Running piece drafting and active pools")
	_test_piece_drafting_and_active_pools()
	print("Running score and damage")
	_test_score_and_damage()
	print("Running piece modifiers and clear attribution")
	_test_piece_modifiers_and_clear_attribution()
	print("Running tutorial system")
	await _test_tutorial_system()
	print("Running tutorial archive replay")
	await _test_tutorial_archive_replay()
	print("Running encounter")
	_test_encounter()
	print("Running electrified stuns")
	_test_electrified_stuns()
	print("Running Act 1 enemy roster")
	_test_act_one_enemy_roster()
	print("Running block world enemy expansion")
	_test_block_world_enemy_expansion()
	print("Running enemy balance curve")
	_test_enemy_balance_curve()
	print("Running save format")
	_test_save_format()
	print("Running progression")
	_test_progression()
	print("Running migrations and active saves")
	_test_migrations_and_active_save()
	print("Running routes")
	_test_routes()
	print("Running events and board layouts")
	_test_events_and_board_layouts()
	print("Running route shops and Matrix catalog")
	_test_shops()
	print("Running special cells")
	_test_special_cells()
	print("Running relic triggers and boss phases")
	_test_relic_triggers_and_phases()
	print("Running boss artifacts")
	await _test_boss_artifacts()
	print("Running daily mode")
	_test_daily_mode()
	print("Running debug encounter test area")
	await _test_debug_encounter_area()
	print("Running Phase 2 scene resources")
	_test_phase_two_scenes()
	print("Running route shop presentation")
	await _test_shop_presentation()
	print("Running route shop target selection and legacy recovery")
	await _test_shop_target_selection_flow()
	print("Running route loadout drawer")
	await _test_route_loadout_drawer()
	print("Running presentation systems")
	await _test_presentation_systems()
	print("Running combat effect visuals")
	await _test_combat_effect_visuals()
	print("Running lethal presentation sequencing")
	await _test_lethal_presentation_sequence()
	print("Running touch board controls")
	await _test_touch_board_controls()
	print("Running status effect modal touch")
	await _test_status_effect_modal_touch()
	print("Running touch settings layout")
	await _test_touch_settings_layout()
	print("Running touch upgrade tabs")
	await _test_touch_upgrade_tabs()
	print("Running scaled enemy damage")
	await _test_scaled_enemy_damage()
	print("Running visual layout stability")
	await _test_visual_layouts()
	print("Running effects, statuses, and items")
	_test_effects_statuses_and_items()
	print("Rogueblocks tests: %d passed, %d failed" % [checks.passed, checks.failed])
	get_tree().quit(0 if checks.failed == 0 else 1)

func _test_piece_modifiers_and_clear_attribution() -> void:
	var vertical: PieceDefinition = PieceDefinition.new()
	vertical.display_name = "Test Vertical"
	vertical.base_cells = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)]
	var mono: PieceDefinition = PieceDefinition.new()
	mono.display_name = "Test Mono"
	mono.base_cells = [Vector2i.ZERO]
	var board: BoardState = BoardState.new(3, 3)
	var vertical_instance: PieceInstance = PieceInstance.new(vertical)
	vertical_instance.source_type = PieceSourceType.Value.BONUS_BLOCK
	vertical_instance.modifiers = [FRACTURE_MODIFIER]
	var vertical_placement: PlacementResult = board.place_piece(Vector2i(1, 0), vertical_instance)
	var left_instance: PieceInstance = PieceInstance.new(mono)
	left_instance.source_type = PieceSourceType.Value.DRAWN_CARD
	board.place_piece(Vector2i(0, 1), left_instance)
	board.place_piece(Vector2i(2, 1), PieceInstance.new(mono))
	checks.truthy(vertical_placement.success, "Attributed Block placement succeeds")
	checks.equal(board.occupant_pieces[1], vertical, "Placed cells retain their Block resource")
	checks.equal(board.occupant_instance_ids[1], vertical_placement.piece_instance_id, "Placed cells retain their unique instance ID")
	checks.equal(board.occupant_source_types[1], PieceSourceType.Value.BONUS_BLOCK, "Placed cells retain their source type")
	checks.truthy(board.get_occupant_modifiers(Vector2i(1, 0)).has(FRACTURE_MODIFIER), "Placed cells retain visual modifier resources")
	var saved_board: Dictionary = board.to_save_data()
	var restored_board: BoardState = BoardState.from_save_data(saved_board)
	checks.equal(restored_board.occupant_pieces.size(), restored_board.cells.size(), "Board restore preserves positional Block metadata for every cell")
	checks.equal(restored_board.occupant_instance_ids[1], vertical_placement.piece_instance_id, "Board saves preserve piece ownership")
	checks.equal(restored_board.get_occupant_modifiers(Vector2i(1, 0))[0], FRACTURE_MODIFIER, "Board saves preserve modifier markings")
	var resumed_placement: PlacementResult = restored_board.place_piece(Vector2i(2, 2), PieceInstance.new(mono))
	checks.truthy(resumed_placement.success, "A resumed fight can place a Block into the final board cell")
	checks.equal(restored_board.occupant_pieces[8], mono, "Resumed placement writes positional Block metadata at the final index")
	var clear: ClearResult = board.resolve_completed_lines()
	checks.truthy(clear.cross_clear, "Attributed clear recognizes row-column crosses")
	checks.equal(clear.piece_contributions.size(), 3, "Cross clear reports every contributing piece instance")
	var vertical_contribution: PieceClearContribution
	for contribution: PieceClearContribution in clear.piece_contributions:
		if contribution.piece_instance_id == vertical_placement.piece_instance_id:
			vertical_contribution = contribution
	checks.truthy(vertical_contribution != null, "Clear result exposes the placed Block contribution")
	checks.equal(vertical_contribution.cleared_cells.size(), 3, "Intersection cells are not duplicated in contributions")
	checks.truthy(vertical_contribution.participated_in_cross_clear, "Contribution records cross participation")
	checks.truthy(vertical_contribution.all_remaining_cells_cleared, "Contribution records full Block removal")
	checks.equal(vertical_contribution.source_type, PieceSourceType.Value.BONUS_BLOCK, "Contribution preserves bonus Block source")
	var run: RunState = RunState.new()
	var modifier_state: PieceModifierState = PieceModifierState.new()
	modifier_state.definition = FRACTURE_MODIFIER
	modifier_state.source_relic = FRACTURE_RELIC
	modifier_state.target_pieces = [vertical]
	run.add_piece_modifier(modifier_state)
	run.removed_pieces.append(vertical)
	run.removed_pieces.clear()
	var persistent_piece: PieceDefinition = ContentRegistry.pieces[0]
	modifier_state.target_pieces.append(persistent_piece)
	var saved_run: RunState = RunState.from_save_data(run.to_save_data())
	checks.equal(saved_run.piece_modifiers.size(), 1, "Piece modifier states survive run save and restore")
	checks.equal(saved_run.piece_modifiers[0].target_pieces[0], persistent_piece, "Selected modifier targets survive save and restore")
	var request: PieceTargetRequest = PieceTargetRequest.new()
	request.selection_mode = PieceTargetSelectionMode.Value.RANDOM_MULTIPLE
	request.candidate_count = 4
	request.selection_count = 2
	var first_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	first_rng.seed = 9001
	var second_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	second_rng.seed = 9001
	var first_targets: Array[PieceDefinition] = PieceTargetSelector.new().resolve_targets(RunState.new(), request, first_rng)
	var second_targets: Array[PieceDefinition] = PieceTargetSelector.new().resolve_targets(RunState.new(), request, second_rng)
	checks.equal(first_targets, second_targets, "Piece target candidates are deterministic for the same seed")
	checks.truthy(ContentRegistry.relics.has(FRACTURE_RELIC), "Fracture Rune is registered")
	checks.truthy(ContentRegistry.piece_modifiers.has(FRACTURE_MODIFIER), "Fracture Rune modifier is registered")
	var affinity_run: RunState = RunState.new()
	var affinity_state: PieceModifierState = PieceModifierState.new()
	affinity_state.definition = FRACTURE_MODIFIER
	affinity_state.source_relic = FRACTURE_RELIC
	affinity_state.target_pieces = [vertical]
	affinity_run.add_piece_modifier(affinity_state)
	var effect_context: EffectContext = EffectContext.new()
	effect_context.run_state = affinity_run
	effect_context.board_state = board
	effect_context.encounter_state = EncounterEffectState.new()
	effect_context.encounter_state.enemy_health = 20
	effect_context.encounter_state.enemy_maximum_health = 20
	effect_context.encounter_state.enemy_shield = 3
	effect_context.current_turn = 2
	effect_context.rng = RandomNumberGenerator.new()
	var affinity_result: PieceModifierTriggerResult = PieceModifierService.new().resolve_after_clear(affinity_run, clear, effect_context)
	checks.equal(affinity_result.shield_damage, 3, "Affinity damage resolves against enemy shield first")
	checks.equal(affinity_result.health_damage, 6, "Affinity damage applies once for each line in a cross clear and respects the applied Cracked status")
	checks.truthy(effect_context.encounter_state.enemy_statuses.get_status(preload("res://content/statuses/cracked.tres") as StatusDefinition) != null, "Affinity status effects use the authoritative status system")
	var shared_line_clear: ClearResult = ClearResult.new()
	shared_line_clear.line_count = 1
	for instance_id: int in [101, 102]:
		var shared_contribution: PieceClearContribution = PieceClearContribution.new()
		shared_contribution.piece = vertical
		shared_contribution.piece_instance_id = instance_id
		shared_contribution.affected_rows = PackedInt32Array([0])
		shared_line_clear.piece_contributions.append(shared_contribution)
	var shared_line_run: RunState = RunState.new()
	var shared_damage_state: PieceModifierState = PieceModifierState.new()
	shared_damage_state.definition = FRACTURE_MODIFIER
	shared_damage_state.target_pieces = [vertical]
	shared_line_run.add_piece_modifier(shared_damage_state)
	var shared_damage_context: EffectContext = EffectContext.new()
	shared_damage_context.run_state = shared_line_run
	shared_damage_context.encounter_state = EncounterEffectState.new()
	shared_damage_context.encounter_state.enemy_health = 20
	shared_damage_context.encounter_state.enemy_maximum_health = 20
	var shared_damage_result: PieceModifierTriggerResult = PieceModifierService.new().resolve_after_clear(shared_line_run, shared_line_clear, shared_damage_context)
	checks.equal(shared_damage_result.health_damage, 4, "Multiple enchanted Blocks on one line trigger damage only once")
	var dot_state: PieceModifierState = PieceModifierState.new()
	dot_state.definition = VENOM_GEOMETRY_MODIFIER
	dot_state.target_pieces = [vertical]
	var dot_run: RunState = RunState.new()
	dot_run.add_piece_modifier(dot_state)
	var dot_context: EffectContext = EffectContext.new()
	dot_context.run_state = dot_run
	dot_context.encounter_state = EncounterEffectState.new()
	dot_context.encounter_state.enemy_health = 20
	dot_context.encounter_state.enemy_maximum_health = 20
	var venom_geometry_result: PieceModifierTriggerResult = PieceModifierService.new().resolve_after_clear(dot_run, shared_line_clear, dot_context)
	checks.equal(venom_geometry_result.health_damage, 2, "Venom Geometry deals direct bonus damage instead of poisoning enemies")
	checks.equal(dot_context.encounter_state.enemy_statuses.get_status(preload("res://content/statuses/affinity_poison.tres") as StatusDefinition), null, "Player Block effects cannot apply Poison to enemies")
	checks.truthy(ResourceLoader.exists("res://scenes/rewards/piece_target_selection_overlay.tscn"), "Choice-based relics provide a reusable target-selection modal")
	var pending_state: PieceModifierState = PieceModifierState.new()
	pending_state.definition = EMBER_BRAND_MODIFIER
	pending_state.pending_selection = true
	pending_state.required_selection_count = 1
	pending_state.candidate_pieces = [ContentRegistry.pieces[0]]
	affinity_run.add_piece_modifier(pending_state)
	affinity_run.pending_piece_selection_flow = PieceSelectionFlow.Value.COMBAT_REWARD
	var pending_restore: RunState = RunState.from_save_data(affinity_run.to_save_data())
	checks.truthy(pending_restore.piece_modifiers.back().pending_selection, "Pending target selections survive interruption")
	checks.equal(pending_restore.pending_piece_selection_flow, PieceSelectionFlow.Value.COMBAT_REWARD, "Pending selection continuation survives interruption")
	var damage: DamageResult = DamageResult.new()
	damage.final_damage = 11
	damage.health_damage = 7
	damage.shield_damage = 4
	damage.enemy_maximum_health = 24
	damage.sources = [FRACTURE_MODIFIER]
	var presentation_damage: DamagePresentationResult = DamagePresentationResult.from_damage_result(damage)
	checks.equal(presentation_damage.total_damage, 11, "Damage presentation aggregates health and shield damage")
	checks.equal(presentation_damage.shield_damage, 4, "Damage presentation preserves shield damage")
	checks.equal(presentation_damage.intensity(), 3, "Damage presentation scales intensity against maximum health")
	dot_state.encounter_trigger_count = 2
	dot_state.triggered_piece_instance_ids = PackedInt64Array([41, 42])
	dot_state.last_trigger_turn = 7
	PieceModifierService.new().reset_encounter(dot_run)
	checks.equal(dot_state.encounter_trigger_count, 0, "Encounter reset clears modifier encounter usage")
	checks.truthy(dot_state.triggered_piece_instance_ids.is_empty(), "Encounter reset clears per-piece trigger history")
	checks.equal(dot_state.last_trigger_turn, -1, "Encounter reset clears per-turn trigger history")

func _test_tutorial_system() -> void:
	checks.truthy(ContentRegistry.tutorials.size() >= 10, "Tutorial content covers guided and contextual mechanics")
	checks.equal(TutorialValidator.new().validate_all(ContentRegistry.tutorials).size(), 0, "Tutorial resources pass validation")
	checks.equal(ROUTE_BASICS_TUTORIAL.replay_context, TutorialReplayContext.Value.ROUTE, "Route lessons replay on the route screen")
	checks.equal(SHOP_BASICS_TUTORIAL.replay_context, TutorialReplayContext.Value.SHOP, "Shop lessons replay on the shop screen")
	checks.equal(RELICS_TUTORIAL.replay_context, TutorialReplayContext.Value.REWARD, "Relic lessons replay on the reward screen")
	checks.equal(BOSS_ARTIFACTS_TUTORIAL.replay_context, TutorialReplayContext.Value.ARTIFACT, "Artifact lessons replay on the artifact screen")
	checks.equal(PERMANENT_PROGRESSION_TUTORIAL.replay_context, TutorialReplayContext.Value.HUB, "Progression lessons replay on the hub where they first appear")
	checks.equal(HUB_OVERVIEW_TUTORIAL.replay_context, TutorialReplayContext.Value.HUB, "Progression Hub Tour replays on the hub")
	checks.truthy(ContentRegistry.tutorials.has(HUB_OVERVIEW_TUTORIAL), "Progression Hub Tour is registered in the content catalog")
	checks.equal(HUB_OVERVIEW_TUTORIAL.activation_event, TutorialEventId.Value.PROGRESSION_HUB_OPENED, "Progression Hub Tour activates when the hub opens")
	checks.equal(HUB_OVERVIEW_TUTORIAL.steps.size(), 6, "Progression Hub Tour explains every major hub area")
	checks.equal(HUB_OVERVIEW_TUTORIAL.steps[0].target.target_key, TutorialTargetKey.Value.HUB_RUN_CONTROLS, "Progression Hub Tour begins with expedition controls")
	checks.equal(HUB_OVERVIEW_TUTORIAL.steps[1].target.target_key, TutorialTargetKey.Value.HUB_PERMANENT_UPGRADES, "Progression Hub Tour explains permanent upgrades")
	checks.equal(HUB_OVERVIEW_TUTORIAL.steps[2].target.target_key, TutorialTargetKey.Value.HUB_DAILY_CHALLENGE, "Progression Hub Tour explains daily challenges")
	checks.equal(HUB_OVERVIEW_TUTORIAL.steps[3].target.target_key, TutorialTargetKey.Value.HUB_ARCHIVE, "Progression Hub Tour explains the archive")
	checks.equal(HUB_OVERVIEW_TUTORIAL.steps[4].target.target_key, TutorialTargetKey.Value.HUB_HEADER_CONTROLS, "Progression Hub Tour explains header controls")
	checks.equal(HUB_OVERVIEW_TUTORIAL.steps[5].target.target_key, TutorialTargetKey.Value.HUB_MAIN_MENU, "Progression Hub Tour explains returning to the main menu")
	checks.equal(UPGRADE_MATRIX_TUTORIAL.replay_context, TutorialReplayContext.Value.UPGRADES, "Upgrade Matrix lessons replay inside the matrix")
	checks.truthy(ContentRegistry.tutorials.has(UPGRADE_MATRIX_TUTORIAL), "Upgrade Matrix tutorial is registered in the content catalog")
	checks.equal(UPGRADE_MATRIX_TUTORIAL.activation_event, TutorialEventId.Value.PERMANENT_UPGRADES_OPENED, "Upgrade Matrix tutorial activates when the matrix opens")
	checks.equal(STARTING_PIECE_DRAFT_TUTORIAL.replay_context, TutorialReplayContext.Value.DRAFT, "Starting Block Draft replays on the draft screen")
	checks.equal(PERMANENT_PROGRESSION_TUTORIAL.steps[0].target.target_key, TutorialTargetKey.Value.HUB_PERMANENT_UPGRADES, "Permanent progression highlights the hub upgrade action")
	checks.equal(UPGRADE_MATRIX_TUTORIAL.steps.size(), 4, "Upgrade Matrix tutorial explains its complete progression flow")
	checks.equal(UPGRADE_MATRIX_TUTORIAL.steps[0].target.target_key, TutorialTargetKey.Value.PROGRESSION_UPGRADE_GRID, "Upgrade Matrix tutorial begins on the colored upgrade board")
	checks.equal(UPGRADE_MATRIX_TUTORIAL.steps[1].target.target_key, TutorialTargetKey.Value.PROGRESSION_UPGRADE_ACTIONS, "Upgrade Matrix tutorial explains buying and placing Blocks")
	checks.equal(UPGRADE_MATRIX_TUTORIAL.steps[2].target.target_key, TutorialTargetKey.Value.PROGRESSION_UPGRADE_DETAILS, "Upgrade Matrix tutorial explains level thresholds")
	checks.equal(UPGRADE_MATRIX_TUTORIAL.steps[3].target.target_key, TutorialTargetKey.Value.PROGRESSION_UPGRADE_CONFIRM, "Upgrade Matrix tutorial explains permanent confirmation")
	checks.equal(ENEMY_ACTIONS_TUTORIAL.steps[0].target.target_key, TutorialTargetKey.Value.COMBAT_ENEMY_INTENT, "Enemy action reference highlights the intent badge")
	checks.equal(GUIDED_ONBOARDING_TUTORIAL.steps[2].target.target_key, TutorialTargetKey.Value.COMBAT_BOARD, "Placement onboarding highlights the board")
	checks.equal(GUIDED_ONBOARDING_TUTORIAL.steps[2].additional_input_targets[0].target_key, TutorialTargetKey.Value.COMBAT_PLACE, "Placement onboarding keeps the Place button interactive")
	checks.equal(GUIDED_ONBOARDING_TUTORIAL.steps[3].target.target_key, TutorialTargetKey.Value.COMBAT_ROTATE_TUTORIAL, "Rotation onboarding uses the responsive rotation target")
	checks.truthy(GUIDED_ONBOARDING_TUTORIAL.steps[3].additional_input_targets.any(func(target: TutorialTarget) -> bool: return target.target_key == TutorialTargetKey.Value.COMBAT_BOARD), "Rotation onboarding permits board swipes")
	checks.truthy(GUIDED_ONBOARDING_TUTORIAL.steps[3].additional_input_targets.any(func(target: TutorialTarget) -> bool: return target.target_key == TutorialTargetKey.Value.COMBAT_ROTATE_LEFT), "Rotation onboarding permits either rotate button")
	checks.equal((GUIDED_ONBOARDING_TUTORIAL.steps[3].entry_actions[0] as TutorialSandboxAction).pieces[0], TET_L_PIECE, "Rotation onboarding loads a rotatable Piece first")
	checks.equal((GUIDED_ONBOARDING_TUTORIAL.steps[3].entry_actions[1] as TutorialSandboxAction).command, TutorialSandboxAction.Command.SHOW_ACTIVE_PIECE_PREVIEW, "Rotation onboarding shows an active preview before requesting rotation")
	checks.equal((GUIDED_ONBOARDING_TUTORIAL.steps[4].entry_actions[1] as TutorialSandboxAction).board_cells.size(), 5, "Line-clear onboarding fills the correct number of cells for a nine-column board")
	checks.truthy(GUIDED_ONBOARDING_TUTORIAL.steps[5].wait_for_player_confirmation and GUIDED_ONBOARDING_TUTORIAL.steps[5].completion_conditions.is_empty(), "Enemy damage onboarding remains readable until confirmed")
	checks.equal(DIFFICULTY_DAILY_TUTORIAL.steps[0].target.target_key, TutorialTargetKey.Value.HUB_DAILY_CHALLENGE, "Daily challenge reference highlights the hub action")
	var progress: TutorialProgress = TutorialProgress.new()
	progress.completed_tutorials = [GUIDED_ONBOARDING_TUTORIAL]
	progress.skipped_tutorials = [ROUTE_BASICS_TUTORIAL]
	progress.dismissed_hints = [RELICS_TUTORIAL]
	progress.active_tutorial = SHOP_BASICS_TUTORIAL
	progress.active_step_index = 1
	progress.record_attempt(SHOP_BASICS_TUTORIAL)
	progress.record_attempt(SHOP_BASICS_TUTORIAL)
	progress.record_completion(GUIDED_ONBOARDING_TUTORIAL, 1234)
	progress.contextual_tips_enabled = false
	var restored: TutorialProgress = TutorialProgress.from_save_data(progress.to_save_data())
	checks.equal(restored.completed_tutorials, progress.completed_tutorials, "Completed tutorial progress persists")
	checks.equal(restored.skipped_tutorials, progress.skipped_tutorials, "Skipped tutorial progress persists")
	checks.equal(restored.active_step_index, 1, "Partial tutorial step persists")
	checks.equal(restored.attempt_count(SHOP_BASICS_TUTORIAL), 2, "Tutorial attempt counts persist")
	checks.falsy(restored.contextual_tips_enabled, "Contextual tutorial preference persists")
	var unknown_progress: TutorialProgress = TutorialProgress.new()
	var unknown_tutorial: TutorialDefinition = TutorialDefinition.new()
	unknown_progress.completed_tutorials = [unknown_tutorial]
	unknown_progress.active_tutorial = unknown_tutorial
	unknown_progress.sanitize(ContentRegistry.tutorials)
	checks.truthy(unknown_progress.completed_tutorials.is_empty(), "Unknown tutorial resources are removed during profile sanitization")
	checks.equal(unknown_progress.active_tutorial, null, "Unknown active tutorials fail safely during migration")
	var migration_data: Dictionary = {"version": 5, "schema": ProfileState.SCHEMA}
	var migrated: Dictionary = ProfileMigration5To6.new().migrate(migration_data)
	checks.equal(migrated.get("version"), 6, "Profile migration advances tutorial saves to version 6")
	checks.truthy(migrated.has("tutorial_progress"), "Profile migration adds tutorial progress safely")
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.LINES_CLEARED)
	event.int_value = 2
	var context: TutorialContext = TutorialContext.new()
	context.current_event = event
	var condition: LineCountClearedCondition = LineCountClearedCondition.new()
	condition.minimum_lines = 2
	checks.truthy(condition.is_satisfied(context), "Tutorial conditions consume semantic gameplay events")
	condition.minimum_lines = 3
	checks.falsy(condition.is_satisfied(context), "Tutorial conditions respect configured thresholds")
	var target_control: Control = Control.new()
	add_child(target_control)
	target_control.position = Vector2(40, 50)
	target_control.size = Vector2(100, 60)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_BOARD, target_control)
	var target: TutorialTarget = TutorialTarget.new()
	target.target_key = TutorialTargetKey.Value.COMBAT_BOARD
	target.padding = 5.0
	var rectangle: Rect2 = TutorialTargetRegistry.resolve_rect(target)
	checks.equal(rectangle.size, Vector2(110, 70), "Tutorial targets resolve controls with configured padding")
	TutorialTargetRegistry.unregister_target(TutorialTargetKey.Value.COMBAT_BOARD)
	target_control.queue_free()
	var old_owner: Node = Node.new()
	var new_owner: Node = Node.new()
	var old_target: Control = Control.new()
	var new_target: Control = Control.new()
	add_child(old_owner)
	add_child(new_owner)
	old_owner.add_child(old_target)
	new_owner.add_child(new_target)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ENEMY, old_target, old_owner)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ENEMY, new_target, new_owner)
	TutorialTargetRegistry.unregister_owner(old_owner)
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.COMBAT_ENEMY), new_target, "An old screen cannot unregister a replacement screen's tutorial target")
	TutorialTargetRegistry.unregister_owner(new_owner)
	old_owner.queue_free()
	new_owner.queue_free()
	var missing_target: TutorialTarget = TutorialTarget.new()
	missing_target.target_key = TutorialTargetKey.Value.COMBAT_REROLL
	checks.equal(TutorialTargetRegistry.resolve_rect(missing_target), Rect2(), "Missing tutorial targets fail safely")
	var formatted: String = TutorialInputFormatter.format_text("Rotate with {rotate_left} or {rotate_right}.")
	checks.falsy(formatted.contains("{rotate_left}"), "Tutorial prompts resolve current input mappings")
	var previous_progress_data: Dictionary = SaveService.profile.tutorial_progress.to_save_data()
	SaveService.profile.tutorial_progress.tutorials_enabled = true
	SaveService.profile.tutorial_progress.completed_tutorials.append(HUB_OVERVIEW_TUTORIAL)
	TutorialService.reset_progress()
	var hub_screen: HubScreen = (load("res://scenes/hub/hub_screen.tscn") as PackedScene).instantiate() as HubScreen
	add_child(hub_screen)
	await get_tree().process_frame
	checks.equal(TutorialService.active_definition, HUB_OVERVIEW_TUTORIAL, "Returning to the hub after Help reset automatically starts the complete Hub Tour")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.HUB_RUN_CONTROLS), hub_screen.get_node("Margin/Layout/Dashboard/ExpeditionCard"), "Hub Tour registers its expedition target")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.HUB_PERMANENT_UPGRADES), hub_screen.get_node("Margin/Layout/Dashboard/UpgradeCard/UpgradeLayout/Upgrades"), "Hub Tour registers its upgrade target")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.HUB_DAILY_CHALLENGE), hub_screen.get_node("Margin/Layout/Dashboard/DailyCard/DailyLayout/Daily"), "Hub Tour registers its daily target")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.HUB_ARCHIVE), hub_screen.get_node("Margin/Layout/Dashboard/ArchiveCard"), "Hub Tour registers its archive target")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.HUB_HEADER_CONTROLS), hub_screen.get_node("Margin/Layout/TopBar"), "Hub Tour registers its header target")
	var hub_top_bar: HBoxContainer = hub_screen.get_node("Margin/Layout/TopBar") as HBoxContainer
	var hub_back: Button = hub_screen.get_node("Margin/Layout/TopBar/Back") as Button
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.HUB_MAIN_MENU), hub_back, "Hub Tour registers its main-menu target")
	checks.equal(hub_back.get_parent(), hub_top_bar, "Hub Back action lives in the header")
	checks.equal(hub_back.get_index(), hub_top_bar.get_child_count() - 1, "Hub Back action is the rightmost header control")
	checks.falsy(hub_screen.has_node("Margin/Layout/MainMenu"), "Hub omits the old bottom return action")
	for hub_step_index: int in range(1, HUB_OVERVIEW_TUTORIAL.steps.size()):
		TutorialService.confirm_current_step()
		checks.equal(TutorialService.current_step(), HUB_OVERVIEW_TUTORIAL.steps[hub_step_index], "Hub Tour advances to step %d" % [hub_step_index + 1])
	TutorialService.confirm_current_step()
	checks.truthy(SaveService.profile.tutorial_progress.completed_tutorials.has(HUB_OVERVIEW_TUTORIAL), "Completing every Hub Tour area records the lesson")
	TutorialService.reset_progress()
	hub_screen.queue_free()
	await get_tree().process_frame
	var matrix_owner: Node = Node.new()
	var matrix_target: Control = Control.new()
	add_child(matrix_owner)
	matrix_owner.add_child(matrix_target)
	TutorialService.enter_screen(TutorialScreen.Value.UPGRADES, matrix_owner)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.PROGRESSION_UPGRADE_GRID, matrix_target, matrix_owner)
	SaveService.profile.tutorial_progress.tutorials_enabled = true
	SaveService.profile.tutorial_progress.completed_tutorials.append(UPGRADE_MATRIX_TUTORIAL)
	TutorialService.reset_progress()
	TutorialService.publish(TutorialEventId.Value.PERMANENT_UPGRADES_OPENED)
	checks.equal(TutorialService.active_definition, UPGRADE_MATRIX_TUTORIAL, "Resetting Help progress allows the Upgrade Matrix tutorial to activate automatically again")
	TutorialService.cancel_active()
	TutorialService.leave_screen(TutorialScreen.Value.UPGRADES, matrix_owner)
	TutorialTargetRegistry.unregister_owner(matrix_owner)
	matrix_owner.queue_free()
	TutorialService.reset_progress()
	checks.truthy(TutorialService.start_tutorial(GUIDED_ONBOARDING_TUTORIAL, true), "A guided tutorial can start manually")
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[0], "Tutorial starts at its first step")
	TutorialService.confirm_current_step()
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[1], "Confirmation advances a message step")
	var selection_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.PIECE_SELECTED)
	selection_event.int_value = 0
	TutorialService.publish_event(selection_event)
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[2], "Authoritative selection event completes the selection step")
	TutorialService.skip_active()
	checks.truthy(SaveService.profile.tutorial_progress.completed_tutorials.has(GUIDED_ONBOARDING_TUTORIAL), "Configured skip marks first-run onboarding complete")
	checks.truthy(SaveService.profile.tutorial_progress.skipped_tutorials.has(GUIDED_ONBOARDING_TUTORIAL), "Tutorial skip persists separately")
	SaveService.profile.tutorial_progress = TutorialProgress.from_save_data(previous_progress_data)
	SaveService.save_profile()
	var overlay_scene: PackedScene = load("res://presentation/tutorial/tutorial_overlay.tscn") as PackedScene
	var overlay: CanvasLayer = overlay_scene.instantiate() as CanvasLayer
	add_child(overlay)
	await get_tree().process_frame
	checks.truthy(overlay.get_node("Root/MessagePanel") != null, "Tutorial overlay provides a message panel")
	checks.truthy(overlay.get_node("Root/Spotlight") is TutorialSpotlight, "Tutorial overlay provides a target-following spotlight")
	checks.truthy(overlay.get_node("Root/InputBlocker") is TutorialInputBlocker, "Tutorial overlay provides configurable input filtering")
	var overlay_root: Control = overlay.get_node("Root") as Control
	var overlay_panel: PanelContainer = overlay.get_node("Root/MessagePanel") as PanelContainer
	checks.equal(overlay_root.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Tutorial overlay root allows highlighted controls to receive input")
	checks.truthy(overlay_root.theme != null, "Tutorial overlay uses the game theme outside the main scene hierarchy")
	checks.equal(overlay_panel.theme_type_variation, &"ElevatedPanel", "Tutorial window uses the game elevated panel style")
	checks.equal((overlay as TutorialOverlay).get_panel_width(1280.0, true), 520.0, "Mobile tutorial panels stay compact on a wide logical viewport")
	checks.equal((overlay as TutorialOverlay).get_panel_width(360.0, true), 312.0, "Narrow mobile tutorial panels retain consistent side margins")
	checks.equal((overlay as TutorialOverlay).get_hint_width(1280.0, true), 360.0, "Mobile tutorial hints use a compact maximum width")
	var skip_visibility_step: TutorialStepDefinition = TutorialStepDefinition.new()
	skip_visibility_step.title = "Skip Visibility"
	skip_visibility_step.body = "Continue is enough."
	skip_visibility_step.wait_for_player_confirmation = true
	skip_visibility_step.input_mode = TutorialInputMode.Value.FULLY_BLOCKED
	var single_step_tutorial: TutorialDefinition = TutorialDefinition.new()
	single_step_tutorial.display_name = "Single Step"
	single_step_tutorial.blocks_gameplay = true
	single_step_tutorial.can_skip = true
	single_step_tutorial.steps = [skip_visibility_step]
	(overlay as TutorialOverlay).call("_show_step", single_step_tutorial, skip_visibility_step, 0)
	checks.falsy((overlay.get_node("Root/MessagePanel/Layout/Actions/Skip") as Button).visible, "Single-step tutorials hide the redundant skip action")
	var multiple_step_tutorial: TutorialDefinition = TutorialDefinition.new()
	multiple_step_tutorial.display_name = "Touch Safety"
	multiple_step_tutorial.blocks_gameplay = true
	multiple_step_tutorial.can_skip = true
	multiple_step_tutorial.steps = [skip_visibility_step, skip_visibility_step]
	(overlay as TutorialOverlay).call("_show_step", multiple_step_tutorial, skip_visibility_step, 0)
	checks.truthy((overlay.get_node("Root/MessagePanel/Layout/Actions/Skip") as Button).visible, "Multi-step tutorials retain the skip action")
	var input_blocker: TutorialInputBlocker = overlay.get_node("Root/InputBlocker") as TutorialInputBlocker
	input_blocker.target_rect = Rect2(100.0, 100.0, 200.0, 120.0)
	var additional_target_rects: Array[Rect2] = [Rect2(400.0, 100.0, 100.0, 120.0)]
	input_blocker.set_additional_target_rects(additional_target_rects)
	checks.truthy(input_blocker.is_pointer_allowed(Vector2(150.0, 150.0), TutorialInputMode.Value.ACTIONS_ONLY), "Highlighted controls remain clickable during action-limited steps")
	checks.truthy(input_blocker.is_pointer_allowed(Vector2(450.0, 150.0), TutorialInputMode.Value.ACTIONS_ONLY), "Configured secondary tutorial targets remain clickable")
	checks.falsy(input_blocker.is_pointer_allowed(Vector2(350.0, 150.0), TutorialInputMode.Value.ACTIONS_ONLY), "Action-limited steps still block unrelated pointer input")
	var tutorial_continue: Button = overlay.get_node("Root/MessagePanel/Layout/Actions/Continue") as Button
	checks.equal(input_blocker.interactive_button_at(tutorial_continue.get_global_rect().get_center()), tutorial_continue, "Tutorial actions are the only interactive controls inside the message window")
	checks.falsy(input_blocker.is_pointer_allowed(overlay_panel.get_global_rect().get_center(), TutorialInputMode.Value.FULLY_BLOCKED), "Blank tutorial window space blocks pointer input")
	TutorialService.cancel_active()
	var tutorial_touch_main: Control = (load("res://scenes/main/main.tscn") as PackedScene).instantiate() as Control
	add_child(tutorial_touch_main)
	await get_tree().process_frame
	checks.truthy(TutorialService.start_tutorial(multiple_step_tutorial, true), "Touch safety tutorial starts for input routing")
	await get_tree().process_frame
	await get_tree().process_frame
	var routed_tutorial_overlay: TutorialOverlay = tutorial_touch_main.call("_tutorial_overlay") as TutorialOverlay
	var routed_tutorial_panel: PanelContainer = routed_tutorial_overlay.get_node("Root/MessagePanel") as PanelContainer
	var routed_tutorial_continue: Button = routed_tutorial_overlay.get_node("Root/MessagePanel/Layout/Actions/Continue") as Button
	var tutorial_underlay: Button = Button.new()
	tutorial_underlay.icon = tutorial_touch_main.get("empty_icon") as Texture2D
	var tutorial_panel_rect: Rect2 = routed_tutorial_panel.get_global_rect()
	tutorial_underlay.position = tutorial_panel_rect.position
	tutorial_underlay.size = tutorial_panel_rect.size
	(tutorial_touch_main.get_node("ScreenContainer") as Control).add_child(tutorial_underlay)
	var tutorial_underlay_presses: Array[int] = [0]
	tutorial_underlay.pressed.connect(func() -> void: tutorial_underlay_presses[0] += 1)
	_send_main_touch(tutorial_touch_main, tutorial_panel_rect.get_center(), 38)
	checks.equal(tutorial_underlay_presses[0], 0, "Touching blank tutorial window space never activates a covered screen button")
	checks.equal(tutorial_touch_main.call("_button_at", routed_tutorial_continue.get_global_rect().get_center()), routed_tutorial_continue, "Tutorial buttons take priority over covered screen buttons")
	_send_main_touch(tutorial_touch_main, routed_tutorial_continue.get_global_rect().get_center(), 39)
	await get_tree().process_frame
	checks.equal(TutorialService.runtime.step_index, 1, "Touch activates the tutorial Continue button")
	checks.equal(tutorial_underlay_presses[0], 0, "Touching a tutorial button never activates a covered screen button")
	TutorialService.cancel_active()
	SaveService.profile.tutorial_progress.erase_history(multiple_step_tutorial)
	tutorial_touch_main.queue_free()
	await get_tree().process_frame
	checks.equal(GUIDED_ONBOARDING_TUTORIAL.steps[2].input_mode, TutorialInputMode.Value.TARGET_ONLY, "Placement tutorial restricts input to the board and Place button")
	var guided_tutorial: TutorialDefinition = GUIDED_ONBOARDING_TUTORIAL
	var summary_step: TutorialStepDefinition = guided_tutorial.steps[guided_tutorial.steps.size() - 1]
	overlay.call("_show_step", guided_tutorial, summary_step, guided_tutorial.steps.size() - 1)
	checks.falsy((overlay.get_node("Root/Spotlight") as TutorialSpotlight).visible, "Untargeted summary steps do not draw a false highlight")
	checks.equal((overlay.get_node("Root/Spotlight") as TutorialSpotlight).target_rect, Rect2(), "Untargeted summary steps clear the previous highlight rectangle")
	var archive_scene: PackedScene = load("res://scenes/tutorial/tutorial_archive_screen.tscn") as PackedScene
	checks.truthy(archive_scene != null, "Tutorial archive is replayable from the hub")
	var fake_step: TutorialStepDefinition = TutorialStepDefinition.new()
	fake_step.title = "Priority"
	fake_step.body = "Priority test"
	fake_step.wait_for_player_confirmation = true
	var low: TutorialDefinition = TutorialDefinition.new()
	low.display_name = "Low"
	low.activation_event = TutorialEventId.Value.STATUS_APPLIED
	low.activation_mode = TutorialActivationMode.Value.CONTEXTUAL_EVENT
	low.repeat_policy = TutorialRepeatPolicy.Value.ALWAYS
	low.priority = 1
	low.steps = [fake_step]
	var high: TutorialDefinition = TutorialDefinition.new()
	high.display_name = "High"
	high.activation_event = TutorialEventId.Value.STATUS_APPLIED
	high.activation_mode = TutorialActivationMode.Value.CONTEXTUAL_EVENT
	high.repeat_policy = TutorialRepeatPolicy.Value.ALWAYS
	high.priority = 99
	high.steps = [fake_step]
	ContentRegistry.tutorials.append(low)
	ContentRegistry.tutorials.append(high)
	var previous_tutorials_enabled: bool = SaveService.profile.tutorial_progress.tutorials_enabled
	var previous_contextual_tips_enabled: bool = SaveService.profile.tutorial_progress.contextual_tips_enabled
	SaveService.profile.tutorial_progress.tutorials_enabled = true
	SaveService.profile.tutorial_progress.contextual_tips_enabled = true
	TutorialService.publish(TutorialEventId.Value.STATUS_APPLIED, 7)
	checks.equal(TutorialService.active_definition, high, "Higher-priority blocking tutorials activate first")
	checks.truthy(TutorialService.queued_tutorials().has(low), "Lower-priority tutorial waits in the queue")
	TutorialService.cancel_active()
	checks.equal(TutorialService.active_definition, low, "Queued tutorial activates after the higher-priority lesson ends")
	checks.equal(TutorialService.context.current_event.int_value, 7, "Queued tutorials retain the event payload that activated them")
	TutorialService.cancel_active()
	var skip_once: TutorialDefinition = TutorialDefinition.new()
	skip_once.display_name = "Skip Once"
	skip_once.activation_event = TutorialEventId.Value.ITEM_USED
	skip_once.activation_mode = TutorialActivationMode.Value.CONTEXTUAL_EVENT
	skip_once.repeat_policy = TutorialRepeatPolicy.Value.ONCE_PER_PROFILE
	skip_once.steps = [fake_step]
	ContentRegistry.tutorials.append(skip_once)
	TutorialService.publish(TutorialEventId.Value.ITEM_USED)
	checks.equal(TutorialService.active_definition, skip_once, "A once-per-profile tutorial activates before it is skipped")
	TutorialService.skip_active()
	TutorialService.publish(TutorialEventId.Value.ITEM_USED)
	checks.equal(TutorialService.active_definition, null, "A skipped once-per-profile tutorial does not retrigger")
	var passive_step: TutorialStepDefinition = TutorialStepDefinition.new()
	passive_step.title = "Passive"
	passive_step.body = "Passive hint"
	passive_step.input_mode = TutorialInputMode.Value.NORMAL_WITH_HINT
	passive_step.auto_advance_delay = 3.0
	var passive: TutorialDefinition = TutorialDefinition.new()
	passive.display_name = "Passive Hint"
	passive.activation_event = TutorialEventId.Value.BONUS_BLOCK_ACQUIRED
	passive.activation_mode = TutorialActivationMode.Value.CONTEXTUAL_EVENT
	passive.repeat_policy = TutorialRepeatPolicy.Value.ONCE_PER_PROFILE
	passive.steps = [passive_step]
	ContentRegistry.tutorials.append(passive)
	TutorialService.publish(TutorialEventId.Value.BONUS_BLOCK_ACQUIRED)
	checks.equal(TutorialService.active_definition, null, "Passive hints never occupy the blocking tutorial runtime")
	checks.truthy(SaveService.profile.tutorial_progress.completed_tutorials.has(passive), "A displayed passive hint records its repeat-policy completion")
	var timed_step: TutorialStepDefinition = TutorialStepDefinition.new()
	timed_step.title = "Timed"
	timed_step.body = "Timed message"
	timed_step.auto_advance_delay = 1.0
	var timed: TutorialDefinition = TutorialDefinition.new()
	timed.display_name = "Manual Advance"
	timed.activation_mode = TutorialActivationMode.Value.MANUAL
	timed.repeat_policy = TutorialRepeatPolicy.Value.MANUAL_ONLY
	timed.steps = [timed_step]
	ContentRegistry.tutorials.append(timed)
	var previous_manual_advance: bool = SaveService.settings.tutorial_manual_advance
	SaveService.settings.tutorial_manual_advance = true
	TutorialService.start_tutorial(timed, true)
	checks.equal(TutorialService.runtime.phase, TutorialRuntimePhase.Value.WAITING_FOR_CONFIRMATION, "Manual advance converts timed tutorial messages into confirmation steps")
	TutorialService.confirm_current_step()
	checks.equal(TutorialService.active_definition, null, "Manual confirmation completes a timed tutorial message")
	SaveService.settings.tutorial_manual_advance = previous_manual_advance
	var restored_second_step: TutorialStepDefinition = TutorialStepDefinition.new()
	restored_second_step.title = "Restored"
	restored_second_step.body = "Restored step"
	restored_second_step.wait_for_player_confirmation = true
	var restorable: TutorialDefinition = TutorialDefinition.new()
	restorable.display_name = "Stable Restore"
	restorable.steps = [fake_step, restored_second_step]
	ContentRegistry.tutorials.append(restorable)
	var saved_active_tutorial: TutorialDefinition = SaveService.profile.tutorial_progress.active_tutorial
	var saved_active_step_index: int = SaveService.profile.tutorial_progress.active_step_index
	var saved_active_runtime: TutorialRuntimeState = SaveService.profile.tutorial_progress.active_runtime
	var restored_runtime: TutorialRuntimeState = TutorialRuntimeState.new()
	restored_runtime.tutorial = restorable
	restored_runtime.step_index = 1
	restored_runtime.screen = TutorialService.current_screen
	restored_runtime.run_sequence = TutorialService.current_run_sequence
	restored_runtime.encounter_sequence = TutorialService.current_encounter_sequence
	SaveService.profile.tutorial_progress.active_tutorial = restorable
	SaveService.profile.tutorial_progress.active_step_index = 1
	SaveService.profile.tutorial_progress.active_runtime = restored_runtime
	TutorialService.call("_restore_saved_tutorial")
	checks.equal(TutorialService.current_step(), restored_second_step, "Saved tutorials restore their typed step position")
	TutorialService.cancel_active()
	SaveService.profile.tutorial_progress.active_tutorial = saved_active_tutorial
	SaveService.profile.tutorial_progress.active_step_index = saved_active_step_index
	SaveService.profile.tutorial_progress.active_runtime = saved_active_runtime
	var once_per_run: TutorialDefinition = TutorialDefinition.new()
	once_per_run.display_name = "Once Per Run"
	once_per_run.activation_event = TutorialEventId.Value.LINES_CLEARED
	once_per_run.activation_mode = TutorialActivationMode.Value.CONTEXTUAL_EVENT
	once_per_run.repeat_policy = TutorialRepeatPolicy.Value.ONCE_PER_RUN
	once_per_run.steps = [fake_step]
	ContentRegistry.tutorials.append(once_per_run)
	var previous_run_sequence: int = TutorialService.current_run_sequence
	var previous_encounter_sequence: int = TutorialService.current_encounter_sequence
	var previous_run_finishes: Array[TutorialDefinition] = TutorialService.finished_this_run.duplicate()
	var previous_encounter_finishes: Array[TutorialDefinition] = TutorialService.finished_this_encounter.duplicate()
	TutorialService.begin_run(1001)
	TutorialService.publish(TutorialEventId.Value.LINES_CLEARED)
	TutorialService.confirm_current_step()
	TutorialService.publish(TutorialEventId.Value.LINES_CLEARED)
	checks.equal(TutorialService.active_definition, null, "Once-per-run tutorials do not repeat within a run")
	TutorialService.begin_run(1002)
	TutorialService.publish(TutorialEventId.Value.LINES_CLEARED)
	checks.equal(TutorialService.active_definition, once_per_run, "Once-per-run tutorials become available in the next run")
	TutorialService.cancel_active()
	TutorialService.current_run_sequence = previous_run_sequence
	TutorialService.current_encounter_sequence = previous_encounter_sequence
	TutorialService.finished_this_run = previous_run_finishes
	TutorialService.finished_this_encounter = previous_encounter_finishes
	ContentRegistry.tutorials.erase(low)
	ContentRegistry.tutorials.erase(high)
	ContentRegistry.tutorials.erase(skip_once)
	ContentRegistry.tutorials.erase(passive)
	ContentRegistry.tutorials.erase(timed)
	ContentRegistry.tutorials.erase(restorable)
	ContentRegistry.tutorials.erase(once_per_run)
	SaveService.profile.tutorial_progress.erase_history(low)
	SaveService.profile.tutorial_progress.erase_history(high)
	SaveService.profile.tutorial_progress.erase_history(skip_once)
	SaveService.profile.tutorial_progress.erase_history(once_per_run)
	SaveService.profile.tutorial_progress.completed_tutorials.erase(passive)
	SaveService.profile.tutorial_progress.completed_tutorials.erase(once_per_run)
	SaveService.profile.tutorial_progress.skipped_tutorials.erase(skip_once)
	SaveService.profile.tutorial_progress.tutorials_enabled = previous_tutorials_enabled
	SaveService.profile.tutorial_progress.contextual_tips_enabled = previous_contextual_tips_enabled
	var visual_target: Control = Control.new()
	visual_target.position = Vector2(120, 90)
	visual_target.size = Vector2(240, 100)
	add_child(visual_target)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.ROUTE_AVAILABLE_NODE, visual_target)
	var previous_reduced_motion: bool = SaveService.settings.reduced_motion
	SaveService.settings.reduced_motion = true
	var route_tutorial: TutorialDefinition = ROUTE_BASICS_TUTORIAL
	overlay.call("_show_step", route_tutorial, route_tutorial.steps[0], 0)
	await get_tree().process_frame
	await get_tree().process_frame
	var message_rectangle: Rect2 = (overlay.get_node("Root/MessagePanel") as Control).get_global_rect()
	checks.truthy(message_rectangle.end.x <= get_viewport().get_visible_rect().end.x and message_rectangle.end.y <= get_viewport().get_visible_rect().end.y, "Tutorial message remains inside the viewport")
	checks.truthy((overlay.get_node("Root/Spotlight") as TutorialSpotlight).target_rect.size.x > 0.0, "Spotlight follows a registered target")
	checks.truthy((overlay.get_node("Root/Pointer") as TutorialPointer).reduced_motion, "Reduced motion replaces animated pointer movement")
	SaveService.settings.reduced_motion = previous_reduced_motion
	TutorialTargetRegistry.unregister_target(TutorialTargetKey.Value.ROUTE_AVAILABLE_NODE)
	visual_target.queue_free()
	overlay.queue_free()
	var mobile_tutorial_viewport: SubViewport = SubViewport.new()
	mobile_tutorial_viewport.size = Vector2i(360, 640)
	add_child(mobile_tutorial_viewport)
	var mobile_overlay: TutorialOverlay = overlay_scene.instantiate() as TutorialOverlay
	mobile_tutorial_viewport.add_child(mobile_overlay)
	await get_tree().process_frame
	mobile_overlay.call("_show_step", guided_tutorial, summary_step, guided_tutorial.steps.size() - 1)
	await get_tree().process_frame
	var mobile_panel: PanelContainer = mobile_overlay.get_node("Root/MessagePanel") as PanelContainer
	checks.truthy(mobile_panel.size.x <= 312.0, "Mobile tutorial panel retains side margins in an actual narrow viewport")
	mobile_tutorial_viewport.queue_free()
	var startup_viewport: SubViewport = SubViewport.new()
	startup_viewport.size = Vector2i(1, 1)
	add_child(startup_viewport)
	var startup_overlay: TutorialOverlay = overlay_scene.instantiate() as TutorialOverlay
	startup_viewport.add_child(startup_overlay)
	await get_tree().process_frame
	var progression_tutorial: TutorialDefinition = PERMANENT_PROGRESSION_TUTORIAL
	startup_overlay.call("_show_step", progression_tutorial, progression_tutorial.steps[0], 0)
	startup_viewport.size = Vector2i(1280, 720)
	await get_tree().process_frame
	await get_tree().process_frame
	var startup_panel: PanelContainer = startup_overlay.get_node("Root/MessagePanel") as PanelContainer
	checks.truthy(startup_panel.size.y <= 280.0, "First-time tutorial layout reflows after receiving a valid viewport size")
	startup_viewport.queue_free()

func _test_tutorial_archive_replay() -> void:
	var previous_progress_data: Dictionary = SaveService.profile.tutorial_progress.to_save_data()
	TutorialService.cancel_active()
	TutorialService.cancel_replay_setup()
	var main_scene: Control = (load("res://scenes/main/main.tscn") as PackedScene).instantiate() as Control
	add_child(main_scene)
	await get_tree().process_frame
	main_scene.call("show_tutorial_archive")
	await get_tree().process_frame
	await get_tree().process_frame
	var archive: TutorialArchiveScreen = main_scene.get("current_screen") as TutorialArchiveScreen
	checks.truthy(archive != null, "Help opens the tutorial archive")
	var replay_requests: Array[TutorialDefinition] = []
	archive.replay_requested.connect(func(definition: TutorialDefinition) -> void: replay_requests.append(definition))
	var card_nodes: Array[Node] = archive.find_children("*", "TutorialArchiveCard", true, false)
	var first_card: TutorialArchiveCard = card_nodes[0] as TutorialArchiveCard if not card_nodes.is_empty() else null
	checks.truthy(first_card != null, "Help archive builds replay cards")
	var scroll: ScrollContainer = archive.get_node("Margin/Layout/Scroll") as ScrollContainer
	var scroll_before: int = scroll.scroll_vertical
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = 31
	press.position = first_card.get_global_rect().get_center()
	press.pressed = true
	archive._input(press)
	main_scene.call("_input", press)
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = press.index
	drag.position = press.position - Vector2(0.0, 28.0)
	drag.relative = Vector2(0.0, -28.0)
	archive._input(drag)
	main_scene.call("_input", drag)
	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = press.index
	release.position = drag.position
	release.pressed = false
	archive._input(release)
	main_scene.call("_input", release)
	checks.truthy(scroll.scroll_vertical > scroll_before, "Dragging a Help card scrolls the archive")
	checks.truthy(replay_requests.is_empty() and main_scene.get("current_screen") == archive, "Dragging a Help card never starts its tutorial")
	main_scene.call("_replay_tutorial", STARTING_PIECE_DRAFT_TUTORIAL)
	var draft_screen: PieceDraftScreen = main_scene.get("current_screen") as PieceDraftScreen
	checks.truthy(draft_screen != null, "Starting Block Draft opens the draft scene from Help")
	checks.equal(TutorialService.active_definition, STARTING_PIECE_DRAFT_TUTORIAL, "Help starts the selected draft tutorial instead of an automatic replacement")
	checks.equal(TutorialService.current_screen, TutorialScreen.Value.DRAFT, "Draft replay registers the correct tutorial screen")
	TutorialService.cancel_active()
	checks.equal(main_scene.get("current_screen"), null, "Ending a draft replay clears its scene immediately")
	checks.falsy(draft_screen.visible, "Ending a draft replay hides its outgoing scene")
	await get_tree().process_frame
	await get_tree().process_frame
	checks.truthy(main_scene.get("current_screen") is TutorialArchiveScreen, "Draft replay returns to Help")
	main_scene.call("_replay_tutorial", ENEMY_ACTIONS_TUTORIAL)
	var replay_run_screen: RunScreen = main_scene.get("current_screen") as RunScreen
	checks.truthy(replay_run_screen != null, "Combat tutorials open the sandbox run scene from Help")
	checks.equal(TutorialService.active_definition, ENEMY_ACTIONS_TUTORIAL, "Help starts the selected combat tutorial")
	TutorialService.confirm_current_step()
	checks.equal(main_scene.get("run_screen"), null, "Completing a Help combat tutorial releases the run screen immediately")
	checks.equal(main_scene.get("current_screen"), null, "Completing a Help combat tutorial clears the current scene immediately")
	checks.falsy(replay_run_screen.visible or replay_run_screen.is_processing_input(), "Completed tutorial combat cannot remain visible or interactive")
	await get_tree().process_frame
	await get_tree().process_frame
	checks.truthy(main_scene.get("current_screen") is TutorialArchiveScreen, "Completed combat replay returns to Help")
	main_scene.call("_replay_tutorial", GUIDED_ONBOARDING_TUTORIAL)
	await get_tree().process_frame
	await get_tree().process_frame
	var guided_run_screen: RunScreen = main_scene.get("current_screen") as RunScreen
	var guided_overlay: TutorialOverlay = main_scene.call("_tutorial_overlay") as TutorialOverlay
	checks.truthy(guided_run_screen != null, "Guided combat onboarding opens its sandbox")
	checks.equal(guided_run_screen.run_state.run_mode, RunMode.Value.TUTORIAL, "Guided sandbox uses tutorial run rules")
	checks.equal(TutorialService.context.encounter_controller, guided_run_screen.controller, "Guided sandbox owns the tutorial gameplay context")
	guided_run_screen._apply_mobile_layout(true)
	var guided_continue: Button = guided_overlay.get_node("Root/MessagePanel/Layout/Actions/Continue") as Button
	_send_main_touch(main_scene, guided_continue.get_global_rect().get_center(), 92)
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[1], "Touch confirmation reaches Block selection")
	await get_tree().process_frame
	checks.equal(guided_run_screen.controller.deck_state.hand[0].piece, DOMINO_PIECE, "Block selection loads the configured Duoblock")
	var guided_hand: PieceHandView = guided_run_screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/PieceHandView") as PieceHandView
	var first_guided_card: PieceHandCard = guided_hand.card_control(guided_run_screen.controller.deck_state.hand[0].card_id)
	var second_guided_card: PieceHandCard = guided_hand.card_control(guided_run_screen.controller.deck_state.hand[1].card_id)
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.COMBAT_PIECE_CHOICE_FIRST), first_guided_card, "Block selection spotlights the requested first Piece")
	checks.falsy(guided_overlay.blocker.is_pointer_allowed(second_guided_card.get_global_rect().get_center(), TutorialInputMode.Value.TARGET_ONLY), "Block selection blocks unrelated Pieces")
	_send_main_touch(main_scene, first_guided_card.get_global_rect().get_center(), 93)
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[2], "Touching the highlighted Piece reaches placement")
	var guided_board: BoardView = guided_run_screen.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/BoardAspect/BoardView") as BoardView
	var guided_place: Button = guided_run_screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/PlaceButton") as Button
	var guided_reroll: Button = guided_run_screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/UtilityActions/RerollButton") as Button
	var guided_board_rect: Rect2 = TutorialTargetRegistry.resolve_rect(GUIDED_ONBOARDING_TUTORIAL.steps[2].target)
	checks.truthy(guided_board_rect.size.x > 0.0 and guided_overlay.spotlight.target_rect == guided_board_rect, "Placement opens a visible spotlight over the board")
	checks.truthy(guided_overlay.blocker.is_pointer_allowed(guided_place.get_global_rect().get_center(), TutorialInputMode.Value.TARGET_ONLY), "The highlighted placement board keeps Place touchable")
	checks.falsy(guided_overlay.blocker.is_pointer_allowed(guided_reroll.get_global_rect().get_center(), TutorialInputMode.Value.TARGET_ONLY), "Placement blocks unrelated combat actions")
	checks.falsy(guided_place.disabled, "The guided placement starts with a valid Place action")
	_send_main_touch(main_scene, guided_place.get_global_rect().get_center(), 94)
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[2], "Placement setup is not replaced while combat is still resolving")
	await get_tree().process_frame
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[3], "Resolved touch placement reaches rotation")
	var guided_rotate_left: Button = guided_run_screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/RotateLeft") as Button
	var guided_rotate_right: Button = guided_run_screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/RotateRight") as Button
	var guided_rotate_icon: TextureRect = guided_rotate_right.get_node("TextureRect") as TextureRect
	checks.falsy(guided_rotate_left.disabled or guided_rotate_right.disabled, "Both guided rotate buttons enable after placement resolves")
	checks.equal(guided_run_screen.controller.state, EncounterController.TurnState.AWAITING_PLACEMENT, "Guided rotation waits in the placement state")
	checks.equal(guided_run_screen.controller.deck_state.hand.size(), 2, "Guided rotation loads both configured Blocks")
	checks.equal(guided_run_screen.controller.deck_state.hand[0].piece, TET_L_PIECE, "Guided rotation loads its L Block first")
	checks.equal(guided_run_screen.controller.deck_state.hand[1].piece, TET_O_PIECE, "Guided rotation keeps its square fallback second")
	checks.equal(guided_run_screen.controller.active_card_index, 0, "Guided rotation selects the first loaded Block")
	checks.equal(guided_run_screen.controller.active_piece.definition if guided_run_screen.controller.active_piece != null else null, TET_L_PIECE, "Guided rotation selects its rotatable L Block")
	checks.truthy(guided_overlay.blocker.is_pointer_allowed(guided_board.get_global_rect().get_center(), TutorialInputMode.Value.ACTIONS_ONLY), "Rotation allows a swipe starting on the board")
	checks.truthy(guided_overlay.blocker.is_pointer_allowed(guided_rotate_left.get_global_rect().get_center(), TutorialInputMode.Value.ACTIONS_ONLY), "Rotation allows the left rotate button")
	checks.truthy(guided_overlay.blocker.is_pointer_allowed(guided_rotate_icon.get_global_rect().get_center(), TutorialInputMode.Value.ACTIONS_ONLY), "Rotation allows the visible right rotate icon")
	checks.equal(main_scene.call("_button_at", guided_rotate_icon.get_global_rect().get_center()), guided_rotate_right, "Touching a rotate icon resolves its parent button")
	var guided_rotation_before_touch: int = guided_run_screen.controller.active_piece.rotation_index
	var guided_rotate_presses: Array[int] = [0]
	guided_rotate_right.pressed.connect(func() -> void: guided_rotate_presses[0] += 1)
	_send_main_touch(main_scene, guided_rotate_icon.get_global_rect().get_center(), 95)
	checks.equal(guided_rotate_presses[0], 1, "Touching the rotate icon emits one button press")
	checks.truthy(guided_run_screen.controller.active_piece.rotation_index != guided_rotation_before_touch, "The guided rotate button changes the active Piece")
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[4], "Touching the rotate icon completes rotation")
	TutorialService.call("_jump_to_step", GUIDED_ONBOARDING_TUTORIAL.steps[3])
	var guided_swipe_rect: Rect2 = guided_board.get_global_rect().grow(-guided_board.get_global_rect().size.x * 0.2)
	_send_guided_run_swipe(main_scene, guided_run_screen, guided_swipe_rect.get_center() - Vector2(60.0, 0.0), guided_swipe_rect.get_center() + Vector2(60.0, 0.0), 96)
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[4], "Swiping across the guided board completes rotation")
	checks.equal(guided_run_screen.controller.board.count_empty_cells(), guided_run_screen.controller.board.width * guided_run_screen.controller.board.height - 5, "Line-clear onboarding creates its five-cell setup")
	checks.equal(guided_run_screen.controller.active_piece.definition, TET_I_PIECE, "Line-clear onboarding selects the intended straight Block")
	var clear_candidate: PiecePlacementCandidate = guided_run_screen.controller.board.find_piece_placement(TET_I_PIECE, Vector2i(5, 7), 0)
	checks.truthy(clear_candidate.found and clear_candidate.origin == Vector2i(5, 7), "Line-clear onboarding has a valid completion placement")
	guided_board.arm_preview(clear_candidate)
	guided_run_screen._update_place_button()
	_send_main_touch(main_scene, guided_place.get_global_rect().get_center(), 97)
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[5], "Completing the guided line reaches the enemy damage explanation")
	checks.equal(TutorialService.runtime.phase, TutorialRuntimePhase.Value.WAITING_FOR_CONFIRMATION, "Enemy damage explanation does not disappear in the clear resolution call stack")
	TutorialService.cancel_active()
	await get_tree().process_frame
	await get_tree().process_frame
	checks.truthy(main_scene.get("current_screen") is TutorialArchiveScreen, "Cancelling guided onboarding returns to Help")
	main_scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	TutorialService.cancel_active()
	TutorialService.cancel_replay_setup()
	SaveService.profile.tutorial_progress = TutorialProgress.from_save_data(previous_progress_data)
	SaveService.save_profile()

func _eligible_enemies(act: int, role: EnemyDefinition.EncounterRole) -> Array[EnemyDefinition]:
	var enemies: Array[EnemyDefinition] = []
	for enemy: EnemyDefinition in ContentRegistry.enemies:
		if enemy.is_available_in_act(act) and enemy.encounter_role == role and enemy.selection_weight > 0.0:
			enemies.append(enemy)
	return enemies

func _test_act_one_enemy_roster() -> void:
	var normal_enemies: Array[EnemyDefinition] = [TRAINING_SLIME_ENEMY, preload("res://content/enemies/ember_wisp.tres"), preload("res://content/enemies/bulwark_beetle.tres"), preload("res://content/enemies/hexling.tres"), preload("res://content/enemies/leech_bloom.tres"), preload("res://content/enemies/scrap_mason.tres"), preload("res://content/enemies/venom_toad.tres")]
	var elite_enemies: Array[EnemyDefinition] = [preload("res://content/enemies/elites/arcane_sentinel.tres")]
	var grid_warden: EnemyDefinition = preload("res://content/enemies/bosses/grid_warden.tres")
	var mason: EnemyDefinition = preload("res://content/enemies/mason.tres")
	var block_enemies: Array[EnemyDefinition] = normal_enemies.duplicate()
	block_enemies.append_array(elite_enemies)
	block_enemies.append_array([grid_warden, mason, preload("res://content/enemies/elites/elite_mason.tres"), preload("res://content/enemies/leech.tres"), preload("res://content/enemies/curator.tres"), preload("res://content/enemies/divider.tres"), preload("res://content/enemies/elites/surveyor.tres"), preload("res://content/enemies/hoarder.tres"), ARCHITECT_ENEMY])
	var block_enemy_paths: Array[String] = ["training_slime", "ember_wisp", "bulwark_beetle", "hexling", "leech_bloom", "scrap_mason", "venom_toad", "arcane_sentinel", "grid_warden", "mason", "elite_mason", "leech", "curator", "divider", "surveyor", "hoarder", "architect"]
	var block_enemy_names: Array[String] = ["Training Blockling", "Ember Blockling", "Bulwark Blockling", "Hex Blockling", "Siphon Blockling", "Scrap Blockling", "Venom Blockling", "Prism Blockmage", "The Grid Colossus", "Rubble Golem", "Bastion Golem", "Siphon Golem", "Archive Blockmage", "Splitter Automaton", "Surveyor Artificer", "Vault Automaton", "The Archlord Engine"]
	for definition: EnemyDefinition in block_enemies.slice(0, normal_enemies.size() + elite_enemies.size() + 1):
		checks.truthy(ContentRegistry.enemies.has(definition), "%s is registered" % definition.display_name)
		checks.truthy(definition.possible_actions.size() >= 2, "%s has at least two actions" % definition.display_name)
		checks.truthy(definition.visual != null and definition.visual.sprite != null, "%s has a visual definition and artwork" % definition.display_name)
	for index: int in block_enemies.size():
		var definition: EnemyDefinition = block_enemies[index]
		var path_key: String = block_enemy_paths[index]
		checks.truthy(ContentRegistry.enemies.has(definition), "%s remains registered" % definition.display_name)
		checks.equal(definition.display_name, block_enemy_names[index], "%s uses its Block faction name" % definition.display_name)
		var visual: EnemyVisualDefinition = definition.visual
		checks.truthy(visual != null and visual.sprite != null, "%s has matching Block artwork" % definition.display_name)
		if visual != null and visual.sprite != null:
			var image: Image = visual.sprite.get_image()
			checks.truthy(image != null and image.detect_alpha(), "%s artwork uses transparency" % definition.display_name)
			if image != null:
				checks.equal(image.get_pixel(0, 0).a, 0.0, "%s artwork has a transparent upper-left corner" % path_key)
				checks.equal(image.get_pixel(image.get_width() - 1, image.get_height() - 1).a, 0.0, "%s artwork has a transparent lower-right corner" % path_key)
	for enemy: EnemyDefinition in elite_enemies:
		checks.equal(enemy.encounter_role, EnemyDefinition.EncounterRole.ELITE, "%s is in the elite pool" % enemy.display_name)
	checks.equal(grid_warden.encounter_role, EnemyDefinition.EncounterRole.BOSS, "Grid Colossus is the Act 1 boss")
	checks.truthy(mason.is_available_in_act(1), "Mason remains available in Act 2")
	checks.falsy(mason.is_available_in_act(2), "Mason is removed from Act 3 onward")
	var expected_normal_counts: Array[int] = [7, 7, 7, 5]
	var expected_elite_counts: Array[int] = [1, 4, 4, 3]
	for act: int in 4:
		checks.equal(_eligible_enemies(act, EnemyDefinition.EncounterRole.NORMAL).size(), expected_normal_counts[act], "Act %d has a balanced normal enemy pool" % (act + 1))
		checks.equal(_eligible_enemies(act, EnemyDefinition.EncounterRole.ELITE).size(), expected_elite_counts[act], "Act %d has an explicit elite enemy pool" % (act + 1))
		checks.equal(_eligible_enemies(act, EnemyDefinition.EncounterRole.BOSS).size(), 2, "Act %d has two explicit boss choices" % (act + 1))
	var profile: ProfileState = ProfileState.new()
	var first_run: RunState = RunState.new()
	first_run.seed_value = 8181
	var first_node: RouteNodeState = RouteNodeState.new()
	first_node.act = 0
	first_node.type = RouteNodeState.NodeType.NORMAL_COMBAT
	var tutorial: EnemyDefinition = EnemyPoolService.new().select_for_node(first_run, first_node, profile, ContentRegistry.enemies)
	checks.equal(tutorial, TRAINING_SLIME_ENEMY, "First profile run begins with the Training Blockling")
	var variety_enemy: EnemyDefinition = EnemyDefinition.new()
	variety_enemy.display_name = "Variety Test Enemy"
	var experienced_pool: Array[EnemyDefinition] = [variety_enemy]
	var threshold_profile: ProfileState = ProfileState.new()
	threshold_profile.total_enemies_defeated = EnemyPoolService.GUARANTEED_TRAINING_ENCOUNTER_LIMIT
	var threshold_run: RunState = RunState.new()
	var threshold_selection: EnemyDefinition = EnemyPoolService.new().select_for_node(threshold_run, first_node, threshold_profile, experienced_pool)
	checks.equal(threshold_selection, TRAINING_SLIME_ENEMY, "Training Blockling remains guaranteed through ten cleared encounters")
	threshold_profile.total_enemies_defeated += 1
	var experienced_run: RunState = RunState.new()
	var experienced_selection: EnemyDefinition = EnemyPoolService.new().select_for_node(experienced_run, first_node, threshold_profile, experienced_pool)
	checks.equal(experienced_selection, variety_enemy, "Training Blockling stops being the default after more than ten cleared encounters")
	profile.completed_runs = 1
	profile.victories = 10
	profile.total_enemies_defeated = EnemyPoolService.GUARANTEED_TRAINING_ENCOUNTER_LIMIT + 1
	var sequence_a: RunState = RunState.new()
	var sequence_b: RunState = RunState.new()
	sequence_a.seed_value = 99117
	sequence_b.seed_value = 99117
	for index: int in 5:
		var node: RouteNodeState = RouteNodeState.new()
		node.column = index
		node.act = 0
		node.type = RouteNodeState.NodeType.NORMAL_COMBAT
		var selected_a: EnemyDefinition = EnemyPoolService.new().select_for_node(sequence_a, node, profile, ContentRegistry.enemies)
		var selected_b: EnemyDefinition = EnemyPoolService.new().select_for_node(sequence_b, node, profile, ContentRegistry.enemies)
		checks.equal(selected_a, selected_b, "Enemy pool is deterministic at node %d" % index)
		if index > 0:
			checks.truthy(sequence_a.enemy_selections[index - 1].enemy != selected_a, "Normal enemies do not repeat consecutively")
	var stale_run: RunState = RunState.new()
	stale_run.seed_value = 4411
	var late_node: RouteNodeState = RouteNodeState.new()
	late_node.act = 2
	late_node.column = 2
	late_node.type = RouteNodeState.NodeType.NORMAL_COMBAT
	var late_enemy: EnemyDefinition = EnemyPoolService.new().select_for_node(stale_run, late_node, profile, ContentRegistry.enemies)
	checks.truthy(late_enemy != null and late_enemy != mason, "Out-of-band enemies are replaced with a valid late-act enemy")
	checks.equal(stale_run.get_selected_enemy(late_node), late_enemy, "Replacement enemy selection persists")
	var stale_mason_run: RunState = RunState.new()
	stale_mason_run.seed_value = 4412
	stale_mason_run.record_enemy_selection(late_node, mason, true)
	var mason_replacement: EnemyDefinition = EnemyPoolService.new().select_for_node(stale_mason_run, late_node, profile, ContentRegistry.enemies)
	checks.truthy(mason_replacement != null and mason_replacement != mason, "Previously recorded Mason encounters are replaced from Act 3 onward")
	var locked_enemy: EnemyDefinition = EnemyDefinition.new()
	locked_enemy.display_name = "Locked Test Enemy"
	locked_enemy.initially_unlocked = false
	var unlocked_enemy: EnemyDefinition = EnemyDefinition.new()
	unlocked_enemy.display_name = "Unlocked Test Enemy"
	var unlock_node: RouteNodeState = RouteNodeState.new()
	unlock_node.type = RouteNodeState.NodeType.NORMAL_COMBAT
	var unlock_run: RunState = RunState.new()
	unlock_run.encounter_index = 3
	checks.equal(EnemyPoolService.new().select_for_node(unlock_run, unlock_node, profile, [locked_enemy, unlocked_enemy]), unlocked_enemy, "Locked enemies stay out of normal encounter selection")
	var run_unlocked_enemy: RunState = RunState.new()
	run_unlocked_enemy.encounter_index = 3
	run_unlocked_enemy.starting_modifiers.unlocked_enemies.append(locked_enemy)
	checks.equal(EnemyPoolService.new().select_for_node(run_unlocked_enemy, unlock_node, profile, [locked_enemy]), locked_enemy, "Run enemy unlocks enter encounter selection")
	var selector: EnemyActionSelector = EnemyActionSelector.new()
	var state: EncounterEffectState = EncounterEffectState.new()
	state.enemy_health = 10
	state.enemy_maximum_health = 10
	var heal: EnemyActionDefinition = EnemyActionDefinition.new()
	heal.display_name = "Heal Test"
	heal.weight = 1.0
	heal.enemy_healing = 2
	var strike: EnemyActionDefinition = EnemyActionDefinition.new()
	strike.display_name = "Strike Test"
	strike.weight = 1.0
	strike.direct_damage = 2
	var test_enemy: EnemyDefinition = EnemyDefinition.new()
	test_enemy.display_name = "Selector Test"
	test_enemy.possible_actions = [heal, strike]
	test_enemy.fallback_action = strike
	var selected_full: EnemyActionDefinition = selector.select_action(test_enemy, 0, state, BoardState.new(10, 10), RandomNumberGenerator.new(), null, [])
	checks.equal(selected_full, strike, "Healing is not selected at full health")
	var shield: EnemyActionDefinition = EnemyActionDefinition.new()
	shield.display_name = "Shield Test"
	shield.weight = 10.0
	shield.disallow_while_shielded = true
	test_enemy.possible_actions = [shield, strike]
	state.enemy_shield = 3
	var selected_shielded: EnemyActionDefinition = selector.select_action(test_enemy, 0, state, BoardState.new(10, 10), RandomNumberGenerator.new(), null, [])
	checks.equal(selected_shielded, strike, "Shield is not reapplied while active")
	state.enemy_shield = 0
	var seeded_a: RandomNumberGenerator = RandomNumberGenerator.new()
	var seeded_b: RandomNumberGenerator = RandomNumberGenerator.new()
	seeded_a.seed = 773
	seeded_b.seed = 773
	test_enemy.possible_actions = [heal, strike]
	state.enemy_health = 5
	checks.equal(selector.select_action(test_enemy, 0, state, BoardState.new(10, 10), seeded_a, null, []), selector.select_action(test_enemy, 0, state, BoardState.new(10, 10), seeded_b, null, []), "Identical action state and seed resolve identically")
	strike.cannot_repeat = true
	checks.equal(selector.select_action(test_enemy, 0, state, BoardState.new(10, 10), seeded_a, strike, []), heal, "Non-repeat actions do not repeat")
	var cooldown: EnemyActionCooldownState = EnemyActionCooldownState.new()
	cooldown.action = heal
	cooldown.remaining_actions = 1
	var cooldowns: Array[EnemyActionCooldownState] = [cooldown]
	checks.equal(selector.select_action(test_enemy, 0, state, BoardState.new(10, 10), seeded_a, null, cooldowns), strike, "Action cooldowns exclude unavailable actions")
	var ember_wisp: EnemyDefinition = preload("res://content/enemies/ember_wisp.tres")
	var intent: ResolvedEnemyIntent = selector.resolve_intent(ember_wisp.possible_actions[0], 3)
	checks.truthy(intent.direct_damage > 0 and intent.applied_statuses.has(preload("res://content/statuses/burn.tres") as StatusDefinition), "Resolved intent exposes final damage and status")
	var saved_sequence: RunState = RunState.from_save_data(sequence_a.to_save_data())
	checks.equal(saved_sequence.enemy_selections.size(), sequence_a.enemy_selections.size(), "Selected enemies survive run save and resume")
	checks.equal(saved_sequence.last_normal_enemy, sequence_a.last_normal_enemy, "Last normal enemy survives run save and resume")
	var legacy_enemy: EnemyDefinition = EnemyDefinition.new()
	legacy_enemy.display_name = "Legacy Intent Test"
	legacy_enemy.direct_damage = 3
	var legacy_controller: EncounterController = EncounterController.new()
	add_child(legacy_controller)
	legacy_controller.start_encounter(RunState.new(), legacy_enemy, PieceGenerator.new(17))
	checks.truthy(legacy_controller.resolved_enemy_intent != null, "Every enemy always exposes a next action intent")
	checks.equal(legacy_controller.resolved_enemy_intent.direct_damage, 3, "Fallback intents expose possible damage")
	legacy_controller.queue_free()

func _test_block_world_enemy_expansion() -> void:
	var bosses: Array[EnemyDefinition] = [preload("res://content/enemies/bosses/giant_block_centipede.tres"), preload("res://content/enemies/bosses/the_smith.tres"), preload("res://content/enemies/bosses/the_designer.tres"), preload("res://content/enemies/bosses/the_summoner.tres")]
	var elites: Array[EnemyDefinition] = [preload("res://content/enemies/elites/furnace_golem.tres"), preload("res://content/enemies/elites/mortar_knight.tres"), preload("res://content/enemies/elites/prism_weaver.tres"), preload("res://content/enemies/elites/chrono_wall.tres"), preload("res://content/enemies/elites/void_bastion.tres"), preload("res://content/enemies/elites/crowned_shard.tres")]
	var normal_enemies: Array[EnemyDefinition] = [preload("res://content/enemies/brick_borer.tres"), preload("res://content/enemies/cinder_cube.tres"), preload("res://content/enemies/chain_stack.tres"), preload("res://content/enemies/rune_mosaic.tres"), preload("res://content/enemies/mirror_slab.tres"), preload("res://content/enemies/glitch_polyomino.tres"), preload("res://content/enemies/null_obelisk.tres"), preload("res://content/enemies/gravity_stack.tres")]
	var expanded_roster: Array[EnemyDefinition] = []
	expanded_roster.append_array(bosses)
	expanded_roster.append_array(elites)
	expanded_roster.append_array(normal_enemies)
	checks.equal(expanded_roster.size(), 18, "The block world expansion contains eighteen enemies")
	for enemy: EnemyDefinition in expanded_roster:
		checks.truthy(ContentRegistry.enemies.has(enemy), "%s is registered in the content catalog" % enemy.display_name)
		checks.truthy(enemy.is_valid(), "%s is a valid enemy definition" % enemy.display_name)
		checks.truthy(enemy.possible_actions.size() >= 2, "%s has a themed action kit" % enemy.display_name)
		checks.truthy(enemy.fallback_action != null, "%s has a fallback action" % enemy.display_name)
		checks.truthy(enemy.visual != null and enemy.visual.sprite != null, "%s has generated artwork" % enemy.display_name)
		if enemy.visual != null and enemy.visual.sprite != null:
			var sprite_image: Image = enemy.visual.sprite.get_image()
			checks.truthy(sprite_image != null and sprite_image.detect_alpha(), "%s artwork uses transparency" % enemy.display_name)
			if sprite_image != null:
				checks.equal(sprite_image.get_pixel(0, 0).a, 0.0, "%s artwork has a transparent corner" % enemy.display_name)
	for boss_index: int in bosses.size():
		checks.equal(bosses[boss_index].encounter_role, EnemyDefinition.EncounterRole.BOSS, "%s is a boss" % bosses[boss_index].display_name)
		checks.truthy(bosses[boss_index].is_available_in_act(boss_index), "%s is assigned to Act %d" % [bosses[boss_index].display_name, boss_index + 1])
	for elite: EnemyDefinition in elites:
		checks.equal(elite.encounter_role, EnemyDefinition.EncounterRole.ELITE, "%s is an elite" % elite.display_name)
	for normal_enemy: EnemyDefinition in normal_enemies:
		checks.equal(normal_enemy.encounter_role, EnemyDefinition.EncounterRole.NORMAL, "%s is a normal enemy" % normal_enemy.display_name)
	var centipede_has_venom: bool = false
	var centipede_has_counter: bool = false
	for action: EnemyActionDefinition in bosses[0].possible_actions:
		centipede_has_venom = centipede_has_venom or action.action_tags.has(&"poison")
		centipede_has_counter = centipede_has_counter or action.counter_definition != null
	checks.truthy(centipede_has_venom and centipede_has_counter, "The Centipede combines Venom with a counterable special")
	var smith_counter_count: int = 0
	var smith_has_guard: bool = false
	for action: EnemyActionDefinition in bosses[1].possible_actions:
		smith_counter_count += 1 if action.counter_definition != null else 0
		smith_has_guard = smith_has_guard or action.action_tags.has(&"shield")
	checks.truthy(smith_has_guard and smith_counter_count >= 2, "The Smith blocks and has two counterable heavy attacks")
	var designer_counter_count: int = 0
	var designer_has_weaken: bool = false
	for action: EnemyActionDefinition in bosses[2].possible_actions:
		designer_counter_count += 1 if action.counter_definition != null else 0
		designer_has_weaken = designer_has_weaken or action.action_tags.has(&"weaken")
	checks.truthy(designer_counter_count >= 3 and designer_has_weaken, "The Designer has multiple counters and weakening magic")
	var summoner_has_slow: bool = false
	var summoner_has_weaken: bool = false
	var summoner_actions_uncounterable: bool = true
	for action: EnemyActionDefinition in bosses[3].possible_actions:
		summoner_has_slow = summoner_has_slow or action.action_tags.has(&"slow")
		summoner_has_weaken = summoner_has_weaken or action.action_tags.has(&"weaken")
		summoner_actions_uncounterable = summoner_actions_uncounterable and action.counter_definition == null
	checks.truthy(summoner_actions_uncounterable and summoner_has_slow and summoner_has_weaken, "The Summoner uses non-counterable Slow and Weaken pressure")

func _test_enemy_balance_curve() -> void:
	var act_one_enemies: Array[EnemyDefinition] = [
		TRAINING_SLIME_ENEMY,
		preload("res://content/enemies/leech_bloom.tres"),
		preload("res://content/enemies/ember_wisp.tres"),
		preload("res://content/enemies/hexling.tres"),
		preload("res://content/enemies/venom_toad.tres"),
		preload("res://content/enemies/bulwark_beetle.tres"),
		preload("res://content/enemies/scrap_mason.tres"),
		preload("res://content/enemies/elites/arcane_sentinel.tres"),
		preload("res://content/enemies/bosses/grid_warden.tres"),
		preload("res://content/enemies/bosses/giant_block_centipede.tres"),
	]
	var act_two_enemies: Array[EnemyDefinition] = [
		preload("res://content/enemies/mason.tres"),
		preload("res://content/enemies/cinder_cube.tres"),
		preload("res://content/enemies/brick_borer.tres"),
		preload("res://content/enemies/chain_stack.tres"),
		preload("res://content/enemies/leech.tres"),
		preload("res://content/enemies/curator.tres"),
		preload("res://content/enemies/elites/elite_mason.tres"),
		preload("res://content/enemies/elites/furnace_golem.tres"),
		preload("res://content/enemies/elites/mortar_knight.tres"),
		preload("res://content/enemies/bosses/the_smith.tres"),
	]
	var act_three_enemies: Array[EnemyDefinition] = [
		preload("res://content/enemies/divider.tres"),
		preload("res://content/enemies/rune_mosaic.tres"),
		preload("res://content/enemies/glitch_polyomino.tres"),
		preload("res://content/enemies/mirror_slab.tres"),
		preload("res://content/enemies/hoarder.tres"),
		preload("res://content/enemies/elites/surveyor.tres"),
		preload("res://content/enemies/elites/prism_weaver.tres"),
		preload("res://content/enemies/elites/chrono_wall.tres"),
		preload("res://content/enemies/bosses/the_designer.tres"),
	]
	var act_four_enemies: Array[EnemyDefinition] = [
		preload("res://content/enemies/null_obelisk.tres"),
		preload("res://content/enemies/gravity_stack.tres"),
		preload("res://content/enemies/elites/crowned_shard.tres"),
		preload("res://content/enemies/elites/void_bastion.tres"),
		preload("res://content/enemies/bosses/the_summoner.tres"),
	]
	_assert_enemy_health_targets(act_one_enemies, PackedInt32Array([15, 17, 17, 18, 20, 22, 23, 38, 65, 54]), "Act 1")
	_assert_enemy_health_targets(act_two_enemies, PackedInt32Array([23, 27, 28, 30, 32, 33, 36, 48, 50, 78]), "Act 2")
	_assert_enemy_health_targets(act_three_enemies, PackedInt32Array([31, 36, 38, 39, 59, 47, 55, 60, 94]), "Act 3")
	_assert_enemy_health_targets(act_four_enemies, PackedInt32Array([47, 52, 62, 70, 108]), "Act 4")
	checks.equal(ARCHITECT_ENEMY.maximum_health, 84, "Act 5 boss receives the full late-game health increase")
	var damage_actions: Array[EnemyActionDefinition] = [
		preload("res://content/enemy_actions/act_1/slime_bash.tres"),
		preload("res://content/enemy_actions/act_1/horn_charge.tres"),
		preload("res://content/enemy_actions/act_2/brick_borer_drill_bite.tres"),
		preload("res://content/enemy_actions/act_2/mortar_knight_trowel_cleave.tres"),
		preload("res://content/enemy_actions/act_3/rune_mosaic_rune_bolt.tres"),
		preload("res://content/enemy_actions/act_3/chrono_wall_time_crush.tres"),
		preload("res://content/enemy_actions/act_4/null_obelisk_fall.tres"),
		preload("res://content/enemy_actions/act_4/void_bastion_void_crush.tres"),
		preload("res://content/enemy_actions/act_4/summoner_swarm_scratch.tres"),
	]
	var damage_targets: PackedInt32Array = PackedInt32Array([3, 6, 5, 8, 5, 6, 8, 9, 5])
	for action_index: int in damage_actions.size():
		checks.equal(damage_actions[action_index].direct_damage, damage_targets[action_index], "%s uses its increased damage target" % damage_actions[action_index].display_name)
	var arc_shield: EnemyActionDefinition = preload("res://content/enemy_actions/act_1/arc_shield.tres")
	var ember_barricade: EnemyActionDefinition = preload("res://content/enemy_actions/act_2/furnace_golem_ember_barricade.tres")
	var null_rampart: EnemyActionDefinition = preload("res://content/enemy_actions/act_4/void_bastion_null_rampart.tres")
	checks.equal((arc_shield.effects[0] as ShieldEffect).amount, 14, "Act 1 elite shielding increases by about half")
	checks.equal((ember_barricade.effects[0] as ShieldEffect).amount, 15, "Act 2 elite shielding increases by half")
	checks.equal((null_rampart.effects[0] as ShieldEffect).amount, 18, "Act 4 elite shielding increases by half")
	var mortar_prison: EnemyActionDefinition = preload("res://content/enemy_actions/act_2/mortar_knight_plaster_prison.tres")
	var gravity_crush: EnemyActionDefinition = preload("res://content/enemy_actions/act_4/gravity_stack_crushing_stack.tres")
	checks.equal(mortar_prison.special_cell_count, 5, "Mortar Knight applies increased locked-cell pressure")
	checks.equal(gravity_crush.blocker_count, 2, "Gravity Stack applies increased blocker pressure")
	var hammerfall: CounterDefinition = preload("res://content/counters/smith_hammerfall.tres")
	var impossible_geometry: CounterDefinition = preload("res://content/counters/designer_impossible_geometry.tres")
	checks.equal((hammerfall.failure_effects[0] as DamageEffect).amount, 15, "Smith counter failure damage increases by half")
	checks.equal((impossible_geometry.failure_effects[0] as DamageEffect).amount, 15, "Designer counter failure damage increases by half")
	var centipede: EnemyDefinition = preload("res://content/enemies/bosses/giant_block_centipede.tres")
	var centipede_counter: CounterDefinition = preload("res://content/counters/centipede_coiling_rush.tres")
	checks.equal(centipede.maximum_health, 54, "Giant Block Centipede health remains the Act 1 benchmark")
	checks.equal(centipede.possible_actions[0].direct_damage, 5, "Giant Block Centipede bite remains unchanged")
	checks.equal((centipede_counter.failure_effects[0] as DamageEffect).amount, 8, "Giant Block Centipede counter damage remains unchanged")

func _assert_enemy_health_targets(enemies: Array[EnemyDefinition], targets: PackedInt32Array, act_label: String) -> void:
	checks.equal(enemies.size(), targets.size(), "%s balance targets cover every audited enemy" % act_label)
	for enemy_index: int in mini(enemies.size(), targets.size()):
		checks.equal(enemies[enemy_index].maximum_health, targets[enemy_index], "%s health target is applied to %s" % [act_label, enemies[enemy_index].display_name])

func _test_events_and_board_layouts() -> void:
	var rules: GameRules = load("res://content/rules/default_game_rules.tres") as GameRules
	checks.equal(Vector2i(rules.board_width, rules.board_height), Vector2i(9, 9), "Default encounters use a 9x9 board")
	checks.truthy(ContentRegistry.events.size() >= 9, "Expanded event pool loads at least nine events")
	var run: RunState = RunState.new()
	var rectangular_choice: EventChoiceDefinition = EventChoiceDefinition.new()
	rectangular_choice.board_width_override = 7
	rectangular_choice.board_height_override = 8
	checks.truthy(EventService.new().apply_choice(rectangular_choice, run, RandomNumberGenerator.new()), "Events can apply rectangular board layouts")
	var saved_run: RunState = RunState.from_save_data(run.to_save_data())
	checks.equal(Vector2i(saved_run.pending_board_width, saved_run.pending_board_height), Vector2i(7, 8), "Rectangular board layouts survive run saves")
	var enemy: EnemyDefinition = EnemyDefinition.new()
	enemy.display_name = "Event Layout Test"
	var controller: EncounterController = EncounterController.new()
	add_child(controller)
	controller.start_encounter(saved_run, enemy, PieceGenerator.new(901))
	checks.equal(Vector2i(controller.board.width, controller.board.height), Vector2i(7, 8), "Next encounter consumes a 7x8 event layout")
	checks.equal(Vector2i(saved_run.pending_board_width, saved_run.pending_board_height), Vector2i.ZERO, "Board layout override is consumed once")
	controller.queue_free()
	var large_run: RunState = RunState.new()
	var large_choice: EventChoiceDefinition = EventChoiceDefinition.new()
	large_choice.board_width_override = 9
	large_choice.board_height_override = 10
	large_choice.corrupted_cells_next_encounter = 3
	EventService.new().apply_choice(large_choice, large_run, RandomNumberGenerator.new())
	checks.equal(Vector2i(large_run.pending_board_width, large_run.pending_board_height), Vector2i(9, 10), "Events support 9x10 board layouts")
	checks.equal(large_run.pending_corrupted_cells, 3, "Board-layout events can combine with encounter modifiers")
	var reward_run: RunState = RunState.new()
	var reward_choice: EventChoiceDefinition = EventChoiceDefinition.new()
	reward_choice.item_reward_count = 1
	reward_choice.emergency_clear_reward = 1
	reward_choice.maximum_health_reward = 2
	EventService.new().apply_choice(reward_choice, reward_run, RandomNumberGenerator.new())
	var has_item: bool = false
	for stack: ItemStack in reward_run.inventory.slots:
		has_item = has_item or stack != null
	checks.truthy(has_item, "Events can reward usable items")
	checks.equal(reward_run.emergency_clear_charges, 1, "Events can reward Emergency Clear charges")
	checks.equal(reward_run.maximum_health, 22, "Events can reinforce maximum health")
	var full_inventory_run: RunState = RunState.new()
	full_inventory_run.shards = 10
	full_inventory_run.inventory = ItemInventory.new(1, 1)
	var blocking_stack: ItemStack = ItemStack.new()
	blocking_stack.definition = ContentRegistry.items[0]
	blocking_stack.quantity = blocking_stack.definition.maximum_stack_size
	full_inventory_run.inventory.slots[0] = blocking_stack
	var item_choice: EventChoiceDefinition = EventChoiceDefinition.new()
	item_choice.shard_cost = 3
	item_choice.item_reward_count = 1
	var event_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	event_rng.seed = 5511
	var event_rng_state: int = event_rng.state
	var inventory_before: Dictionary = full_inventory_run.inventory.to_save_data()
	checks.falsy(EventService.new().can_apply_choice(item_choice, full_inventory_run, event_rng), "Item events report unavailable when every reward would overflow inventory")
	checks.falsy(EventService.new().apply_choice(item_choice, full_inventory_run, event_rng), "An unavailable item reward does not partially commit its event choice")
	checks.equal(full_inventory_run.shards, 10, "Rejected item events do not spend Shards")
	checks.equal(full_inventory_run.inventory.to_save_data(), inventory_before, "Rejected item events leave inventory unchanged")
	checks.equal(event_rng.state, event_rng_state, "Rejected item events leave the shared RNG unchanged")
	var minimum_pool_run: RunState = RunState.new()
	PiecePoolService.new().initialize_deck(minimum_pool_run, [_card(801, MONOMINO_PIECE), _card(802, DOMINO_PIECE)], 8)
	var removal_choice: EventChoiceDefinition = EventChoiceDefinition.new()
	removal_choice.remove_piece_from_pool = true
	removal_choice.shard_reward = 9
	var removal_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	removal_rng.seed = 6611
	var removal_rng_state: int = removal_rng.state
	checks.falsy(EventService.new().apply_choice(removal_choice, minimum_pool_run, removal_rng), "Events cannot remove a Block shape below the minimum pile size")
	checks.equal(minimum_pool_run.shards, 0, "Rejected removal events do not grant unrelated rewards")
	checks.equal(removal_rng.state, removal_rng_state, "Rejected removal events do not advance RNG")
	var unlock_choice: EventChoiceDefinition = EventChoiceDefinition.new()
	unlock_choice.unlock_piece_for_run = true
	minimum_pool_run.maximum_active_piece_pool_size = minimum_pool_run.deck_cards.size()
	checks.falsy(EventService.new().can_apply_choice(unlock_choice, minimum_pool_run, removal_rng), "Unlock events reject a full Block pile instead of consuming the reward")
	var locked_event: RunEventDefinition = preload("res://content/events/abandoned_workshop.tres")
	var event_profile: ProfileState = ProfileState.new()
	var event_node: RouteNodeState = RouteNodeState.new()
	checks.equal(EventService.new().select_event(7171, event_node, [locked_event], event_profile), null, "Permanently locked events stay out of the selection pool")
	event_profile.unlocked_events.append(locked_event)
	checks.equal(EventService.new().select_event(7171, event_node, [locked_event], event_profile), locked_event, "Permanent event unlocks enter the selection pool")
	for escapable_event: RunEventDefinition in [preload("res://content/events/supply_drone.tres"), preload("res://content/events/shattered_cache.tres")]:
		var has_safe_exit: bool = escapable_event.choices.any(func(choice: EventChoiceDefinition) -> bool: return choice.shard_cost == 0 and choice.health_cost == 0 and choice.item_reward_count == 0)
		checks.truthy(has_safe_exit, "%s retains an always-available exit choice" % escapable_event.title)

func _test_effects_statuses_and_items() -> void:
	var fracture_trace_status: ApplyStatusEffect = FRACTURE_TRACE_EFFECT.effects[0] as ApplyStatusEffect
	var fracture_rune_status: ApplyStatusEffect = FRACTURE_MODIFIER.effects[1] as ApplyStatusEffect
	var fracture_mine: ItemDefinition = preload("res://content/items/fracture_mine.tres")
	var fracture_mine_status: ApplyStatusEffect = fracture_mine.effects[1] as ApplyStatusEffect
	checks.equal(CRACKED_STATUS.default_duration_turns, 3, "Cracked defaults to three turns on enemies")
	checks.equal(VULNERABLE_STATUS.default_duration_turns, 3, "The stronger enemy fracture status defaults to three turns")
	checks.truthy(fracture_trace_status != null and fracture_trace_status.duration_turns == 3, "Fracture Trace applies Cracked for three turns")
	checks.truthy(fracture_rune_status != null and fracture_rune_status.duration_turns == 3, "Fracture Rune applies Cracked for three turns")
	checks.truthy(fracture_mine_status != null and fracture_mine_status.duration_turns == 3, "Fracture Mine applies Cracked for three turns")
	var slowed_run: RunState = RunState.new()
	var slowed_enemy: EnemyDefinition = EnemyDefinition.new()
	slowed_enemy.display_name = "Slowed Rotation Test"
	slowed_enemy.attack_interval = 20
	var slowed_controller: EncounterController = EncounterController.new()
	add_child(slowed_controller)
	slowed_controller.start_encounter(slowed_run, slowed_enemy, PieceGenerator.new(81))
	slowed_controller.active_piece = PieceInstance.new(TET_L_PIECE)
	slowed_controller.state = EncounterController.TurnState.AWAITING_PLACEMENT
	var slowed_hands: StatusDefinition = preload("res://content/statuses/slowed_hands.tres")
	slowed_run.player_statuses.apply_status(slowed_hands, slowed_hands)
	var rotation_before: int = slowed_controller.active_piece.rotation_index
	slowed_controller.rotate_clockwise()
	slowed_controller.rotate_counterclockwise()
	checks.equal(slowed_controller.active_piece.rotation_index, rotation_before, "Slowed Hands blocks both rotation directions")
	slowed_run.player_statuses.remove_status(slowed_hands)
	slowed_controller.rotate_clockwise()
	checks.truthy(slowed_controller.active_piece.rotation_index != rotation_before, "Rotation becomes available after Slowed Hands expires")
	slowed_controller.queue_free()
	checks.truthy(ContentRegistry.relics.size() >= 20, "Expanded relic pool loads at least twenty relics")
	checks.equal(ContentRegistry.items.size(), 38, "Field Device catalog loads all eighteen legacy devices and twenty additions")
	var placement_relic_run: RunState = RunState.new()
	FIFTH_GEAR_RELIC.apply(placement_relic_run, "Elite reward")
	TWIN_SPOOL_RECYCLER_RELIC.apply(placement_relic_run, "Elite reward")
	checks.equal(placement_relic_run.modifiers.placement_point_bonus, 1, "Fifth Gear grants one additional PM per turn")
	checks.equal(placement_relic_run.modifiers.free_redraws_per_turn_bonus, 2, "Twin-Spool Recycler grants two free redraws per turn")
	var restored_placement_relic_run: RunState = RunState.from_save_data(placement_relic_run.to_save_data())
	checks.equal(restored_placement_relic_run.modifiers.placement_point_bonus, 1, "Placement-point relic bonuses survive run saves")
	checks.equal(restored_placement_relic_run.modifiers.free_redraws_per_turn_bonus, 2, "Free-redraw relic bonuses survive run saves")
	var variant_count: int = 0
	var variant_bases: Array[ItemDefinition] = []
	var icon_paths: Array[String] = []
	var retired_terms: Array[String] = ["potion", "flask", "tonic", "draught", "serum"]
	for definition: ItemDefinition in ContentRegistry.items:
		checks.falsy(definition.display_name.is_empty(), "Every Field Device has a display name")
		checks.falsy(definition.description.is_empty(), "%s has a gameplay description" % definition.display_name)
		checks.truthy(definition.icon != null and not definition.icon.resource_path.is_empty(), "%s has a generated icon" % definition.display_name)
		if definition.icon != null:
			checks.falsy(icon_paths.has(definition.icon.resource_path), "%s uses a unique icon" % definition.display_name)
			icon_paths.append(definition.icon.resource_path)
		var lowercase_name: String = definition.display_name.to_lower()
		for retired_term: String in retired_terms:
			checks.falsy(lowercase_name.contains(retired_term), "%s no longer uses retired potion naming" % definition.display_name)
		if definition.variant_of != null:
			variant_count += 1
			checks.truthy(ContentRegistry.items.has(definition.variant_of), "%s links to a registered base device" % definition.display_name)
			if not variant_bases.has(definition.variant_of):
				variant_bases.append(definition.variant_of)
	checks.equal(variant_count, 10, "Field Device catalog includes ten variants")
	checks.equal(variant_bases.size(), 10, "Field Device variants cover ten unique base devices")
	var ignited_blocks_effect: SpawnIgnitedBlocksEffect = SPAWN_IGNITED_BLOCKS_EFFECT_SCRIPT.new() as SpawnIgnitedBlocksEffect
	checks.truthy(ContentRegistry.statuses.has(ignited_blocks_effect.burn_status), "Cinder Grid is registered for saves")
	checks.truthy(ContentRegistry.statuses.has(load("res://content/statuses/repair_nanites.tres") as StatusDefinition), "Repair Nanites is registered for saves")
	checks.truthy(ContentRegistry.piece_modifiers.has(ignited_blocks_effect.fire_visual_modifier), "Ignited Block visuals are registered for saves")
	var repeatable_relics: Array[RelicDefinition] = [preload("res://content/relics/sharp_lines.tres"), preload("res://content/relics/combo_core.tres"), preload("res://content/relics/clean_geometry.tres"), preload("res://content/relics/stonebreaker.tres"), preload("res://content/relics/double_cut.tres"), preload("res://content/relics/cross_coil.tres"), preload("res://content/relics/perfect_prism.tres")]
	for relic: RelicDefinition in repeatable_relics:
		checks.truthy(relic.repeatable, "%s is a repeatable damage relic" % relic.display_name)
	var stacking_run: RunState = RunState.new()
	var sharp_lines: RelicDefinition = repeatable_relics[0]
	sharp_lines.apply(stacking_run)
	sharp_lines.apply(stacking_run)
	checks.equal(stacking_run.relics.count(sharp_lines), 2, "Repeatable relic ownership records each stack")
	var stacking_clear: ClearResult = ClearResult.new()
	stacking_clear.line_count = 2
	var stacking_damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(stacking_run, EncounterEffectState.new(), stacking_clear, 0, GameRules.new()))
	checks.equal(stacking_damage.modifier_bonus, 4, "Repeatable relic damage modifiers stack")
	checks.truthy(ContentRegistry.get_reward_pool(stacking_run).has(sharp_lines), "Owned repeatable relics remain in reward pools")
	var stacked_trigger_run: RunState = RunState.new()
	var double_cut: RelicDefinition = preload("res://content/relics/double_cut.tres")
	stacked_trigger_run.add_relic(double_cut)
	stacked_trigger_run.add_relic(double_cut)
	var stacked_clear: ClearResult = ClearResult.new()
	stacked_clear.line_count = 2
	var stacked_damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(stacked_trigger_run, EncounterEffectState.new(), stacked_clear, 0, GameRules.new()))
	checks.equal(stacked_damage.modifier_bonus, 4, "Repeatable triggered damage relics resolve every owned stack")
	var stonebreaker_run: RunState = RunState.new()
	var stonebreaker: RelicDefinition = repeatable_relics[3]
	stonebreaker_run.add_relic(stonebreaker)
	var blocker_clear: ClearResult = ClearResult.new()
	blocker_clear.line_count = 1
	blocker_clear.blockers_destroyed = 2
	var stonebreaker_damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(stonebreaker_run, EncounterEffectState.new(), blocker_clear, 0, GameRules.new()))
	checks.equal(stonebreaker_damage.modifier_bonus, 4, "Stonebreaker damage scales from destroyed blockers without controller coupling")
	var blocker_board: BoardState = BoardState.new(1, 1)
	blocker_board.set_cell(Vector2i.ZERO, BoardState.BLOCKER)
	var blocker_cells: Array[Vector2i] = [Vector2i.ZERO]
	RelicTriggerService.new().apply_spawned_blocker_durability(stonebreaker_run, blocker_board, blocker_cells)
	checks.equal(blocker_board.get_cell_type(Vector2i.ZERO), CellType.Value.ARMORED, "Stonebreaker durability resolves from relic trigger data")
	var rejector_run: RunState = RunState.new()
	rejector_run.add_relic(preload("res://content/relics/rejector.tres"))
	rejector_run.discarded_piece_count = 12
	checks.equal(RelicTriggerService.new().rerolls_after_discard(rejector_run), 1, "Rejector discard timing generates a free redraw from relic trigger data")
	var run: RunState = RunState.new()
	var encounter: EncounterEffectState = EncounterEffectState.new()
	encounter.enemy_health = 10
	encounter.enemy_maximum_health = 10
	encounter.enemy_shield = 3
	var context: EffectContext = EffectContext.new()
	context.run_state = run
	context.encounter_state = encounter
	var item_source: ItemDefinition = ItemDefinition.new()
	context.source = item_source
	var damage: DamageEffect = DamageEffect.new()
	damage.target = EffectTarget.Value.ENEMY
	damage.amount = 5
	var damage_result: EffectResult = damage.apply(context)
	checks.equal(damage_result.shield_damage, 3, "Effect damage consumes enemy shield first")
	checks.equal(encounter.enemy_health, 8, "Effect damage reaches enemy health after shield")
	checks.truthy(damage_result.damage_results[0].calculation_sources.has(item_source), "Item damage keeps its source in the calculation trace")
	var piercing: DamageEffect = DamageEffect.new()
	piercing.target = EffectTarget.Value.ENEMY
	piercing.amount = 3
	piercing.ignores_shield = true
	piercing.apply(context)
	checks.equal(encounter.enemy_health, 5, "Piercing damage ignores shield")
	var counter_source: CounterDefinition = CounterDefinition.new()
	var counter_context: EffectContext = EffectContext.new()
	counter_context.source = counter_source
	counter_context.target = EffectTarget.Value.PLAYER
	counter_context.run_state = run
	counter_context.encounter_state = encounter
	var counter_damage: DamageEffect = DamageEffect.new()
	counter_damage.target = EffectTarget.Value.PLAYER
	counter_damage.amount = 2
	var counter_damage_result: EffectResult = counter_damage.apply(counter_context)
	checks.truthy(counter_damage_result.damage_results[0].calculation_sources.has(counter_source), "Counter damage keeps its source in the calculation trace")
	var reserve_run: RunState = RunState.new()
	reserve_run.player_health = 2
	reserve_run.last_reserve_charges = 1
	var reserve_context: EffectContext = EffectContext.new()
	reserve_context.run_state = reserve_run
	reserve_context.encounter_state = EncounterEffectState.new()
	reserve_context.last_reserve_health = 1
	reserve_context.last_reserve_message = "Reserve protected"
	var reserve_damage: DamageEffect = DamageEffect.new()
	reserve_damage.target = EffectTarget.Value.PLAYER
	reserve_damage.amount = 20
	var reserve_result: EffectResult = reserve_damage.apply(reserve_context)
	checks.equal(reserve_run.player_health, 1, "Gameplay effects respect Last Reserve health protection")
	checks.equal(reserve_run.last_reserve_charges, 0, "Gameplay-effect lethal damage consumes one Last Reserve charge")
	checks.truthy(reserve_result.damage_results[0].lethal_damage_prevented, "Gameplay-effect damage reports prevented lethal damage")
	checks.equal(reserve_result.messages, ["Reserve protected"], "Last Reserve feedback propagates through effect results")
	var poison: StatusDefinition = preload("res://content/statuses/poison.tres")
	var collection: StatusCollection = StatusCollection.new()
	collection.apply_status(poison, poison, 2, 2)
	collection.apply_status(poison, poison, 3, 2)
	checks.equal(collection.get_status(poison).stacks, 3, "Status stacks respect maximum")
	checks.equal(collection.get_status(poison).remaining_turns, 3, "Stack and refresh keeps longest duration")
	var saved_statuses: StatusCollection = StatusCollection.from_save_data(collection.to_save_data())
	checks.equal(saved_statuses.get_status(poison).stacks, 3, "Status stacks survive serialization")
	var invalid_statuses: StatusCollection = StatusCollection.from_save_data([
		{"definition": "res://content/statuses/missing_status.tres", "remaining_turns": 2},
		{"definition": ContentReferenceCodec.encode(poison), "remaining_turns": 0}
	])
	checks.truthy(invalid_statuses.instances.is_empty(), "Status restoration drops unknown and expired entries")
	var inventory: ItemInventory = ItemInventory.new(2, 4)
	var healing: ItemDefinition = preload("res://content/items/minor_healing_potion.tres")
	var shop_icon: ShopItemIcon = (load("res://presentation/cards/shop_item_icon.tscn") as PackedScene).instantiate() as ShopItemIcon
	add_child(shop_icon)
	var icon_state: ShopItemViewState = ShopItemViewState.new()
	icon_state.category = ShopItemViewState.Category.POTION
	icon_state.icon = healing.icon
	shop_icon.setup(icon_state)
	checks.equal((shop_icon.get_node("ItemTexture") as TextureRect).texture, healing.icon, "Shop cards render the Field Device texture")
	shop_icon.queue_free()
	var stack: ItemStack = ItemStack.new()
	stack.definition = healing
	stack.quantity = 2
	checks.truthy(inventory.add(stack).added, "Item stack enters inventory")
	var second: ItemStack = ItemStack.new()
	second.definition = healing
	second.quantity = 2
	var overflow: InventoryAddResult = inventory.add(second)
	checks.truthy(overflow.added, "Compatible item quantities merge and overflow into free slot")
	checks.equal(inventory.slots[0].quantity, 3, "Inventory respects definition stack limit")
	checks.equal(inventory.slots[1].quantity, 1, "Inventory keeps excess quantity")
	inventory.lock_slot(0)
	checks.falsy(inventory.consume(0), "Locked slots retain their items")
	var restored: ItemInventory = ItemInventory.from_save_data(inventory.to_save_data())
	checks.equal(restored.slots[0].quantity, 3, "Inventory order and quantity survive serialization")
	checks.truthy(restored.locked_slots.has(0), "Inventory locks survive serialization")
	run.player_health = 10
	context.run_state = run
	var use_context: ItemUseContext = ItemUseContext.new()
	use_context.slot_index = 1
	use_context.effect_context = context
	var use_result: ItemUseResult = ItemService.new().use_item(restored, use_context)
	checks.truthy(use_result.used, "Valid potion use resolves its gameplay effect")
	checks.equal(run.player_health, 15, "Healing potion changes authoritative health")
	checks.equal(restored.slots[1], null, "Successful item use consumes one quantity")
	var counter_definition: CounterDefinition = preload("res://content/counters/column_collapse.tres")
	var counter_board: BoardState = BoardState.new(4, 4)
	counter_board.set_cell(Vector2i(0, 0), 1)
	counter_board.set_cell(Vector2i(0, 1), 1)
	var counter_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	counter_rng.seed = 44
	var counter: ActiveCounterState = CounterService.new().create(counter_definition, TRAINING_SLIME_ENEMY, counter_board, counter_rng)
	checks.equal(counter.target_columns.size(), 1, "Column counter generates one authoritative target")
	var counter_save: ActiveCounterState = ActiveCounterState.from_save_data(counter.to_save_data())
	checks.equal(counter_save.target_columns, counter.target_columns, "Counter targets survive serialization")
	var clear: ClearResult = ClearResult.new()
	clear.completed_columns.append(counter.target_columns[0])
	CounterService.new().apply_clear(counter, counter_definition, clear)
	checks.truthy(counter.is_completed, "Clearing the marked column completes its counter")
	var capsule_definition: ItemDefinition = preload("res://content/items/block_capsule.tres")
	var capsule: ItemStack = ItemStack.new()
	capsule.definition = capsule_definition
	capsule.bonus_piece = DOMINO_PIECE
	capsule.quantity = 2
	var other_capsule: ItemStack = ItemStack.new()
	other_capsule.definition = capsule_definition
	other_capsule.bonus_piece = TET_I_PIECE
	other_capsule.quantity = 1
	checks.falsy(capsule.is_compatible(other_capsule), "Bonus Blocks with different shapes never merge")

func _piece(name: StringName, cells: Array[Vector2i], rotation: bool = true) -> PieceDefinition:
	var piece: PieceDefinition = PieceDefinition.new()
	piece.display_name = String(name)
	piece.base_cells = cells
	piece.allow_rotation = rotation
	return piece

func _card(card_id: int, piece: PieceDefinition, effect: PieceCardEffectDefinition = null) -> PieceCardState:
	var card: PieceCardState = PieceCardState.new()
	card.card_id = card_id
	card.piece = piece
	card.intrinsic_effect = effect
	return card

func _test_rotations() -> void:
	var square: PieceDefinition = _piece(&"o", [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
	var line: PieceDefinition = _piece(&"i", [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])
	var anchored_line: PieceDefinition = _piece(&"anchored_i", [Vector2i(1, 0), Vector2i(0, 0), Vector2i(2, 0), Vector2i(3, 0)])
	var anchored_rotations: Array[Array] = PieceRotationService.get_unique_rotations(anchored_line)
	checks.equal(PieceRotationService.get_unique_rotations(square).size(), 1, "O has one rotation")
	checks.equal(PieceRotationService.get_unique_rotations(line).size(), 2, "I has two rotations")
	checks.equal(anchored_rotations[0][0] as Vector2i, Vector2i(1, 0), "Normalization preserves the authored anchor cell")
	checks.equal(anchored_rotations[1][0] as Vector2i, Vector2i(0, 1), "Rotation preserves the authored anchor cell index")
	checks.equal(TRI_I_PIECE.base_cells[0], Vector2i(1, 0), "Straight Block anchors from its middle tile")
	checks.equal(TET_S_PIECE.base_cells[0], Vector2i(1, 1), "S Block anchors from its lower middle tile")
	checks.equal(TET_Z_PIECE.base_cells[0], Vector2i(1, 1), "Z Block anchors from its lower middle tile")
	checks.equal(TET_L_PIECE.base_cells[0], Vector2i(0, 2), "L Block anchors from its corner tile")
	var instance: PieceInstance = PieceInstance.new(line)
	var original: Array[Vector2i] = instance.get_cells()
	for index: int in 4:
		instance.rotate_clockwise()
	checks.equal(instance.get_cells(), original, "Four rotations return to original")
	instance.rotate_counterclockwise()
	checks.equal(instance.rotation_index, 1, "Counterclockwise wraps")

func _test_board_placement() -> void:
	var board: BoardState = BoardState.new(4, 4)
	var domino: PieceInstance = PieceInstance.new(_piece(&"d", [Vector2i(0, 0), Vector2i(1, 0)]))
	checks.truthy(board.place_piece(Vector2i(0, 0), domino).success, "Valid placement")
	checks.falsy(board.place_piece(Vector2i(3, 0), domino).success, "Out of bounds fails")
	checks.falsy(board.place_piece(Vector2i(0, 0), domino).success, "Overlap fails")
	board.set_cell(Vector2i(2, 2), BoardState.BLOCKER)
	checks.falsy(board.place_piece(Vector2i(2, 2), domino).success, "Blocker overlap fails")
	checks.equal(board.get_cell(Vector2i(1, 0)), 1, "Board indexing")
	checks.truthy(board.place_piece(Vector2i(2, 3), domino).success, "Edge placement")

func _test_ignited_blocks() -> void:
	var effect: SpawnIgnitedBlocksEffect = SPAWN_IGNITED_BLOCKS_EFFECT_SCRIPT.new() as SpawnIgnitedBlocksEffect
	var first_board: BoardState = BoardState.new(4, 4)
	var first_encounter: EncounterEffectState = EncounterEffectState.new()
	first_encounter.enemy_health = 10
	first_encounter.enemy_maximum_health = 10
	var first_context: EffectContext = EffectContext.new()
	first_context.board_state = first_board
	first_context.encounter_state = first_encounter
	first_context.rng = RandomNumberGenerator.new()
	first_context.rng.seed = 4127
	var first_result: EffectResult = effect.apply(first_context)
	checks.truthy(first_result.applied, "Ignited Block effect applies when the board has room")
	checks.equal(first_result.affected_cells.size(), 2, "Ignited Block effect places two Blocks")
	checks.equal(first_board.count_empty_cells(), 14, "Ignited Blocks occupy board cells")
	for cell: Vector2i in first_result.affected_cells:
		var cell_index: int = cell.y * first_board.width + cell.x
		checks.equal(first_board.occupant_pieces[cell_index], effect.generated_piece, "Ignited cells contain Monoblocks")
		checks.truthy(first_board.get_occupant_modifiers(cell).has(effect.fire_visual_modifier), "Ignited Blocks carry the neutral flame marker")
	var burn_instance: StatusInstance = first_encounter.enemy_statuses.get_status(effect.burn_status)
	checks.truthy(burn_instance != null, "Ignited Blocks apply Cinder Grid")
	if burn_instance != null:
		checks.equal(burn_instance.stacks, 2, "Each ignited Block contributes one burn stack")
		checks.equal(burn_instance.remaining_turns, 2, "Cinder Grid lasts two player turns")
	var second_board: BoardState = BoardState.new(4, 4)
	var second_context: EffectContext = EffectContext.new()
	second_context.board_state = second_board
	second_context.encounter_state = EncounterEffectState.new()
	second_context.rng = RandomNumberGenerator.new()
	second_context.rng.seed = 4127
	var second_result: EffectResult = effect.apply(second_context)
	checks.equal(second_result.affected_cells, first_result.affected_cells, "Ignited Block placement is deterministic for a fixed seed")
	var tick_context: EffectContext = EffectContext.new()
	tick_context.target = EffectTarget.Value.ENEMY
	tick_context.encounter_state = first_encounter
	StatusResolver.new().tick(first_encounter.enemy_statuses, StatusTickPhase.Value.START_PLAYER_TURN, tick_context)
	checks.equal(first_encounter.enemy_health, 8, "Two ignited Blocks deal two damage on the first tick")
	StatusResolver.new().tick(first_encounter.enemy_statuses, StatusTickPhase.Value.START_PLAYER_TURN, tick_context)
	checks.equal(first_encounter.enemy_health, 6, "Two ignited Blocks deal two damage on the second tick")
	checks.truthy(first_encounter.enemy_statuses.get_status(effect.burn_status) == null, "Cinder Grid expires after two ticks")
	var repeated_board: BoardState = BoardState.new(4, 4)
	var repeated_encounter: EncounterEffectState = EncounterEffectState.new()
	repeated_encounter.enemy_health = 10
	repeated_encounter.enemy_maximum_health = 10
	var repeated_context: EffectContext = EffectContext.new()
	repeated_context.board_state = repeated_board
	repeated_context.encounter_state = repeated_encounter
	repeated_context.rng = RandomNumberGenerator.new()
	repeated_context.rng.seed = 9182
	effect.apply(repeated_context)
	effect.apply(repeated_context)
	checks.equal(repeated_encounter.enemy_statuses.instances.size(), 2, "Repeated Seeders preserve independent burn durations")
	var repeated_tick_context: EffectContext = EffectContext.new()
	repeated_tick_context.target = EffectTarget.Value.ENEMY
	repeated_tick_context.encounter_state = repeated_encounter
	StatusResolver.new().tick(repeated_encounter.enemy_statuses, StatusTickPhase.Value.START_PLAYER_TURN, repeated_tick_context)
	checks.equal(repeated_encounter.enemy_health, 6, "Four ignited Blocks deal four damage after repeated uses")
	StatusResolver.new().tick(repeated_encounter.enemy_statuses, StatusTickPhase.Value.START_PLAYER_TURN, repeated_tick_context)
	checks.equal(repeated_encounter.enemy_health, 2, "Each repeated Seeder burns for its full second tick")
	checks.truthy(repeated_encounter.enemy_statuses.instances.is_empty(), "Independent Seeder burns expire without extending each other")
	var partial_board: BoardState = BoardState.new(2, 1)
	partial_board.set_cell(Vector2i.ZERO, 1)
	var partial_context: EffectContext = EffectContext.new()
	partial_context.board_state = partial_board
	partial_context.encounter_state = EncounterEffectState.new()
	partial_context.rng = RandomNumberGenerator.new()
	partial_context.rng.seed = 19
	var partial_result: EffectResult = effect.apply(partial_context)
	var partial_burn: StatusInstance = partial_context.encounter_state.enemy_statuses.get_status(effect.burn_status)
	checks.equal(partial_result.affected_cells.size(), 1, "Ignited Block effect uses the remaining empty cell")
	checks.truthy(partial_burn != null and partial_burn.stacks == 1, "Partial placement applies only one burn stack")
	var full_board: BoardState = BoardState.new(1, 1)
	full_board.set_cell(Vector2i.ZERO, 1)
	var full_context: EffectContext = EffectContext.new()
	full_context.board_state = full_board
	full_context.encounter_state = EncounterEffectState.new()
	full_context.rng = RandomNumberGenerator.new()
	var full_result: EffectResult = effect.apply(full_context)
	checks.falsy(full_result.applied, "Ignited Block effect fails cleanly on a full board")
	checks.truthy(full_context.encounter_state.enemy_statuses.instances.is_empty(), "A full board does not apply phantom burn")
	var definition: ItemDefinition = ItemDefinition.new()
	var effects: Array[GameplayEffect] = [effect]
	definition.effects = effects
	var inventory: ItemInventory = ItemInventory.new(1, 1)
	var stack: ItemStack = ItemStack.new()
	stack.definition = definition
	checks.truthy(inventory.add(stack).added, "Ignited Block test item enters inventory")
	var use_context: ItemUseContext = ItemUseContext.new()
	use_context.slot_index = 0
	use_context.effect_context = full_context
	var use_result: ItemUseResult = ItemService.new().use_item(inventory, use_context)
	checks.falsy(use_result.used, "Full-board Ignited Block item use fails")
	checks.truthy(inventory.slots[0] != null and inventory.slots[0].quantity == 1, "Failed full-board use does not consume the item")

func _test_grid_scrubber() -> void:
	var effect: GameplayEffect = REMOVE_RANDOM_OCCUPIED_CELLS_EFFECT_SCRIPT.new() as GameplayEffect
	effect.set("count", 2)
	var first_board: BoardState = BoardState.new(3, 2)
	for x: int in 3:
		first_board.set_cell(Vector2i(x, 0), x + 1)
	first_board.set_cell(Vector2i(0, 1), 4)
	first_board.set_cell(Vector2i(1, 1), BoardState.BLOCKER)
	var first_context: EffectContext = EffectContext.new()
	first_context.board_state = first_board
	first_context.rng = RandomNumberGenerator.new()
	first_context.rng.seed = 6651
	var first_result: EffectResult = effect.apply(first_context)
	checks.truthy(first_result.applied, "Grid Scrubber applies when occupied cells exist")
	checks.equal(first_result.affected_cells.size(), 2, "Grid Scrubber removes its configured cell count")
	checks.equal(first_board.get_cell(Vector2i(1, 1)), BoardState.BLOCKER, "Grid Scrubber leaves blocker cells intact")
	var second_board: BoardState = BoardState.new(3, 2)
	for x: int in 3:
		second_board.set_cell(Vector2i(x, 0), x + 1)
	second_board.set_cell(Vector2i(0, 1), 4)
	second_board.set_cell(Vector2i(1, 1), BoardState.BLOCKER)
	var second_context: EffectContext = EffectContext.new()
	second_context.board_state = second_board
	second_context.rng = RandomNumberGenerator.new()
	second_context.rng.seed = 6651
	checks.equal(effect.apply(second_context).affected_cells, first_result.affected_cells, "Grid Scrubber is deterministic for a fixed seed")
	var empty_context: EffectContext = EffectContext.new()
	empty_context.board_state = BoardState.new(2, 2)
	empty_context.rng = RandomNumberGenerator.new()
	var definition: ItemDefinition = ItemDefinition.new()
	var effects: Array[GameplayEffect] = [effect]
	definition.effects = effects
	var inventory: ItemInventory = ItemInventory.new(1, 1)
	var stack: ItemStack = ItemStack.new()
	stack.definition = definition
	checks.truthy(inventory.add(stack).added, "Grid Scrubber test item enters inventory")
	var use_context: ItemUseContext = ItemUseContext.new()
	use_context.slot_index = 0
	use_context.effect_context = empty_context
	var use_result: ItemUseResult = ItemService.new().use_item(inventory, use_context)
	checks.falsy(use_result.used, "Grid Scrubber fails cleanly on an empty board")
	checks.truthy(inventory.slots[0] != null and inventory.slots[0].quantity == 1, "Failed Grid Scrubber use keeps its charge")

func _test_poisoned_blocks() -> void:
	var board: BoardState = BoardState.new(4, 2)
	var domino: PieceDefinition = _piece(&"poisoned_domino", [Vector2i.ZERO, Vector2i.RIGHT])
	checks.truthy(board.place_piece(Vector2i.ZERO, PieceInstance.new(domino)).success, "First Block is available for poisoning")
	checks.truthy(board.place_piece(Vector2i(2, 0), PieceInstance.new(domino)).success, "Second Block is available for poisoning")
	var venom_burst: EnemyActionDefinition = load("res://content/enemy_actions/act_1/venom_spit.tres") as EnemyActionDefinition
	var poison_effect: GameplayEffect = venom_burst.effects[0]
	var context: EffectContext = EffectContext.new()
	context.board_state = board
	context.rng = RandomNumberGenerator.new()
	context.rng.seed = 7719
	context.stack_modifier = 1
	var effect_result: EffectResult = poison_effect.apply(context)
	checks.truthy(effect_result.applied, "Enemy poison marks placed Blocks")
	checks.equal(effect_result.affected_cells.size(), 4, "Empowered Venom marks one extra complete Block")
	for x: int in board.width:
		checks.truthy(board.is_cell_poisoned(Vector2i(x, 0)), "Every cell belonging to a poisoned Block is marked")
	var restored: BoardState = BoardState.from_save_data(board.to_save_data())
	checks.truthy(restored != null and restored.is_cell_poisoned(Vector2i.ZERO), "Poisoned Block markers survive encounter save and restore")
	checks.equal(restored.get_cell_poison_damage(Vector2i.ZERO), 3, "Poisoned Block damage survives encounter save and restore")
	var board_view: BoardView = BoardView.new()
	board_view.size = Vector2(400, 200)
	add_child(board_view)
	board_view.set_board(restored)
	await get_tree().process_frame
	await get_tree().process_frame
	var poison_marker_count: int = 0
	for tile_entry: BoardTileMapRenderer.TileLayerEntry in board_view.tile_renderer.tile_layers:
		if tile_entry.band == BoardTileMapRenderer.LayerBand.MARKER and tile_entry.style == BoardTileMapRenderer.TileStyle.DOT:
			poison_marker_count += tile_entry.layer.get_used_cells().size()
	checks.equal(poison_marker_count, 4, "Poisoned Block cells render visible board markers")
	board_view.queue_free()
	await get_tree().process_frame
	var clear: ClearResult = restored.resolve_completed_lines()
	checks.equal(clear.poisoned_block_count, 2, "A clear counts poisoned Blocks rather than their individual cells")
	checks.equal(clear.poisoned_block_damage, 6, "Each involved poisoned Block deals its configured damage once")
	checks.equal(clear.poison_damage_source_cells.size(), 2, "Poison damage retains one visual source cell per involved Block")
	checks.equal(clear.player_damage, 6, "Poisoned Block damage is routed to the player through clear damage")
	checks.falsy(restored.is_cell_poisoned(Vector2i.ZERO), "Cleared poison markers are removed with their Blocks")
	checks.equal(poison_effect.get_script().resource_path, "res://core/effects/implementations/mark_random_blocks_poisoned_effect.gd", "Venom Burst uses the poisoned Block effect")
	checks.truthy(venom_burst.applied_statuses.is_empty(), "Venom Burst poisons Blocks without applying a player status")
	var venom_flask: ItemDefinition = load("res://content/items/venom_flask.tres") as ItemDefinition
	checks.truthy(venom_flask.effects[0] is ApplyStatusEffect, "Corrosive Charge applies Venom to the enemy")
	if venom_flask.effects[0] is ApplyStatusEffect:
		checks.equal((venom_flask.effects[0] as ApplyStatusEffect).status, load("res://content/statuses/venom.tres") as StatusDefinition, "Corrosive Charge uses the three-turn Venom status")
	checks.truthy(VENOM_GEOMETRY_MODIFIER.effects[0] is DamageEffect, "Player Venom Geometry deals damage without poisoning enemies")

func _test_electrified_blocks() -> void:
	var board: BoardState = BoardState.new(4, 2)
	var domino: PieceDefinition = _piece(&"electrified_domino", [Vector2i.ZERO, Vector2i.RIGHT])
	checks.truthy(board.place_piece(Vector2i.ZERO, PieceInstance.new(domino)).success, "First Block is available for electrification")
	checks.truthy(board.place_piece(Vector2i(2, 0), PieceInstance.new(domino)).success, "Second Block is available for electrification")
	var action: EnemyActionDefinition = load("res://content/enemy_actions/act_1/static_field.tres") as EnemyActionDefinition
	var effect: MarkRandomBlocksElectrifiedEffect = action.effects[0].duplicate(true) as MarkRandomBlocksElectrifiedEffect
	var context: EffectContext = EffectContext.new()
	context.board_state = board
	context.rng = RandomNumberGenerator.new()
	context.rng.seed = 5512
	effect.block_count = 2
	var effect_result: EffectResult = effect.apply(context)
	checks.truthy(effect_result.applied, "Static Field marks placed Blocks")
	checks.equal(effect_result.affected_cells.size(), 4, "Static Field marks complete Block instances")
	for x: int in board.width:
		checks.truthy(board.is_cell_electrified(Vector2i(x, 0)), "Every cell belonging to an electrified Block is marked")
	var poison_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	poison_rng.seed = 5513
	board.poison_random_blocks(2, 3, poison_rng)
	checks.truthy(board.is_cell_poisoned(Vector2i.ZERO) and board.is_cell_electrified(Vector2i.ZERO), "Poison and Electrified coexist on one Block")
	checks.equal(board.get_cell_poison_damage(Vector2i.ZERO), 3, "Electrified does not overwrite poisoned Block damage")
	var restored: BoardState = BoardState.from_save_data(board.to_save_data())
	checks.truthy(restored != null and restored.is_cell_electrified(Vector2i.ZERO), "Electrified Block markers survive encounter save and restore")
	var board_view: BoardView = BoardView.new()
	board_view.size = Vector2(400, 200)
	add_child(board_view)
	board_view.set_board(restored)
	await get_tree().process_frame
	await get_tree().process_frame
	checks.equal(board_view.tile_renderer.electrified_effect_layer.get_cell_count(), 4, "Electrified Block cells use one batched shader layer")
	checks.equal(board_view.tile_renderer.poisoned_effect_layer.get_cell_count(), 4, "Poisoned Block cells use their shader layer alongside electricity")
	checks.equal(board_view.tile_renderer.electrified_effect_layer.effect_shader.resource_path, "res://presentation/shaders/electrified_block.gdshader", "Electrified Blocks use the electrical shader")
	checks.equal(board_view.tile_renderer.poisoned_effect_layer.effect_shader.resource_path, "res://presentation/shaders/poisoned_block.gdshader", "Poisoned Blocks use the poison shader")
	var occupied_layer_index: int = -1
	var marker_layer_index: int = -1
	for entry: BoardTileMapRenderer.TileLayerEntry in board_view.tile_renderer.tile_layers:
		if entry.band == BoardTileMapRenderer.LayerBand.OCCUPIED:
			occupied_layer_index = maxi(occupied_layer_index, entry.layer.get_index())
		elif entry.band == BoardTileMapRenderer.LayerBand.MARKER and marker_layer_index < 0:
			marker_layer_index = entry.layer.get_index()
	var electrified_layer_index: int = board_view.tile_renderer.electrified_effect_layer.get_index()
	checks.truthy(occupied_layer_index < electrified_layer_index and electrified_layer_index < marker_layer_index, "Animated Block status shaders render above Blocks and below crisp markers")
	board_view.tile_renderer.clear_all()
	checks.equal(board_view.tile_renderer.electrified_effect_layer.get_cell_count(), 4, "Tile refreshes preserve unchanged batched status cells")
	board_view.queue_free()
	await get_tree().process_frame
	var clear: ClearResult = restored.resolve_completed_lines()
	checks.equal(clear.electrified_block_count, 2, "A clear counts electrified Blocks rather than individual cells")
	checks.equal(clear.electrified_source_cells.size(), 2, "Electrified clear retains one source cell per involved Block")
	checks.falsy(restored.is_cell_electrified(Vector2i.ZERO), "Cleared electrical markers are removed with their Blocks")
	var empty_context: EffectContext = EffectContext.new()
	empty_context.board_state = BoardState.new(2, 2)
	empty_context.rng = RandomNumberGenerator.new()
	checks.falsy(effect.apply(empty_context).applied, "Static Field fails cleanly without placed Blocks")
	checks.equal(action.required_absent_block_flag, CellFlag.Value.ELECTRIFIED, "Static Field requires a Block without an electrical mark")
	checks.falsy(board.has_block_without_flag(CellFlag.Value.ELECTRIFIED), "A fully marked board reports no target for Static Field")
	var selector_enemy: EnemyDefinition = EnemyDefinition.new()
	selector_enemy.possible_actions = [action]
	selector_enemy.fallback_action = action
	var selector_state: EncounterEffectState = EncounterEffectState.new()
	selector_state.enemy_health = 1
	selector_state.enemy_maximum_health = 1
	var selector_cooldowns: Array[EnemyActionCooldownState] = []
	var selected_action: EnemyActionDefinition = EnemyActionSelector.new().select_action(
		selector_enemy,
		0,
		selector_state,
		board,
		context.rng,
		null,
		selector_cooldowns
	)
	checks.equal(selected_action, null, "Static Field is not selected as an action or fallback when every placed Block is already Electrified")

func _test_line_clears() -> void:
	var board: BoardState = BoardState.new(3, 3)
	for x: int in 3:
		board.set_cell(Vector2i(x, 1), 1)
	for y: int in 3:
		board.set_cell(Vector2i(1, y), BoardState.BLOCKER if y == 2 else 1)
	var clear: ClearResult = board.resolve_completed_lines()
	checks.equal(clear.line_count, 2, "Cross counts row and column")
	checks.equal(clear.cleared_cell_count, 5, "Intersection counted once")
	checks.truthy(clear.cross_clear, "Cross detected")
	checks.truthy(clear.perfect_clear, "Perfect clear detected")
	checks.truthy(board.is_board_empty(), "Blockers clear with line")
	var stable: BoardState = BoardState.new(3, 3)
	stable.set_cell(Vector2i(0, 2), 7)
	for x: int in 3:
		stable.set_cell(Vector2i(x, 0), 1)
	stable.resolve_completed_lines()
	checks.equal(stable.get_cell(Vector2i(0, 2)), 7, "Remaining cells do not move")

func _test_deck_drawing() -> void:
	var one: PieceCardState = _card(1, DOMINO_PIECE)
	var two: PieceCardState = _card(2, TET_I_PIECE)
	var three: PieceCardState = _card(3, TET_L_PIECE)
	var four: PieceCardState = _card(4, TET_O_PIECE)
	var state: EncounterDeckState = EncounterDeckState.new()
	state.draw_pile = [one, two, three, four]
	var service: DeckService = DeckService.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7001
	var first_draw: Array[PieceCardState] = service.draw(state, 3, rng)
	checks.equal(first_draw, [four, three, two], "Draws resolve from the top of the draw pile in order")
	checks.equal(state.draw_pile, [one], "Drawing removes only the resolved cards from the draw pile")
	service.move_to_in_play(state, four.card_id)
	var discarded_hand: Array[PieceCardState] = service.discard_hand(state)
	checks.equal(discarded_hand, [three, two], "Unplayed hand cards preserve hand order when discarded")
	service.discard_in_play(state, four.card_id)
	checks.equal(state.discard_pile, [three, two, four], "The played card enters the discard pile after unplayed cards")
	var second_draw: Array[PieceCardState] = service.draw(state, 3, rng)
	checks.equal(second_draw[0], one, "A remaining draw-pile card resolves before discard reshuffling")
	checks.equal(state.shuffle_count, 1, "An empty draw pile reshuffles the discard pile exactly once")
	checks.equal(state.hand.size(), 3, "Drawing continues after a mid-draw reshuffle")
	checks.truthy(state.contains_unique_card_ids(), "Deck zones preserve unique card identities through transfers")
	var retrieval_state: EncounterDeckState = EncounterDeckState.new()
	retrieval_state.discard_pile = [one, two, three]
	var transfer: TransferDeckCardsEffect = TransferDeckCardsEffect.new()
	transfer.source_pile = DeckPileType.Value.DISCARD
	transfer.destination_pile = DeckPileType.Value.HAND
	transfer.selection = DeckCardSelection.Value.TOP
	transfer.count = 2
	var transfer_context: EffectContext = EffectContext.new()
	transfer_context.deck_state = retrieval_state
	transfer_context.rng = RandomNumberGenerator.new()
	var transfer_result: EffectResult = transfer.apply(transfer_context)
	checks.equal(transfer_result.moved_cards, [three, two], "Discard retrieval takes the most recently discarded cards first")
	checks.equal(retrieval_state.hand, [two, three], "Retrieved cards enter the hand in stable playable order")
	checks.equal(retrieval_state.discard_pile, [one], "Retrieval leaves unselected discard cards in place")
	var capped_retrieval_state: EncounterDeckState = EncounterDeckState.new()
	capped_retrieval_state.hand = [one, two]
	capped_retrieval_state.discard_pile = [three, four]
	var capped_transfer_context: EffectContext = EffectContext.new()
	capped_transfer_context.deck_state = capped_retrieval_state
	capped_transfer_context.rng = RandomNumberGenerator.new()
	capped_transfer_context.maximum_hand_size = 3
	var capped_transfer_result: EffectResult = transfer.apply(capped_transfer_context)
	checks.equal(capped_transfer_result.moved_cards, [four], "Discard retrieval stops at the configured hand capacity")
	checks.equal(capped_retrieval_state.discard_pile, [three], "Cards above the retrieval hand cap remain discarded")
	var saved_state: EncounterDeckState = EncounterDeckState.from_save_data(state.to_save_data())
	checks.equal(_card_ids(saved_state.draw_pile), _card_ids(state.draw_pile), "Deck saves preserve draw-pile order")
	checks.equal(_card_ids(saved_state.hand), _card_ids(state.hand), "Deck saves preserve hand order")
	checks.equal(_card_ids(saved_state.discard_pile), _card_ids(state.discard_pile), "Deck saves preserve discard-pile order")
	checks.equal(saved_state.shuffle_count, state.shuffle_count, "Deck saves preserve reshuffle count")
	var reroll_run: RunState = RunState.new()
	reroll_run.modifiers.reroll_bonus = 1
	PiecePoolService.new().initialize_deck(reroll_run, [one, two, three, four], 8)
	var reroll_enemy: EnemyDefinition = EnemyDefinition.new()
	reroll_enemy.display_name = "Reroll Test"
	reroll_enemy.maximum_health = 100
	reroll_enemy.attack_interval = 100
	var reroll_controller: EncounterController = EncounterController.new()
	reroll_controller.deck_rules = reroll_controller.deck_rules.duplicate(true) as DeckRules
	reroll_controller.deck_rules.shuffle_at_encounter_start = false
	add_child(reroll_controller)
	checks.truthy(reroll_controller.start_encounter(reroll_run, reroll_enemy, PieceGenerator.new(7002)), "Deck-backed encounter starts for reroll coverage")
	checks.equal(reroll_controller.deck_state.hand.size(), 4, "A player round draws four pieces by default")
	checks.equal(reroll_controller.maximum_placement_points, 4, "A player round starts with four maximum placement points")
	checks.equal(reroll_controller.placement_points_remaining, 4, "All placement points are available at round start")
	var hand_before_reroll: Array[int] = _card_ids(reroll_controller.deck_state.hand)
	reroll_controller.reroll()
	checks.equal(reroll_controller.rerolls, 0, "Reroll consumes one configured charge")
	checks.equal(reroll_controller.deck_state.hand.size(), 4, "A free redraw replaces every remaining hand piece")
	checks.equal(reroll_controller.deck_state.discard_pile.size(), 0, "Reroll reshuffles the discarded hand when the draw pile is exhausted")
	checks.equal(reroll_controller.deck_state.draw_pile.size(), 0, "A four-piece redraw replaces exactly four discarded pieces")
	checks.truthy(reroll_controller.deck_state.contains_unique_card_ids(), "Reroll never duplicates card identities across piles")
	checks.falsy(_card_ids(reroll_controller.deck_state.hand) == hand_before_reroll, "Seeded reroll changes the ordered hand")
	var countdown_before_paid_redraw: int = reroll_controller.enemy_countdown
	reroll_controller.redraw_hand()
	checks.equal(reroll_controller.placement_points_remaining, 3, "A paid redraw spends one placement point")
	checks.equal(reroll_controller.enemy_countdown, countdown_before_paid_redraw - 1, "A paid redraw advances one enemy countdown step")
	checks.equal(reroll_controller.deck_state.hand.size(), 4, "A paid redraw preserves the remaining hand size")
	var placement_origin: Vector2i = _find_valid_piece_origin(reroll_controller.board, reroll_controller.active_piece)
	reroll_controller.place(placement_origin)
	checks.equal(reroll_controller.placement_points_remaining, 2, "A normal placement spends one placement point after a redraw")
	checks.equal(reroll_controller.deck_state.hand.size(), 3, "A placed piece leaves the other three pieces in hand")
	checks.equal(reroll_controller.deck_state.in_play.size(), 1, "Placed pieces remain in play until the player round ends")
	checks.equal(reroll_controller.deck_state.discard_pile.size(), 0, "A normal placement does not discard the remaining hand mid-round")
	var discarded_before_partial_redraw: int = reroll_run.discarded_piece_count
	var countdown_before_partial_redraw: int = reroll_controller.enemy_countdown
	reroll_controller.redraw_hand()
	checks.equal(reroll_controller.placement_points_remaining, 1, "Redrawing a partial hand still costs one placement point")
	checks.equal(reroll_controller.enemy_countdown, countdown_before_partial_redraw - 1, "A partial redraw advances one enemy countdown step")
	checks.equal(reroll_controller.deck_state.hand.size(), 3, "Discarding three remaining pieces redraws exactly three pieces")
	checks.equal(reroll_run.discarded_piece_count, discarded_before_partial_redraw + 3, "Each piece replaced by a partial redraw is recorded as one discard")
	reroll_controller.end_player_turn()
	checks.equal(reroll_controller.turn_number, 2, "Ending early starts the next player round")
	checks.equal(reroll_controller.placement_points_remaining, 4, "The next player round restores all placement points")
	reroll_controller.queue_free()
	var placement_run: RunState = RunState.new()
	var placement_cards: Array[PieceCardState] = []
	for card_id: int in range(20, 28):
		placement_cards.append(_card(card_id, MONOMINO_PIECE))
	PiecePoolService.new().initialize_deck(placement_run, placement_cards, 8)
	var placement_controller: EncounterController = EncounterController.new()
	placement_controller.deck_rules = placement_controller.deck_rules.duplicate(true) as DeckRules
	placement_controller.deck_rules.shuffle_at_encounter_start = false
	add_child(placement_controller)
	checks.truthy(placement_controller.start_encounter(placement_run, reroll_enemy, PieceGenerator.new(7003)), "Four-placement cap encounter starts")
	for placement_index: int in 4:
		var guaranteed_origin: Vector2i = _find_valid_piece_origin(placement_controller.board, placement_controller.active_piece)
		placement_controller.place(guaranteed_origin)
		if placement_index < 3:
			checks.equal(placement_controller.turn_number, 1, "The player turn remains active before the fourth placement")
			checks.equal(placement_controller.placement_points_remaining, 3 - placement_index, "Each placement spends exactly one PM")
	checks.equal(placement_controller.turn_number, 2, "The fourth placement reaches the cap and starts the next player turn")
	checks.equal(placement_controller.placement_points_remaining, 4, "The new turn restores the four-PM cap")
	checks.equal(placement_controller.deck_state.hand.size(), 4, "The new turn draws a fresh four-piece hand")
	placement_controller.queue_free()
	var hoarder_run: RunState = RunState.new()
	var hoarder_cards: Array[PieceCardState] = []
	for card_id: int in range(40, 48):
		hoarder_cards.append(_card(card_id, MONOMINO_PIECE))
	PiecePoolService.new().initialize_deck(hoarder_run, hoarder_cards, 8)
	var hoarder_controller: EncounterController = EncounterController.new()
	add_child(hoarder_controller)
	hoarder_controller.start_encounter(hoarder_run, preload("res://content/enemies/hoarder.tres") as EnemyDefinition, PieceGenerator.new(7004))
	checks.equal(hoarder_controller.deck_state.hand.size(), 3, "Hoarder's configured draw penalty reduces the four-piece base hand to three")
	hoarder_controller.queue_free()
	var relentless_run: RunState = RunState.new()
	relentless_run.difficulty = preload("res://content/difficulties/relentless.tres") as DifficultyDefinition
	var relentless_cards: Array[PieceCardState] = []
	for card_id: int in range(50, 58):
		relentless_cards.append(_card(card_id, MONOMINO_PIECE))
	PiecePoolService.new().initialize_deck(relentless_run, relentless_cards, 8)
	var relentless_controller: EncounterController = EncounterController.new()
	add_child(relentless_controller)
	relentless_controller.start_encounter(relentless_run, reroll_enemy, PieceGenerator.new(7005))
	checks.equal(relentless_controller.deck_state.hand.size(), 3, "Relentless difficulty reduces the four-piece base hand to the safe three-piece minimum")
	relentless_controller.queue_free()

func _test_piece_card_effects() -> void:
	var run: RunState = RunState.new()
	var encounter: EncounterEffectState = EncounterEffectState.new()
	encounter.enemy_health = 10
	encounter.enemy_maximum_health = 10
	var context: EffectContext = EffectContext.new()
	context.run_state = run
	context.encounter_state = encounter
	context.rng = RandomNumberGenerator.new()
	var powered_card: PieceCardState = _card(101, DOMINO_PIECE, KINETIC_IMPACT_EFFECT)
	var filler_card: PieceCardState = _card(102, DOMINO_PIECE)
	var service: PieceCardEffectService = PieceCardEffectService.new()
	var powered_result: EffectResult = service.resolve_placement(powered_card, context)
	var filler_result: EffectResult = service.resolve_placement(filler_card, context)
	var kinetic_damage: int = (KINETIC_IMPACT_EFFECT.effects[0] as DamageEffect).amount
	checks.equal(powered_result.health_damage, kinetic_damage, "A powered piece resolves its configured placement effect")
	checks.equal(encounter.enemy_health, 10 - kinetic_damage, "Placement piece damage updates authoritative enemy health")
	checks.falsy(filler_result.applied, "A duplicate filler card of the same shape has no intrinsic effect")
	var shield_card: PieceCardState = _card(106, DOMINO_PIECE, PRISM_GUARD_EFFECT)
	var first_shield_result: EffectResult = service.resolve_placement(shield_card, context)
	var capped_shield_result: EffectResult = service.resolve_placement(shield_card, context)
	checks.equal(first_shield_result.shield_granted, 2, "Prism Guard grants two Shield from zero")
	checks.equal(encounter.player_shield, 2, "Prism Guard raises total Shield to its configured cap")
	checks.equal(capped_shield_result.shield_granted, 0, "Additional shielding Blocks grant no Shield at the cap")
	encounter.player_shield = 1
	var partial_shield_result: EffectResult = service.resolve_placement(shield_card, context)
	checks.equal(partial_shield_result.shield_granted, 1, "Prism Guard grants only the amount needed to reach two Shield")
	checks.equal(encounter.player_shield, 2, "Prism Guard never raises total Shield above two")
	checks.truthy(PRISM_GUARD_EFFECT.effects[0] is CappedShieldEffect, "Prism Guard uses the reusable capped Shield effect")
	var board: BoardState = BoardState.new(1, 1)
	var clear_card: PieceCardState = _card(103, MONOMINO_PIECE, REPAIR_GLYPH_EFFECT)
	var instance: PieceInstance = PieceInstance.new()
	instance.bind_card(clear_card)
	checks.truthy(board.place_piece(Vector2i.ZERO, instance).success, "A card-backed Block can be placed for clear-effect persistence")
	var restored_board: BoardState = BoardState.from_save_data(board.to_save_data())
	checks.equal(restored_board.occupant_card_ids[0], clear_card.card_id, "Board saves preserve the occupying card identity")
	checks.equal(restored_board.occupant_card_effects[0], REPAIR_GLYPH_EFFECT, "Board saves preserve intrinsic effects on placed cells")
	checks.equal(restored_board.get_occupant_card_effect(Vector2i.ZERO), REPAIR_GLYPH_EFFECT, "Placed effect indicators resolve from restored board-cell metadata")
	var clear: ClearResult = restored_board.resolve_completed_lines()
	checks.equal(clear.piece_contributions.size(), 1, "A restored clear retains card attribution")
	checks.equal(clear.piece_contributions[0].card.intrinsic_effect, REPAIR_GLYPH_EFFECT, "Clear contributions retain the restored card effect")
	run.player_health = run.maximum_health - 2
	context.board_state = restored_board
	var clear_result: EffectResult = service.resolve_clear_contributions(clear, context)
	checks.equal(clear_result.healing, 1, "A persisted full-clear card effect resolves after board restoration")
	checks.equal(run.player_health, run.maximum_health - 1, "Clear-card healing updates authoritative player health")
	var weighted_controller: EncounterController = EncounterController.new()
	weighted_controller.deck_rules = DeckRules.new()
	weighted_controller.deck_rules.base_enemy_health_multiplier = 1.0
	weighted_controller.deck_rules.enemy_health_bonus_per_effect_weight = 0.1
	weighted_controller.deck_rules.maximum_effect_deck_health_bonus = 1.0
	var utility_card: PieceCardState = _card(104, DOMINO_PIECE, RECLAIM_LOOP_EFFECT)
	var curse_card: PieceCardState = _card(105, DOMINO_PIECE, CURSED_FRAGMENT_EFFECT)
	var utility_multiplier: float = weighted_controller._deck_enemy_health_multiplier([utility_card])
	var utility_and_curse_multiplier: float = weighted_controller._deck_enemy_health_multiplier([utility_card, curse_card])
	var expected_utility_multiplier: float = 1.0 + RECLAIM_LOOP_EFFECT.enemy_health_scaling_weight * 0.1
	checks.truthy(is_equal_approx(utility_multiplier, expected_utility_multiplier), "Utility effects contribute proportionally to enemy health scaling")
	checks.truthy(is_equal_approx(utility_and_curse_multiplier, utility_multiplier), "Curse effects contribute no enemy health scaling")

func _card_ids(cards: Array[PieceCardState]) -> Array[int]:
	var ids: Array[int] = []
	for card: PieceCardState in cards:
		ids.append(card.card_id)
	return ids

func _test_generation() -> void:
	var first: PieceGenerator = PieceGenerator.new(2468)
	first.rng.randi()
	var saved_generator: Dictionary = first.to_save_data()
	var expected_next_value: int = first.rng.randi()
	var restored: PieceGenerator = PieceGenerator.new(1)
	restored.restore(saved_generator)
	checks.equal(restored.rng.randi(), expected_next_value, "Piece generator saves preserve deterministic RNG continuation")

func _test_piece_drafting_and_active_pools() -> void:
	var rules: PieceDraftRules = load("res://content/rules/default_piece_draft_rules.tres") as PieceDraftRules
	var profile: ProfileState = ProfileState.new()
	var service: PieceDraftService = PieceDraftService.new()
	var first: PieceDraftState = service.generate_starting_draft(profile, 481516, rules)
	var second: PieceDraftState = service.generate_starting_draft(profile, 481516, rules)
	checks.equal(first.candidate_pieces(), second.candidate_pieces(), "Starting draft is deterministic for a seed and profile")
	checks.equal(_card_effects(first.candidate_cards()), _card_effects(second.candidate_cards()), "Starting draft effects are deterministic for a seed and profile")
	checks.equal(first.candidates.size(), rules.candidate_count, "Starting draft uses the configured candidate count")
	checks.equal(rules.candidate_count, 14, "Default starting draft presents fourteen pieces")
	checks.equal(rules.selection_count, 8, "Default starting draft builds an eight-card deck")
	var powered_candidate_count: int = 0
	for candidate: PieceDraftCandidate in first.candidates:
		powered_candidate_count += 1 if candidate.card.intrinsic_effect != null else 0
	checks.equal(powered_candidate_count, rules.effect_candidate_count, "Starting draft rolls the configured number of powered cards")
	service.randomize_selection(first, 90210)
	checks.equal(first.selected_card_ids.size(), 8, "Random selection chooses exactly eight card identities")
	checks.equal(first.selected_effect_count(), rules.required_effect_selection_count, "Random selection chooses the configured powered-piece count")
	var first_random_selection: Array[int] = first.selected_card_ids.duplicate()
	var first_random_state: int = first.generation_seed_state
	service.randomize_selection(first, 90210)
	checks.truthy(first.generation_seed_state != first_random_state, "Each random draft selection advances its persisted RNG state")
	checks.falsy(first.selected_card_ids == first_random_selection, "Repeated Randomize presses produce a fresh valid draft selection")
	checks.truthy(service.can_confirm_draft(first, rules.minimum_active_pool_size), "Configured draft selection can be confirmed")
	var run: RunState = RunState.new()
	run.seed_value = 481516
	checks.truthy(service.confirm_draft(first, run, rules).changed, "Confirming a draft initializes the active pool")
	run.piece_draft = first
	checks.equal(run.deck_cards.size(), rules.selection_count, "Only selected cards enter the run deck")
	checks.truthy(run.deck_cards.all(func(card: PieceCardState) -> bool: return card.is_starting_card), "Starting cards retain draft source metadata")
	checks.truthy(_has_unique_card_ids(run.deck_cards), "Draft confirmation assigns every selected copy a unique card ID")
	checks.equal(_count_powered_cards(run.deck_cards), rules.required_effect_selection_count, "The confirmed deck contains the configured powered-piece count")
	var duplicate_rules: PieceDraftRules = rules.duplicate(true) as PieceDraftRules
	duplicate_rules.candidate_count = 12
	duplicate_rules.selection_count = 8
	duplicate_rules.allow_duplicate_pieces = true
	duplicate_rules.maximum_copies_per_piece = 3
	duplicate_rules.minimum_distinct_piece_count = 4
	duplicate_rules.prevent_all_small_piece_draft = false
	duplicate_rules.prevent_all_large_piece_draft = false
	duplicate_rules.effect_candidate_count = 0
	duplicate_rules.required_effect_selection_count = 0
	duplicate_rules.random_effect_pool.clear()
	var duplicate_eligible: Array[PieceDefinition] = []
	for definition: PieceDefinition in ContentRegistry.pieces:
		if definition.initially_unlocked and definition.can_appear_in_starting_draft and definition.permanent_card_effect == null and not duplicate_rules.excluded_piece_tags.any(func(tag: StringName) -> bool: return definition.tags.has(tag)):
			duplicate_eligible.append(definition)
	duplicate_eligible.sort_custom(func(left: PieceDefinition, right: PieceDefinition) -> bool: return left.resource_path < right.resource_path)
	checks.truthy(duplicate_eligible.size() >= 4, "Duplicate draft coverage has four eligible filler shapes")
	if duplicate_eligible.size() >= 4:
		for definition: PieceDefinition in ContentRegistry.pieces:
			if not duplicate_eligible.slice(0, 4).has(definition):
				duplicate_rules.excluded_pieces.append(definition)
		var duplicate_draft: PieceDraftState = service.generate_starting_draft(profile, 314159, duplicate_rules)
		var duplicate_counts: Dictionary[PieceDefinition, int] = {}
		for candidate: PieceDraftCandidate in duplicate_draft.candidates:
			duplicate_counts[candidate.piece] = duplicate_counts.get(candidate.piece, 0) + 1
		checks.equal(duplicate_draft.candidates.size(), 12, "Duplicate-enabled draft fills all twelve candidate slots")
		checks.equal(duplicate_counts.size(), 4, "Duplicate-enabled draft maintains the configured distinct-shape floor")
		checks.truthy(duplicate_counts.values().all(func(count: int) -> bool: return count == 3), "Duplicate-enabled draft respects the three-copy cap per shape")
		checks.truthy(duplicate_draft.candidates[0].candidate_id != duplicate_draft.candidates[1].candidate_id, "Repeated shapes remain independently selectable card identities")
	var permanent_piece: PieceDefinition = _piece(&"permanent_effect_piece", [Vector2i.ZERO])
	permanent_piece.permanent_card_effect = PRISM_GUARD_EFFECT
	var override_rules: PieceDraftRules = rules.duplicate(true) as PieceDraftRules
	override_rules.candidate_count = 1
	override_rules.selection_count = 1
	override_rules.minimum_active_pool_size = 1
	override_rules.maximum_active_pool_size = 1
	override_rules.allow_duplicate_pieces = false
	override_rules.minimum_distinct_piece_count = 1
	override_rules.effect_candidate_count = 0
	override_rules.required_effect_selection_count = 1
	override_rules.excluded_pieces.assign(ContentRegistry.pieces)
	var override_draft: PieceDraftState = service.generate_starting_draft(profile, 271828, override_rules, [permanent_piece])
	checks.equal(override_draft.candidates.size(), 1, "A permanently powered shape remains eligible for the draft")
	if not override_draft.candidates.is_empty():
		checks.equal(override_draft.candidates[0].card.intrinsic_effect, PRISM_GUARD_EFFECT, "A shape's permanent effect overrides random effect assignment")
	var addition: PieceDefinition
	for definition: PieceDefinition in ContentRegistry.pieces:
		if not PiecePoolService.new().contains_piece(run, definition):
			addition = definition
			break
	checks.truthy(addition != null, "Inactive Blocks remain available for pool-expansion effects")
	if addition != null:
		var pool_service: PiecePoolService = PiecePoolService.new()
		checks.truthy(pool_service.add_piece(run, addition, FRACTURE_RELIC).changed, "A relic source can add an inactive Block")
		checks.equal(run.deck_cards.size(), rules.selection_count + 1, "Adding a Block expands the run deck")
		checks.truthy(pool_service.add_piece(run, addition, GUARDIAN_RELIC).changed, "A second copy can enter the deck as a distinct card")
		checks.equal(pool_service.count_piece_copies(run, addition), 2, "Duplicate additions retain both copies")
		var first_added_card: PieceCardState = pool_service.get_entry(run, addition, FRACTURE_RELIC)
		checks.truthy(pool_service.remove_card(run, first_added_card.card_id, FRACTURE_RELIC).changed, "A specific duplicate copy can be removed by card ID")
		checks.equal(pool_service.count_piece_copies(run, addition), 1, "Removing one card leaves the other duplicate active")
		var size_before_full_add: int = run.deck_cards.size()
		run.maximum_active_piece_pool_size = size_before_full_add
		checks.equal(pool_service.add_piece(run, addition, FRACTURE_RELIC).reason, PiecePoolChangeResult.Reason.POOL_FULL, "The configured active-pool maximum is enforced")
		checks.equal(run.deck_cards.size(), size_before_full_add, "A full deck never silently expands")
		run.maximum_active_piece_pool_size = rules.maximum_active_pool_size
		var random_effect: AddPieceToPoolRelicEffect = AddPieceToPoolRelicEffect.new()
		random_effect.include_locked_pieces = true
		random_effect.apply(run, FRACTURE_RELIC)
		checks.equal(run.deck_cards.size(), size_before_full_add + 1, "Random addition relics add one deterministic card")
		checks.equal(run.pending_piece_addition, null, "Random addition relics do not also open a second selection reward")
	var pending: PendingPieceAdditionState = PendingPieceAdditionState.new()
	pending.source_relic = FRACTURE_RELIC
	pending.candidate_pieces.assign(first.candidate_pieces().slice(0, 3))
	pending.selected_pieces = [pending.candidate_pieces[1]]
	pending.continuation_flow = PieceSelectionFlow.Value.COMBAT_REWARD
	run.pending_piece_addition = pending
	var restored: RunState = RunState.from_save_data(run.to_save_data())
	checks.equal(restored.piece_draft.candidate_pieces(), first.candidate_pieces(), "Active saves preserve draft order including duplicate shapes")
	checks.equal(restored.piece_draft.selected_card_ids, first.selected_card_ids, "Active saves preserve selected draft card identities")
	checks.equal(_card_ids(restored.deck_cards), _card_ids(run.deck_cards), "Active saves preserve exact deck card identities")
	checks.equal(_card_effects(restored.deck_cards), _card_effects(run.deck_cards), "Active saves preserve per-card intrinsic effects")
	checks.equal(restored.pending_piece_addition.selected_pieces, pending.selected_pieces, "Active saves preserve a pending pool choice")
	checks.equal(restored.pending_piece_addition.continuation_flow, PieceSelectionFlow.Value.COMBAT_REWARD, "Pending choices preserve their resume flow")
	var json_value: Variant = JSON.parse_string(JSON.stringify(run.to_save_data()))
	var json_restored: RunState = RunState.from_save_data(json_value as Dictionary)
	checks.equal(_card_ids(json_restored.deck_cards), _card_ids(run.deck_cards), "JSON active saves preserve exact deck card identities")
	checks.equal(_card_effects(json_restored.deck_cards), _card_effects(run.deck_cards), "JSON active saves preserve card effects")
	var interrupted_data: Dictionary = run.to_save_data()
	interrupted_data["deck_cards"] = []
	interrupted_data["active_piece_pool_entries"] = []
	var repaired_run: RunState = RunState.from_save_data(interrupted_data)
	repaired_run.ensure_active_piece_pool()
	checks.equal(_card_effects(repaired_run.deck_cards), _card_effects(first.selected_cards()), "Confirmed drafts rebuild a missing deck with selected card effects")
	var minimum_run: RunState = RunState.new()
	var minimum_cards: Array[PieceCardState] = []
	minimum_cards.assign(first.selected_cards().slice(0, 2))
	PiecePoolService.new().initialize_deck(minimum_run, minimum_cards, 12)
	checks.equal(PiecePoolService.new().remove_card(minimum_run, minimum_run.deck_cards[0].card_id, null, 2).reason, PiecePoolChangeResult.Reason.MINIMUM_POOL, "Card removal cannot shrink the deck below its minimum")
	var small_rules: PieceDraftRules = rules.duplicate(true) as PieceDraftRules
	small_rules.required_piece_tags = [&"small"]
	var small_draft: PieceDraftState = service.generate_starting_draft(profile, 112358, small_rules)
	var contains_small: bool = false
	for piece: PieceDefinition in small_draft.candidate_pieces():
		contains_small = contains_small or piece.tags.has(&"small")
	checks.truthy(contains_small, "Required composition tags guarantee a matching candidate without filtering the whole draft")
	var draft_viewport: SubViewport = SubViewport.new()
	draft_viewport.size = Vector2i(1280, 720)
	add_child(draft_viewport)
	var draft_screen: PieceDraftScreen = (load("res://scenes/piece_draft/piece_draft_screen.tscn") as PackedScene).instantiate() as PieceDraftScreen
	draft_viewport.add_child(draft_screen)
	draft_screen.start(run, rules)
	checks.truthy(draft_screen.get_node("Margin/Layout/Content/DetailPanel") != null, "Draft screen resolves its responsive detail panel")
	var first_draft_card: PieceDraftCard = draft_screen.get_node("Margin/Layout/Content/Scroll/CandidateGrid").get_child(0) as PieceDraftCard
	checks.truthy(first_draft_card.block_visual_settings != null and first_draft_card.block_visual_settings.block_style_texture != null, "Draft cards receive the shared Block texture directly from their scene")
	draft_viewport.queue_free()

func _card_effects(cards: Array[PieceCardState]) -> Array[PieceCardEffectDefinition]:
	var effects: Array[PieceCardEffectDefinition] = []
	for card: PieceCardState in cards:
		effects.append(card.intrinsic_effect)
	return effects

func _count_powered_cards(cards: Array[PieceCardState]) -> int:
	var count: int = 0
	for card: PieceCardState in cards:
		count += 1 if card.intrinsic_effect != null else 0
	return count

func _has_unique_card_ids(cards: Array[PieceCardState]) -> bool:
	var ids: Dictionary[int, bool] = {}
	for card: PieceCardState in cards:
		if card.card_id <= 0 or ids.has(card.card_id):
			return false
		ids[card.card_id] = true
	return true

func _test_score_and_damage() -> void:
	var rules: GameRules = GameRules.new()
	var clear: ClearResult = ClearResult.new()
	clear.line_count = 2
	clear.cross_clear = true
	var score: ScoreResult = ScoreService.calculate(clear, 1, rules)
	checks.equal(score.final_score, 540, "Score combo and cross bonus")
	var run: RunState = RunState.new()
	var upgrade_source: UpgradeDefinition = UpgradeDefinition.new()
	var line_modifier: DamageModifierDefinition = DamageModifierDefinition.new()
	line_modifier.event_type = DamageEventType.Value.CLEAR
	line_modifier.value = 1.0
	line_modifier.scaling = DamageModifierScaling.Value.CLEARED_LINES
	var combo_modifier: DamageModifierDefinition = DamageModifierDefinition.new()
	combo_modifier.event_type = DamageEventType.Value.CLEAR
	combo_modifier.value = 1.0
	combo_modifier.scaling = DamageModifierScaling.Value.COMBO_LEVEL
	run.modifiers.damage_modifiers = [line_modifier.create_instance(upgrade_source), combo_modifier.create_instance(upgrade_source)]
	var damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(run, EncounterEffectState.new(), clear, 1, rules))
	checks.equal(damage.combo_bonus, 1, "Rule combo damage remains separately traceable")
	checks.equal(damage.final_damage, 9, "Damage modifiers apply")
	var strength: StatusDefinition = preload("res://content/statuses/strength.tres")
	var vulnerable: StatusDefinition = preload("res://content/statuses/vulnerable.tres")
	run.player_statuses.apply_status(strength, strength)
	var status_encounter: EncounterEffectState = EncounterEffectState.new()
	status_encounter.enemy_statuses.apply_status(vulnerable, vulnerable)
	var status_damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(run, status_encounter, clear, 1, rules))
	checks.equal(status_damage.final_damage, 14, "Outgoing and incoming statuses share the ordered damage pipeline")
	checks.truthy(status_damage.calculation_sources.has(strength) and status_damage.calculation_sources.has(vulnerable), "Status contributions remain traceable to their definitions")
	run.player_statuses.remove_status(strength)
	clear.blockers_destroyed = 2
	var blocker_damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(run, EncounterEffectState.new(), clear, 1, rules))
	checks.equal(blocker_damage.blocker_penalty, 2, "Each blocker on a cleared line adds one damage penalty")
	checks.equal(blocker_damage.final_damage, 7, "Cleared blockers reduce player damage by one each")
	clear.blockers_destroyed = 0
	rules.combo_damage_bonus_per_level = 3
	var consecutive_damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(run, EncounterEffectState.new(), clear, 2, rules))
	checks.equal(consecutive_damage.combo_bonus, 6, "Configured combo damage applies to every consecutive combo level")
	var default_rules: GameRules = load("res://content/rules/default_game_rules.tres") as GameRules
	checks.truthy(default_rules.combo_damage_bonus_per_level >= 0, "Default game rules expose adjustable combo damage")
	checks.equal(rules.score_for_lines(5), 1400, "Score beyond four")
	checks.equal(rules.damage_for_lines(5), 14, "Damage beyond four")

func _test_encounter() -> void:
	var current_run: RunState = RunState.new()
	var enemy: EnemyDefinition = EnemyDefinition.new()
	enemy.display_name = "Test Enemy"
	enemy.maximum_health = 100
	enemy.attack_interval = 1
	enemy.direct_damage = 2
	enemy.blocker_count = 1
	var controller: EncounterController = EncounterController.new()
	add_child(controller)
	controller.start_encounter(current_run, enemy, PieceGenerator.new(99))
	var checkpoint_count: Array[int] = [0]
	controller.safe_point_reached.connect(func(_data: Dictionary) -> void: checkpoint_count[0] += 1)
	var health_before: int = current_run.player_health
	checks.truthy(controller.active_piece != null, "Encounter selects a placeable drawn card")
	controller.rotate_clockwise()
	checks.equal(checkpoint_count[0], 1, "Rotating a Block updates the fight checkpoint")
	controller.place(Vector2i.ZERO)
	checks.equal(current_run.player_health, health_before - 2, "Enemy countdown triggers attack")
	checks.equal(controller.enemy_countdown, 1, "Enemy countdown resets")
	checks.truthy(controller.board.cells.has(BoardState.BLOCKER), "Enemy blocker uses empty cell")
	for y: int in controller.board.height:
		for x: int in controller.board.width:
			controller.board.set_cell(Vector2i(x, y), 1)
	controller._generate_turn()
	checks.equal(controller.state, EncounterController.TurnState.RUN_LOST, "No valid cards across all piles end the run")
	controller.queue_free()
	var selector: EncounterController = EncounterController.new()
	var first_block: PieceDefinition = _piece(&"first_block", [Vector2i.ZERO])
	var second_block: PieceDefinition = _piece(&"second_block", [Vector2i.ZERO])
	var first_card: PieceCardState = _card(201, first_block)
	var second_card: PieceCardState = _card(202, second_block)
	selector.state = EncounterController.TurnState.AWAITING_PLACEMENT
	selector.deck_state = EncounterDeckState.new()
	selector.deck_state.hand = [first_card, second_card]
	selector.hand_placeable = [true, true]
	selector.active_card_index = 0
	selector.active_card = first_card
	selector.active_piece = PieceInstance.new()
	selector.active_piece.bind_card(first_card)
	selector.select_next_choice()
	checks.equal(selector.active_card_index, 1, "Block switch advances to the next hand card")
	selector.hand_placeable = [true, false]
	selector.select_next_choice()
	checks.equal(selector.active_card_index, 0, "Block switch skips an unavailable hand card")
	checks.truthy(InputMap.has_action("switch_block") and not InputMap.action_get_events("switch_block").is_empty(), "Block switch input is mapped")
	selector.free()
	var perfect_clear_run: RunState = RunState.new()
	var perfect_clear_enemy: EnemyDefinition = EnemyDefinition.new()
	perfect_clear_enemy.display_name = "Perfect Clear Test Enemy"
	perfect_clear_enemy.maximum_health = 20
	perfect_clear_enemy.attack_interval = 20
	var perfect_clear_controller: EncounterController = EncounterController.new()
	perfect_clear_controller.deck_rules = _unscaled_deck_rules(perfect_clear_controller.deck_rules)
	add_child(perfect_clear_controller)
	perfect_clear_controller.start_encounter(perfect_clear_run, perfect_clear_enemy, PieceGenerator.new(8080))
	var i_block: PieceDefinition = TET_I_PIECE
	var clear_row: int = perfect_clear_controller.board.height - 1
	var covered_columns: int = i_block.base_cells.size() * 2
	for column: int in range(covered_columns, perfect_clear_controller.board.width):
		perfect_clear_controller.board.set_cell(Vector2i(column, clear_row), 1)
	var perfect_clear_card_id: int = 300
	for origin: Vector2i in [Vector2i(0, clear_row), Vector2i(i_block.base_cells.size(), clear_row)]:
		_prepare_controller_card(perfect_clear_controller, _card(perfect_clear_card_id, i_block))
		perfect_clear_card_id += 1
		perfect_clear_controller.place(origin)
	checks.truthy(perfect_clear_controller.last_clear_result.perfect_clear, "Completing the default board row with two I Blocks produces a perfect clear")
	checks.equal(perfect_clear_controller.rules.perfect_clear_damage_bonus, 5, "Default perfect-clear damage uses the balanced configurable value")
	checks.equal(perfect_clear_controller.enemy_health, 13, "The first two-I-Block perfect clear deals 7 damage instead of instantly killing the enemy")
	checks.equal(perfect_clear_run.player_shield, perfect_clear_controller.rules.perfect_clear_shield, "Perfect-clear Shield persists on the authoritative run state")
	checks.equal(perfect_clear_controller.effect_state.player_shield, perfect_clear_run.player_shield, "Perfect-clear Shield remains synchronized with encounter effects")
	perfect_clear_controller.queue_free()
	var counter_run: RunState = RunState.new()
	var after_action_status: StatusDefinition = StatusDefinition.new()
	after_action_status.default_duration_turns = 2
	after_action_status.duration_phase = StatusTickPhase.Value.AFTER_ENEMY_ACTION
	counter_run.player_statuses.apply_status(after_action_status, after_action_status, 2)
	var failure_damage: DamageEffect = DamageEffect.new()
	failure_damage.target = EffectTarget.Value.PLAYER
	failure_damage.amount = 2
	var failure_counter: CounterDefinition = CounterDefinition.new()
	failure_counter.display_name = "Failure Test"
	failure_counter.duration_turns = 3
	failure_counter.failure_effects = [failure_damage]
	var counter_action: EnemyActionDefinition = EnemyActionDefinition.new()
	counter_action.display_name = "Counter Test Action"
	counter_action.counter_definition = failure_counter
	var counter_enemy: EnemyDefinition = EnemyDefinition.new()
	counter_enemy.display_name = "Counter Test Enemy"
	counter_enemy.maximum_health = 30
	counter_enemy.attack_interval = 2
	counter_enemy.possible_actions = [counter_action]
	var counter_controller: EncounterController = EncounterController.new()
	add_child(counter_controller)
	counter_controller.start_encounter(counter_run, counter_enemy, PieceGenerator.new(31337))
	var counter_health_before: int = counter_run.player_health
	counter_controller._resolve_enemy_step(ClearResult.new())
	checks.equal(counter_run.player_statuses.get_status(after_action_status).remaining_turns, 2, "After-action status duration does not advance when the enemy countdown remains active")
	counter_controller._resolve_enemy_step(ClearResult.new())
	checks.equal(counter_run.player_health, counter_health_before - failure_damage.amount, "An incomplete counter resolves its failure effect before the enemy action")
	checks.equal(counter_run.player_statuses.get_status(after_action_status).remaining_turns, 1, "After-action status duration advances after an enemy action executes")
	checks.truthy(counter_controller.active_counter != null and not counter_controller.active_counter.resolved, "The next selected enemy action creates its counter immediately")
	var delay_effect: DelayEnemyAttackEffect = DelayEnemyAttackEffect.new()
	delay_effect.placements = 1
	delay_effect.maximum_over_base = 2
	var delay_counter: CounterDefinition = CounterDefinition.new()
	delay_counter.display_name = "Delay Test"
	delay_counter.success_effects = [delay_effect]
	var completed_counter: ActiveCounterState = ActiveCounterState.new()
	completed_counter.definition = delay_counter
	completed_counter.is_completed = true
	completed_counter.required_progress = 1
	counter_controller.active_counter = completed_counter
	counter_controller.active_counter_definition = delay_counter
	counter_controller.enemy_countdown = 1
	counter_controller._resolve_counter_if_ready()
	checks.equal(counter_controller.enemy_countdown, counter_enemy.attack_interval + delay_effect.placements, "Counter delay effects apply on top of the reset attack interval")
	counter_controller.queue_free()
	var lethal_clear_run: RunState = RunState.new()
	var defeated_action_damage: DamageEffect = DamageEffect.new()
	defeated_action_damage.target = EffectTarget.Value.PLAYER
	defeated_action_damage.amount = 4
	var defeated_action_counter: CounterDefinition = CounterDefinition.new()
	defeated_action_counter.display_name = "Defeated Action"
	defeated_action_counter.counter_type = CounterType.Value.USE_COUNTER_ITEM
	defeated_action_counter.duration_turns = 1
	defeated_action_counter.failure_effects = [defeated_action_damage]
	var defeated_action: EnemyActionDefinition = EnemyActionDefinition.new()
	defeated_action.display_name = "Defeated Enemy Action"
	defeated_action.counter_definition = defeated_action_counter
	var lethal_clear_enemy: EnemyDefinition = EnemyDefinition.new()
	lethal_clear_enemy.display_name = "Lethal Clear Test Enemy"
	lethal_clear_enemy.maximum_health = 1
	lethal_clear_enemy.attack_interval = 20
	lethal_clear_enemy.possible_actions = [defeated_action]
	var lethal_clear_controller: EncounterController = EncounterController.new()
	lethal_clear_controller.deck_rules = _unscaled_deck_rules(lethal_clear_controller.deck_rules)
	add_child(lethal_clear_controller)
	lethal_clear_controller.start_encounter(lethal_clear_run, lethal_clear_enemy, PieceGenerator.new(1775))
	var health_before_lethal_clear: int = lethal_clear_run.player_health
	var lethal_action_clear_row: int = lethal_clear_controller.board.height - 1
	for column: int in range(1, lethal_clear_controller.board.width):
		lethal_clear_controller.board.set_cell(Vector2i(column, lethal_action_clear_row), 1)
	_prepare_controller_card(lethal_clear_controller, _card(399, MONOMINO_PIECE))
	lethal_clear_controller.place(Vector2i(0, lethal_action_clear_row))
	checks.equal(lethal_clear_controller.state, EncounterController.TurnState.ENCOUNTER_WON, "A lethal clear wins before the defeated enemy can act")
	checks.equal(lethal_clear_run.player_health, health_before_lethal_clear, "A defeated enemy's pending counter action deals no damage")
	checks.truthy(lethal_clear_controller.active_counter != null and not lethal_clear_controller.active_counter.resolved, "A defeated enemy's counter deadline does not resolve")
	lethal_clear_controller.queue_free()
	var simultaneous_run: RunState = RunState.new()
	simultaneous_run.player_health = 1
	var lethal_status: StatusDefinition = StatusDefinition.new()
	lethal_status.tick_phase = StatusTickPhase.Value.END_PLAYER_TURN
	lethal_status.tick_amount = 1
	simultaneous_run.player_statuses.apply_status(lethal_status, lethal_status)
	var simultaneous_enemy: EnemyDefinition = EnemyDefinition.new()
	simultaneous_enemy.display_name = "Simultaneous Lethal Test Enemy"
	simultaneous_enemy.maximum_health = 1
	simultaneous_enemy.attack_interval = 20
	var simultaneous_controller: EncounterController = EncounterController.new()
	simultaneous_controller.deck_rules = _unscaled_deck_rules(simultaneous_controller.deck_rules)
	add_child(simultaneous_controller)
	simultaneous_controller.start_encounter(simultaneous_run, simultaneous_enemy, PieceGenerator.new(1776))
	var encounter_won: Array[bool] = [false]
	var run_lost: Array[bool] = [false]
	simultaneous_controller.encounter_won.connect(func() -> void: encounter_won[0] = true)
	simultaneous_controller.run_lost.connect(func(_reason: String) -> void: run_lost[0] = true)
	var lethal_clear_row: int = simultaneous_controller.board.height - 1
	for column: int in range(1, simultaneous_controller.board.width):
		simultaneous_controller.board.set_cell(Vector2i(column, lethal_clear_row), 1)
	simultaneous_controller.board.set_cell(Vector2i(simultaneous_controller.board.width - 1, lethal_clear_row - 1), 1)
	_prepare_controller_card(simultaneous_controller, _card(400, MONOMINO_PIECE))
	simultaneous_controller.place(Vector2i(0, lethal_clear_row))
	checks.equal(simultaneous_run.player_health, 0, "End-turn status damage remains lethal on an enemy-killing clear")
	checks.truthy(run_lost[0], "Simultaneous lethal damage ends the run")
	checks.falsy(encounter_won[0], "Simultaneous lethal damage does not award an encounter victory")
	simultaneous_controller.queue_free()

func _test_electrified_stuns() -> void:
	var status_collection: StatusCollection = StatusCollection.new()
	status_collection.apply_status(ELECTRIFIED_STATUS, ELECTRIFIED_STATUS, 9, 4)
	status_collection.apply_status(ELECTRIFIED_STATUS, ELECTRIFIED_STATUS, 5, 2)
	var electrified_instance: StatusInstance = status_collection.get_status(ELECTRIFIED_STATUS)
	checks.equal(electrified_instance.remaining_turns, 1, "Electrified duration is capped at one round")
	checks.equal(electrified_instance.stacks, 1, "Electrified never gains additional stacks")
	checks.truthy(status_collection.has_control_effect(StatusControlEffect.Value.STUN), "Electrified exposes typed stun control")
	electrified_instance.remaining_turns = 9
	var restored_statuses: StatusCollection = StatusCollection.from_save_data(status_collection.to_save_data())
	checks.truthy(restored_statuses.has_control_effect(StatusControlEffect.Value.STUN), "Electrified stun survives save and restore")
	checks.equal(restored_statuses.get_status(ELECTRIFIED_STATUS).remaining_turns, 1, "Restored statuses respect their configured duration cap")
	var additive_status: StatusDefinition = StatusDefinition.new()
	additive_status.default_duration_turns = 1
	additive_status.maximum_duration_turns = 1
	additive_status.stacking_rule = StatusStackingRule.Value.ADD_DURATION
	var additive_statuses: StatusCollection = StatusCollection.new()
	additive_statuses.apply_status(additive_status, additive_status, 1)
	additive_statuses.apply_status(additive_status, additive_status, 1)
	checks.equal(additive_statuses.get_status(additive_status).remaining_turns, 1, "Additive duration stacking cannot exceed the configured maximum")
	var enemy_run: RunState = RunState.new()
	var enemy: EnemyDefinition = EnemyDefinition.new()
	enemy.display_name = "Electrical Test Enemy"
	enemy.maximum_health = 100
	enemy.attack_interval = 1
	enemy.direct_damage = 3
	var enemy_stun_controller: EncounterController = EncounterController.new()
	enemy_stun_controller.deck_rules = _unscaled_deck_rules(enemy_stun_controller.deck_rules)
	add_child(enemy_stun_controller)
	checks.truthy(enemy_stun_controller.start_encounter(enemy_run, enemy, PieceGenerator.new(4401)), "Enemy stun test encounter starts")
	var preserved_counter: ActiveCounterState = ActiveCounterState.new()
	preserved_counter.definition = CounterDefinition.new()
	preserved_counter.turns_remaining = 2
	preserved_counter.required_progress = 1
	enemy_stun_controller.active_counter = preserved_counter
	enemy_stun_controller.active_counter_definition = preserved_counter.definition
	enemy_stun_controller.effect_state.enemy_statuses.apply_status(ELECTRIFIED_STATUS, ELECTRIFIED_STATUS, 1)
	var enemy_stun_health_before: int = enemy_run.player_health
	var countdown_before_stun: int = enemy_stun_controller.enemy_countdown
	checks.truthy(enemy_stun_controller._resolve_enemy_step(ClearResult.new()), "Enemy stun resolves as a valid skipped move")
	checks.equal(enemy_run.player_health, enemy_stun_health_before, "Enemy stun prevents attack damage")
	checks.equal(enemy_stun_controller.enemy_countdown, countdown_before_stun, "Enemy stun preserves the current countdown")
	checks.falsy(preserved_counter.is_failed or preserved_counter.resolved, "Enemy stun preserves the active counter")
	checks.falsy(enemy_stun_controller.effect_state.enemy_statuses.has_control_effect(StatusControlEffect.Value.STUN), "Enemy stun is consumed after one skipped move")
	enemy_stun_controller.active_counter = null
	enemy_stun_controller.active_counter_definition = null
	enemy_stun_controller._resolve_enemy_step(ClearResult.new())
	checks.equal(enemy_run.player_health, enemy_stun_health_before - enemy.direct_damage, "Enemy attacks normally after its one skipped move")
	enemy_stun_controller.queue_free()
	var stasis_charge: ItemDefinition = load("res://content/items/slowing_flask.tres") as ItemDefinition
	var stasis_effect: ApplyStatusEffect = stasis_charge.effects[0] as ApplyStatusEffect
	checks.truthy(stasis_effect != null and stasis_effect.status == ELECTRIFIED_STATUS and stasis_effect.target == EffectTarget.Value.ENEMY, "Stasis Charge applies Electrified to the enemy")
	var player_run: RunState = RunState.new()
	var player_stun_controller: EncounterController = EncounterController.new()
	player_stun_controller.deck_rules = _unscaled_deck_rules(player_stun_controller.deck_rules)
	player_stun_controller.game_rules = player_stun_controller.game_rules.duplicate(true) as GameRules
	player_stun_controller.game_rules.perfect_clear_shield = 0
	add_child(player_stun_controller)
	checks.truthy(player_stun_controller.start_encounter(player_run, enemy, PieceGenerator.new(4402)), "Player stun test encounter starts")
	var clear_row: int = player_stun_controller.board.height - 1
	for column: int in range(1, player_stun_controller.board.width):
		player_stun_controller.board.place_piece(Vector2i(column, clear_row), PieceInstance.new(MONOMINO_PIECE))
	for row: int in range(clear_row):
		player_stun_controller.board.place_piece(Vector2i(0, row), PieceInstance.new(MONOMINO_PIECE))
	var electrified_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	electrified_rng.seed = 4403
	player_stun_controller.board.electrify_random_blocks(2, electrified_rng)
	var active_card: PieceCardState = _card(900, MONOMINO_PIECE)
	_prepare_controller_card(player_stun_controller, active_card)
	player_stun_controller.deck_state.draw_pile = [
		_card(901, MONOMINO_PIECE),
		_card(902, MONOMINO_PIECE),
		_card(903, MONOMINO_PIECE),
		_card(904, MONOMINO_PIECE),
		_card(905, MONOMINO_PIECE),
	]
	player_stun_controller.maximum_placement_points = 4
	player_stun_controller.placement_points_remaining = 3
	var player_health_before: int = player_run.player_health
	var turn_before_stun: int = player_stun_controller.turn_number
	player_stun_controller.place(Vector2i(0, clear_row))
	checks.truthy(player_stun_controller.last_clear_result.cross_clear and player_stun_controller.last_clear_result.perfect_clear, "Cross and perfect clear cleansing resolve before the electrical stun")
	checks.equal(player_stun_controller.last_clear_result.electrified_block_count, 2, "Multiple electrified Blocks report one player stun event")
	checks.equal(player_run.player_health, player_health_before - enemy.direct_damage, "Electrified clear advances the enemy exactly once")
	checks.equal(player_stun_controller.turn_number, turn_before_stun + 1, "Electrified clear ends the remaining player turn")
	checks.equal(player_stun_controller.placement_points_remaining, player_stun_controller.maximum_placement_points, "A fresh placement economy starts after player stun")
	checks.falsy(player_run.player_statuses.has_control_effect(StatusControlEffect.Value.STUN), "Player stun is consumed after ending one turn")
	checks.equal(player_stun_controller.state, EncounterController.TurnState.AWAITING_PLACEMENT, "Player regains control after one stunned round")
	player_stun_controller.queue_free()
	var player_stun_effect: ApplyStatusEffect = ApplyStatusEffect.new()
	player_stun_effect.status = ELECTRIFIED_STATUS
	player_stun_effect.duration_turns = 1
	player_stun_effect.target = EffectTarget.Value.PLAYER
	var player_stun_action: EnemyActionDefinition = EnemyActionDefinition.new()
	player_stun_action.display_name = "Test Shock"
	player_stun_action.direct_damage = 2
	player_stun_action.effects = [player_stun_effect]
	player_stun_action.applied_statuses = [ELECTRIFIED_STATUS]
	var control_enemy: EnemyDefinition = EnemyDefinition.new()
	control_enemy.display_name = "Control Test Enemy"
	control_enemy.maximum_health = 100
	control_enemy.attack_interval = 1
	control_enemy.possible_actions = [player_stun_action]
	control_enemy.fallback_action = player_stun_action
	var redraw_stun_run: RunState = RunState.new()
	var redraw_stun_controller: EncounterController = EncounterController.new()
	redraw_stun_controller.deck_rules = _unscaled_deck_rules(redraw_stun_controller.deck_rules)
	add_child(redraw_stun_controller)
	checks.truthy(redraw_stun_controller.start_encounter(redraw_stun_run, control_enemy, PieceGenerator.new(4404)), "Redraw stun test encounter starts")
	var redraw_health_before: int = redraw_stun_run.player_health
	var redraw_turn_before: int = redraw_stun_controller.turn_number
	redraw_stun_controller.redraw_hand()
	checks.equal(redraw_stun_run.player_health, redraw_health_before - player_stun_action.direct_damage, "A redraw-triggered stun advances the enemy exactly once")
	checks.equal(redraw_stun_controller.turn_number, redraw_turn_before + 1, "A redraw-triggered stun ends the remaining player turn")
	checks.falsy(redraw_stun_run.player_statuses.has_control_effect(StatusControlEffect.Value.STUN), "A redraw-triggered stun is consumed after one round")
	checks.equal(redraw_stun_controller.state, EncounterController.TurnState.AWAITING_PLACEMENT, "Control returns after a redraw-triggered stun")
	redraw_stun_controller.queue_free()
	var pass_stun_run: RunState = RunState.new()
	var pass_stun_controller: EncounterController = EncounterController.new()
	pass_stun_controller.deck_rules = _unscaled_deck_rules(pass_stun_controller.deck_rules)
	add_child(pass_stun_controller)
	checks.truthy(pass_stun_controller.start_encounter(pass_stun_run, control_enemy, PieceGenerator.new(4407)), "Pass stun test encounter starts")
	var pass_health_before: int = pass_stun_run.player_health
	var pass_turn_before: int = pass_stun_controller.turn_number
	pass_stun_controller.end_player_turn()
	checks.equal(pass_stun_run.player_health, pass_health_before - player_stun_action.direct_damage * 2, "A pass-triggered stun skips the next placement round before the enemy moves again")
	checks.equal(pass_stun_controller.turn_number, pass_turn_before + 2, "A pass-triggered stun advances through one stunned round")
	checks.falsy(pass_stun_run.player_statuses.has_control_effect(StatusControlEffect.Value.STUN), "A pass-triggered stun is consumed instead of refreshing forever")
	checks.equal(pass_stun_controller.state, EncounterController.TurnState.AWAITING_PLACEMENT, "Control returns after a pass-triggered stunned round")
	pass_stun_controller.queue_free()
	var twin_stun_run: RunState = RunState.new()
	var twin_stun_controller: EncounterController = EncounterController.new()
	twin_stun_controller.deck_rules = _unscaled_deck_rules(twin_stun_controller.deck_rules)
	add_child(twin_stun_controller)
	checks.truthy(twin_stun_controller.start_encounter(twin_stun_run, control_enemy, PieceGenerator.new(4405)), "Twin skip stun test encounter starts")
	twin_stun_controller.twin_core_second_placement = true
	twin_stun_controller.pending_enemy_step_after_twin = true
	var twin_health_before: int = twin_stun_run.player_health
	var twin_turn_before: int = twin_stun_controller.turn_number
	checks.truthy(twin_stun_controller.skip_twin_core_placement(), "Twin Core secondary placement can be skipped")
	checks.equal(twin_stun_run.player_health, twin_health_before - player_stun_action.direct_damage, "Twin Core skip resolves one enemy move before the stun ends the turn")
	checks.equal(twin_stun_controller.turn_number, twin_turn_before + 1, "Twin Core skip stun advances to one fresh turn")
	checks.falsy(twin_stun_controller.twin_core_second_placement or twin_stun_controller.pending_enemy_step_after_twin, "Twin Core state is cleared after its pending move applies stun")
	twin_stun_controller.queue_free()
	var item_stun_run: RunState = RunState.new()
	var self_stun_item: ItemDefinition = ItemDefinition.new()
	self_stun_item.display_name = "Test Conductor"
	self_stun_item.effects = [player_stun_effect]
	var self_stun_stack: ItemStack = ItemStack.new()
	self_stun_stack.definition = self_stun_item
	item_stun_run.inventory.slots[0] = self_stun_stack
	var item_stun_controller: EncounterController = EncounterController.new()
	item_stun_controller.deck_rules = _unscaled_deck_rules(item_stun_controller.deck_rules)
	add_child(item_stun_controller)
	checks.truthy(item_stun_controller.start_encounter(item_stun_run, enemy, PieceGenerator.new(4406)), "Item stun test encounter starts")
	var item_health_before: int = item_stun_run.player_health
	var item_turn_before: int = item_stun_controller.turn_number
	checks.truthy(item_stun_controller.use_item(0).used, "A configurable item can Electrify the player")
	checks.equal(item_stun_run.player_health, item_health_before - enemy.direct_damage, "A player-targeted item stun advances the enemy exactly once")
	checks.equal(item_stun_controller.turn_number, item_turn_before + 1, "A player-targeted item stun ends the current turn without a second enemy move")
	checks.falsy(item_stun_run.player_statuses.has_control_effect(StatusControlEffect.Value.STUN), "A player-targeted item stun is consumed after one round")
	var capsule_stack: ItemStack = ItemStack.new()
	capsule_stack.definition = BLOCK_CAPSULE_ITEM
	capsule_stack.bonus_piece = MONOMINO_PIECE
	item_stun_run.inventory.slots[0] = capsule_stack
	item_stun_controller.twin_core_second_placement = true
	var blocked_capsule_result: ItemUseResult = item_stun_controller.use_item(0)
	checks.falsy(blocked_capsule_result.used or item_stun_controller.bonus_placement_mode, "Bonus Blocks cannot interrupt a Twin Core secondary placement")
	checks.truthy(item_stun_run.inventory.slots[0] == capsule_stack, "A Twin-blocked Bonus Block remains in inventory")
	item_stun_controller.queue_free()

func _prepare_controller_card(controller: EncounterController, card: PieceCardState) -> void:
	controller.deck_state = EncounterDeckState.new()
	controller.deck_state.hand = [card]
	controller.placement_points_remaining = 1
	controller.hand_placeable = [true]
	controller.active_card_index = 0
	controller.active_card = card
	controller.active_piece = PieceInstance.new()
	controller.active_piece.bind_card(card)
	controller.active_piece.source_type = PieceSourceType.Value.DRAWN_CARD
	controller.state = EncounterController.TurnState.AWAITING_PLACEMENT

func _unscaled_deck_rules(source: DeckRules) -> DeckRules:
	var rules: DeckRules = source.duplicate(true) as DeckRules
	rules.base_enemy_health_multiplier = 1.0
	rules.enemy_health_bonus_per_effect_weight = 0.0
	rules.maximum_effect_deck_health_bonus = 0.0
	return rules

func _test_save_format() -> void:
	checks.truthy(ContentRegistry.catalog != null and not ContentRegistry.catalog.all_definitions().is_empty(), "The typed content catalog is available at runtime")
	SaveService.save_profile()
	checks.truthy(FileAccess.file_exists("user://profile.json"), "Profile file is generated")
	var file: FileAccess = FileAccess.open("user://profile.json", FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	checks.truthy(parsed is Dictionary, "Profile is valid JSON")
	var data: Dictionary = parsed as Dictionary
	checks.equal(int(data.get("version", 0)), SaveService.SAVE_VERSION, "Save version is written")

func _test_progression() -> void:
	var profile: ProfileState = ProfileState.new()
	profile.fragments = 100
	var service: ProgressionService = ProgressionService.new(ContentRegistry.upgrades)
	var core: UpgradeDefinition = preload("res://content/upgrades/reinforced_core.tres")
	checks.equal(service.get_next_level_cost(profile, core), 3, "Explicit first upgrade cost")
	var result: PurchaseResult = service.purchase_upgrade(profile, core)
	checks.truthy(result.success, "Upgrade purchase succeeds")
	checks.equal(profile.fragments, 97, "Purchase deducts Fragments")
	checks.equal(profile.total_fragments_spent, 3, "Purchase records spending")
	checks.equal(profile.get_upgrade_level(core), 1, "Purchase increments level")
	var original_profile: ProfileState = SaveService.profile
	SaveService.profile = profile
	checks.truthy(SaveService.save_profile(), "Purchased permanent upgrade writes immediately")
	var persisted_profile: Dictionary = SaveService._read_verified_json(SaveService.PROFILE_PATH, ProfileState.SCHEMA)
	checks.equal(ProfileState.from_save_data(persisted_profile).get_upgrade_level(core), 1, "Permanent upgrade level survives profile serialization")
	SaveService.profile = original_profile
	SaveService.save_profile()
	var modifiers: StartingRunModifiers = service.resolve_starting_modifiers(profile)
	checks.equal(modifiers.maximum_health_bonus, 2, "Purchased health resolves")
	var snapshot_profile: ProfileState = ProfileState.new()
	snapshot_profile.unlocked_pieces.append(TET_L_PIECE)
	snapshot_profile.unlocked_enemies.append(MASON_ENEMY)
	var content_snapshot: StartingRunModifiers = service.resolve_starting_modifiers(snapshot_profile)
	snapshot_profile.unlocked_pieces.clear()
	snapshot_profile.unlocked_enemies.clear()
	checks.truthy(content_snapshot.unlocked_pieces.has(TET_L_PIECE) and content_snapshot.unlocked_enemies.has(MASON_ENEMY), "Run modifiers retain an independent snapshot of permanent content unlocks")
	var reserve: UpgradeDefinition = preload("res://content/upgrades/last_reserve.tres")
	checks.falsy(service.can_purchase(profile, reserve).allowed, "Prerequisite blocks purchase")
	service.purchase_upgrade(profile, core)
	service.purchase_upgrade(profile, core)
	profile.fragments = reserve.get_cost_for_level(0)
	checks.truthy(service.can_purchase(profile, reserve).allowed, "Prerequisite level unlocks purchase")
	profile.fragments = 0
	checks.falsy(service.can_purchase(profile, reserve).allowed, "Insufficient currency blocks purchase")
	var unlock_profile: ProfileState = ProfileState.new()
	unlock_profile.fragments = 1000
	var archives: Array[UpgradeDefinition] = [preload("res://content/upgrades/shape_archive_i.tres"), preload("res://content/upgrades/shape_archive_ii.tres"), preload("res://content/upgrades/shape_archive_iii.tres"), preload("res://content/upgrades/shape_archive_iv.tres"), preload("res://content/upgrades/shape_archive_v.tres"), preload("res://content/upgrades/shape_archive_vi.tres"), preload("res://content/upgrades/shape_archive_vii.tres")]
	var archive_pieces: Array[PieceDefinition] = [preload("res://content/pieces/tri_v.tres"), preload("res://content/pieces/tet_p.tres"), preload("res://content/pieces/pent_l.tres"), preload("res://content/pieces/pent_u.tres"), preload("res://content/pieces/pent_w.tres"), preload("res://content/pieces/pent_cross.tres"), preload("res://content/pieces/pent_t.tres")]
	var archive_costs: Array[int] = [20, 25, 30, 40, 50, 65, 80]
	for index: int in archives.size():
		var archive: UpgradeDefinition = archives[index]
		checks.truthy(archive.is_valid(), "Block archive upgrade is registered: %s" % archive.display_name)
		checks.equal(archive.get_cost_for_level(0), archive_costs[index], "Piece Blueprint uses its reduced Fragment cost: %s" % archive.display_name)
		var unlock_effect: UnlockContentEffect = archive.effects[0] as UnlockContentEffect
		checks.equal(unlock_effect.pieces, [archive_pieces[index]], "Each archive unlocks exactly one Block")
		var piece_definition: PieceDefinition = archive_pieces[index]
		checks.truthy(piece_definition.is_valid() and not piece_definition.initially_unlocked, "Archive Block starts permanently locked: %s" % piece_definition.display_name)
		if index + 1 < archives.size():
			checks.falsy(service.can_purchase(unlock_profile, archives[index + 1]).allowed, "The next Block archive stays locked until the current one is purchased")
		checks.truthy(service.purchase_upgrade(unlock_profile, archive).success, "Block archive purchase succeeds: %s" % archive.display_name)
		checks.truthy(unlock_profile.unlocked_pieces.has(archive_pieces[index]), "Purchased archive permanently unlocks its Block")
	checks.equal(unlock_profile.fragments, 690, "The complete sequential Piece Blueprint chain costs 310 Fragments")
	var damage_upgrade: UpgradeDefinition = preload("res://content/upgrades/damage_calibration.tres")
	checks.truthy(damage_upgrade != null and damage_upgrade.is_valid(), "Permanent damage upgrade is registered")
	var damage_profile: ProfileState = ProfileState.new()
	var damage_costs: Array[int] = [20, 90, 300]
	damage_profile.fragments = 410
	for level: int in 3:
		checks.equal(service.get_next_level_cost(damage_profile, damage_upgrade), damage_costs[level], "Damage upgrade level %d uses its explicit cost" % (level + 1))
		checks.truthy(service.purchase_upgrade(damage_profile, damage_upgrade).success, "Damage upgrade level %d can be purchased" % (level + 1))
	checks.equal(damage_profile.fragments, 0, "Three Line Impact levels cost 410 Fragments total")
	var damage_modifiers: StartingRunModifiers = service.resolve_starting_modifiers(damage_profile)
	checks.equal(damage_modifiers.damage_modifiers[0].stacks, 3, "Three permanent damage levels grant a three-stack damage modifier")
	var restored_damage_modifiers: StartingRunModifiers = StartingRunModifiers.from_save_data(damage_modifiers.to_save_data())
	checks.equal(restored_damage_modifiers.damage_modifiers[0].stacks, 3, "Permanent damage modifier serializes")
	checks.equal(restored_damage_modifiers.damage_modifiers[0].source, damage_upgrade, "Permanent damage modifier keeps its trace source after serialization")
	var redraw_upgrade: UpgradeDefinition = preload("res://content/upgrades/second_look.tres")
	var showcase_upgrade: UpgradeDefinition = preload("res://content/upgrades/larger_showcase.tres")
	var reward_reroll_upgrade: UpgradeDefinition = preload("res://content/upgrades/reward_insight.tres")
	checks.equal(redraw_upgrade.max_level, 4, "Redraw Reserve contains all four redraw levels")
	checks.equal(showcase_upgrade.max_level, 1, "Wider Draft has one level")
	checks.equal(showcase_upgrade.get_cost_for_level(0), 15, "Wider Draft retains its original first-level Fragment cost")
	checks.equal(reward_reroll_upgrade.max_level, 1, "Reward Reroll has one level")
	checks.truthy(showcase_upgrade.final_level_requires_full_area, "Wider Draft requires its complete usable Matrix area")
	checks.falsy(reward_reroll_upgrade.final_level_requires_full_area, "Reward Reroll retains its authored partial-area threshold")
	checks.truthy(showcase_upgrade.board_level_thresholds.is_empty(), "Wider Draft does not retain a partial-area milestone")
	checks.equal(reward_reroll_upgrade.board_level_thresholds, PackedInt32Array([30]), "Reward Reroll preserves its former first-level Matrix requirement")
	var board_rules: UpgradeBoardRules = UpgradeBoardRules.load_default()
	checks.equal(board_rules.default_level_thresholds, PackedInt32Array([20, 50, 90, 140, 200]), "Matrix thresholds back-load higher upgrade levels")
	checks.equal(ContentRegistry.upgrades.size(), 27, "Removed upgrades are absent from the content catalog")
	checks.equal(board_rules.region_slots.size(), 27, "The themed Matrix contains every retained upgrade")
	var previous_threshold: int = 0
	var previous_threshold_cost: int = 0
	for threshold: int in board_rules.default_level_thresholds:
		var threshold_cost: int = threshold - previous_threshold
		checks.truthy(threshold_cost > previous_threshold_cost, "Each default Matrix level costs more cells than the previous level")
		previous_threshold = threshold
		previous_threshold_cost = threshold_cost
	var blueprint_upgrades: Array[UpgradeDefinition] = [
		preload("res://content/upgrades/shape_archive_i.tres"),
		preload("res://content/upgrades/shape_archive_ii.tres"),
		preload("res://content/upgrades/shape_archive_iii.tres"),
		preload("res://content/upgrades/shape_archive_iv.tres"),
		preload("res://content/upgrades/shape_archive_v.tres"),
		preload("res://content/upgrades/shape_archive_vi.tres"),
		preload("res://content/upgrades/shape_archive_vii.tres"),
	]
	var blueprint_slots: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 4, 5, 10])
	for blueprint_index: int in blueprint_upgrades.size():
		var actual_slot: int = -1
		for region_slot: UpgradeBoardRegionSlot in board_rules.region_slots:
			if region_slot.upgrade == blueprint_upgrades[blueprint_index]:
				actual_slot = region_slot.slot_index
				break
		checks.equal(actual_slot, blueprint_slots[blueprint_index], "Piece Blueprints remain grouped on the Matrix")
	var foundry: UpgradeBoardShopService = UpgradeBoardShopService.new()
	checks.equal(foundry.calculate_piece_price(MONOMINO_PIECE), 4, "The reduced Foundry price starts at four Fragments")
	checks.equal(foundry.calculate_piece_price(DOMINO_PIECE), 7, "The reduced Foundry price charges three Fragments for the second cell")
	var elite_upgrade: UpgradeDefinition = preload("res://content/upgrades/spawn_more_elites.tres")
	checks.truthy(elite_upgrade != null and elite_upgrade.is_valid(), "Elite Routes permanent upgrade is registered")
	checks.equal(elite_upgrade.get_cost_for_level(0), 200, "Elite Routes costs 200 Fragments")
	var elite_profile: ProfileState = ProfileState.new()
	elite_profile.fragments = 200
	checks.truthy(service.purchase_upgrade(elite_profile, elite_upgrade).success, "Elite Routes can be purchased")
	var elite_modifiers: StartingRunModifiers = service.resolve_starting_modifiers(elite_profile)
	checks.equal(elite_modifiers.elite_nodes_per_route_bonus, 2, "Elite Routes snapshots two additional Elite nodes")
	checks.equal(StartingRunModifiers.from_save_data(elite_modifiers.to_save_data()).elite_nodes_per_route_bonus, 2, "Elite route bonus survives run serialization")
	var upgraded_run: RunState = RunState.new()
	upgraded_run.apply_starting_modifiers(damage_modifiers, 20)
	checks.equal(upgraded_run.modifiers.damage_modifiers[0].stacks, 3, "New runs apply the permanent damage modifier")
	var upgraded_clear: ClearResult = ClearResult.new()
	upgraded_clear.line_count = 2
	var upgraded_damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(upgraded_run, EncounterEffectState.new(), upgraded_clear, 0, GameRules.new()))
	checks.equal(upgraded_damage.modifier_bonus, 6, "Level-three Line Impact adds +3 damage per cleared line")
	var boss_profile: ProfileState = ProfileState.new()
	var boss_run: RunState = RunState.new()
	boss_run.run_sequence = 71001
	var boss_node: RouteNodeState = RouteNodeState.new()
	boss_node.act = 1
	boss_node.type = RouteNodeState.NodeType.BOSS
	SaveService.profile = boss_profile
	checks.equal(SaveService.award_boss_fragments(boss_run, boss_node, 10), 10, "Act boss immediately awards configured Fragments")
	checks.equal(SaveService.award_boss_fragments(boss_run, boss_node, 10), 0, "Resuming cannot duplicate a claimed boss reward")
	checks.equal(boss_profile.fragments, 10, "Boss reward reaches the permanent Fragment balance")
	checks.equal(ProfileState.from_save_data(boss_profile.to_save_data()).claimed_boss_rewards.size(), 1, "Boss reward claim survives profile serialization")
	SaveService.profile = original_profile
	SaveService.save_profile()
	var fragment_rules: ProgressionRules = ProgressionRules.new()
	boss_run.enemies_defeated = 5
	checks.equal(fragment_rules.calculate_run_fragments(boss_run, false, 1.0), fragment_rules.normal_enemy_fragments * 3 + fragment_rules.elite_enemy_fragments + fragment_rules.first_enemy_victory_fragments, "Run-end payout includes the first victory bonus without duplicating immediate boss Fragments")

	var standard_difficulty: DifficultyDefinition = preload("res://content/difficulties/standard.tres")
	var pressured_difficulty: DifficultyDefinition = preload("res://content/difficulties/pressured.tres")
	checks.equal(ContentRegistry.difficulties[0], standard_difficulty, "Difficulty catalog starts with Standard progression")
	var difficulty_profile: ProfileState = ProfileState.new()
	SaveService.profile = difficulty_profile
	SaveService._unlock_next_difficulty(standard_difficulty)
	checks.truthy(difficulty_profile.unlocked_difficulties.has(pressured_difficulty), "Winning Standard unlocks the next configured difficulty")
	checks.equal(difficulty_profile.highest_difficulty_completed, 1, "Difficulty completion tracks the configured progression index")
	var difficulty_run: RunState = RunState.new()
	difficulty_run.difficulty = pressured_difficulty
	checks.equal(SaveService._fragment_reward_multiplier(difficulty_run), pressured_difficulty.fragment_reward_multiplier, "Difficulty Fragment multiplier applies to run and boss payouts")
	SaveService.profile = original_profile
	SaveService.save_profile()

func _test_migrations_and_active_save() -> void:
	var old: Dictionary = {"version": 1, "meta_currency": 7, "unknown_future_field": "kept"}
	var migrated: Dictionary = SaveMigrationService.new().migrate_profile(old)
	checks.equal(int(migrated.get("version", 0)), ProfileState.CURRENT_VERSION, "Migrations reach current version")
	checks.equal(int(migrated.get("fragments", 0)), 7, "Legacy currency migrates")
	checks.equal(String(migrated.get("unknown_future_field", "")), "kept", "Unknown fields survive migration")
	var daily_migration: Dictionary = ProfileMigration7To8.new().migrate({"version": 7, "daily_history": [{"date": "2026-07-10", "practice": false}, {"date": "2026-07-11", "practice": true}]})
	checks.equal(daily_migration.get("ranked_daily_attempt_dates", []), ["2026-07-10"], "Profile migration preserves completed ranked Daily attempts")
	var upgrade_migration: Dictionary = ProfileMigration8To9.new().migrate({
		"version": 8,
		"upgrade_progress": [
			{"upgrade": ProfileMigration8To9.REDRAW_UID, "level": 2},
			{"upgrade": ProfileMigration8To9.CONTROLLED_REDRAW_UID, "level": 1},
			{"upgrade": ProfileMigration8To9.EXPANDED_FOUNDATION_UID, "level": 1},
		],
	})
	var upgrade_migration_profile: ProfileState = ProfileState.from_save_data(upgrade_migration)
	var redraw_upgrade: UpgradeDefinition = preload("res://content/upgrades/second_look.tres")
	checks.equal(upgrade_migration_profile.get_upgrade_level(redraw_upgrade), 3, "Upgrade migration combines both former redraw upgrades")
	checks.equal(upgrade_migration_profile.upgrade_progress.size(), 1, "Upgrade migration removes Expanded Foundation")
	var future: Dictionary = SaveMigrationService.new().migrate_profile({"version": 999})
	checks.truthy(future.is_empty(), "Future save version is rejected")
	var run: RunState = RunState.new()
	run.seed_value = 7654
	run.player_health = 10
	checks.truthy(SaveService.save_active_run({"run_state": run.to_save_data(), "rng": PieceGenerator.new(7654).to_save_data(), "ended": false}), "Atomic active run save")
	checks.truthy(SaveService.has_valid_active_run(), "Active run validates")
	checks.truthy(SaveService.save_active_run({"run_state": run.to_save_data(), "rng": PieceGenerator.new(7654).to_save_data(), "ended": false}), "Atomic replacement succeeds")
	checks.truthy(FileAccess.file_exists(SaveService.ACTIVE_RUN_BACKUP_PATH), "Atomic replacement retains backup")
	var saved_encounter_deck: EncounterDeckState = EncounterDeckState.new()
	saved_encounter_deck.hand = [_card(701, MONOMINO_PIECE, PRISM_GUARD_EFFECT)]
	var encounter_data: Dictionary = {"enemy_id": "mason", "board": BoardState.new(2, 2).to_save_data(), "deck_state": saved_encounter_deck.to_save_data(), "active_card_id": 701}
	checks.truthy(SaveService.save_active_run({"run_state": run.to_save_data(), "rng": PieceGenerator.new(7654).to_save_data(), "encounter": encounter_data, "ended": false}), "Fight checkpoint saves")
	checks.truthy(SaveService.has_resumable_encounter(), "Saved encounter is recognized as a resumable fight")
	var hub: HubScreen = (load("res://scenes/hub/hub_screen.tscn") as PackedScene).instantiate() as HubScreen
	add_child(hub)
	checks.truthy((hub.get_node("Margin/Layout/Dashboard/ExpeditionCard/Expedition/Actions/ResumeFight") as Button).visible, "Progression hub shows Resume Fight for an interrupted encounter")
	checks.falsy((hub.get_node("Margin/Layout/Dashboard/ExpeditionCard/Expedition/Actions/ContinueRun") as Button).visible, "Generic continue action is hidden while a fight can resume")
	checks.truthy(SaveService.save_active_run({"run_state": run.to_save_data(), "rng": PieceGenerator.new(7654).to_save_data(), "reward": {"reward_ids": ["overflow"], "selected": false}, "ended": false}), "Post-fight reward checkpoint saves separately")
	hub.refresh()
	checks.falsy((hub.get_node("Margin/Layout/Dashboard/ExpeditionCard/Expedition/Actions/ResumeFight") as Button).visible, "Resume Fight is hidden after combat has ended")
	checks.truthy((hub.get_node("Margin/Layout/Dashboard/ExpeditionCard/Expedition/Actions/ContinueRun") as Button).visible, "Continue Run resumes non-combat checkpoints")
	var requested_difficulties: Array[DifficultyDefinition] = []
	var daily_requests: Array[bool] = []
	hub.new_run_requested.connect(func(difficulty: DifficultyDefinition) -> void: requested_difficulties.append(difficulty))
	hub.daily_requested.connect(func() -> void: daily_requests.append(true))
	var new_run_button: Button = hub.get_node("Margin/Layout/Dashboard/ExpeditionCard/Expedition/Actions/NewRun") as Button
	var daily_button: Button = hub.get_node("Margin/Layout/Dashboard/DailyCard/DailyLayout/Daily") as Button
	var replacement_dialog: ConfirmationDialog = hub.get_node("ConfirmRunReplacement") as ConfirmationDialog
	new_run_button.pressed.emit()
	checks.truthy(replacement_dialog.visible, "New Run asks before replacing a resumable run")
	checks.equal(requested_difficulties.size(), 0, "New Run waits for replacement confirmation")
	replacement_dialog.confirmed.emit()
	replacement_dialog.hide()
	checks.equal(requested_difficulties.size(), 1, "Confirming New Run dispatches the selected difficulty")
	daily_button.pressed.emit()
	checks.truthy(replacement_dialog.visible, "Daily Run asks before replacing a resumable run")
	checks.equal(daily_requests.size(), 0, "Daily Run waits for replacement confirmation")
	replacement_dialog.confirmed.emit()
	replacement_dialog.hide()
	checks.equal(daily_requests.size(), 1, "Confirming Daily Run dispatches the request")
	SaveService.clear_active_run()
	new_run_button.pressed.emit()
	daily_button.pressed.emit()
	checks.falsy(replacement_dialog.visible, "Run replacement confirmation stays hidden without a resumable run")
	checks.equal(requested_difficulties.size(), 2, "New Run starts immediately without a resumable run")
	checks.equal(daily_requests.size(), 2, "Daily Run starts immediately without a resumable run")
	hub.queue_free()
	var original_profile_data: Dictionary = SaveService.profile.to_save_data()
	var reset_profile: ProfileState = ProfileState.new()
	reset_profile.fragments = 91
	reset_profile.completed_runs = 4
	SaveService.profile = reset_profile
	checks.truthy(SaveService.save_profile(), "Progressed profile is available before starting a new game")
	checks.truthy(SaveService.save_active_run({"run_state": run.to_save_data(), "rng": PieceGenerator.new(7654).to_save_data(), "ended": false}), "Active expedition exists before starting a new game")
	checks.truthy(SaveService.start_new_game(), "Starting a new game writes a fresh profile")
	checks.equal(SaveService.profile.fragments, 0, "New game clears permanent currency")
	checks.equal(SaveService.profile.completed_runs, 0, "New game clears progression statistics")
	checks.falsy(SaveService.has_valid_active_run(), "New game clears the current expedition")
	checks.falsy(FileAccess.file_exists(SaveService.PROFILE_BACKUP_PATH), "New game cannot restore erased progression from the old backup")
	checks.truthy(SaveService.settings.master_volume >= 0.0, "New game preserves player settings")
	SaveService.profile = ProfileState.from_save_data(original_profile_data)
	SaveService.save_profile()

func _test_routes() -> void:
	var default_route_settings: RouteGenerationSettings = (load("res://content/rules/route_generation_settings.tres") as RouteGenerationSettings).normalized()
	checks.equal(default_route_settings.branch_probability, 0.25, "Default routes use the reduced optional branch rate")
	var first: GeneratedRoute = RouteGenerator.new().generate(12345, false)
	var second: GeneratedRoute = RouteGenerator.new().generate(12345, false)
	checks.equal(first.to_save_data(), second.to_save_data(), "Route generation is deterministic")
	checks.equal(first.get_act_count(), 4, "Default route act count comes from settings")
	var default_elite_count: int = _count_elite_route_nodes(first)
	checks.truthy(default_elite_count >= default_route_settings.minimum_elite_nodes_per_route, "Route respects the configurable Elite encounter minimum")
	checks.truthy(default_elite_count <= default_route_settings.maximum_elite_nodes_per_route, "Route respects the configurable Elite encounter maximum")
	var elite_upgraded_route: GeneratedRoute = RouteGenerator.new().generate(12345, false, 2)
	checks.equal(_count_elite_route_nodes(elite_upgraded_route), default_elite_count + 2, "Elite route upgrade adds exactly two Elite encounters")
	checks.truthy(_count_elite_route_nodes(elite_upgraded_route) <= default_route_settings.maximum_elite_nodes_per_route + 2, "Elite route upgrade expands the configured maximum by two")
	for act: int in first.get_act_count():
		var shop_count: int = 0
		var boss_count: int = 0
		var boss_column: int = -1
		var fixed_path_count: int = 0
		var recovery_count: int = 0
		var fixed_shop_found: bool = false
		var fixed_recovery_found: bool = false
		for node: RouteNodeState in first.nodes:
			if node.act != act:
				continue
			checks.falsy(node.column == 0 and node.type == RouteNodeState.NodeType.SHOP, "Shop never appears in first stage")
			shop_count += 1 if node.type == RouteNodeState.NodeType.SHOP else 0
			boss_count += 1 if node.type == RouteNodeState.NodeType.BOSS else 0
			boss_column = node.column if node.type == RouteNodeState.NodeType.BOSS else boss_column
			fixed_path_count += 1 if node.type != RouteNodeState.NodeType.BOSS and node.connections.size() == 1 else 0
			if node.type == RouteNodeState.NodeType.RECOVERY:
				recovery_count += 1
				checks.truthy(node.column >= default_route_settings.earliest_recovery_stage - 1, "Recovery respects its configured earliest stage")
			fixed_shop_found = fixed_shop_found or node.fixed_room and node.column == 2 and node.type == RouteNodeState.NodeType.SHOP
			fixed_recovery_found = fixed_recovery_found or node.fixed_room and node.column == 6 and node.type == RouteNodeState.NodeType.RECOVERY
			if node.type != RouteNodeState.NodeType.BOSS:
				checks.truthy(not node.connections.is_empty(), "Route node has no dead end")
		checks.truthy(shop_count >= 1 if default_route_settings.maximum_shop_nodes_per_act > 0 else shop_count == 0, "Act shop generation matches its configured availability")
		checks.truthy(shop_count <= default_route_settings.maximum_shop_nodes_per_act, "Act respects the configurable shop maximum")
		checks.equal(boss_count, 1, "Act contains one boss")
		checks.truthy(boss_column >= default_route_settings.minimum_columns - 1 and boss_column <= default_route_settings.maximum_columns - 1, "Boss column respects the configured route length")
		checks.truthy(fixed_path_count >= 2, "Act contains fixed corridor choices")
		checks.truthy(recovery_count >= default_route_settings.minimum_recovery_nodes_per_act, "Act respects the configurable recovery minimum")
		checks.truthy(recovery_count <= default_route_settings.maximum_recovery_nodes_per_act, "Act respects the configurable recovery maximum")
		checks.truthy(fixed_shop_found and fixed_recovery_found, "Configured Shop and Recovery rooms appear in their fixed columns")
		checks.equal(first.count_connection_crossings(act), 0, "Ordered route lanes do not cross")
	for seed_value: int in 24:
		var sampled_route: GeneratedRoute = RouteGenerator.new().generate(8100 + seed_value, false)
		checks.truthy(_count_elite_route_nodes(sampled_route) >= default_route_settings.minimum_elite_nodes_per_route, "Sampled route respects the Elite encounter minimum")
		checks.truthy(_count_elite_route_nodes(sampled_route) <= default_route_settings.maximum_elite_nodes_per_route, "Sampled route respects the Elite encounter maximum")
		for act: int in sampled_route.get_act_count():
			var sampled_recoveries: int = 0
			var sampled_shops: int = 0
			for node: RouteNodeState in sampled_route.nodes:
				if node.act != act:
					continue
				if node.type == RouteNodeState.NodeType.RECOVERY:
					sampled_recoveries += 1
					checks.truthy(node.column >= default_route_settings.earliest_recovery_stage - 1, "Sampled recovery respects earliest stage")
				sampled_shops += 1 if node.type == RouteNodeState.NodeType.SHOP else 0
			checks.truthy(sampled_recoveries >= default_route_settings.minimum_recovery_nodes_per_act and sampled_recoveries <= default_route_settings.maximum_recovery_nodes_per_act, "Sampled act respects configured recovery bounds")
			checks.truthy(sampled_shops <= default_route_settings.maximum_shop_nodes_per_act, "Sampled act respects the shop maximum")
			checks.equal(sampled_route.count_connection_crossings(act), 0, "Sampled route keeps every lane connection ordered")
	var custom_settings: RouteGenerationSettings = RouteGenerationSettings.new()
	custom_settings.act_count = 2
	custom_settings.minimum_columns = 6
	custom_settings.maximum_columns = 6
	custom_settings.maximum_rows = 2
	custom_settings.minimum_corridor_length = 3
	custom_settings.maximum_corridor_length = 3
	custom_settings.minimum_recovery_nodes_per_act = 1
	custom_settings.maximum_recovery_nodes_per_act = 1
	custom_settings.earliest_recovery_stage = 4
	custom_settings.maximum_shop_nodes_per_act = 0
	custom_settings.minimum_elite_nodes_per_route = 0
	custom_settings.maximum_elite_nodes_per_route = 0
	var fixed_event_rule: RouteFixedRoomRule = RouteFixedRoomRule.new()
	fixed_event_rule.act_index = 0
	fixed_event_rule.column_index = 4
	fixed_event_rule.room_type = RouteNodeState.NodeType.EVENT
	fixed_event_rule.row_placement = RouteFixedRoomRule.RowPlacement.ENTIRE_COLUMN
	custom_settings.fixed_rooms = [fixed_event_rule]
	var custom_route: GeneratedRoute = RouteGenerator.new(custom_settings).generate(77, false)
	checks.equal(custom_route.get_act_count(), 2, "Route act count is configurable")
	checks.equal(custom_route.get_column_count(0), 6, "Route column count is configurable")
	var custom_shop_count: int = 0
	for node: RouteNodeState in custom_route.nodes:
		custom_shop_count += 1 if node.type == RouteNodeState.NodeType.SHOP else 0
		if node.type == RouteNodeState.NodeType.RECOVERY:
			checks.truthy(node.column >= 3, "Custom recovery stage is respected")
	checks.equal(custom_shop_count, 0, "Shop maximum can disable shop generation")
	checks.equal(_count_elite_route_nodes(custom_route), 0, "Elite maximum can disable Elite encounter generation")
	for fixed_event: RouteNodeState in custom_route.get_nodes_in_column(0, 4):
		checks.truthy(fixed_event.fixed_room and fixed_event.type == RouteNodeState.NodeType.EVENT, "Fixed-room rules can fill a configured column")
	for other_act_event: RouteNodeState in custom_route.get_nodes_in_column(1, 4):
		checks.falsy(other_act_event.fixed_room, "Act-specific fixed rooms do not leak into other acts")
	var restored: GeneratedRoute = GeneratedRoute.from_save_data(first.to_save_data())
	checks.equal(restored.to_save_data(), first.to_save_data(), "Route serialization round trip")
	var json_route_value: Variant = JSON.parse_string(JSON.stringify(first.to_save_data()))
	var json_route_data: Dictionary = json_route_value as Dictionary
	var json_restored: GeneratedRoute = GeneratedRoute.from_save_data(json_route_data)
	checks.equal(json_restored.to_save_data(), first.to_save_data(), "Route serialization survives JSON numeric conversion")
	var floating_route_data: Dictionary = first.to_save_data().duplicate(true)
	for node_value: Variant in floating_route_data.get("nodes", []) as Array:
		var floating_node_data: Dictionary = node_value as Dictionary
		var floating_connections: Array = floating_node_data.get("connections", []) as Array
		for connection_index: int in floating_connections.size():
			floating_connections[connection_index] = float(floating_connections[connection_index])
	var floating_restored: GeneratedRoute = GeneratedRoute.from_save_data(floating_route_data)
	checks.equal(floating_restored.to_save_data(), first.to_save_data(), "Route loading accepts floating-point connection indices from disk")

func _test_shops() -> void:
	var run: RunState = RunState.new()
	run.shards = 100
	run.player_health = 10
	run.maximum_health = 20
	run.starting_modifiers.shop_discount = 0.15
	var service: ShopService = ShopService.new()
	var shop_node: RouteNodeState = RouteNodeState.new()
	shop_node.type = RouteNodeState.NodeType.SHOP
	var first: ShopState = service.generate_shop(4321, shop_node, run, ContentRegistry.relics)
	var second: ShopState = service.generate_shop(4321, shop_node, run, ContentRegistry.relics)
	checks.equal(first.to_save_data(), second.to_save_data(), "Shop inventory is deterministic")
	checks.falsy(first.has_board_pieces(), "Route shops never contain permanent Upgrade Board pieces")
	var heal: ShopItem
	var consumable: ShopItem
	var has_relic: bool = false
	for item: ShopItem in first.items:
		if item.type == ShopItem.ItemType.HEAL:
			heal = item
		elif item.type == ShopItem.ItemType.RELIC:
			has_relic = true
		elif item.type == ShopItem.ItemType.CONSUMABLE and item.item != preload("res://content/items/block_capsule.tres") and consumable == null:
			consumable = item
	checks.truthy(has_relic, "Route shops generate relic offers")
	checks.truthy(consumable != null, "Route shops generate potion or item offers")
	checks.truthy(heal != null, "Route shops generate a healing service")
	checks.truthy(service.purchase(consumable, run), "Potion shop purchase succeeds")
	var purchased_stack: ItemStack
	for stack: ItemStack in run.inventory.slots:
		if stack != null and stack.definition == consumable.item:
			purchased_stack = stack
	checks.truthy(purchased_stack != null, "Purchased potion enters run inventory")
	var saved_run: RunState = RunState.from_save_data(run.to_save_data())
	checks.equal(saved_run.inventory.to_save_data(), run.inventory.to_save_data(), "Purchased potion survives run save and load")
	checks.equal(heal.final_price, 12, "Shop discount rounds down")
	checks.truthy(service.purchase(heal, run), "Healing purchase succeeds")
	checks.equal(run.player_health, 15, "Healing purchase restores health")
	checks.falsy(service.purchase(heal, run), "Purchased item cannot repeat")
	var restored: ShopState = ShopState.from_save_data(first.to_save_data())
	checks.truthy(not restored.has_board_pieces() and restored.items.back().display_name == first.items.back().display_name, "Route ShopState survives serialization without becoming board stock")
	var block_effect_relics: Array[RelicDefinition] = [preload("res://content/relics/ember_brand.tres"), FRACTURE_RELIC, GUARDIAN_RELIC, preload("res://content/relics/venom_geometry.tres")]
	var elite_only_relics: Array[RelicDefinition] = block_effect_relics.duplicate()
	elite_only_relics.append(FIFTH_GEAR_RELIC)
	elite_only_relics.append(TWIN_SPOOL_RECYCLER_RELIC)
	var reward_run: RunState = RunState.new()
	reward_run.route = GeneratedRoute.new()
	var reward_node: RouteNodeState = RouteNodeState.new()
	reward_node.type = RouteNodeState.NodeType.NORMAL_COMBAT
	reward_run.route.nodes.append(reward_node)
	reward_run.route.current_node = reward_node
	var normal_reward_pool: Array[RelicDefinition] = ContentRegistry.get_reward_pool(reward_run)
	for relic: RelicDefinition in elite_only_relics:
		checks.falsy(normal_reward_pool.has(relic), "Very rare relic is excluded from normal encounter rewards: %s" % relic.display_name)
	reward_node.type = RouteNodeState.NodeType.ELITE_COMBAT
	var elite_reward_pool: Array[RelicDefinition] = ContentRegistry.get_reward_pool(reward_run)
	var restricted_relics: Array[RelicDefinition] = []
	for elite_only_relic: RelicDefinition in elite_only_relics:
		restricted_relics.append(elite_only_relic)
		checks.truthy(elite_reward_pool.has(elite_only_relic), "Very rare relic appears after an Elite victory: %s" % elite_only_relic.display_name)
	var restricted_shop: ShopState = service.generate_shop(9876, shop_node, reward_run, restricted_relics)
	checks.falsy(restricted_shop.items.any(func(item: ShopItem) -> bool: return item.type == ShopItem.ItemType.RELIC), "Elite-only Block effects never appear in route shops")
	var stale_relic_offer: ShopItem = ShopItem.new()
	stale_relic_offer.type = ShopItem.ItemType.RELIC
	stale_relic_offer.relic = FRACTURE_RELIC
	stale_relic_offer.final_price = 1
	reward_run.shards = 10
	checks.falsy(service.purchase(stale_relic_offer, reward_run), "Loaded shop stock cannot bypass elite-only relic eligibility")
	checks.equal(reward_run.shards, 10, "Rejected stale relic stock does not spend Shards")
	checks.falsy(stale_relic_offer.purchased, "Rejected stale relic stock remains unpurchased")
	var removal_run: RunState = RunState.new()
	PiecePoolService.new().initialize_deck(removal_run, [_card(811, MONOMINO_PIECE), _card(812, DOMINO_PIECE), _card(813, TRI_I_PIECE)], 8)
	removal_run.add_artifact(VAULT_SHAPES_ARTIFACT, 0)
	removal_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards = [removal_run.deck_cards[0]]
	var removal_offer: ShopItem = ShopItem.new()
	removal_offer.type = ShopItem.ItemType.REMOVE_PIECE
	removal_offer.piece = MONOMINO_PIECE
	removal_offer.final_price = 1
	removal_run.shards = 1
	checks.truthy(service.purchase(removal_offer, removal_run), "Shop removal purchases use an actually removable Block shape")
	checks.equal(removal_run.shards, 0, "Shop removal deducts its configured Shard price")
	checks.truthy(removal_run.removed_pieces.has(MONOMINO_PIECE), "Purchased Block removal disables that shape for the run")
	checks.truthy(removal_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards.is_empty(), "Removing a Block shape also purges matching Vault storage")
	checks.falsy(PiecePoolService.new().get_eligible_additions(ProfileState.new(), removal_run, [], [], true).has(MONOMINO_PIECE), "Retired Block shapes stay out of later addition rewards")
	checks.falsy(PiecePoolService.new().add_piece(removal_run, MONOMINO_PIECE).changed, "The Block-pile boundary rejects re-adding a retired shape")
	var minimum_offer: ShopItem = ShopItem.new()
	minimum_offer.type = ShopItem.ItemType.REMOVE_PIECE
	minimum_offer.piece = DOMINO_PIECE
	checks.falsy(service.purchase(minimum_offer, removal_run), "Loaded removal stock cannot reduce the enabled Block pile below its minimum")
	var board_service: UpgradeBoardShopService = UpgradeBoardShopService.new()
	var profile: ProfileState = ProfileState.new()
	profile.fragments = 1000
	var unlocked_piece_count: int = 0
	for piece: PieceDefinition in ContentRegistry.pieces:
		if piece.initially_unlocked:
			unlocked_piece_count += 1
	var catalog: ShopState = board_service.generate_catalog(ContentRegistry.pieces, profile)
	checks.equal(catalog.items.size(), unlocked_piece_count, "Upgrade Board catalog includes only unlocked registered Blocks")
	checks.truthy(catalog.has_only_board_pieces(), "Upgrade Board catalog stays separate from route inventory")
	var catalog_prices_by_cell_count: Dictionary[int, int] = {}
	for item: ShopItem in catalog.items:
		var offered_piece: PieceDefinition = item.piece
		var cell_count: int = offered_piece.base_cells.size()
		if catalog_prices_by_cell_count.has(cell_count):
			checks.equal(item.final_price, catalog_prices_by_cell_count[cell_count], "Upgrade Board catalog prices match for Blocks with %d cells" % cell_count)
		else:
			catalog_prices_by_cell_count[cell_count] = item.final_price
	var catalog_piece: PieceDefinition = catalog.items[0].piece
	var quantity_before: int = profile.upgrade_piece_inventory.get_quantity(catalog_piece)
	checks.truthy(board_service.purchase_piece(catalog_piece, profile), "Matrix catalog purchase spends Fragments")
	checks.truthy(board_service.purchase_piece(catalog_piece, profile), "Matrix catalog permits repeat purchases of one shape")
	checks.equal(profile.upgrade_piece_inventory.get_quantity(catalog_piece), quantity_before + 2, "Repeat catalog purchases add both Blocks to the permanent reserve")

func _test_special_cells() -> void:
	var bonus_board: BoardState = BoardState.new(2, 1)
	bonus_board.set_special_cell(Vector2i(0, 0), CellType.Value.BONUS)
	checks.truthy(bonus_board.is_empty(Vector2i(0, 0)), "Bonus cell permits placement")
	bonus_board.set_cell(Vector2i(0, 0), 1)
	bonus_board.set_cell(Vector2i(1, 0), 1)
	var bonus_clear: ClearResult = bonus_board.resolve_completed_lines()
	checks.equal(bonus_clear.shard_reward, 3, "Bonus clear grants Shards")
	var locked: BoardState = BoardState.new(2, 2)
	locked.set_special_cell(Vector2i.ZERO, CellType.Value.LOCKED, 2)
	checks.falsy(locked.is_empty(Vector2i.ZERO), "Locked cell denies placement")
	checks.equal(locked.count_empty_cells(), 3, "Locked cells are excluded from placeable empty-cell counts")
	locked.advance_special_cells(1)
	locked.advance_special_cells(2)
	checks.truthy(locked.is_empty(Vector2i.ZERO), "Locked cell expires")
	var target_board: BoardState = BoardState.new(1, 1)
	target_board.set_special_cell(Vector2i.ZERO, CellType.Value.TARGET, 1)
	var target_card: PieceCardState = _card(909, MONOMINO_PIECE, KINETIC_IMPACT_EFFECT)
	var target_piece: PieceInstance = PieceInstance.new()
	target_piece.bind_card(target_card)
	var target_placement: PlacementResult = target_board.place_piece(Vector2i.ZERO, target_piece)
	checks.truthy(target_placement.success and target_board.cell_values[0] == 1, "Placing on a timed target preserves its remaining duration")
	checks.equal(target_board.advance_special_cells(1), 1, "An occupied timed target expires on schedule")
	checks.truthy(target_board.is_empty(Vector2i.ZERO) and target_board.get_cell_type(Vector2i.ZERO) == CellType.Value.EMPTY, "Expired targets become normal empty cells")
	checks.truthy(target_board.occupant_pieces[0] == null and target_board.occupant_card_ids[0] == 0 and target_board.occupant_instance_ids[0] == 0, "Target expiry clears all occupant ownership metadata")
	var armor: BoardState = BoardState.new(2, 1)
	armor.set_special_cell(Vector2i.ZERO, CellType.Value.ARMORED, 2)
	armor.set_cell(Vector2i(1, 0), 1)
	var first_clear: ClearResult = armor.resolve_completed_lines()
	checks.equal(first_clear.blockers_destroyed, 0, "Armored blocker survives first clear")
	checks.equal(armor.cell_values[0], 1, "Armored durability decreases")
	armor.set_cell(Vector2i(1, 0), 2)
	var second_clear: ClearResult = armor.resolve_completed_lines()
	checks.equal(second_clear.blockers_destroyed, 1, "Armored blocker breaks on second clear")
	var corrupted: BoardState = BoardState.new(1, 1)
	corrupted.set_special_cell(Vector2i.ZERO, CellType.Value.CORRUPTED)
	corrupted.set_cell(Vector2i.ZERO, 1)
	checks.equal(corrupted.advance_special_cells(3), 1, "Occupied corruption damages every third turn")
	var restored: BoardState = BoardState.from_save_data(corrupted.to_save_data())
	checks.equal(restored.cell_types, corrupted.cell_types, "Special cells serialize")

func _test_relic_triggers_and_phases() -> void:
	var run: RunState = RunState.new()
	run.relics = [preload("res://content/relics/overflow.tres"), preload("res://content/relics/clean_geometry.tres")]
	var clear: ClearResult = ClearResult.new()
	clear.line_count = 3
	clear.cross_clear = true
	RelicTriggerService.new().resolve_after_clear(AfterClearContext.new(run, clear))
	var damage: DamageResult = CombatResolver.calculate_damage(DamageCalculationContext.for_clear(run, EncounterEffectState.new(), clear, 0, GameRules.new()))
	checks.equal(run.shards, 5, "Overflow trigger grants Shards")
	checks.equal(damage.modifier_bonus, 3, "Clean Geometry trigger adds damage")
	var architect: EnemyDefinition = ARCHITECT_ENEMY
	var controller: EncounterController = EncounterController.new()
	add_child(controller)
	var boss_run: RunState = RunState.new()
	controller.start_encounter(boss_run, architect, PieceGenerator.new(55))
	controller.enemy_health = floori(float(architect.maximum_health) * 0.6)
	controller._check_phase_transition()
	checks.equal(controller.current_phase_index, 1, "Boss crosses phase threshold")
	controller._check_phase_transition()
	checks.equal(controller.current_phase_index, 1, "Boss phase transition executes once")
	checks.equal(int(controller.to_save_data()["current_phase_index"]), 1, "Boss phase serializes")
	controller.queue_free()
	var phased_enemy: EnemyDefinition = EnemyDefinition.new()
	phased_enemy.display_name = "Effect Phase Test"
	phased_enemy.maximum_health = 100
	phased_enemy.attack_interval = 6
	var opening_phase: EnemyPhaseDefinition = EnemyPhaseDefinition.new()
	opening_phase.health_threshold_percent = 1.0
	opening_phase.attack_interval = 5
	var middle_phase: EnemyPhaseDefinition = EnemyPhaseDefinition.new()
	middle_phase.health_threshold_percent = 0.75
	middle_phase.attack_interval = 4
	var final_phase: EnemyPhaseDefinition = EnemyPhaseDefinition.new()
	final_phase.health_threshold_percent = 0.5
	final_phase.attack_interval = 3
	phased_enemy.phases = [opening_phase, middle_phase, final_phase]
	var phased_run: RunState = RunState.new()
	phased_run.difficulty = preload("res://content/difficulties/pressured.tres") as DifficultyDefinition
	var phased_controller: EncounterController = EncounterController.new()
	phased_controller.deck_rules = _unscaled_deck_rules(phased_controller.deck_rules)
	add_child(phased_controller)
	phased_controller.start_encounter(phased_run, phased_enemy, PieceGenerator.new(4455))
	checks.equal(phased_controller.enemy_countdown, 4, "Difficulty modifies the opening boss phase interval")
	var effect_counter_definition: CounterDefinition = CounterDefinition.new()
	effect_counter_definition.display_name = "Effect Damage Counter"
	effect_counter_definition.counter_type = CounterType.Value.DEAL_DAMAGE
	effect_counter_definition.required_progress = 10
	var effect_counter_state: ActiveCounterState = CounterService.new().create(effect_counter_definition, phased_enemy, phased_controller.board, RandomNumberGenerator.new())
	phased_controller.active_counter = effect_counter_state
	phased_controller.active_counter_definition = effect_counter_definition
	var effect_damage: DamageEffect = DamageEffect.new()
	effect_damage.target = EffectTarget.Value.ENEMY
	effect_damage.amount = 55
	var phase_card_effect: PieceCardEffectDefinition = PieceCardEffectDefinition.new()
	phase_card_effect.display_name = "Phase Strike"
	phase_card_effect.description = "Test phase damage"
	phase_card_effect.effects = [effect_damage]
	var phase_card: PieceCardState = _card(991, MONOMINO_PIECE, phase_card_effect)
	phased_controller.effect_state.enemy_statuses.apply_status(phased_controller.regeneration_status, phased_enemy, 2)
	phased_controller._sync_effect_state_from_controller()
	var phase_damage_result: EffectResult = effect_damage.apply(phased_controller._create_effect_context(phase_card_effect, EffectTarget.Value.ENEMY))
	phased_controller._apply_card_effect_result(phase_card, phase_damage_result)
	checks.truthy(effect_counter_state.resolved and effect_counter_state.is_completed, "Effect damage resolves a completed counter before replacing the boss phase")
	checks.equal(phased_controller.current_phase_index, 2, "One large effect hit advances through every crossed boss phase")
	checks.equal(phased_controller.enemy_countdown, 2, "Difficulty remains applied to the final crossed phase interval")
	checks.equal(phased_controller.effect_state.enemy_base_interval, 2, "Delay-effect caps track the current difficulty-adjusted phase interval")
	checks.equal(phased_controller.effect_state.enemy_statuses.get_status(phased_controller.regeneration_status), null, "Large non-clear damage interrupts enemy Regeneration")
	phased_controller.queue_free()

func _test_daily_mode() -> void:
	var seed_one: int = DailyChallengeService.get_seed_for_date("2026-07-11")
	var seed_two: int = DailyChallengeService.get_seed_for_date("2026-07-11")
	checks.equal(seed_one, seed_two, "Daily seed is stable")
	var daily: RunState = DailyChallengeService.create_daily_run("2026-07-11", false)
	checks.truthy(daily.daily_mode, "Daily run is marked")
	checks.equal(daily.run_mode, RunMode.Value.DAILY, "Daily runs use the dedicated run mode")
	checks.equal(daily.daily_date_key, "2026-07-11", "Daily run stores its challenge date independently of completion time")
	checks.equal(daily.starting_modifiers.maximum_health_bonus, 0, "Daily disables permanent modifiers")
	checks.falsy(daily.daily_practice, "Official daily attempt is distinct")
	var restored_daily: RunState = RunState.from_save_data(daily.to_save_data())
	checks.equal(restored_daily.daily_date_key, daily.daily_date_key, "Daily challenge date survives run serialization")
	checks.equal(DailyChallengeService.infer_date_key(seed_one, 1783771200000), "2026-07-11", "Legacy Daily saves recover their original date from the run sequence")
	var daily_main: Control = (load("res://scenes/main/main.tscn") as PackedScene).instantiate() as Control
	var daily_profile: ProfileState = daily_main.call("_run_content_profile") as ProfileState
	checks.truthy(daily_profile != SaveService.profile and daily_profile.unlocked_pieces.is_empty() and daily_profile.unlocked_enemies.is_empty() and daily_profile.unlocked_events.is_empty(), "Daily content eligibility ignores permanent collection unlocks")
	var original_profile: ProfileState = SaveService.profile
	SaveService.profile = ProfileState.new()
	checks.truthy(SaveService.claim_ranked_daily_attempt("2026-07-11"), "Starting a ranked Daily persists its attempt claim")
	checks.truthy(bool(daily_main.call("_has_daily_attempt", "2026-07-11")), "A persisted Daily claim survives replacement of the active run")
	daily.player_health = 1
	daily.bosses_defeated = 3
	var daily_record: RunRecordResult = SaveService.record_run(daily, false, "Daily test")
	checks.truthy(daily_record.success and daily_record.fragments_earned == 0, "A zero-fragment Daily result reports successful persistence")
	checks.equal(SaveService.profile.daily_history.back().date, "2026-07-11", "Daily history records the run's original date even after the calendar changes")
	checks.equal(SaveService.profile.run_history.back().bosses_defeated, 3, "Run history records every defeated boss instead of inferring one from victory")
	var saved_daily_profile: ProfileState = ProfileState.from_save_data(SaveService.profile.to_save_data())
	checks.truthy(saved_daily_profile.has_ranked_daily_attempt("2026-07-11"), "Ranked Daily attempt claims survive profile serialization")
	SaveService.profile = original_profile
	SaveService.save_profile()
	daily_main.free()

func _test_boss_artifacts() -> void:
	checks.equal(ContentRegistry.artifacts.size(), 9, "Expanded Boss Artifact set loads from content resources")
	for definition: BossArtifactDefinition in ContentRegistry.artifacts:
		checks.truthy(definition.is_valid() and not definition.effects.is_empty(), "Boss Artifact validates: %s" % definition.display_name)
	var run: RunState = RunState.new()
	run.seed_value = 24680
	var first_offers: Array[BossArtifactDefinition] = ArtifactRewardGenerator.new().generate(run, ARCHITECT_ENEMY, 0, 3)
	var second_offers: Array[BossArtifactDefinition] = ArtifactRewardGenerator.new().generate(run, ARCHITECT_ENEMY, 0, 3)
	checks.equal(first_offers, second_offers, "Fixed run seeds reproduce Boss Artifact offers")
	checks.equal(first_offers.size(), 3, "Boss reward generates three distinct Artifact offers")
	checks.truthy(run.add_artifact(first_offers[0], 0), "Run accepts a unique Boss Artifact")
	checks.falsy(run.add_artifact(first_offers[0], 1), "Boss Artifacts cannot stack")
	var excluded_offers: Array[BossArtifactDefinition] = ArtifactRewardGenerator.new().generate(run, ARCHITECT_ENEMY, 1, 3)
	var owned_excluded: bool = true
	for definition: BossArtifactDefinition in excluded_offers:
		owned_excluded = owned_excluded and definition != first_offers[0]
	checks.truthy(owned_excluded, "Owned Boss Artifacts are excluded from later rewards")
	var capped_run: RunState = RunState.new()
	checks.truthy(capped_run.add_artifact(ContentRegistry.artifacts[0], 0) and capped_run.add_artifact(ContentRegistry.artifacts[1], 1) and capped_run.add_artifact(ContentRegistry.artifacts[2], 2), "Run accepts the configured maximum of three Boss Artifacts")
	checks.falsy(capped_run.add_artifact(ContentRegistry.artifacts[3], 3), "Run rejects Boss Artifacts beyond the configured maximum")
	var runtime_state: BossArtifactState = run.get_artifact_state(first_offers[0])
	runtime_state.trigger_counter = 2
	runtime_state.remaining_encounter_uses = 1
	runtime_state.stored_cards = [_card(501, MONOMINO_PIECE, KINETIC_IMPACT_EFFECT)]
	var restored: RunState = RunState.from_save_data(run.to_save_data())
	var restored_state: BossArtifactState = restored.get_artifact_state(first_offers[0])
	checks.equal(restored_state.trigger_counter, 2, "Artifact trigger counters survive run saves")
	checks.equal(restored_state.stored_cards[0].piece, MONOMINO_PIECE, "Artifact stored cards preserve their Block shape")
	checks.equal(restored_state.stored_cards[0].intrinsic_effect, KINETIC_IMPACT_EFFECT, "Artifact stored cards preserve their intrinsic effect")
	var legacy_vault_state: BossArtifactState = BossArtifactState.from_save_data({"artifact_id": "vault_shapes", "stored_piece_id": "mono"})
	checks.equal(legacy_vault_state.stored_cards[0].piece, MONOMINO_PIECE, "Legacy single-slot Vault saves migrate into typed card storage")
	var warden_run: RunState = RunState.new()
	warden_run.add_artifact(WARDEN_PRISM_ARTIFACT, 0)
	var enemy: EnemyDefinition = TRAINING_SLIME_ENEMY
	var controller: EncounterController = EncounterController.new()
	add_child(controller)
	controller.start_encounter(warden_run, enemy, PieceGenerator.new(314))
	checks.equal(controller.deck_state.hand.size(), 5, "Warden's Prism increases the normal draw from four to five")
	controller.queue_free()
	var overclocked_run: RunState = RunState.new()
	overclocked_run.add_artifact(OVERCLOCKED_FEED_ARTIFACT, 0)
	var overclocked_controller: EncounterController = EncounterController.new()
	add_child(overclocked_controller)
	overclocked_controller.start_encounter(overclocked_run, enemy, PieceGenerator.new(315))
	checks.equal(overclocked_controller.deck_state.hand.size(), 5, "Overclocked Feed draws five pieces")
	checks.equal(overclocked_controller.maximum_placement_points, 5, "Overclocked Feed grants five PM")
	checks.equal(overclocked_controller.current_redraw_placement_point_cost(), 2, "Overclocked Feed makes redraws cost two PM")
	var overclocked_countdown_before_redraw: int = overclocked_controller.enemy_countdown
	overclocked_controller.redraw_hand()
	checks.equal(overclocked_controller.placement_points_remaining, 3, "Overclocked Feed spends both PM charged for a redraw")
	checks.equal(overclocked_controller.enemy_countdown, overclocked_countdown_before_redraw - 2, "A two-PM redraw advances two enemy countdown steps")
	overclocked_controller.placement_points_remaining = 1
	for cell_index: int in overclocked_controller.board.cells.size():
		overclocked_controller.board.cells[cell_index] = overclocked_controller.board.next_piece_value
	overclocked_controller.board.cells[0] = BoardState.EMPTY
	overclocked_controller.deck_state.hand = [_card(710, TET_O_PIECE)]
	overclocked_controller.deck_state.draw_pile = [_card(711, MONOMINO_PIECE)]
	overclocked_controller.deck_state.discard_pile.clear()
	overclocked_controller.deck_state.in_play.clear()
	var locked_overclocked_checkpoint: Dictionary = overclocked_controller.to_save_data()
	var locked_overclocked_run_data: Dictionary = overclocked_run.to_save_data()
	overclocked_controller._continue_player_turn()
	checks.equal(overclocked_controller.turn_number, 2, "An unaffordable redraw cannot lock an Overclocked Feed turn")
	checks.equal(overclocked_controller.placement_points_remaining, 5, "Auto-ending an inaccessible hand restores the next turn's PM")
	overclocked_controller.queue_free()
	var restored_overclocked_run: RunState = RunState.from_save_data(locked_overclocked_run_data)
	var restored_overclocked_controller: EncounterController = EncounterController.new()
	add_child(restored_overclocked_controller)
	restored_overclocked_controller.start_encounter(restored_overclocked_run, enemy, PieceGenerator.new(317))
	checks.truthy(restored_overclocked_controller.restore_from_save(locked_overclocked_checkpoint), "An inaccessible Overclocked Feed hand restores successfully")
	checks.equal(restored_overclocked_controller.turn_number, 2, "Restoring an unaffordable redraw state automatically advances to a playable turn")
	checks.equal(restored_overclocked_controller.placement_points_remaining, 5, "The normalized restored turn has all Overclocked Feed PM")
	restored_overclocked_controller.queue_free()
	var closed_loop_run: RunState = RunState.new()
	closed_loop_run.add_artifact(CLOSED_LOOP_HOPPER_ARTIFACT, 0)
	var closed_loop_controller: EncounterController = EncounterController.new()
	add_child(closed_loop_controller)
	closed_loop_controller.start_encounter(closed_loop_run, enemy, PieceGenerator.new(316))
	checks.equal(closed_loop_controller.deck_state.hand.size(), 4, "Closed-Loop Hopper keeps the standard four-piece draw")
	checks.equal(closed_loop_controller.maximum_placement_points, 3, "Closed-Loop Hopper reduces the turn to three PM")
	checks.equal(closed_loop_controller.current_redraw_placement_point_cost(), 0, "Closed-Loop Hopper grants one free redraw each turn")
	closed_loop_controller.redraw_hand()
	checks.equal(closed_loop_controller.placement_points_remaining, 3, "Closed-Loop Hopper's first redraw preserves PM")
	checks.equal(closed_loop_controller.current_redraw_placement_point_cost(), 1, "Closed-Loop Hopper's later redraws use the standard PM cost")
	checks.falsy(closed_loop_run.add_artifact(OVERCLOCKED_FEED_ARTIFACT, 1), "Closed-Loop Hopper excludes the incompatible Overclocked Feed")
	closed_loop_controller.queue_free()
	var architect_run: RunState = RunState.new()
	architect_run.add_artifact(ARCHITECT_HAND_ARTIFACT, 0)
	var architect_board: BoardState = BoardState.new(10, 10)
	var service: ArtifactService = ArtifactService.new()
	var architect_hand_effect: ArchitectHandEffect = ARCHITECT_HAND_ARTIFACT.effects[0] as ArchitectHandEffect
	var test_piece: PieceDefinition = architect_hand_effect.generated_piece
	var archlord_result: ArtifactEffectContext
	for index: int in 3:
		archlord_result = service.after_piece_placement(architect_run, architect_board, RandomNumberGenerator.new(), test_piece, PieceSourceType.Value.DRAWN_CARD)
	checks.equal(architect_board.count_empty_cells(), 99, "Archlord's Hand adds one valid cell every third placement")
	var ignited_cell: Vector2i = Vector2i(-1, -1)
	for y: int in architect_board.height:
		for x: int in architect_board.width:
			var candidate_cell: Vector2i = Vector2i(x, y)
			if architect_board.get_cell(candidate_cell) >= 0:
				ignited_cell = candidate_cell
				break
		if ignited_cell.x >= 0:
			break
	checks.truthy(ignited_cell.x >= 0, "Archlord's Hand exposes its spawned Monoblock cell")
	if ignited_cell.x >= 0:
		var ignited_index: int = ignited_cell.y * architect_board.width + ignited_cell.x
		checks.equal(architect_board.occupant_pieces[ignited_index], architect_hand_effect.generated_piece, "Archlord's Hand records its spawned Block as a Monoblock")
		checks.equal(int(architect_board.occupant_source_types[ignited_index]), int(PieceSourceType.Value.ARTIFACT_GENERATED), "Archlord's Hand records its Monoblock as Artifact-generated")
		checks.truthy(architect_board.get_occupant_modifiers(ignited_cell).has(architect_hand_effect.fire_visual_modifier), "Archlord's Hand marks its Monoblock with the Fire visual")
	var archlord_fire_visual: PieceModifierDefinition = architect_hand_effect.fire_visual_modifier
	checks.truthy(archlord_fire_visual != null and archlord_fire_visual.has_board_effect_marker(), "Archlord Fire registers a board effect marker")
	checks.truthy(archlord_fire_visual != null and archlord_fire_visual.effects.is_empty(), "Archlord Fire's board marker does not duplicate its gameplay damage")
	var fire_definition: StatusDefinition = preload("res://content/statuses/archlord_fire.tres")
	checks.equal(archlord_result.enemy_status, fire_definition, "Archlord's Hand applies its Fire status")
	checks.equal(archlord_result.enemy_status_duration, 3, "Archlord's Hand Fire lasts three turns")
	var archlord_definition: BossArtifactDefinition = ARCHITECT_HAND_ARTIFACT
	checks.equal(archlord_definition.display_name, "Archlord's Hand", "Archlord's Hand uses its updated name")
	checks.truthy(archlord_definition.drawback.is_empty(), "Archlord's Hand has no drawback text")
	var fire_state: EncounterEffectState = EncounterEffectState.new()
	fire_state.enemy_health = 10
	fire_state.enemy_maximum_health = 10
	fire_state.enemy_statuses.apply_status(fire_definition, ARCHITECT_HAND_ARTIFACT, 3)
	var fire_context: EffectContext = EffectContext.new()
	fire_context.target = EffectTarget.Value.ENEMY
	fire_context.encounter_state = fire_state
	for turn: int in 3:
		StatusResolver.new().tick(fire_state.enemy_statuses, StatusTickPhase.Value.START_PLAYER_TURN, fire_context)
	checks.equal(fire_state.enemy_health, 7, "Archlord Fire deals one damage for each of three turns")
	checks.truthy(fire_state.enemy_statuses.get_status(fire_definition) == null, "Archlord Fire expires after its third tick")
	var twin_run: RunState = RunState.new()
	twin_run.add_artifact(TWIN_CORE_ARTIFACT, 0)
	var twin_board: BoardState = BoardState.new(10, 10)
	for index: int in 4:
		service.after_piece_placement(twin_run, twin_board, RandomNumberGenerator.new(), test_piece, PieceSourceType.Value.DRAWN_CARD)
	checks.truthy(twin_run.get_artifact_state(TWIN_CORE_ARTIFACT).ready, "Twin Core becomes ready every fourth placement")
	var twin_flow_run: RunState = RunState.new()
	twin_flow_run.add_artifact(TWIN_CORE_ARTIFACT, 0)
	var slow_enemy: EnemyDefinition = EnemyDefinition.new()
	slow_enemy.display_name = "Slow Test"
	slow_enemy.maximum_health = 1000
	slow_enemy.attack_interval = 20
	var twin_controller: EncounterController = EncounterController.new()
	add_child(twin_controller)
	twin_controller.start_encounter(twin_flow_run, slow_enemy, PieceGenerator.new(43))
	var countdown_before_twin: int = 0
	var normal_placements: int = 0
	var total_placements: int = 0
	while normal_placements < 4 and total_placements < 8:
		normal_placements += 1
		if normal_placements == 4:
			countdown_before_twin = twin_controller.enemy_countdown
		var origin: Vector2i = _find_valid_piece_origin(twin_controller.board, twin_controller.active_piece)
		twin_controller.place(origin)
		total_placements += 1
	checks.equal(normal_placements, 4, "Twin Core counts four primary deck-card placements")
	checks.truthy(twin_controller.twin_core_second_placement, "Twin Core opens an optional second placement on its fourth trigger")
	checks.equal(twin_controller.enemy_countdown, countdown_before_twin, "Twin Core does not advance the enemy before the second placement decision")
	twin_controller.skip_twin_core_placement()
	checks.equal(twin_controller.enemy_countdown, countdown_before_twin - 1, "Twin Core advances the enemy exactly once after its second-placement window")
	twin_controller.queue_free()
	var resume_run: RunState = RunState.new()
	resume_run.add_artifact(ARCHITECT_HAND_ARTIFACT, 0)
	var resume_controller: EncounterController = EncounterController.new()
	add_child(resume_controller)
	var resume_generator: PieceGenerator = PieceGenerator.new(72)
	resume_controller.start_encounter(resume_run, slow_enemy, resume_generator)
	resume_run.get_artifact_state(ARCHITECT_HAND_ARTIFACT).trigger_counter = 2
	resume_controller.placement_points_remaining = 2
	resume_controller.free_redraws_remaining_this_turn = 1
	resume_controller.enemy_countdown = slow_enemy.attack_interval + 3
	var encounter_checkpoint: Dictionary = resume_controller.to_save_data()
	var saved_counter: ActiveCounterState = ActiveCounterState.new()
	saved_counter.definition = preload("res://content/counters/row_sever.tres") as CounterDefinition
	saved_counter.turns_remaining = 2
	saved_counter.target_rows = PackedInt32Array([3])
	encounter_checkpoint["active_counter"] = saved_counter.to_save_data()
	var generator_checkpoint: Dictionary = resume_generator.to_save_data()
	var loaded_resume_run: RunState = RunState.from_save_data(resume_run.to_save_data())
	var loaded_controller: EncounterController = EncounterController.new()
	add_child(loaded_controller)
	var loaded_generator: PieceGenerator = PieceGenerator.new(72)
	loaded_generator.restore(generator_checkpoint)
	var restored_counters: Array[ActiveCounterState] = []
	var restore_safe_points: Array[Dictionary] = []
	loaded_controller.counter_changed.connect(func(counter: ActiveCounterState, _definition: CounterDefinition) -> void: restored_counters.append(counter))
	loaded_controller.safe_point_reached.connect(func(data: Dictionary) -> void: restore_safe_points.append(data))
	checks.truthy(loaded_controller.restore_encounter(loaded_resume_run, slow_enemy, loaded_generator, encounter_checkpoint), "Interrupted fight restores without starting a replacement encounter")
	checks.equal(loaded_resume_run.get_artifact_state(ARCHITECT_HAND_ARTIFACT).trigger_counter, 2, "Interrupted fight resume restores Artifact counters after encounter initialization")
	checks.equal(loaded_controller.placement_points_remaining, 2, "Interrupted fight resume restores remaining placement points")
	checks.equal(loaded_controller.free_redraws_remaining_this_turn, 1, "Interrupted fight resume restores per-turn free redraws")
	checks.equal(loaded_controller.enemy_countdown, slow_enemy.attack_interval + 3, "Interrupted fight resume preserves enemy delay above the base interval")
	checks.equal(restored_counters.back(), loaded_controller.active_counter, "Restoring a fight publishes the restored counter state")
	checks.equal(restored_counters.back().target_rows, PackedInt32Array([3]), "Restored counter row markers retain their saved targets")
	checks.equal(loaded_generator.to_save_data(), generator_checkpoint, "Direct fight restoration preserves the saved future RNG sequence")
	checks.truthy(restore_safe_points.is_empty(), "Direct fight restoration does not overwrite its checkpoint while rebuilding state")
	var won_checkpoint: Dictionary = encounter_checkpoint.duplicate(true)
	won_checkpoint["state"] = int(EncounterController.TurnState.ENCOUNTER_WON)
	won_checkpoint["enemy_health"] = 0
	var won_run: RunState = RunState.from_save_data(resume_run.to_save_data())
	var won_controller: EncounterController = EncounterController.new()
	add_child(won_controller)
	checks.truthy(won_controller.restore_encounter(won_run, slow_enemy, PieceGenerator.new(72), won_checkpoint), "Terminal victory checkpoints restore successfully")
	checks.equal(won_controller.state, EncounterController.TurnState.ENCOUNTER_WON, "Terminal restore preserves the encounter victory state")
	checks.equal(won_controller.enemy_health, 0, "Terminal restore preserves zero enemy health")
	checks.equal(won_run.enemies_defeated, resume_run.enemies_defeated, "Terminal restore does not award the same enemy victory twice")
	var lost_checkpoint: Dictionary = encounter_checkpoint.duplicate(true)
	lost_checkpoint["state"] = int(EncounterController.TurnState.RUN_LOST)
	lost_checkpoint["defeat_reason"] = "No valid placements"
	var lost_controller: EncounterController = EncounterController.new()
	add_child(lost_controller)
	checks.truthy(lost_controller.restore_encounter(RunState.from_save_data(resume_run.to_save_data()), slow_enemy, PieceGenerator.new(72), lost_checkpoint), "Terminal defeat checkpoints restore successfully")
	checks.equal(lost_controller.defeat_reason, "No valid placements", "Terminal restore preserves the specific defeat reason")
	checks.equal(String(lost_controller.to_save_data()["defeat_reason"]), "No valid placements", "Resaved terminal defeats retain their specific reason")
	resume_controller.queue_free()
	loaded_controller.queue_free()
	won_controller.queue_free()
	lost_controller.queue_free()
	var time_run: RunState = RunState.new()
	time_run.add_artifact(TIMEKEEPER_GEAR_ARTIFACT, 0)
	var double_clear: ClearResult = ClearResult.new()
	double_clear.line_count = 2
	checks.equal(service.modify_enemy_countdown(time_run, double_clear, 1).countdown_step, 0, "Timekeeper pauses countdown after a two-line clear")
	var no_clear: ClearResult = ClearResult.new()
	checks.equal(service.modify_enemy_countdown(time_run, no_clear, 1).countdown_step, 2, "Timekeeper accelerates countdown after no clear")
	var momentum_run: RunState = RunState.new()
	momentum_run.add_artifact(MOMENTUM_LATTICE_ARTIFACT, 0)
	service.on_encounter_started(momentum_run, BoardState.new(), RandomNumberGenerator.new())
	var cleared_line: ClearResult = ClearResult.new()
	cleared_line.line_count = 1
	checks.falsy(service.modify_combo_resolution(momentum_run, cleared_line, 1).preserve_combo, "Momentum Lattice arms after a clear without changing successful combo resolution")
	checks.truthy(momentum_run.get_artifact_state(MOMENTUM_LATTICE_ARTIFACT).ready, "Momentum Lattice records an available grace placement")
	checks.truthy(service.modify_combo_resolution(momentum_run, no_clear, 1).preserve_combo, "Momentum Lattice preserves a combo through one no-clear placement")
	checks.falsy(service.modify_combo_resolution(momentum_run, no_clear, 1).preserve_combo, "Momentum Lattice does not preserve a second consecutive no-clear placement")
	var mold_run: RunState = RunState.new()
	mold_run.add_artifact(INFINITE_MOLD_ARTIFACT, 0)
	for index: int in 3:
		service.after_piece_placement(mold_run, BoardState.new(), RandomNumberGenerator.new(), test_piece, PieceSourceType.Value.DRAWN_CARD)
	var capsule_found: bool = false
	for stack: ItemStack in mold_run.inventory.slots:
		capsule_found = capsule_found or stack != null and stack.definition == BLOCK_CAPSULE_ITEM and stack.bonus_piece == test_piece
	checks.truthy(capsule_found, "Infinite Mold generates a capsule after three repeated Blocks")
	var vault_run: RunState = RunState.new()
	vault_run.add_artifact(VAULT_SHAPES_ARTIFACT, 0)
	var vault_service: VaultStorageService = VaultStorageService.new()
	var vault_card: PieceCardState = _card(601, test_piece, KINETIC_IMPACT_EFFECT)
	for turn: int in 5:
		vault_service.advance_primary_turn(vault_run)
	checks.equal(vault_service.turns_remaining(vault_run), 1, "Vault remains unavailable for its first five qualifying turns")
	checks.falsy(vault_service.can_capture(vault_run, false, false, false), "Vault cannot capture before its configured interval")
	vault_service.advance_primary_turn(vault_run)
	checks.truthy(vault_service.can_capture(vault_run, false, false, false), "Vault becomes ready on its sixth qualifying turn")
	checks.truthy(vault_service.capture(vault_run, vault_card), "A charged Vault captures one discarded card")
	checks.equal(vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards[0], vault_card, "Vault stores the captured card identity")
	checks.equal(vault_service.capacity(), 1, "Vault starts with one storage slot")
	for turn: int in 6:
		vault_service.advance_primary_turn(vault_run)
	vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards.clear()
	checks.falsy(vault_service.can_capture(vault_run, false, false, true), "Vault retrieval turn cannot refill a charged Vault")
	checks.truthy(vault_service.can_capture(vault_run, false, false, false), "Charged Vault may capture on a later normal turn")
	var vault_identity_run: RunState = RunState.new()
	vault_identity_run.add_artifact(VAULT_SHAPES_ARTIFACT, 0)
	var vault_identity_cards: Array[PieceCardState] = []
	for card_id: int in range(730, 738):
		vault_identity_cards.append(_card(card_id, MONOMINO_PIECE))
	PiecePoolService.new().initialize_deck(vault_identity_run, vault_identity_cards, 8)
	var vaulted_identity_card: PieceCardState = vault_identity_run.deck_cards[0]
	vault_identity_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards = [vaulted_identity_card]
	var vault_identity_controller: EncounterController = EncounterController.new()
	add_child(vault_identity_controller)
	vault_identity_controller.start_encounter(vault_identity_run, enemy, PieceGenerator.new(912))
	checks.falsy(_card_ids(vault_identity_controller.deck_state.all_cards()).has(vaulted_identity_card.card_id), "A vaulted piece is excluded from the next encounter's draw pile")
	var identity_activation: SpecialPieceActivationResult = vault_identity_controller.use_vault_piece()
	checks.truthy(identity_activation.succeeded(), "A cross-encounter vaulted piece remains retrievable")
	if identity_activation.succeeded():
		vault_identity_controller.place(identity_activation.candidate.origin)
		checks.truthy(vault_identity_controller.deck_state.in_play.has(vaulted_identity_card), "A placed Vault piece enters the current encounter play zone")
		vault_identity_controller._discard_in_play_cards()
		checks.truthy(vault_identity_controller.deck_state.discard_pile.has(vaulted_identity_card), "A placed Vault piece joins the current encounter discard cycle")
	vault_identity_controller.queue_free()
	var returned_identity_controller: EncounterController = EncounterController.new()
	add_child(returned_identity_controller)
	returned_identity_controller.start_encounter(vault_identity_run, enemy, PieceGenerator.new(913))
	checks.truthy(_card_ids(returned_identity_controller.deck_state.all_cards()).has(vaulted_identity_card.card_id), "A placed Vault piece returns to the Block pile for later encounters")
	returned_identity_controller.queue_free()
	var vault_controller: EncounterController = EncounterController.new()
	add_child(vault_controller)
	vault_controller.start_encounter(vault_run, enemy, PieceGenerator.new(911))
	vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards = [vault_card]
	var preview_candidates: Array[PiecePlacementCandidate] = []
	vault_controller.special_preview_requested.connect(func(candidate: PiecePlacementCandidate) -> void: preview_candidates.append(candidate))
	var vault_activation: SpecialPieceActivationResult = vault_controller.use_vault_piece()
	checks.truthy(vault_activation.succeeded(), "Vault retrieval starts when its Block has a placement")
	checks.equal(preview_candidates.size(), 1, "Vault retrieval requests an immediate board preview")
	checks.truthy(preview_candidates[0].found, "Vault preview uses a valid placement candidate")
	var vault_checkpoint: Dictionary = vault_controller.to_save_data()
	var resumed_vault_run: RunState = RunState.from_save_data(vault_run.to_save_data())
	var resumed_vault_controller: EncounterController = EncounterController.new()
	add_child(resumed_vault_controller)
	resumed_vault_controller.start_encounter(resumed_vault_run, enemy, PieceGenerator.new(911))
	checks.truthy(resumed_vault_controller.restore_from_save(vault_checkpoint), "Interrupted Vault preview restores its encounter")
	checks.truthy(resumed_vault_controller.vault_piece_placement_active, "Interrupted Vault preview retains its retrieval-turn guard")
	checks.equal(resumed_vault_controller.active_piece.source_type, PieceSourceType.Value.ARTIFACT_GENERATED, "Resumed Vault Block keeps its artifact source")
	var alternate_vault_card_index: int = -1
	for card_index: int in resumed_vault_controller.deck_state.hand.size():
		if card_index != resumed_vault_controller.active_card_index and resumed_vault_controller.hand_placeable[card_index]:
			alternate_vault_card_index = card_index
			break
	checks.truthy(alternate_vault_card_index >= 0, "Vault source switching test has another placeable hand card")
	if alternate_vault_card_index >= 0:
		resumed_vault_controller.select_choice(alternate_vault_card_index)
		checks.falsy(resumed_vault_controller.vault_piece_placement_active, "Selecting a drawn card cancels the pending Vault placement")
		checks.equal(resumed_vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards[0].card_id, vault_card.card_id, "Cancelling an unplaced Vault card returns it to storage")
		checks.equal(resumed_vault_controller.active_piece.source_type, PieceSourceType.Value.DRAWN_CARD, "The selected drawn card replaces the cancelled Vault source")
		var regular_vault_candidate: PiecePlacementCandidate = resumed_vault_controller.board.find_piece_placement(resumed_vault_controller.active_piece.definition)
		checks.truthy(regular_vault_candidate.found, "The drawn card selected after a Vault Block remains placeable")
		if regular_vault_candidate.found:
			resumed_vault_controller.place(regular_vault_candidate.origin)
		checks.equal(resumed_vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards[0].card_id, vault_card.card_id, "Placing the regular card does not consume the returned Vault card")
	resumed_vault_controller.queue_free()
	vault_controller._discard_unplayed_hand(true)
	vault_controller.vault_piece_placement_active = false
	checks.truthy(vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards.is_empty(), "Vault cannot refill while its retrieved card resolves")
	var capsule_run: RunState = RunState.new()
	var capsule_definition: ItemDefinition = BLOCK_CAPSULE_ITEM
	var capsule_stack: ItemStack = ItemStack.new()
	capsule_stack.definition = capsule_definition
	capsule_stack.bonus_piece = test_piece
	capsule_stack.quantity = 1
	capsule_run.inventory.slots[0] = capsule_stack
	var capsule_controller: EncounterController = EncounterController.new()
	add_child(capsule_controller)
	capsule_controller.start_encounter(capsule_run, enemy, PieceGenerator.new(912))
	checks.truthy(capsule_controller.use_item(0).used, "Capsule begins its automatic preview flow")
	var capsule_checkpoint: Dictionary = capsule_controller.to_save_data()
	var resumed_capsule_run: RunState = RunState.from_save_data(capsule_run.to_save_data())
	var resumed_capsule_controller: EncounterController = EncounterController.new()
	add_child(resumed_capsule_controller)
	resumed_capsule_controller.start_encounter(resumed_capsule_run, enemy, PieceGenerator.new(912))
	checks.truthy(resumed_capsule_controller.restore_from_save(capsule_checkpoint), "Interrupted Capsule preview restores its encounter")
	checks.truthy(resumed_capsule_controller.bonus_placement_mode, "Resumed Capsule keeps bonus placement mode")
	checks.equal(resumed_capsule_controller.active_piece.source_type, PieceSourceType.Value.BONUS_BLOCK, "Resumed Capsule Block keeps its item source")
	checks.equal(resumed_capsule_run.inventory.slots[0].quantity, 1, "Resumed unplaced Capsule remains unconsumed")
	resumed_capsule_controller.select_choice(resumed_capsule_controller.active_card_index)
	checks.falsy(resumed_capsule_controller.bonus_placement_mode, "Selecting a drawn card cancels the pending Capsule placement")
	checks.equal(resumed_capsule_controller.active_piece.source_type, PieceSourceType.Value.DRAWN_CARD, "The selected drawn card replaces the cancelled Capsule source")
	checks.equal(resumed_capsule_run.inventory.slots[0].quantity, 1, "Switching away from a Capsule preserves its charge")
	var regular_capsule_candidate: PiecePlacementCandidate = resumed_capsule_controller.board.find_piece_placement(resumed_capsule_controller.active_piece.definition)
	checks.truthy(regular_capsule_candidate.found, "The drawn card selected after a Capsule remains placeable")
	if regular_capsule_candidate.found:
		resumed_capsule_controller.place(regular_capsule_candidate.origin)
	checks.equal(resumed_capsule_run.inventory.slots[0].quantity, 1, "Placing the drawn card does not consume the cancelled Capsule")
	capsule_controller.queue_free()
	resumed_capsule_controller.queue_free()
	vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards = [vault_card]
	for y: int in vault_controller.board.height:
		for x: int in vault_controller.board.width:
			vault_controller.board.set_cell(Vector2i(x, y), 1)
	var blocked_activation: SpecialPieceActivationResult = vault_controller.use_vault_piece()
	checks.equal(blocked_activation.status, SpecialPieceActivationStatus.Value.NO_VALID_PLACEMENT, "Vault reports when its Block has no placement")
	checks.equal(vault_run.get_artifact_state(VAULT_SHAPES_ARTIFACT).stored_cards[0].card_id, vault_card.card_id, "Failed Vault preview preserves the stored card")
	var blocked_capsule: ItemStack = ItemStack.new()
	blocked_capsule.definition = capsule_definition
	blocked_capsule.bonus_piece = test_piece
	blocked_capsule.quantity = 1
	vault_run.inventory.slots[0] = blocked_capsule
	var blocked_capsule_result: ItemUseResult = vault_controller.use_item(0)
	checks.falsy(blocked_capsule_result.used, "Capsule refuses to start when its Block has no placement")
	checks.truthy(blocked_capsule_result.message.contains("no valid placement"), "Blocked Capsule reports its placement failure")
	checks.equal(vault_run.inventory.slots[0].quantity, 1, "Blocked Capsule keeps its inventory charge")
	vault_controller.queue_free()
	var no_vault_pool: Array[RelicDefinition] = ContentRegistry.get_reward_pool(RunState.new())
	checks.falsy(no_vault_pool.has(VAULT_ACCELERATOR_RELIC), "Vault Accelerator stays out of rewards without the Vault artifact")
	var vault_reward_pool: Array[RelicDefinition] = ContentRegistry.get_reward_pool(vault_run)
	checks.truthy(vault_reward_pool.has(VAULT_ACCELERATOR_RELIC), "Vault Accelerator enters rewards after obtaining the Vault artifact")
	VAULT_ACCELERATOR_RELIC.apply(vault_run)
	checks.equal(vault_service.effective_interval(vault_run), 5, "Vault Accelerator reduces the configured storage interval")
	checks.falsy(ContentRegistry.get_reward_pool(vault_run).has(VAULT_ACCELERATOR_RELIC), "Owned Vault Accelerator leaves the non-repeatable reward pool")
	var restored_vault_run: RunState = RunState.from_save_data(vault_run.to_save_data())
	checks.equal(restored_vault_run.modifiers.vault_storage_cooldown_reduction, 1, "Vault cooldown relic effect survives run saves")
	var reward_viewport: SubViewport = SubViewport.new()
	reward_viewport.size = Vector2i(1280, 720)
	add_child(reward_viewport)
	var reward_screen: ArtifactRewardScreen = (load("res://scenes/rewards/artifact_reward_screen.tscn") as PackedScene).instantiate() as ArtifactRewardScreen
	reward_viewport.add_child(reward_screen)
	var reward_run: RunState = RunState.new()
	reward_run.seed_value = 1234
	reward_screen.start(reward_run, ARCHITECT_ENEMY, 0)
	await get_tree().process_frame
	checks.equal(reward_screen.rewards.size(), 3, "Boss Artifact reward screen presents three cards")
	checks.equal((reward_screen.get_node("Margin/Layout/Cards") as HBoxContainer).get_child_count(), 3, "Artifact reward cards show exact rule changes")
	for card_node: Node in (reward_screen.get_node("Margin/Layout/Cards") as HBoxContainer).get_children():
		var artifact_card: ArtifactRewardCard = card_node as ArtifactRewardCard
		var artifact_icon: Control = artifact_card.get_node("Layout/ArtifactIcon") as Control
		checks.truthy(artifact_card.get_global_rect().encloses(artifact_icon.get_global_rect()), "Artifact reward icons remain inside their cards")
		checks.falsy(artifact_card.has_node("Layout/Systems"), "Artifact cards omit redundant affected-system footer text")
	for artifact: BossArtifactDefinition in reward_screen.rewards:
		reward_screen._mark_artifact_viewed(artifact)
	reward_screen._select_reward(0)
	checks.equal(reward_run.artifacts.size(), 1, "Selecting an Artifact commits it immediately")
	checks.truthy(bool(reward_screen.to_save_data()["selected"]), "Artifact reward checkpoint records committed selection")
	reward_viewport.queue_free()

func _find_valid_piece_origin(board: BoardState, piece: PieceInstance) -> Vector2i:
	for y: int in board.height:
		for x: int in board.width:
			var cells: Array[Vector2i] = []
			for offset: Vector2i in piece.get_cells():
				cells.append(Vector2i(x, y) + offset)
			if board.can_place(cells):
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func _test_debug_encounter_area() -> void:
	var rules: DebugEncounterRules = load("res://content/rules/debug_encounter_rules.tres") as DebugEncounterRules
	var configuration: DebugEncounterConfiguration = DebugEncounterConfiguration.new()
	configuration.enemy = TRAINING_SLIME_ENEMY
	configuration.difficulty = HOSTILE_DIFFICULTY
	configuration.seed_value = 908172
	configuration.player_health = 27
	configuration.player_shield = 5
	configuration.board_width = 8
	configuration.board_height = 9
	configuration.pieces = [
		DebugEncounterPieceSelection.new(MONOMINO_PIECE, KINETIC_IMPACT_EFFECT),
		DebugEncounterPieceSelection.new(MONOMINO_PIECE),
	]
	configuration.items = [
		DebugEncounterItemSelection.new(BARRIER_POTION_ITEM, 2),
		DebugEncounterItemSelection.new(BLOCK_CAPSULE_ITEM, 2, TET_I_PIECE),
	]
	configuration.relics = [FIFTH_GEAR_RELIC]
	configuration.artifacts = [CLOSED_LOOP_HOPPER_ARTIFACT]
	var builder: DebugEncounterBuilder = DebugEncounterBuilder.new()
	checks.equal(builder.validate(configuration, rules, GameRules.new()), String(), "A complete typed debug encounter configuration validates")
	var invalid_artifacts: DebugEncounterConfiguration = configuration.duplicate_configuration()
	invalid_artifacts.artifacts.append(OVERCLOCKED_FEED_ARTIFACT)
	checks.truthy(not builder.validate(invalid_artifacts, rules, GameRules.new()).is_empty(), "Incompatible test artifacts are rejected before combat")
	var invalid_relic_stacks: DebugEncounterConfiguration = configuration.duplicate_configuration()
	invalid_relic_stacks.relics = [FIFTH_GEAR_RELIC, FIFTH_GEAR_RELIC]
	checks.truthy(not builder.validate(invalid_relic_stacks, rules, GameRules.new()).is_empty(), "Non-repeatable relics cannot be stacked in a test")
	var invalid_item_quantity: DebugEncounterConfiguration = configuration.duplicate_configuration()
	invalid_item_quantity.items[0].quantity = BARRIER_POTION_ITEM.maximum_stack_size + 1
	checks.truthy(not builder.validate(invalid_item_quantity, rules, GameRules.new()).is_empty(), "Item quantities above their stack limit are rejected")
	checks.equal(configuration.items[0].quantity, 2, "Duplicated test configurations retain independent typed item selections")
	var missing_bonus_piece: DebugEncounterConfiguration = configuration.duplicate_configuration()
	missing_bonus_piece.items[1].bonus_piece = null
	checks.truthy(not builder.validate(missing_bonus_piece, rules, GameRules.new()).is_empty(), "Block Capsule items require a stored Block")
	var repeatable_configuration: DebugEncounterConfiguration = configuration.duplicate_configuration()
	repeatable_configuration.relics = [SHARP_LINES_RELIC, SHARP_LINES_RELIC]
	repeatable_configuration.artifacts.clear()
	var repeatable_run: RunState = builder.create_run(repeatable_configuration, rules, GameRules.new())
	checks.truthy(repeatable_run != null and repeatable_run.relics.count(SHARP_LINES_RELIC) == 2, "Repeatable relic stacks are applied exactly as configured")
	var deterministic_rules: DebugEncounterRules = rules.duplicate(true) as DebugEncounterRules
	deterministic_rules.maximum_piece_count = configuration.pieces.size()
	deterministic_rules.default_piece_count = configuration.pieces.size()
	var first_order_configuration: DebugEncounterConfiguration = configuration.duplicate_configuration()
	first_order_configuration.artifacts.clear()
	first_order_configuration.relics = [TWIN_PREFERENCE_RELIC, SHAPE_SUPPRESSOR_RELIC]
	var second_order_configuration: DebugEncounterConfiguration = first_order_configuration.duplicate_configuration()
	second_order_configuration.relics.reverse()
	var first_order_run: RunState = builder.create_run(first_order_configuration, deterministic_rules, GameRules.new())
	var second_order_run: RunState = builder.create_run(second_order_configuration, deterministic_rules, GameRules.new())
	checks.truthy(first_order_run != null and second_order_run != null, "Order-sensitive relic constellations build successfully")
	if first_order_run != null and second_order_run != null:
		checks.equal(first_order_run.shards, second_order_run.shards, "Relic setup is independent of checkbox click order")
		checks.equal(first_order_run.deck_cards.size(), second_order_run.deck_cards.size(), "Relic setup produces a deterministic pile size")
		for card_index: int in first_order_run.deck_cards.size():
			checks.equal(first_order_run.deck_cards[card_index].piece, second_order_run.deck_cards[card_index].piece, "Relic setup preserves deterministic Block ordering")
			checks.equal(first_order_run.deck_cards[card_index].intrinsic_effect, second_order_run.deck_cards[card_index].intrinsic_effect, "Relic setup preserves deterministic Block effects")
	var debug_tutorial_events: Array[TutorialEventId.Value] = []
	var debug_tutorial_recorder: Callable = func(event: TutorialEvent) -> void:
		if event.type == TutorialEventId.Value.PIECE_ADDED_TO_POOL:
			debug_tutorial_events.append(event.type)
	TutorialService.event_published.connect(debug_tutorial_recorder)
	var cache_configuration: DebugEncounterConfiguration = configuration.duplicate_configuration()
	cache_configuration.artifacts.clear()
	cache_configuration.relics = [SMALL_SHAPE_CACHE_RELIC]
	var cache_run: RunState = builder.create_run(cache_configuration, rules, GameRules.new())
	TutorialService.event_published.disconnect(debug_tutorial_recorder)
	checks.truthy(cache_run != null and cache_run.deck_cards.size() > configuration.pieces.size(), "Acquisition relics still add Blocks to debug constellations")
	checks.truthy(debug_tutorial_events.is_empty(), "Debug relic acquisition does not publish progression tutorial events")
	var debug_run: RunState = builder.create_run(configuration, rules, GameRules.new())
	checks.truthy(debug_run != null, "Debug encounter builder creates a run")
	checks.truthy(debug_run.debug_run and debug_run.run_mode == RunMode.Value.DEBUG, "Test runs use the isolated debug mode")
	checks.equal(debug_run.seed_value, configuration.seed_value, "Test seed is authoritative")
	checks.equal(debug_run.difficulty, HOSTILE_DIFFICULTY, "Selected difficulty is authoritative")
	checks.equal(debug_run.player_health, configuration.player_health, "Configured Core health is applied")
	checks.equal(debug_run.maximum_health, configuration.player_health, "Configured Core health also sets the debug maximum")
	checks.equal(debug_run.player_shield, configuration.player_shield, "Configured starting Shield is applied")
	checks.equal(debug_run.pending_board_width, configuration.board_width, "Configured board width reaches encounter initialization")
	checks.equal(debug_run.pending_board_height, configuration.board_height, "Configured board height reaches encounter initialization")
	checks.equal(debug_run.deck_cards.size(), configuration.pieces.size(), "The exact configured Block pile is created")
	checks.equal(debug_run.deck_cards[0].piece, MONOMINO_PIECE, "Duplicate Block definitions remain in the test pile")
	checks.equal(debug_run.deck_cards[1].piece, MONOMINO_PIECE, "A second copy of the same Block remains independent")
	checks.equal(debug_run.deck_cards[0].intrinsic_effect, KINETIC_IMPACT_EFFECT, "A selected Block effect is preserved")
	checks.equal(debug_run.deck_cards[1].intrinsic_effect, null, "A filler copy of the same Block remains effect-free")
	checks.truthy(debug_run.deck_cards[0].card_id != debug_run.deck_cards[1].card_id, "Duplicate test Blocks receive unique card IDs")
	checks.truthy(debug_run.relics.has(FIFTH_GEAR_RELIC), "Selected relic is owned in the test run")
	checks.equal(debug_run.modifiers.placement_point_bonus, 1, "Relic acquisition effects apply before combat")
	checks.truthy(debug_run.get_artifact_state(CLOSED_LOOP_HOPPER_ARTIFACT) != null, "Selected artifact state is initialized")
	var barrier_stack: ItemStack
	var capsule_stack: ItemStack
	for stack: ItemStack in debug_run.inventory.slots:
		if stack != null and stack.definition == BARRIER_POTION_ITEM:
			barrier_stack = stack
		elif stack != null and stack.definition == BLOCK_CAPSULE_ITEM:
			capsule_stack = stack
	checks.truthy(barrier_stack != null and barrier_stack.quantity == 2, "Configured item quantities are loaded into the test inventory")
	checks.truthy(capsule_stack != null and capsule_stack.quantity == 2 and capsule_stack.bonus_piece == TET_I_PIECE, "Configured Block Capsules preserve their stored Block")
	var targeted_configuration: DebugEncounterConfiguration = configuration.duplicate_configuration()
	targeted_configuration.relics = [FRACTURE_RELIC]
	targeted_configuration.artifacts.clear()
	var targeted_run: RunState = builder.create_run(targeted_configuration, rules, GameRules.new())
	checks.truthy(targeted_run != null and not targeted_run.piece_modifiers.is_empty(), "Targeted relics create their Block modifier in the test run")
	checks.falsy(targeted_run.piece_modifiers[0].pending_selection, "Targeted relic selections resolve before test combat")
	checks.truthy(not targeted_run.piece_modifiers[0].target_pieces.is_empty(), "Targeted relics receive a deterministic compatible Block")
	var addition_configuration: DebugEncounterConfiguration = configuration.duplicate_configuration()
	addition_configuration.relics = [CURATORS_CHOICE_RELIC]
	addition_configuration.artifacts.clear()
	var addition_run: RunState = builder.create_run(addition_configuration, rules, GameRules.new())
	checks.truthy(addition_run != null and addition_run.pending_piece_addition == null, "Relic Block additions resolve before test combat")
	checks.equal(addition_run.deck_cards.size(), configuration.pieces.size() + 1, "A selected Block-addition relic applies its acquisition effect")
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child(viewport)
	var setup: DebugEncounterSetupScreen = (load("res://scenes/debug/debug_encounter_setup_screen.tscn") as PackedScene).instantiate() as DebugEncounterSetupScreen
	viewport.add_child(setup)
	setup.start(configuration)
	await get_tree().process_frame
	checks.equal(setup.piece_rows.size(), configuration.pieces.size(), "Setup screen creates one editable row per configured Block")
	checks.equal(setup.item_rows.size(), ContentRegistry.items.size(), "Setup screen exposes the complete item catalog")
	checks.equal(setup.relic_rows.size(), ContentRegistry.relics.size(), "Setup screen exposes the complete relic catalog")
	checks.equal(setup.artifact_rows.size(), ContentRegistry.artifacts.size(), "Setup screen exposes the complete artifact catalog")
	checks.falsy((setup.get_node("%StartTest") as Button).disabled, "A valid setup enables direct combat")
	var repeatable_relic_row_index: int = setup.relics.find(SHARP_LINES_RELIC)
	var repeatable_relic_row: DebugContentToggle = setup.relic_rows[repeatable_relic_row_index]
	var repeatable_quantity_controls: HBoxContainer = repeatable_relic_row.get_node("%QuantityControls") as HBoxContainer
	checks.truthy(repeatable_quantity_controls.visible, "Repeatable relics expose a configurable stack count")
	repeatable_relic_row.set_quantity(3, true)
	checks.equal(setup.configuration.relics.count(SHARP_LINES_RELIC), 3, "Relic stack controls update the typed test configuration")
	var barrier_item_row_index: int = setup.items.find(BARRIER_POTION_ITEM)
	var barrier_item_row: DebugContentToggle = setup.item_rows[barrier_item_row_index]
	var barrier_quantity_controls: HBoxContainer = barrier_item_row.get_node("%QuantityControls") as HBoxContainer
	checks.truthy(barrier_quantity_controls.visible, "Stackable items expose configurable quantities")
	barrier_item_row.set_quantity(1, true)
	checks.equal(setup.configuration.get_item_selection(BARRIER_POTION_ITEM).quantity, 1, "Item quantity controls update the typed test configuration")
	checks.equal((barrier_item_row.get_node("%Selected") as CheckButton).icon, BARRIER_POTION_ITEM.icon, "Item rows use their configured gameplay icons")
	var capsule_item_row_index: int = setup.items.find(BLOCK_CAPSULE_ITEM)
	var capsule_item_row: DebugContentToggle = setup.item_rows[capsule_item_row_index]
	var capsule_piece_button: Button = capsule_item_row.get_node("%Auxiliary") as Button
	checks.truthy(capsule_piece_button.visible and capsule_piece_button.text.to_upper().contains(TET_I_PIECE.display_name.to_upper()), "Block Capsule rows expose their stored Block")
	var architect_artifact_row_index: int = setup.artifacts.find(ARCHITECT_HAND_ARTIFACT)
	var architect_artifact_row: DebugContentToggle = setup.artifact_rows[architect_artifact_row_index]
	var architect_description: Label = architect_artifact_row.get_node("%Description") as Label
	checks.falsy(architect_description.text.contains(setup.artifact_drawback_label), "Artifacts without drawbacks do not render an empty drawback line")
	var first_selection: DebugEncounterPieceSelection = setup.configuration.pieces[0]
	setup.configuration.pieces[0] = null
	setup._rebuild_piece_rows()
	var malformed_piece_count: int = setup.configuration.pieces.size()
	checks.truthy((setup.piece_rows[0].get_node("%Duplicate") as Button).disabled, "Malformed Block rows disable duplication")
	setup.piece_rows[0].duplicate_requested.emit(setup.piece_rows[0])
	checks.equal(setup.configuration.pieces.size(), malformed_piece_count, "Duplicating a malformed Block row is safely ignored")
	setup.configuration.pieces[0] = first_selection
	setup._rebuild_piece_rows()
	setup.piece_rows[0].duplicate_requested.emit(setup.piece_rows[0])
	await get_tree().process_frame
	checks.equal(setup.configuration.pieces.size(), configuration.pieces.size() + 1, "The same Block can be duplicated in the setup pile")
	checks.truthy(setup.configuration.pieces[0] != setup.configuration.pieces[1], "Duplicated rows retain independent typed selections")
	checks.equal(setup.configuration.pieces[0].effect, KINETIC_IMPACT_EFFECT, "Duplicating a Block preserves its chosen effect")
	viewport.size = Vector2i(480, 800)
	await get_tree().process_frame
	checks.equal((setup.get_node("%SetupGrid") as GridContainer).columns, 2, "Test setup condenses its configuration grid on touch-sized screens")
	var blocks_scroll: ScrollContainer = setup.get_node("%BlocksScroll") as ScrollContainer
	var horizontal_scroll_start: Vector2 = blocks_scroll.get_global_rect().get_center()
	var horizontal_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	horizontal_touch.index = 72
	horizontal_touch.position = horizontal_scroll_start
	horizontal_touch.pressed = true
	setup._input(horizontal_touch)
	var horizontal_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	horizontal_drag.index = horizontal_touch.index
	horizontal_drag.position = horizontal_scroll_start + Vector2(-180.0, 0.0)
	horizontal_drag.relative = Vector2(-180.0, 0.0)
	setup._input(horizontal_drag)
	checks.truthy(blocks_scroll.scroll_horizontal > 0, "Block effect and action controls are reachable through horizontal touch scrolling")
	horizontal_touch.position = horizontal_drag.position
	horizontal_touch.pressed = false
	setup._input(horizontal_touch)
	(setup.get_node("%ItemsTab") as Button).pressed.emit()
	await get_tree().process_frame
	var item_scroll: ScrollContainer = setup.get_node("%ItemsScroll") as ScrollContainer
	checks.truthy(item_scroll.visible and setup._active_scroll() == item_scroll, "Items use the shared touch-scroll catalog")
	var item_scroll_start: Vector2 = item_scroll.get_global_rect().get_center()
	var item_scroll_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	item_scroll_touch.index = 74
	item_scroll_touch.position = item_scroll_start
	item_scroll_touch.pressed = true
	setup._input(item_scroll_touch)
	var item_scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	item_scroll_drag.index = item_scroll_touch.index
	item_scroll_drag.position = item_scroll_start + Vector2(0.0, -120.0)
	item_scroll_drag.relative = Vector2(0.0, -120.0)
	setup._input(item_scroll_drag)
	checks.truthy(item_scroll.scroll_vertical > 0, "The item catalog scrolls vertically through touch drag input")
	item_scroll_touch.position = item_scroll_drag.position
	item_scroll_touch.pressed = false
	setup._input(item_scroll_touch)
	checks.truthy(capsule_piece_button.get_global_rect().end.x <= viewport.size.x, "Stored Block controls remain inside a touch-sized viewport")
	(setup.get_node("%RelicsTab") as Button).pressed.emit()
	await get_tree().process_frame
	checks.truthy(repeatable_quantity_controls.get_global_rect().end.x <= viewport.size.x, "Repeatable relic stack controls remain inside a touch-sized viewport")
	var relic_scroll: ScrollContainer = setup.get_node("%RelicsScroll") as ScrollContainer
	var scroll_start: Vector2 = relic_scroll.get_global_rect().get_center()
	var scroll_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	scroll_touch.index = 73
	scroll_touch.position = scroll_start
	scroll_touch.pressed = true
	setup._input(scroll_touch)
	var scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	scroll_drag.index = scroll_touch.index
	scroll_drag.position = scroll_start + Vector2(0.0, -120.0)
	scroll_drag.relative = Vector2(0.0, -120.0)
	setup._input(scroll_drag)
	checks.truthy(relic_scroll.scroll_vertical > 0, "Test catalogs scroll vertically through touch drag input")
	scroll_touch.position = scroll_drag.position
	scroll_touch.pressed = false
	setup._input(scroll_touch)
	checks.truthy((setup.get_node("%StartTest") as Button).get_global_rect().end.y <= viewport.size.y, "Test launch controls remain inside a touch-sized viewport")
	viewport.size = Vector2i(800, 480)
	await get_tree().process_frame
	setup._open_enemy_picker()
	await get_tree().process_frame
	var landscape_picker: DebugOptionPicker = setup.get_node("%OptionPicker") as DebugOptionPicker
	var landscape_picker_panel: PanelContainer = landscape_picker.get_node("%PickerPanel") as PanelContainer
	checks.truthy(landscape_picker.choice_buttons.size() <= landscape_picker.desktop_columns * landscape_picker.short_viewport_rows, "Short landscape pickers reduce their page length")
	checks.truthy(landscape_picker_panel.get_global_rect().end.y <= viewport.size.y, "Short landscape picker controls remain inside the viewport")
	landscape_picker.close_picker()
	viewport.size = Vector2i(480, 800)
	await get_tree().process_frame
	var back_requests: Array[bool] = []
	setup.back_requested.connect(func() -> void: back_requests.append(true))
	var cancel_event: InputEventAction = InputEventAction.new()
	cancel_event.action = &"ui_cancel"
	cancel_event.pressed = true
	setup._unhandled_input(cancel_event)
	checks.equal(back_requests.size(), 1, "Keyboard and controller cancel return from the test setup")
	var requested_configurations: Array[DebugEncounterConfiguration] = []
	setup.encounter_requested.connect(func(requested: DebugEncounterConfiguration) -> void: requested_configurations.append(requested))
	(setup.get_node("%StartTest") as Button).pressed.emit()
	checks.equal(requested_configurations.size(), 1, "START TEST emits one typed encounter configuration")
	checks.equal(requested_configurations[0].pieces.size(), setup.configuration.pieces.size(), "Emitted setup preserves the exact configured pile")
	setup.queue_free()
	viewport.queue_free()
	await get_tree().process_frame
	var original_profile: ProfileState = SaveService.profile
	var debug_profile: ProfileState = ProfileState.from_save_data(original_profile.to_save_data())
	debug_profile.discovered_pieces.erase(MONOMINO_PIECE)
	SaveService.profile = debug_profile
	var completed_runs_before: int = debug_profile.completed_runs
	var victories_before: int = debug_profile.victories
	var items_used_before: int = debug_profile.total_items_used
	var counters_completed_before: int = debug_profile.total_boss_actions_countered
	var main_viewport: SubViewport = SubViewport.new()
	main_viewport.size = Vector2i(480, 800)
	add_child(main_viewport)
	var main_scene: Control = (load("res://scenes/main/main.tscn") as PackedScene).instantiate() as Control
	main_viewport.add_child(main_scene)
	await get_tree().process_frame
	var menu: MainMenuScreen = main_scene.get("current_screen") as MainMenuScreen
	checks.truthy(menu != null, "Main router opens the main menu before the test area")
	var test_area_button: Button = menu.get_node("%TestAreaButton") as Button
	checks.equal((menu.get_node("%Composition") as GridContainer).columns, 1, "Main menu switches to its compact layout on a touch-sized screen")
	checks.truthy(Rect2(Vector2.ZERO, Vector2(main_viewport.size)).encloses(test_area_button.get_global_rect()), "The main-menu test entry remains fully reachable on a touch-sized screen")
	checks.equal(test_area_button.visible, OS.is_debug_build(), "Main-menu test entry follows debug-build visibility")
	if test_area_button.visible:
		test_area_button.pressed.emit()
	else:
		main_scene.call("show_debug_test_area")
	await get_tree().process_frame
	checks.truthy(main_scene.get("current_screen") is DebugEncounterSetupScreen, "Main-menu test entry opens the setup scene")
	main_viewport.size = Vector2i(1280, 720)
	await get_tree().process_frame
	var touch_setup: DebugEncounterSetupScreen = main_scene.get("current_screen") as DebugEncounterSetupScreen
	var touch_piece_row: DebugPieceLoadoutRow = touch_setup.piece_rows[0]
	var touch_picker: DebugOptionPicker = touch_setup.get_node("%OptionPicker") as DebugOptionPicker
	var piece_selector: Button = touch_piece_row.get_node("%PieceOptions") as Button
	_send_viewport_touch(main_viewport, piece_selector.get_global_rect().get_center(), 80)
	await get_tree().process_frame
	checks.truthy(touch_picker.visible, "Touch opens the Block selection picker")
	checks.truthy(main_viewport.gui_get_focus_owner() is DebugOptionChoiceButton, "The Block picker owns focus while open")
	var piece_choice_button: DebugOptionChoiceButton
	for button: DebugOptionChoiceButton in touch_picker.choice_buttons:
		var candidate_piece: PieceDefinition = touch_piece_row.piece_options[button.choice_index]
		if button.choice_index != touch_piece_row.get_selected_piece_index() and candidate_piece.permanent_card_effect == null:
			piece_choice_button = button
			break
	checks.truthy(piece_choice_button != null, "Block picker exposes a different selectable Block on the active page")
	if piece_choice_button != null:
		var selected_piece: PieceDefinition = touch_piece_row.piece_options[piece_choice_button.choice_index]
		_send_viewport_touch(main_viewport, piece_choice_button.get_global_rect().get_center(), 81)
		await get_tree().process_frame
		checks.falsy(touch_picker.visible, "Touch selection closes the Block picker")
		checks.equal(touch_setup.configuration.pieces[0].piece, selected_piece, "Touch selection updates the typed Block configuration")
		checks.equal(main_viewport.gui_get_focus_owner(), piece_selector, "Closing the Block picker restores focus to its selector")
	var effect_selector: Button = touch_piece_row.get_node("%EffectOptions") as Button
	_send_viewport_touch(main_viewport, effect_selector.get_global_rect().get_center(), 82)
	await get_tree().process_frame
	checks.truthy(touch_picker.visible, "Touch opens the effect selection picker")
	var effect_choice_button: DebugOptionChoiceButton
	for button: DebugOptionChoiceButton in touch_picker.choice_buttons:
		if button.choice_index > 0 and button.choice_index < touch_piece_row.effect_options.size() and touch_piece_row.effect_options[button.choice_index] != null:
			effect_choice_button = button
			break
	checks.truthy(effect_choice_button != null, "Effect picker exposes a powered effect on the active page")
	if effect_choice_button != null:
		var selected_effect: PieceCardEffectDefinition = touch_piece_row.effect_options[effect_choice_button.choice_index]
		_send_viewport_touch(main_viewport, effect_choice_button.get_global_rect().get_center(), 83)
		await get_tree().process_frame
		checks.falsy(touch_picker.visible, "Touch selection closes the effect picker")
		checks.equal(touch_setup.configuration.pieces[0].effect, selected_effect, "Touch selection updates the typed Block effect")
	var relics_tab: Button = touch_setup.get_node("%RelicsTab") as Button
	_send_viewport_touch(main_viewport, relics_tab.get_global_rect().get_center(), 84)
	await get_tree().process_frame
	checks.truthy((touch_setup.get_node("%RelicsScroll") as ScrollContainer).visible, "Touch opens the relic catalog")
	var touch_relic_index: int = -1
	for relic_index: int in touch_setup.relics.size():
		if touch_setup.relics[relic_index].repeatable:
			touch_relic_index = relic_index
			break
	checks.truthy(touch_relic_index >= 0, "Test catalog contains a repeatable relic for touch quantity controls")
	if touch_relic_index >= 0:
		var touch_relic: RelicDefinition = touch_setup.relics[touch_relic_index]
		var touch_relic_row: DebugContentToggle = touch_setup.relic_rows[touch_relic_index]
		var touch_relic_scroll: ScrollContainer = touch_setup.get_node("%RelicsScroll") as ScrollContainer
		touch_relic_scroll.ensure_control_visible(touch_relic_row)
		await get_tree().process_frame
		var decrease_quantity: Button = touch_relic_row.get_node("%Decrease") as Button
		var increase_quantity: Button = touch_relic_row.get_node("%Increase") as Button
		checks.truthy(decrease_quantity.custom_minimum_size.y >= 48.0 and increase_quantity.custom_minimum_size.y >= 48.0, "Relic stack controls use touch-sized targets")
		checks.truthy(Rect2(Vector2.ZERO, Vector2(main_viewport.size)).encloses(increase_quantity.get_global_rect()), "The visible relic increment control remains inside the viewport")
		checks.equal(main_scene.call("_button_at", increase_quantity.get_global_rect().get_center()), increase_quantity, "Touch hit testing resolves the relic increment control")
		_send_viewport_touch(main_viewport, increase_quantity.get_global_rect().get_center(), 85)
		_send_viewport_touch(main_viewport, increase_quantity.get_global_rect().get_center(), 86)
		checks.equal(touch_relic_row.get_quantity(), 2, "Touch increment raises a repeatable relic to two stacks")
		checks.equal(touch_setup.configuration.relics.count(touch_relic), 2, "Touch increment updates the typed relic configuration")
		checks.truthy((touch_relic_row.get_node("%Selected") as CheckButton).button_pressed, "A positive relic stack count keeps its selection enabled")
		_send_viewport_touch(main_viewport, decrease_quantity.get_global_rect().get_center(), 87)
		checks.equal(touch_relic_row.get_quantity(), 1, "Touch decrement removes one relic stack")
		for touch_index: int in range(88, 88 + touch_setup.rules.maximum_repeatable_relic_copies):
			_send_viewport_touch(main_viewport, increase_quantity.get_global_rect().get_center(), touch_index)
		_send_viewport_touch(main_viewport, increase_quantity.get_global_rect().get_center(), 97)
		checks.equal(touch_relic_row.get_quantity(), touch_setup.rules.maximum_repeatable_relic_copies, "Relic touch increment clamps at the configured maximum")
		for touch_index: int in range(98, 99 + touch_setup.rules.maximum_repeatable_relic_copies):
			_send_viewport_touch(main_viewport, decrease_quantity.get_global_rect().get_center(), touch_index)
		checks.equal(touch_relic_row.get_quantity(), 0, "Relic touch decrement clamps at zero")
		checks.equal(touch_setup.configuration.relics.count(touch_relic), 0, "Zero touch quantity removes the relic from the typed configuration")
		checks.falsy((touch_relic_row.get_node("%Selected") as CheckButton).button_pressed, "Zero relic stacks clear the selection toggle")
	main_scene.call("_start_debug_encounter", configuration)
	await get_tree().process_frame
	var launched_screen: RunScreen = main_scene.get("current_screen") as RunScreen
	var launched_run: RunState = main_scene.get("run_state") as RunState
	checks.truthy(launched_screen != null and launched_run != null, "Main router launches the normal run screen for a test")
	checks.equal(launched_screen.controller.enemy, TRAINING_SLIME_ENEMY, "Chosen enemy reaches the encounter controller")
	checks.equal(launched_run.deck_cards.size(), configuration.pieces.size(), "Chosen Block pile reaches the launched encounter")
	checks.truthy(launched_run.relics.has(FIFTH_GEAR_RELIC) and launched_run.get_artifact_state(CLOSED_LOOP_HOPPER_ARTIFACT) != null, "Chosen relics and artifacts reach the launched encounter")
	checks.falsy(launched_screen.tutorials_enabled, "Contextual tutorials stay isolated from debug encounters")
	checks.falsy(SaveService.profile.discovered_pieces.has(MONOMINO_PIECE), "Drawing a Block in a test does not alter profile discoveries")
	var strength_stack: ItemStack = ItemStack.new()
	strength_stack.definition = STRENGTH_TONIC_ITEM
	launched_run.inventory.slots[0] = strength_stack
	checks.truthy(launched_screen.controller.use_item(0).used, "Items remain usable in a debug encounter")
	checks.equal(SaveService.profile.total_items_used, items_used_before, "Debug item use does not alter profile statistics")
	var debug_counter_definition: CounterDefinition = CounterDefinition.new()
	debug_counter_definition.display_name = "Debug Isolation"
	var debug_counter: ActiveCounterState = ActiveCounterState.new()
	debug_counter.definition = debug_counter_definition
	debug_counter.required_progress = 1
	debug_counter.current_progress = 1
	debug_counter.is_completed = true
	launched_screen.controller.active_counter = debug_counter
	launched_screen.controller.active_counter_definition = debug_counter_definition
	launched_screen.controller._resolve_counter_if_ready()
	checks.equal(SaveService.profile.total_boss_actions_countered, counters_completed_before, "Debug counter completion does not alter profile statistics")
	launched_screen.encounter_won.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	checks.truthy(main_scene.get("current_screen") is DebugEncounterSetupScreen, "Finishing a test returns to the retained setup instead of rewards")
	checks.equal(SaveService.profile.completed_runs, completed_runs_before, "Test combat does not record a completed run")
	checks.equal(SaveService.profile.victories, victories_before, "Test combat does not change victory statistics")
	main_scene.queue_free()
	main_viewport.queue_free()
	await get_tree().process_frame
	SaveService.profile = original_profile
	SaveService.save_profile()

func _test_phase_two_scenes() -> void:
	var paths: Array[String] = [
		"res://scenes/hub/hub_screen.tscn",
		"res://scenes/upgrades/upgrade_tree_screen.tscn",
		"res://scenes/routes/route_map_screen.tscn",
		"res://scenes/shops/shop_screen.tscn",
		"res://scenes/events/event_screen.tscn",
		"res://scenes/collection/info_screen.tscn",
		"res://scenes/settings/settings_screen.tscn",
		"res://scenes/piece_draft/piece_draft_screen.tscn",
		"res://scenes/tutorial/tutorial_archive_screen.tscn",
		"res://scenes/run/run_screen.tscn",
		"res://scenes/debug/debug_encounter_setup_screen.tscn",
		"res://scenes/debug/debug_piece_loadout_row.tscn",
		"res://scenes/debug/debug_content_toggle.tscn",
		"res://scenes/debug/debug_option_picker.tscn",
		"res://scenes/debug/debug_option_choice_button.tscn",
		"res://scenes/rewards/reward_screen.tscn",
		"res://scenes/run_end/run_end_screen.tscn",
		"res://scenes/routes/run_loadout_drawer.tscn",
		"res://ui/piece_pool_view.tscn",
		"res://ui/piece_pool_card.tscn",
		"res://ui/relic_collection_view.tscn",
		"res://ui/owned_relic_card.tscn",
		"res://scenes/rewards/artifact_reward_screen.tscn",
		"res://ui/artifact_collection_view.tscn",
		"res://presentation/artifacts/artifact_combat_strip.tscn"
	]
	for path: String in paths:
		checks.truthy(load(path) is PackedScene, "Scene loads: %s" % path)
	var back_button_scenes: Array[String] = [
		"res://scenes/collection/info_screen.tscn",
		"res://scenes/debug/debug_encounter_setup_screen.tscn",
		"res://scenes/hub/hub_screen.tscn",
		"res://scenes/piece_draft/piece_draft_screen.tscn",
		"res://scenes/routes/route_map_screen.tscn",
		"res://scenes/settings/settings_screen.tscn",
		"res://scenes/tutorial/tutorial_archive_screen.tscn",
		"res://scenes/upgrades/upgrade_tree_screen.tscn",
	]
	for scene_path: String in back_button_scenes:
		var packed_scene: PackedScene = load(scene_path) as PackedScene
		var screen: Node = packed_scene.instantiate()
		var back_button: Button = screen.find_child("Back", true, false) as Button
		checks.truthy(back_button != null, "Screen exposes a Back button: %s" % scene_path)
		if back_button != null:
			checks.equal(back_button.custom_minimum_size, STANDARD_BACK_BUTTON_MINIMUM_SIZE, "Back button uses the shared minimum size: %s" % scene_path)
		screen.free()
	for upgrade: UpgradeDefinition in ContentRegistry.upgrades:
		checks.truthy(upgrade.is_valid(), "Upgrade validates: %s" % upgrade.display_name)
	var legacy_shape_term: String = "tet" + "romino"
	for piece: PieceDefinition in ContentRegistry.pieces:
		checks.equal(piece.display_name.findn(legacy_shape_term), -1, "Piece name uses generic block terminology: %s" % piece.display_name)

func _test_route_loadout_drawer() -> void:
	var run: RunState = RunState.new()
	run.route = RouteGenerator.new().generate(7219, false)
	var pool: Array[PiecePoolEntry] = run.get_current_piece_pool()
	checks.truthy(not pool.is_empty(), "Run exposes its authoritative piece pool")
	for index: int in range(1, pool.size()):
		var previous: PiecePoolEntry = pool[index - 1]
		var current: PiecePoolEntry = pool[index]
		checks.truthy(previous.cells.size() < current.cells.size() or previous.cells.size() == current.cells.size() and previous.piece.resource_path < current.piece.resource_path, "Piece pool keeps stable size and resource sorting")
	var removed_piece: PieceDefinition = pool[0].piece
	run.remove_piece_from_pool(removed_piece)
	var removed_entry: PiecePoolEntry
	for entry: PiecePoolEntry in run.get_current_piece_pool():
		if entry.piece == removed_piece:
			removed_entry = entry
	checks.truthy(removed_entry != null and not removed_entry.is_enabled, "Removed pieces remain visible with a disabled state")
	var newly_unlocked_piece: PieceDefinition
	for definition: PieceDefinition in ContentRegistry.pieces:
		if not definition.initially_unlocked:
			newly_unlocked_piece = definition
			break
	if newly_unlocked_piece != null:
		run.unlock_piece_for_run(newly_unlocked_piece)
		var new_piece_found: bool = false
		for entry: PiecePoolEntry in run.get_current_piece_pool():
			if entry.piece == newly_unlocked_piece:
				new_piece_found = entry.is_new
		checks.truthy(new_piece_found, "Pieces added during a run expose a NEW display state")
	var relic: RelicDefinition = ContentRegistry.relics[0]
	run.add_relic(relic, "Act 1 Shop")
	run.add_relic(relic, "Act 1 Shop")
	run.add_artifact(WARDEN_PRISM_ARTIFACT, 0)
	var owned: Array[OwnedRelicState] = run.get_owned_relics()
	checks.equal(owned.size(), 1, "Duplicate relics collapse into one display model")
	checks.equal(owned[0].stacks, 2, "Relic display model exposes stack count")
	checks.equal(owned[0].source_description, "Act 1 Shop", "Relic display model records its source")
	checks.truthy(owned[0].is_new, "New relic is marked until its drawer is viewed")
	var restored: RunState = RunState.from_save_data(run.to_save_data())
	checks.truthy(restored.unviewed_relics.has(relic), "New relic marker persists in active-run saves")
	if newly_unlocked_piece != null:
		checks.truthy(restored.unviewed_pieces.has(newly_unlocked_piece), "New piece marker persists in active-run saves")
	checks.equal(restored.get_owned_relics()[0].source_description, "Act 1 Shop", "Relic source persists in active-run saves")
	checks.truthy(restored.removed_pieces.has(removed_piece), "Removed piece state persists in active-run saves")
	var route_viewport: SubViewport = SubViewport.new()
	route_viewport.size = Vector2i(1280, 720)
	add_child(route_viewport)
	var screen: RouteMapScreen = (load("res://scenes/routes/route_map_screen.tscn") as PackedScene).instantiate() as RouteMapScreen
	route_viewport.add_child(screen)
	screen.start(run)
	await get_tree().process_frame
	var drawer: RunLoadoutDrawer = screen.get_node("Margin/Layout/Panel/MapLayer/LoadoutDrawer") as RunLoadoutDrawer
	drawer.motion.animation_speed = 0.0
	var route_scroll: ScrollContainer = screen.get_node("Margin/Layout/Panel/MapLayer/RouteScroll") as ScrollContainer
	var route_tree: RouteTreeView = screen.get_node("Margin/Layout/Panel/MapLayer/RouteScroll/RouteTree") as RouteTreeView
	checks.truthy(route_tree.custom_minimum_size.x > route_scroll.size.x, "Route content remains wider than its viewport for horizontal exploration")
	var inspectable_nodes: Array[RouteNodeState] = run.route.get_available_nodes()
	var inspected_node: RouteNodeState = inspectable_nodes[0]
	var inspected_button: Button = route_tree.node_buttons[inspected_node] as Button
	var node_info_panel: PanelContainer = screen.get_node("Margin/Layout/Panel/MapLayer/NodeTypeInfo") as PanelContainer
	var node_info_title: Label = node_info_panel.get_node("InfoMargin/InfoLayout/Copy/NodeTypeInfoTitle") as Label
	var node_info_description: Label = node_info_panel.get_node("InfoMargin/InfoLayout/Copy/NodeTypeInfoDescription") as Label
	var node_presentation: RouteSymbolSet = route_tree.symbol_set
	var node_info_press: InputEventScreenTouch = InputEventScreenTouch.new()
	node_info_press.index = 52
	node_info_press.position = inspected_button.get_global_rect().get_center()
	node_info_press.pressed = true
	screen._input(node_info_press)
	route_tree.touch_hold_started_msec = Time.get_ticks_msec() - ceili(route_tree.touch_hold_duration * 1000.0) - 1
	route_tree._process(0.0)
	checks.truthy(node_info_panel.visible, "Holding a route node opens its room-type information")
	checks.equal(node_info_title.text, node_presentation.title_for(inspected_node.type), "Route hold information names only the room type")
	checks.equal(node_info_description.text, node_presentation.description_for(inspected_node.type), "Route hold information uses the generic room-type description")
	checks.equal(inspected_button.tooltip_text, node_presentation.tooltip_for(inspected_node.type), "Mouse and touch route information share the generic type copy")
	checks.falsy(inspected_button.tooltip_text.contains("Stage") or inspected_button.tooltip_text.contains("Available") or inspected_button.tooltip_text.contains("Fixed room"), "Route information omits node-specific route content")
	var node_info_release: InputEventScreenTouch = InputEventScreenTouch.new()
	node_info_release.index = node_info_press.index
	node_info_release.position = node_info_press.position
	node_info_release.pressed = false
	screen._input(node_info_release)
	checks.falsy(node_info_panel.visible, "Releasing a held route node closes its information")
	checks.equal(route_tree.touch_hold_index, RouteTreeView.NO_TOUCH_INDEX, "Route hold interaction releases touch ownership cleanly")
	var route_scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	route_scroll_press.index = 51
	route_scroll_press.position = inspected_button.get_global_rect().get_center()
	route_scroll_press.pressed = true
	screen._input(route_scroll_press)
	var route_scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	route_scroll_drag.index = route_scroll_press.index
	route_scroll_drag.position = route_scroll_press.position - Vector2(180.0, 80.0)
	route_scroll_drag.relative = Vector2(-180.0, -80.0)
	screen._input(route_scroll_drag)
	var route_scroll_release: InputEventScreenTouch = InputEventScreenTouch.new()
	route_scroll_release.index = route_scroll_press.index
	route_scroll_release.position = route_scroll_drag.position
	route_scroll_release.pressed = false
	screen._input(route_scroll_release)
	checks.truthy(route_scroll.scroll_horizontal > 0, "Dragging the route map scrolls it horizontally on touch")
	checks.equal(screen.route_scroll_touch_index, RouteMapScreen.NO_TOUCH_INDEX, "Route scrolling releases touch ownership cleanly")
	checks.falsy(node_info_panel.visible, "Dragging from a route node cancels its hold information")
	checks.equal(route_tree.touch_hold_index, RouteTreeView.NO_TOUCH_INDEX, "Route scrolling cancels node-hold ownership")
	await get_tree().process_frame
	var route_rect: Rect2 = route_tree.get_global_rect()
	var enabled_count: int = 0
	for entry: PiecePoolEntry in run.get_current_piece_pool():
		enabled_count += 1 if entry.is_enabled else 0
	checks.equal((screen.get_node("Margin/Layout/RunStats/Stats/Pieces") as LoadoutCounterButton).badge_text, "%d/%d" % [enabled_count, run.maximum_active_piece_pool_size], "Route status displays current pool size and capacity")
	checks.equal((screen.get_node("Margin/Layout/RunStats/Stats/Relics") as LoadoutCounterButton).badge_text, "2", "Route status displays current relic count")
	checks.equal((screen.get_node("Margin/Layout/RunStats/Stats/Artifacts") as LoadoutCounterButton).badge_text, "1", "Route status displays current Boss Artifact count")
	(screen.get_node("Margin/Layout/RunStats/Stats/Pieces") as Button).pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	checks.truthy(drawer.visible and drawer.active_tab == RunLoadoutDrawer.Tab.PIECES, "Pieces counter opens the Pieces tab")
	checks.equal(route_tree.get_global_rect(), route_rect, "Opening the loadout drawer does not resize or shift the route map")
	checks.truthy(drawer.get_global_rect().end.x <= 1280.0 and drawer.get_global_rect().end.y <= 720.0, "Loadout drawer remains usable at 1280 by 720")
	var piece_grid: GridContainer = drawer.get_node("Layout/Content/PiecePoolView/PiecePoolScroll/Margin/PieceGrid") as GridContainer
	checks.equal(piece_grid.get_child_count(), run.get_current_piece_pool().size(), "Piece drawer renders every available and removed piece")
	var removed_card_found: bool = false
	for child: Node in piece_grid.get_children():
		var card: PiecePoolCard = child as PiecePoolCard
		if card.entry.piece == removed_piece:
			removed_card_found = not card.entry.is_enabled and card.tooltip_text.contains("Removed during this run") and card.focus_mode != Control.FOCUS_NONE
	checks.truthy(removed_card_found, "Removed piece card exposes its state and modifier source")
	var hub_requests: Array[int] = [0]
	screen.hub_requested.connect(func() -> void: hub_requests[0] += 1)
	var hub_button: Button = screen.get_node("Margin/Layout/TopBar/BackSlot/Back") as Button
	var hub_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	hub_touch.index = 12
	hub_touch.position = hub_button.get_global_rect().get_center()
	hub_touch.pressed = true
	screen._input(hub_touch)
	checks.equal(hub_requests[0], 1, "Route Leave touch bypasses persistent scene overlays")
	checks.equal(hub_button.get_parent().get_parent(), screen.get_node("Margin/Layout/TopBar"), "Route Back action lives in the header")
	checks.falsy(screen.has_node("Margin/Layout/Hub"), "Route map omits the old bottom return action")
	(screen.get_node("Margin/Layout/RunStats/Stats/Relics") as Button).pressed.emit()
	await get_tree().process_frame
	checks.truthy(drawer.visible and drawer.active_tab == RunLoadoutDrawer.Tab.RELICS, "Relics counter switches to the Relics tab")
	var relic_grid: GridContainer = drawer.get_node("Layout/Content/RelicCollectionView/RelicCollectionScroll/Margin/RelicGrid") as GridContainer
	checks.equal(relic_grid.get_child_count(), 1, "Relic drawer renders owned relic stacks as cards")
	var relic_card: OwnedRelicCard = relic_grid.get_child(0) as OwnedRelicCard
	checks.truthy(relic_card.tooltip_text.contains("Act 1 Shop") and relic_card.tooltip_text.contains("Stacks: 2"), "Relic tooltip includes stack and acquisition details")
	(screen.get_node("Margin/Layout/RunStats/Stats/Artifacts") as Button).pressed.emit()
	await get_tree().process_frame
	checks.truthy(drawer.visible and drawer.active_tab == RunLoadoutDrawer.Tab.ARTIFACTS, "Artifacts counter switches to the Boss Artifacts tab")
	var artifact_grid: GridContainer = drawer.get_node("Layout/Content/ArtifactCollectionView/ArtifactCollectionScroll/Margin/ArtifactGrid") as GridContainer
	checks.equal(artifact_grid.get_child_count(), 1, "Artifact drawer lists every active Boss Artifact")
	checks.truthy((artifact_grid.get_child(0) as OwnedArtifactCard).tooltip_text.contains("Risk:"), "Artifact tooltip exposes its full benefit and drawback")
	(drawer.get_node("Layout/Header/ArtifactTab") as Button).pressed.emit()
	await get_tree().process_frame
	checks.falsy(drawer.visible, "Selecting the active drawer tab closes it")
	drawer.open_tab(RunLoadoutDrawer.Tab.PIECES)
	var cancel_event: InputEventAction = InputEventAction.new()
	cancel_event.action = &"ui_cancel"
	cancel_event.pressed = true
	drawer._unhandled_input(cancel_event)
	await get_tree().process_frame
	checks.falsy(drawer.visible, "Escape closes the loadout drawer")
	if ContentRegistry.relics.size() > 1:
		run.add_relic(ContentRegistry.relics[1], "Event")
		checks.equal((screen.get_node("Margin/Layout/RunStats/Stats/Relics") as LoadoutCounterButton).badge_text, "3", "Route relic counter updates immediately after acquisition")
	var empty_view: RelicCollectionView = (load("res://ui/relic_collection_view.tscn") as PackedScene).instantiate() as RelicCollectionView
	add_child(empty_view)
	empty_view.setup([])
	checks.truthy((empty_view.get_node("EmptyState") as Label).visible, "Empty relic collection remains selectable and explanatory")
	empty_view.queue_free()
	route_viewport.queue_free()
	var mobile_viewport: SubViewport = SubViewport.new()
	mobile_viewport.size = Vector2i(360, 400)
	add_child(mobile_viewport)
	var mobile_host: Control = Control.new()
	mobile_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mobile_viewport.add_child(mobile_host)
	var mobile_drawer: RunLoadoutDrawer = (load("res://scenes/routes/run_loadout_drawer.tscn") as PackedScene).instantiate() as RunLoadoutDrawer
	mobile_host.add_child(mobile_drawer)
	var mobile_run: RunState = RunState.new()
	for relic_definition: RelicDefinition in ContentRegistry.relics:
		mobile_run.add_relic(relic_definition, "Mobile test")
	for artifact_index: int in mini(3, ContentRegistry.artifacts.size()):
		mobile_run.add_artifact(ContentRegistry.artifacts[artifact_index], artifact_index)
	mobile_drawer.setup(mobile_run)
	mobile_drawer.motion.animation_speed = 0.0
	mobile_drawer.open_tab(RunLoadoutDrawer.Tab.PIECES)
	await get_tree().process_frame
	await get_tree().process_frame
	checks.truthy(mobile_drawer.size.x >= mobile_host.size.x - 20.0, "Mobile loadout drawer spans the available parent width")
	checks.falsy((mobile_drawer.get_node("Layout/Header/Title") as Label).visible, "Mobile loadout drawer compacts its header instead of narrowing")
	var mobile_piece_scroll: ScrollContainer = mobile_drawer.get_node("Layout/Content/PiecePoolView/PiecePoolScroll") as ScrollContainer
	var piece_scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	piece_scroll_press.index = 4
	piece_scroll_press.position = mobile_piece_scroll.get_global_rect().get_center()
	piece_scroll_press.pressed = true
	mobile_drawer._input(piece_scroll_press)
	var piece_scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	piece_scroll_drag.index = 4
	piece_scroll_drag.position = piece_scroll_press.position - Vector2(0.0, 100.0)
	piece_scroll_drag.relative = Vector2(0.0, -100.0)
	mobile_drawer._input(piece_scroll_drag)
	checks.truthy(mobile_piece_scroll.scroll_vertical > 0, "Touch dragging scrolls the mobile piece collection")
	mobile_drawer.open_tab(RunLoadoutDrawer.Tab.RELICS)
	await get_tree().process_frame
	var mobile_relic_scroll: ScrollContainer = mobile_drawer.get_node("Layout/Content/RelicCollectionView/RelicCollectionScroll") as ScrollContainer
	var relic_scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	relic_scroll_press.index = 5
	relic_scroll_press.position = mobile_relic_scroll.get_global_rect().get_center()
	relic_scroll_press.pressed = true
	mobile_drawer._input(relic_scroll_press)
	var relic_scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	relic_scroll_drag.index = 5
	relic_scroll_drag.position = relic_scroll_press.position - Vector2(0.0, 100.0)
	relic_scroll_drag.relative = Vector2(0.0, -100.0)
	mobile_drawer._input(relic_scroll_drag)
	checks.truthy(mobile_relic_scroll.scroll_vertical > 0, "Touch dragging scrolls the mobile relic collection")
	mobile_drawer.open_tab(RunLoadoutDrawer.Tab.ARTIFACTS)
	await get_tree().process_frame
	var mobile_artifact_scroll: ScrollContainer = mobile_drawer.get_node("Layout/Content/ArtifactCollectionView/ArtifactCollectionScroll") as ScrollContainer
	var artifact_scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	artifact_scroll_press.index = 6
	artifact_scroll_press.position = mobile_artifact_scroll.get_global_rect().get_center()
	artifact_scroll_press.pressed = true
	mobile_drawer._input(artifact_scroll_press)
	var artifact_scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	artifact_scroll_drag.index = 6
	artifact_scroll_drag.position = artifact_scroll_press.position - Vector2(0.0, 100.0)
	artifact_scroll_drag.relative = Vector2(0.0, -100.0)
	mobile_drawer._input(artifact_scroll_drag)
	checks.truthy(mobile_artifact_scroll.scroll_vertical > 0, "Touch dragging scrolls the mobile Boss Artifact collection")
	mobile_viewport.queue_free()

func _test_shop_presentation() -> void:
	var service: ShopService = ShopService.new()
	var run: RunState = RunState.new()
	run.shards = 100
	run.player_health = 10
	run.maximum_health = 20
	var shop_node: RouteNodeState = RouteNodeState.new()
	shop_node.type = RouteNodeState.NodeType.SHOP
	var shop: ShopState = service.generate_shop(4815, shop_node, run, ContentRegistry.relics)
	var heal: ShopItem
	for item: ShopItem in shop.items:
		if item.type == ShopItem.ItemType.HEAL:
			heal = item
	var heal_view: ShopItemViewState = service.describe_item(heal, run)
	checks.equal(heal_view.availability, ShopItemViewState.Availability.AFFORDABLE, "Shop presentation marks usable services affordable")
	checks.truthy(heal_view.comparison.contains("15 / 20"), "Healing detail compares current and resulting health")
	run.shards = heal.final_price - 1
	heal_view = service.describe_item(heal, run)
	checks.equal(heal_view.availability, ShopItemViewState.Availability.UNAFFORDABLE, "Shop presentation distinguishes unaffordable stock")
	checks.truthy(heal_view.status_text.contains("Need 1 more"), "Unaffordable shop state explains the missing Shards")
	run.shards = 100
	run.player_health = run.maximum_health
	heal_view = service.describe_item(heal, run)
	checks.equal(heal_view.availability, ShopItemViewState.Availability.UNAVAILABLE, "Shop presentation distinguishes unavailable services")
	checks.equal(heal_view.status_text, "Full HP", "Unavailable healing explains why it cannot be bought")
	var purchased_heal: ShopItem = ShopItem.from_save_data(heal.to_save_data())
	purchased_heal.purchased = true
	checks.equal(service.describe_item(purchased_heal, run).availability, ShopItemViewState.Availability.PURCHASED, "Purchased stock remains visible with a bought state")
	var consumable_offer: ShopItem
	for item: ShopItem in shop.items:
		if item.type == ShopItem.ItemType.CONSUMABLE:
			consumable_offer = item
			break
	if consumable_offer != null:
		var definition: ItemDefinition = consumable_offer.item
		var full_run: RunState = RunState.new()
		full_run.shards = 100
		full_run.inventory = ItemInventory.new(1, 1)
		var blocking_stack: ItemStack = ItemStack.new()
		blocking_stack.definition = definition
		blocking_stack.bonus_piece = consumable_offer.piece
		blocking_stack.quantity = definition.maximum_stack_size
		full_run.inventory.slots[0] = blocking_stack
		var full_inventory_view: ShopItemViewState = service.describe_item(consumable_offer, full_run)
		checks.equal(full_inventory_view.status_text, "No inventory space", "Consumable detail explains full inventory restrictions")
	run.player_health = 10
	var shop_viewport: SubViewport = SubViewport.new()
	shop_viewport.size = Vector2i(1280, 720)
	add_child(shop_viewport)
	var screen: ShopScreen = (load("res://scenes/shops/shop_screen.tscn") as PackedScene).instantiate() as ShopScreen
	shop_viewport.add_child(screen)
	screen.start(run, shop)
	await get_tree().process_frame
	var content: HBoxContainer = screen.get_node("Margin/Layout/Content") as HBoxContainer
	var detail_panel: PanelContainer = screen.get_node("Margin/Layout/Content/DetailPanel") as PanelContainer
	checks.truthy(content.get_global_rect().end.x <= 1280.0 and content.get_global_rect().end.y <= 720.0, "Two-column shop remains inside 1280 by 720")
	checks.truthy(detail_panel.size.x >= 390.0, "Shop gives the detail panel useful reading space")
	checks.equal(screen.cards.size(), shop.items.size(), "Categorized shop grids render every stock item")
	var inventory_scroll: ScrollContainer = screen.get_node("Margin/Layout/Content/InventoryPanel/InventoryMargin/Scroll") as ScrollContainer
	var scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	scroll_press.index = 3
	scroll_press.position = inventory_scroll.get_global_rect().get_center()
	scroll_press.pressed = true
	screen._input(scroll_press)
	var scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	scroll_drag.index = 3
	scroll_drag.position = scroll_press.position - Vector2(0.0, 90.0)
	scroll_drag.relative = Vector2(0.0, -90.0)
	screen._input(scroll_drag)
	checks.truthy(inventory_scroll.scroll_vertical > 0, "Vertical touch dragging scrolls the shop inventory")
	var scroll_release: InputEventScreenTouch = InputEventScreenTouch.new()
	scroll_release.index = 3
	scroll_release.position = scroll_drag.position
	scroll_release.pressed = false
	screen._input(scroll_release)
	checks.equal(screen.scroll_touch_index, -1, "Shop touch scrolling releases its tracked finger")
	checks.truthy((screen.get_node("Margin/Layout/Content/InventoryPanel/InventoryMargin/Scroll/Categories/RelicHeader") as Label).visible, "Shop separates relic stock with a category heading")
	checks.truthy((screen.get_node("Margin/Layout/Content/InventoryPanel/InventoryMargin/Scroll/Categories/ServiceHeader") as Label).visible, "Shop separates services with a category heading")
	if screen.cards.size() > 1:
		screen.cards[0].grab_focus()
		var navigation_event: InputEventKey = InputEventKey.new()
		navigation_event.physical_keycode = KEY_D
		navigation_event.pressed = true
		screen._unhandled_input(navigation_event)
		checks.truthy(screen.cards[1].has_focus(), "WASD navigation moves keyboard focus between shop cards")
	var capsule_card: ShopItemCard
	for card: ShopItemCard in screen.cards:
		if card.view_state.category == ShopItemViewState.Category.BLOCK_CAPSULE:
			capsule_card = card
	checks.truthy(capsule_card != null and capsule_card.view_state.piece != null, "Block capsule cards use their stored procedural Block shape")
	if capsule_card != null:
		capsule_card.preview_requested.emit(capsule_card.view_state.item)
		checks.equal((screen.get_node("Margin/Layout/Content/DetailPanel/DetailMargin/Detail/DetailHeader/BasicInfo/ItemName") as Label).text, capsule_card.view_state.item.display_name, "Hover or focus updates the persistent detail panel")
		checks.truthy((screen.get_node("Margin/Layout/Content/DetailPanel/DetailMargin/Detail/PracticalEffect") as Label).text.contains("uses"), "Capsule detail states its number of uses")
	var first_card: ShopItemCard
	for card: ShopItemCard in screen.cards:
		if card.view_state.item.type != ShopItem.ItemType.RELIC and service.can_purchase(card.view_state.item, run):
			first_card = card
			break
	checks.truthy(first_card != null, "Generated shop has an affordable valid offer")
	var shards_before_selection: int = run.shards
	if first_card != null:
		var selected_offer: ShopItem = first_card.view_state.item
		var selected_price: int = selected_offer.final_price
		first_card.pressed.emit()
		checks.equal(run.shards, shards_before_selection, "Selecting a shop card does not purchase it immediately")
		checks.equal(screen.selected_item, selected_offer, "Pressing a shop card selects its matching offer")
		(screen.get_node("Margin/Layout/Content/DetailPanel/DetailMargin/Detail/Buy") as Button).pressed.emit()
		checks.truthy(selected_offer.purchased, "Dedicated Buy button confirms the selected purchase")
		checks.equal(run.shards, shards_before_selection - selected_price, "Confirmed purchase updates Shards")
		checks.truthy((screen.get_node("Margin/Layout/Header/HeaderLayout/Status/Shards") as Label).text.contains(str(run.shards)), "Shop status row updates after purchase")
	run.shards = 0
	screen._refresh()
	var unaffordable_found: bool = false
	for card: ShopItemCard in screen.cards:
		if not card.view_state.item.purchased and card.view_state.availability == ShopItemViewState.Availability.UNAFFORDABLE:
			unaffordable_found = card.tooltip_text.contains("Need")
	checks.truthy(unaffordable_found, "Unaffordable cards expose a concise missing-Shards tooltip")
	var left_events: Array[bool] = []
	screen.left_shop.connect(func() -> void: left_events.append(true))
	var cancel_event: InputEventAction = InputEventAction.new()
	cancel_event.action = &"ui_cancel"
	cancel_event.pressed = true
	screen._unhandled_input(cancel_event)
	checks.truthy(not left_events.is_empty() and shop.left, "Escape leaves the shop through the normal completion flow")
	shop_viewport.queue_free()

func _test_shop_target_selection_flow() -> void:
	var target_run: RunState = RunState.new()
	target_run.run_mode = RunMode.Value.TUTORIAL
	target_run.shards = 100
	target_run.ensure_active_piece_pool()
	var shop_node: RouteNodeState = RouteNodeState.new()
	shop_node.type = RouteNodeState.NodeType.SHOP
	var route: GeneratedRoute = GeneratedRoute.new()
	route.nodes.append(shop_node)
	target_run.route = route
	target_run.route.current_node = shop_node
	var target_item: ShopItem = ShopItem.new()
	target_item.display_name = CURATORS_CHOICE_RELIC.display_name
	target_item.type = ShopItem.ItemType.RELIC
	target_item.relic = CURATORS_CHOICE_RELIC
	target_item.final_price = 25
	var target_shop: ShopState = ShopState.new()
	target_shop.route_node = shop_node
	target_shop.items.append(target_item)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child(viewport)
	var main_scene: Control = (load("res://scenes/main/main.tscn") as PackedScene).instantiate() as Control
	viewport.add_child(main_scene)
	await get_tree().process_frame
	main_scene.set("run_state", target_run)
	main_scene.set("generator", PieceGenerator.new(target_run.seed_value))
	var misplaced_board_item: ShopItem = ShopItem.new()
	misplaced_board_item.type = ShopItem.ItemType.BOARD_PIECE
	misplaced_board_item.piece = MONOMINO_PIECE
	var misplaced_board_shop: ShopState = ShopState.new()
	misplaced_board_shop.route_node = shop_node
	misplaced_board_shop.items.append(misplaced_board_item)
	main_scene.set("current_shop_state", misplaced_board_shop)
	main_scene.call("show_shop", shop_node)
	await get_tree().process_frame
	var recovered_route_shop: ShopState = main_scene.get("current_shop_state") as ShopState
	checks.truthy(recovered_route_shop != misplaced_board_shop and not recovered_route_shop.has_board_pieces(), "Opening a route shop replaces saved permanent-Block stock with normal run offers")
	main_scene.set("current_shop_state", target_shop)
	main_scene.call("show_shop", shop_node)
	var shop_screen: ShopScreen = main_scene.get("current_screen") as ShopScreen
	shop_screen._purchase_selected()
	var target_overlay: PieceAdditionScreen = main_scene.get("current_screen") as PieceAdditionScreen
	checks.truthy(target_item.purchased, "Shop purchase applies a Block-selection relic")
	checks.truthy(target_overlay != null and target_run.pending_piece_addition != null, "Block selection opens immediately after the shop purchase")
	checks.equal(target_run.pending_piece_addition.continuation_flow, PieceSelectionFlow.Value.SHOP, "Shop Block selection keeps the shop return flow")
	viewport.queue_free()

func _test_presentation_systems() -> void:
	var theme: Theme = load("res://presentation/theme/game_theme.tres") as Theme
	checks.truthy(theme != null, "Visual theme loads")
	for variation: StringName in [&"PrimaryButton", &"SecondaryButton", &"GhostButton", &"DangerButton", &"CompactButton", &"CompactPrimaryButton", &"RewardCard", &"RouteNodeCard"]:
		checks.falsy(theme.get_type_variation_base(variation).is_empty(), "Theme variation exists: %s" % variation)
	var reward_normal: StyleBox = theme.get_stylebox(&"normal", &"RewardCard")
	var reward_hover: StyleBox = theme.get_stylebox(&"hover", &"RewardCard")
	for side: Side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		checks.equal(reward_hover.get_content_margin(side), reward_normal.get_content_margin(side), "Reward hover preserves card content margins on side %d" % side)
	var motion: MotionSettings = MotionSettings.new()
	motion.reduced_motion = true
	checks.equal(motion.duration(1.0), 0.35, "Reduced motion shortens presentation")
	motion.animation_speed = 0.0
	checks.equal(motion.duration(1.0), 0.0, "Disabled animation resolves immediately")
	var enemy: EnemyDefinition = EnemyDefinition.new()
	enemy.display_name = "Fallback"
	var enemy_view: EnemyPresentation = (load("res://presentation/combat/enemy_presentation.tscn") as PackedScene).instantiate() as EnemyPresentation
	add_child(enemy_view)
	await get_tree().process_frame
	enemy_view.configure(enemy)
	checks.truthy(enemy_view.definition != null, "Missing enemy art uses procedural fallback")
	enemy_view.play_phase_change("TEST PHASE")
	enemy_view.play_phase_change("DUPLICATE")
	checks.truthy(enemy_view.phase_transitioning, "Enemy phase presentation cannot start twice")
	enemy_view.configure(enemy)
	enemy_view.play_death()
	enemy_view.play_death()
	checks.truthy(enemy_view.death_started, "Enemy death cannot start twice")
	enemy_view.skip_to_final_state()
	checks.equal(enemy_view.actor.modulate.a, 0.0, "Skipped death reaches final state")
	enemy_view.configure(TRAINING_SLIME_ENEMY, TRAINING_SLIME_ENEMY.visual)
	enemy_view.size = Vector2(330, 178)
	await get_tree().process_frame
	checks.truthy(enemy_view.actor.position.x >= 0.0 and enemy_view.actor.position.y >= 0.0, "Enemy actor remains anchored inside its stage")
	checks.truthy(enemy_view.shadow.position.y < enemy_view.size.y, "Enemy shadow remains inside its stage")
	checks.truthy(enemy_view.glow.position.distance_to(enemy_view.size * Vector2(0.5, 0.48)) < 1.0, "Enemy glow remains centered")
	var counter_definition: CounterDefinition = CounterDefinition.new()
	counter_definition.description = "Deal eight damage before this attack resolves."
	counter_definition.counter_type = CounterType.Value.DEAL_DAMAGE
	counter_definition.duration_turns = 3
	counter_definition.required_progress = 8
	var counter_action: EnemyActionDefinition = EnemyActionDefinition.new()
	counter_action.display_name = "Counter Test"
	counter_action.intent_description = "A test attack."
	counter_action.counter_definition = counter_definition
	counter_action.direct_damage = 9
	var counter_intent: ResolvedEnemyIntent = EnemyActionSelector.new().resolve_intent(counter_action, 3)
	var counter_state: ActiveCounterState = ActiveCounterState.new()
	counter_state.definition = counter_definition
	counter_state.current_progress = 2
	counter_state.required_progress = 8
	counter_state.turns_remaining = 3
	var counter_intent_view: EnemyIntentView = EnemyIntentView.new()
	counter_intent_view.size = Vector2(400.0, 44.0)
	add_child(counter_intent_view)
	counter_intent_view.display_intent(counter_intent)
	counter_intent_view.set_counter_state(counter_state)
	checks.truthy(counter_intent_view._is_counterable(), "Counterable intents expose their compact indicator")
	checks.equal(counter_intent_view._detail_text(), "DEAL DMG 2/8 · 3T · 9 DMG", "Counterable intents describe their objective, progress, deadline, and damage in one line")
	checks.truthy(counter_intent_view.tooltip_text.contains(counter_definition.description), "Counterable intent tooltips include the full counter description")
	counter_definition.short_intent_description = "BREAK CORE"
	checks.truthy(counter_intent_view._detail_text().begins_with("BREAK CORE 2/8"), "Counter intent objectives support a configurable compact description")
	var effects: VFXLayer = (load("res://presentation/vfx/vfx_layer.tscn") as PackedScene).instantiate() as VFXLayer
	add_child(effects)
	await get_tree().process_frame
	checks.equal(effects.rings.size(), 4, "Impact effects are pooled")
	checks.equal(effects.texts.size(), 22, "Floating combat text provides normal, secondary, and critical pools")
	checks.equal(effects.projectiles.size(), effects.visual_settings.maximum_projectile_count, "Projectile effects use the configured pool size")
	checks.equal(effects.bursts.size(), 6, "Particle effects are pooled")
	var board_view: BoardView = BoardView.new()
	board_view.size = Vector2(400, 400)
	board_view.set_board(BoardState.new(10, 10))
	board_view.placed_overlay_cells = [Vector2i.ZERO]
	add_child(board_view)
	var player_health_target: Control = Control.new()
	player_health_target.position = Vector2(520.0, 40.0)
	player_health_target.size = Vector2(180.0, 32.0)
	add_child(player_health_target)
	var presentation: CombatPresentationController = CombatPresentationController.new()
	add_child(presentation)
	presentation.configure(enemy_view, board_view, effects, null, player_health_target)
	var busy_states: Array[bool] = []
	presentation.busy_changed.connect(func(busy: bool) -> void: busy_states.append(busy))
	presentation.motion.animation_speed = 2.0
	var presented_damage: DamageResult = DamageResult.new()
	presented_damage.final_damage = 7
	presented_damage.health_damage = 7
	presented_damage.enemy_maximum_health = 12
	presentation.enqueue_enemy_damage(presented_damage)
	await get_tree().create_timer(0.2).timeout
	var visible_damage_text: FloatingText
	for floating: FloatingText in effects.texts:
		if floating.visible and floating.text == "-7":
			visible_damage_text = floating
			break
	checks.truthy(presentation.playing, "Enemy damage presentation runs its queued animation")
	checks.truthy(effects.rings.any(func(ring: ImpactRing) -> bool: return ring.visible), "Enemy damage presentation emits a visible impact")
	checks.truthy(visible_damage_text != null, "Enemy damage presentation emits its floating damage number")
	await presentation.wait_until_idle()
	var poisoned_clear: ClearResult = ClearResult.new()
	poisoned_clear.poisoned_block_damage = 4
	poisoned_clear.poison_damage_source_cells = [Vector2i.ZERO, Vector2i(2, 0)]
	presentation.playing = true
	presentation.enqueue_poisoned_block_damage(poisoned_clear)
	presentation.enqueue_enemy_attack(3, [])
	checks.equal(presentation.queue.size(), 2, "Poison damage and a same-turn enemy attack are queued independently")
	checks.equal(presentation.queue[0].get_method(), &"_play_poisoned_block_damage", "Poison damage keeps its own visual step before the enemy attack")
	checks.equal(presentation.queue[1].get_method(), &"_play_enemy_attack", "The enemy attack remains queued after poison damage")
	presentation.playing = false
	presentation.call("_start_queue")
	await get_tree().process_frame
	var visible_poison_projectiles: Array[EnergyProjectile] = []
	for projectile: EnergyProjectile in effects.projectiles:
		if projectile.visible and projectile.color == presentation.visual_settings.poisoned_block_color:
			visible_poison_projectiles.append(projectile)
	checks.equal(visible_poison_projectiles.size(), 2, "Each poisoned Block launches a visible projectile")
	var expected_health_target: Vector2 = effects.global_to_layer(player_health_target.get_global_rect().get_center())
	for projectile: EnergyProjectile in visible_poison_projectiles:
		checks.truthy(projectile.end_position.distance_to(expected_health_target) < 0.01, "Poison projectiles travel to the player health bar")
	await presentation.wait_until_idle()
	presentation.playing = true
	presentation.skip_to_end()
	checks.falsy(presentation.playing, "Animation skip reaches idle state")
	checks.truthy(not busy_states.is_empty() and not busy_states.back(), "Animation skip restores input state")
	checks.truthy(board_view.placed_overlay_cells.is_empty(), "Animation skip clears board overlays")
	effects.clear_effects()
	checks.falsy(effects.rings[0].visible, "VFX clear restores inactive state")
	presentation.queue_free()
	board_view.queue_free()
	player_health_target.queue_free()
	effects.queue_free()
	counter_intent_view.queue_free()
	enemy_view.queue_free()
	for definition: EnemyDefinition in ContentRegistry.enemies:
		checks.truthy(definition.visual != null and definition.visual.sprite != null, "Enemy visual loads: %s" % definition.display_name)

func _test_combat_effect_visuals() -> void:
	var settings: CombatVisualSettings = load("res://content/presentation/combat_visual_settings.tres") as CombatVisualSettings
	checks.truthy(settings != null and settings.combo != null, "Combat visual settings load with combo configuration")
	var maximum_colored_combo: int = settings.combo.maximum_colored_combo
	checks.truthy(maximum_colored_combo > 0, "Combo color configuration has a positive saturation point")
	checks.truthy(settings.combo.color_for_combo(0) != settings.combo.color_for_combo(maximum_colored_combo), "Combo gradient changes across its configured range")
	checks.equal(settings.combo.color_for_combo(maximum_colored_combo + 1), settings.combo.color_for_combo(maximum_colored_combo), "Combo colors stay at their maximum above the configured range")
	var burn: StatusDefinition = preload("res://content/statuses/burn.tres")
	checks.truthy(burn != null and burn.visual_definition != null, "Burn has a typed status visual")
	checks.equal(burn.visual_definition.channel, StatusVisualChannel.Value.BURN, "Burn uses the burn shader channel")
	var enemy: EnemyDefinition = TRAINING_SLIME_ENEMY
	var enemy_view: EnemyPresentation = (load("res://presentation/combat/enemy_presentation.tscn") as PackedScene).instantiate() as EnemyPresentation
	add_child(enemy_view)
	await get_tree().process_frame
	enemy_view.configure(enemy, load("res://content/enemy_visuals/training_slime.tres") as EnemyVisualDefinition)
	var statuses: StatusCollection = StatusCollection.new()
	statuses.apply_status(burn, burn, 2, 2)
	enemy_view.set_combat_state(null, 0, statuses)
	checks.truthy(enemy_view.get_effect_strength(StatusVisualChannel.Value.BURN) > 0.0, "Burn status activates the enemy burn shader")
	statuses.remove_status(burn)
	enemy_view.set_combat_state(null, 0, statuses)
	checks.equal(enemy_view.get_effect_strength(StatusVisualChannel.Value.BURN), 0.0, "Removing Burn clears the enemy burn shader")
	enemy_view.motion.reduced_motion = true
	statuses.apply_status(burn, burn, 2, 1)
	enemy_view.set_combat_state(null, 0, statuses)
	checks.equal(float(enemy_view.flash_material.get_shader_parameter("burn_speed")), 0.0, "Reduced motion keeps Burn static")
	var electrified: StatusDefinition = ELECTRIFIED_STATUS
	enemy_view.motion.reduced_motion = false
	statuses.apply_status(electrified, electrified, 1, 1)
	enemy_view.set_combat_state(null, 0, statuses)
	checks.truthy(enemy_view.get_effect_strength(StatusVisualChannel.Value.BURN) > 0.0, "Enemy status shader composes Burn with other effects")
	checks.truthy(enemy_view.get_effect_strength(StatusVisualChannel.Value.ELECTRIFIED) > 0.0, "Electrified activates the enemy electrical shader")
	statuses.remove_status(electrified)
	enemy_view.set_combat_state(null, 0, statuses)
	checks.equal(enemy_view.get_effect_strength(StatusVisualChannel.Value.ELECTRIFIED), 0.0, "Removing Electrified clears the enemy electrical shader")
	var player_health_bar: StatusHealthBar = (load("res://presentation/combat/status_health_bar.tscn") as PackedScene).instantiate() as StatusHealthBar
	var enemy_health_bar: StatusHealthBar = (load("res://presentation/combat/status_health_bar.tscn") as PackedScene).instantiate() as StatusHealthBar
	player_health_bar.size = Vector2(200.0, 18.0)
	enemy_health_bar.size = Vector2(120.0, 18.0)
	player_health_bar.minimum_effect_display_seconds = 0.05
	add_child(player_health_bar)
	add_child(enemy_health_bar)
	await get_tree().process_frame
	var health_statuses: StatusCollection = StatusCollection.new()
	var poison: StatusDefinition = load("res://content/statuses/poison.tres") as StatusDefinition
	health_statuses.apply_status(burn, burn, 2, 1)
	health_statuses.apply_status(poison, poison, 2, 2)
	health_statuses.apply_status(electrified, electrified, 1, 1)
	player_health_bar.set_effects(health_statuses)
	checks.truthy(player_health_bar.get_effect_strength(StatusVisualChannel.Value.BURN) > 0.0, "Player health uses the burning shader when Burn is active")
	checks.truthy(player_health_bar.get_effect_strength(StatusVisualChannel.Value.POISON) > 0.0, "Player health uses the poison shader when Poison is active")
	checks.truthy(player_health_bar.get_effect_strength(StatusVisualChannel.Value.ELECTRIFIED) > 0.0, "Player health uses the electrical shader when stunned")
	checks.truthy(player_health_bar.effect_material != enemy_health_bar.effect_material, "Player and enemy health bars own independent shader materials")
	player_health_bar.motion.reduced_motion = true
	player_health_bar.set_effects(health_statuses)
	checks.equal(float(player_health_bar.effect_material.get_shader_parameter("electrified_speed")), 0.0, "Reduced motion keeps health-bar electricity static")
	health_statuses.instances.clear()
	player_health_bar.set_effects(health_statuses)
	checks.truthy(player_health_bar.get_effect_strength(StatusVisualChannel.Value.BURN) > 0.0, "Short-lived statuses remain visible for the configured shader pulse")
	await get_tree().create_timer(0.07).timeout
	checks.equal(player_health_bar.get_effect_strength(StatusVisualChannel.Value.BURN), 0.0, "Expired status pulses clear the health shader")
	for registered_status: StatusDefinition in ContentRegistry.statuses:
		if registered_status.visible_to_player:
			checks.truthy(registered_status.visual_definition != null, "Visible status has a shader profile: %s" % registered_status.display_name)
	var board_view: BoardView = BoardView.new()
	board_view.visual_settings = settings
	add_child(board_view)
	await get_tree().process_frame
	var markers: Array[PieceModifierDefinition] = board_view.get_board_effect_markers([EMBER_BRAND_MODIFIER, FRACTURE_MODIFIER, GUARDIAN_PATTERN_MODIFIER])
	checks.equal(markers.size(), settings.maximum_cell_markers, "Board markers respect the configured maximum")
	checks.truthy(markers.has(GUARDIAN_PATTERN_MODIFIER) and markers.has(FRACTURE_MODIFIER), "Highest-priority effect modifiers receive board marks")
	var effect_board: BoardState = BoardState.new(4, 4)
	var effect_piece: PieceInstance = PieceInstance.new(_piece(&"effect_marker_piece", [Vector2i.ZERO]))
	effect_piece.modifiers = [FRACTURE_MODIFIER]
	effect_board.place_piece(Vector2i(1, 1), effect_piece)
	board_view.size = Vector2(320.0, 320.0)
	board_view.set_board(effect_board)
	var preview_piece: PieceInstance = PieceInstance.new(effect_piece.definition)
	preview_piece.modifiers = [EMBER_BRAND_MODIFIER]
	board_view.set_active_piece(preview_piece)
	board_view.preview_origin = Vector2i(2, 2)
	board_view.preview_visible = true
	await get_tree().process_frame
	var placed_markers: Array[PieceModifierDefinition] = board_view.get_board_effect_markers(effect_board.get_occupant_modifiers(Vector2i(1, 1)))
	var preview_markers: Array[PieceModifierDefinition] = board_view.get_board_effect_markers(preview_piece.modifiers)
	checks.truthy(not placed_markers.is_empty() and placed_markers[0] == FRACTURE_MODIFIER, "Placed Block effects still resolve on the TileMap board")
	checks.truthy(not preview_markers.is_empty() and preview_markers[0] == EMBER_BRAND_MODIFIER, "Preview Block effects still resolve on the TileMap board")
	var effects_render_above_tiles: bool = not board_view.tile_renderer.tile_layers.is_empty()
	for tile_entry: BoardTileMapRenderer.TileLayerEntry in board_view.tile_renderer.tile_layers:
		effects_render_above_tiles = effects_render_above_tiles and not tile_entry.layer.z_as_relative and tile_entry.layer.z_index < board_view.z_index
	checks.truthy(effects_render_above_tiles, "Block effect visuals render above every TileMap layer")
	var effects: VFXLayer = (load("res://presentation/vfx/vfx_layer.tscn") as PackedScene).instantiate() as VFXLayer
	effects.position = Vector2(137.0, 83.0)
	add_child(effects)
	await get_tree().process_frame
	var expected_local: Vector2 = Vector2(48.0, 32.0)
	var global_point: Vector2 = effects.get_global_transform_with_canvas() * expected_local
	checks.truthy(effects.global_to_layer(global_point).distance_to(expected_local) < 0.01, "VFX converts global target points into its local canvas")
	var global_flash_rect: Rect2 = Rect2(global_point, Vector2(72.0, 44.0))
	effects.target_flash(global_flash_rect, Color.RED, 0.15, 0.2)
	checks.truthy(effects.target_flashes[0].visible, "Local player damage flash activates in the VFX layer")
	checks.truthy(effects.target_flashes[0].position.distance_to(expected_local) < 0.01, "Local player damage flash uses converted target coordinates")
	var run_scene: Control = (load("res://scenes/run/run_screen.tscn") as PackedScene).instantiate() as Control
	add_child(run_scene)
	await get_tree().process_frame
	checks.truthy((run_scene.get_node("VFXLayer") as VFXLayer).visible, "Run screen keeps combat VFX visible")
	var combo_label: Label = run_scene.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/Combo") as Label
	checks.truthy(combo_label.material == null, "Combo label does not use an effect material")
	var combo_minimum_size: Vector2 = combo_label.custom_minimum_size
	(run_scene as RunScreen).motion = MotionSettings.new()
	(run_scene as RunScreen)._update_combo_color(settings.combo.maximum_colored_combo)
	checks.equal(combo_label.get_theme_color("font_color"), settings.combo.color_for_combo(maximum_colored_combo), "Configured maximum combo uses the gradient's final color")
	checks.equal(combo_label.custom_minimum_size, combo_minimum_size, "Combo color feedback does not change label layout")
	run_scene.queue_free()
	effects.queue_free()
	board_view.queue_free()
	player_health_bar.queue_free()
	enemy_health_bar.queue_free()
	enemy_view.queue_free()

func _test_visual_layouts() -> void:
	checks.equal(int(ProjectSettings.get_setting("display/window/handheld/orientation", 0)), int(DisplayServer.SCREEN_SENSOR_LANDSCAPE), "Mobile builds follow the device sensor while preserving landscape orientation")
	var tutorials_enabled: bool = SaveService.profile.tutorial_progress.tutorials_enabled
	SaveService.profile.tutorial_progress.tutorials_enabled = false
	TutorialService.cancel_active()
	var main_scene: Control = (load("res://scenes/main/main.tscn") as PackedScene).instantiate() as Control
	add_child(main_scene)
	await get_tree().process_frame
	var transition_container: Control = main_scene.get_node("ScreenContainer") as Control
	var menu_settings: Button = transition_container.get_child(0).get_node("Composition/MenuCard/Menu/SettingsButton") as Button
	_send_main_touch(main_scene, menu_settings.get_global_rect().get_center(), 20)
	await get_tree().process_frame
	var settings_screen: SettingsScreen = transition_container.get_child(transition_container.get_child_count() - 1) as SettingsScreen
	checks.truthy(settings_screen != null, "Touch opens Settings through the persistent screen router")
	var settings_back: Button = settings_screen.get_node("Center/Panel/Layout/Back") as Button
	_send_main_touch(main_scene, settings_back.get_global_rect().get_center(), 21)
	await get_tree().process_frame
	checks.truthy(transition_container.get_child(transition_container.get_child_count() - 1) is HubScreen, "Touch remains active after replacing the current screen")
	main_scene.call("start_new_run", 1307, RunState.new().difficulty)
	await get_tree().process_frame
	var draft_screen: PieceDraftScreen = transition_container.get_child(transition_container.get_child_count() - 1) as PieceDraftScreen
	checks.truthy(draft_screen != null, "A touch-driven standard run opens the starting Block draft")
	var main_touch_layout_size: Vector2 = main_scene.size
	main_scene.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	main_scene.size = Vector2(480.0, 800.0)
	await get_tree().process_frame
	await get_tree().process_frame
	var draft_scroll: ScrollContainer = draft_screen.get_node("Margin/Layout/Content/Scroll") as ScrollContainer
	var draft_card: PieceDraftCard = draft_screen.get_node("Margin/Layout/Content/Scroll/CandidateGrid").get_child(0) as PieceDraftCard
	var selected_draft_cards_before_scroll: Array[int] = (main_scene.get("run_state") as RunState).piece_draft.selected_card_ids.duplicate()
	var draft_scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	draft_scroll_press.index = 34
	draft_scroll_press.position = draft_card.get_global_rect().get_center()
	draft_scroll_press.pressed = true
	draft_screen._input(draft_scroll_press)
	main_scene._input(draft_scroll_press)
	var draft_scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	draft_scroll_drag.index = draft_scroll_press.index
	draft_scroll_drag.position = draft_scroll_press.position - Vector2(0.0, 120.0)
	draft_scroll_drag.relative = Vector2(0.0, -120.0)
	draft_screen._input(draft_scroll_drag)
	main_scene._input(draft_scroll_drag)
	var draft_scroll_release: InputEventScreenTouch = InputEventScreenTouch.new()
	draft_scroll_release.index = draft_scroll_press.index
	draft_scroll_release.position = draft_scroll_drag.position
	draft_scroll_release.pressed = false
	draft_screen._input(draft_scroll_release)
	main_scene._input(draft_scroll_release)
	checks.truthy(draft_scroll.scroll_vertical > 0, "Dragging a starting Block card scrolls the pre-run selection")
	checks.equal((main_scene.get("run_state") as RunState).piece_draft.selected_card_ids, selected_draft_cards_before_scroll, "Scrolling the pre-run selection never toggles its starting Block")
	main_scene.size = main_touch_layout_size
	await get_tree().process_frame
	await get_tree().process_frame
	var randomize_draft: Button = draft_screen.get_node("Margin/Layout/Actions/Randomize") as Button
	_send_main_touch(main_scene, randomize_draft.get_global_rect().get_center(), 22)
	await get_tree().process_frame
	var begin_draft: Button = draft_screen.get_node("Margin/Layout/Actions/Begin") as Button
	checks.falsy(begin_draft.disabled, "Randomizing a touch draft creates a valid Block selection")
	_send_main_touch(main_scene, begin_draft.get_global_rect().get_center(), 23)
	await get_tree().process_frame
	var route_screen: RouteMapScreen = transition_container.get_child(transition_container.get_child_count() - 1) as RouteMapScreen
	var standard_run: RunState = main_scene.get("run_state") as RunState
	checks.truthy(route_screen != null, "Confirming a touch draft opens the standard route")
	checks.truthy(standard_run != null and not standard_run.deck_cards.is_empty(), "A touch-confirmed standard run reaches its route with a built deck")
	var available_route_button: Button
	for node: Node in route_screen.get_node("Margin/Layout/Panel/MapLayer/RouteScroll/RouteTree").get_children():
		var route_button: Button = node as Button
		if route_button != null and not route_button.disabled:
			available_route_button = route_button
			break
	checks.truthy(available_route_button != null, "Touch transition test finds an available route node")
	_send_main_touch(main_scene, available_route_button.get_global_rect().get_center(), 24)
	await get_tree().process_frame
	var routed_run_screen: RunScreen = transition_container.get_child(transition_container.get_child_count() - 1) as RunScreen
	checks.truthy(routed_run_screen != null, "Touch selects a route node after prior screen replacements")
	checks.truthy(routed_run_screen != null and routed_run_screen.controller.deck_state != null and not routed_run_screen.controller.deck_state.hand.is_empty(), "A touch-started standard combat draws a Block hand")
	var routed_pause: Button = routed_run_screen.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/PauseButton") as Button
	_send_main_touch(main_scene, routed_pause.get_global_rect().get_center(), 25)
	checks.truthy(main_scene.get("pause_screen") is PauseScreen, "Pause remains touchable after route-to-run replacement")
	var outgoing_screen: Control = transition_container.get_child(0) as Control
	main_scene.call("_clear_screens")
	checks.falsy(outgoing_screen.visible, "Outgoing screens become invisible immediately during scene changes")
	checks.falsy(outgoing_screen.is_processing_input() or outgoing_screen.is_processing_unhandled_input(), "Outgoing screens stop owning touch input before deferred deletion")
	main_scene.queue_free()
	await get_tree().process_frame
	SaveService.profile.tutorial_progress.tutorials_enabled = tutorials_enabled
	SaveService.save_profile()
	var addition_run: RunState = RunState.new()
	var pending_addition: PendingPieceAdditionState = PendingPieceAdditionState.new()
	for index: int in mini(3, ContentRegistry.pieces.size()):
		pending_addition.candidate_pieces.append(ContentRegistry.pieces[index])
	addition_run.pending_piece_addition = pending_addition
	var addition_screen: PieceAdditionScreen = (load("res://scenes/piece_draft/piece_addition_screen.tscn") as PackedScene).instantiate() as PieceAdditionScreen
	add_child(addition_screen)
	addition_screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	addition_screen.size = Vector2(480, 800)
	addition_screen.start(addition_run)
	await get_tree().process_frame
	await get_tree().process_frame
	var addition_panel: PanelContainer = addition_screen.get_node("Center/Panel") as PanelContainer
	var candidate_scroll: ScrollContainer = addition_screen.get_node("Center/Panel/Layout/CandidateScroll") as ScrollContainer
	checks.truthy(is_equal_approx(addition_panel.size.x, addition_screen.size.x * 0.5), "Block-addition dialog occupies half the screen width")
	candidate_scroll.scroll_horizontal = 0
	var scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	scroll_press.index = 8
	scroll_press.position = candidate_scroll.get_global_rect().get_center()
	scroll_press.pressed = true
	addition_screen._input(scroll_press)
	var scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	scroll_drag.index = 8
	scroll_drag.position = scroll_press.position - Vector2(90.0, 2.0)
	scroll_drag.relative = Vector2(-90.0, -2.0)
	addition_screen._input(scroll_drag)
	checks.truthy(candidate_scroll.scroll_horizontal > 0, "Block-addition candidates scroll horizontally with touch dragging")
	addition_screen.queue_free()
	await get_tree().process_frame
	var run_scene: RunScreen = (load("res://scenes/run/run_screen.tscn") as PackedScene).instantiate() as RunScreen
	add_child(run_scene)
	run_scene.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	run_scene.size = Vector2(1280, 720)
	await get_tree().process_frame
	await get_tree().process_frame
	var aspect: AspectRatioContainer = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/BoardAspect") as AspectRatioContainer
	var visual_board: BoardView = aspect.get_node("BoardView") as BoardView
	visual_board.set_board(BoardState.new(10, 10))
	var initial_size: Vector2 = visual_board.size
	var main_margin: MarginContainer = run_scene.get_node("MainMargin") as MarginContainer
	var discard_pile: PiecePileView = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt/ItemBeltLayout/DiscardPileView") as PiecePileView
	var draw_pile: PiecePileView = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt/ItemBeltLayout/DrawPileView") as PiecePileView
	var item_panel: PanelContainer = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt") as PanelContainer
	checks.truthy(main_margin.get_global_rect().end.y <= run_scene.size.y, "Run screen fits inside 720p height")
	checks.truthy(discard_pile.get_global_rect().end.y <= run_scene.size.y - 8.0, "Compact discard pile remains fully visible at 720p")
	checks.falsy(run_scene.has_node("MainMargin/ScreenLayout/TopStatus/StatusRow/PlayerPanel/PlayerHealthTrail"), "Player health has no redundant trail bar")
	checks.falsy(run_scene.has_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/EnemyStage/EnemyLayout/EnemyHealthTrail"), "Enemy health has no redundant trail bar")
	var drawn_board: Rect2 = visual_board.get_board_rect()
	drawn_board.position += visual_board.global_position
	checks.truthy(item_panel.get_global_rect().position.x >= drawn_board.end.x, "Potion rail stays right of the board")
	checks.truthy(draw_pile.get_global_rect().position.y < discard_pile.get_global_rect().position.y, "Draw and discard piles stack below the item slots")
	checks.falsy(run_scene.has_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/DiscardPanel"), "The obsolete large left discard rail is removed")
	var board_layout_position: Vector2 = visual_board.position
	var discard_layout_position: Vector2 = discard_pile.position
	visual_board._play_invalid_feedback()
	await get_tree().process_frame
	checks.equal(visual_board.position, board_layout_position, "Invalid placement shake never moves the board control")
	checks.equal(discard_pile.position, discard_layout_position, "Invalid placement shake never moves the compact discard pile")
	var place_button: Button = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/PlaceButton") as Button
	checks.truthy(place_button.custom_minimum_size.y >= 56.0, "Touch place action has a large target")
	var end_turn_button: Button = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/UtilityActions/EndTurnButton") as Button
	checks.truthy(end_turn_button.custom_minimum_size.y >= 50.0, "End Turn is exposed as a touch-sized action")
	var debug_panel: PanelContainer = run_scene.get_node("DebugPanel") as PanelContainer
	var debug_event_log: PanelContainer = run_scene.get_node("EventLogPanel") as PanelContainer
	var debug_log_button: Button = run_scene.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/LogButton") as Button
	var debug_close_button: Button = run_scene.get_node("DebugPanel/DebugLayout/DebugHeader/DebugClose") as Button
	var debug_action_groups: Array[GridContainer] = [
		run_scene.get_node("DebugPanel/DebugLayout/CombatActions") as GridContainer,
		run_scene.get_node("DebugPanel/DebugLayout/EncounterActions") as GridContainer,
		run_scene.get_node("DebugPanel/DebugLayout/TutorialActions") as GridContainer,
	]
	var debug_action_order: Array[StringName] = []
	for action_group: GridContainer in debug_action_groups:
		checks.equal(action_group.columns, run_scene.debug_overlay_desktop_columns, "Desktop debug actions use the configured column count")
		for child: Node in action_group.get_children():
			var action_button: Button = child as Button
			checks.truthy(action_button != null and action_button.custom_minimum_size.x >= 150.0 and action_button.custom_minimum_size.y >= 52.0, "Debug action %s has a touch-sized target" % child.name)
			debug_action_order.append(child.name)
	checks.equal(debug_action_order, [
		&"DebugDamage", &"DebugHeal", &"DebugBlocker", &"DebugClear",
		&"DebugModifier", &"DebugPrint", &"DebugRestart", &"DebugWin",
		&"DebugTutorial", &"DebugTutorialNext", &"DebugTutorialReset", &"DebugTutorialValidate",
	], "Debug actions are ordered by combat, encounter, and tutorial workflow")
	checks.truthy(debug_close_button.custom_minimum_size.y >= 52.0, "The debug overlay exposes a touch-sized Close action")
	debug_log_button.toggled.emit(true)
	checks.truthy(debug_panel.visible and debug_event_log.visible and debug_log_button.button_pressed, "Opening run debug keeps its panel, log, and header toggle synchronized")
	checks.truthy(Rect2(Vector2.ZERO, run_scene.size).encloses(debug_panel.get_global_rect()), "The desktop debug panel remains inside the run viewport")
	var debug_overlay_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	debug_overlay_touch.index = 35
	debug_overlay_touch.position = (run_scene.get_node("DebugPanel/DebugLayout/DebugText") as Label).get_global_rect().get_center()
	debug_overlay_touch.pressed = true
	run_scene.screen_swipe_gesture.begin(debug_overlay_touch.index, Vector2.ZERO, true)
	run_scene._input(debug_overlay_touch)
	checks.falsy(run_scene.screen_swipe_active, "Touching debug panel content cannot start or retain a gameplay swipe")
	debug_close_button.pressed.emit()
	checks.falsy(debug_panel.visible or debug_event_log.visible or debug_log_button.button_pressed, "Closing run debug hides both panels and resets the header toggle")
	var rotate_left: Button = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/RotateLeft") as Button
	var rotate_right: Button = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/RotateRight") as Button
	var rotate_left_key: Control = rotate_left.get_node("Label") as Control
	var rotate_right_key: Control = rotate_right.get_node("Label") as Control
	checks.truthy(rotate_left.custom_minimum_size.y >= 56.0 and rotate_right.custom_minimum_size.y >= 56.0, "Turn actions have mobile-sized touch targets")
	checks.truthy(rotate_left_key.visible and rotate_right_key.visible, "Desktop rotate actions show their Q and E keycaps")
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.COMBAT_ROTATE_TUTORIAL), rotate_right, "Desktop rotation onboarding highlights the visible rotate button")
	run_scene._apply_mobile_layout(true)
	checks.equal(TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.COMBAT_ROTATE_TUTORIAL), rotate_right, "Mobile rotation onboarding highlights the visible rotate button")
	checks.truthy(rotate_left.visible and rotate_right.visible, "Mobile layout keeps both rotate buttons available")
	checks.truthy(rotate_left_key.visible and rotate_right_key.visible, "Rotation key labels remain stable when the responsive layout changes")
	checks.falsy(run_scene.has_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/SwipeHint"), "Mobile rotation controls no longer show a swipe hint")
	run_scene._apply_mobile_layout(false)
	checks.truthy(rotate_left_key.visible and rotate_right_key.visible, "Returning to desktop restores rotate keycaps")
	var rotation_row: HBoxContainer = place_button.get_parent() as HBoxContainer
	var disabled_row_size: Vector2 = rotation_row.size
	place_button.disabled = false
	await get_tree().process_frame
	checks.equal(rotation_row.size, disabled_row_size, "Place availability does not resize its control row")
	checks.equal(visual_board.size, initial_size, "Place availability does not resize the board")
	var hand_view: PieceHandView = run_scene.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/PieceHandView") as PieceHandView
	hand_view.set_hand([_card(901, TRI_I_PIECE), _card(902, TET_O_PIECE, PRISM_GUARD_EFFECT), _card(903, TET_L_PIECE), _card(905, MONOMINO_PIECE)], 902)
	(run_scene.get_node("EventLogPanel/EventLog") as RichTextLabel).text = "A long event entry wraps without resizing the board allocation."
	await get_tree().process_frame
	checks.equal(visual_board.size, initial_size, "Board size is stable with a four-piece hand")
	checks.equal(hand_view.current_cards.size(), 4, "Reusable hand view renders every drawn piece")
	var hand_scroll: ScrollContainer = hand_view.get_node("CardScroll") as ScrollContainer
	var rendered_hand: HBoxContainer = hand_view.get_node("CardScroll/Cards") as HBoxContainer
	checks.truthy(rendered_hand.get_global_rect().end.x <= hand_scroll.get_global_rect().end.x + 1.0, "Four drawn pieces fit without horizontal clipping at 720p")
	var touch_selected_card_ids: Array[int] = []
	hand_view.card_selected.connect(func(card_id: int) -> void: touch_selected_card_ids.append(card_id))
	hand_view.set_hand([
		_card(906, TET_O_PIECE, PRISM_GUARD_EFFECT),
		_card(907, TRI_I_PIECE),
		_card(908, TET_L_PIECE),
		_card(909, MONOMINO_PIECE),
		_card(910, TET_O_PIECE),
		_card(911, TRI_I_PIECE),
	], 906)
	await get_tree().process_frame
	hand_scroll.scroll_horizontal = 0
	var effect_card: PieceHandCard = hand_view.card_control(906)
	var hand_touch_position: Vector2 = effect_card.get_global_rect().get_center()
	var hand_scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	hand_scroll_press.index = 31
	hand_scroll_press.position = hand_touch_position
	hand_scroll_press.pressed = true
	hand_view._input(hand_scroll_press)
	var hand_scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	hand_scroll_drag.index = 31
	hand_scroll_drag.position = hand_touch_position - Vector2(hand_view.touch_scroll_deadzone + 80.0, 0.0)
	hand_scroll_drag.relative = Vector2(-hand_view.touch_scroll_deadzone - 80.0, 0.0)
	hand_view._input(hand_scroll_drag)
	checks.truthy(hand_scroll.scroll_horizontal > 0, "Drawn pieces scroll horizontally with touch dragging")
	checks.truthy(hand_view.touch_dragging, "Drawn-piece dragging crosses the selection deadzone")
	var hand_scroll_release: InputEventScreenTouch = InputEventScreenTouch.new()
	hand_scroll_release.index = 31
	hand_scroll_release.position = hand_scroll_drag.position
	hand_scroll_release.pressed = false
	hand_view._input(hand_scroll_release)
	hand_view._select_card(906)
	checks.truthy(touch_selected_card_ids.is_empty(), "Touch scrolling does not select its starting piece")
	hand_scroll.scroll_horizontal = 0
	var detail_press: InputEventScreenTouch = InputEventScreenTouch.new()
	detail_press.index = 32
	detail_press.position = effect_card.get_global_rect().get_center()
	detail_press.pressed = true
	hand_view._input(detail_press)
	hand_view.touch_started_msec = Time.get_ticks_msec() - ceili(hand_view.touch_hold_duration * 1000.0) - 1
	hand_view._process(0.0)
	var effect_preview: PanelContainer = hand_view.get_node("EffectPreviewLayer/EffectPreview") as PanelContainer
	var effect_preview_text: Label = effect_preview.get_node("Margin/Content/EffectPreviewText") as Label
	checks.truthy(effect_preview.visible, "Holding a drawn piece opens its effect preview")
	checks.equal(effect_preview_text.text, effect_card.tooltip_text, "Touch hold and delayed mouse hover use the same piece-effect details")
	var detail_release: InputEventScreenTouch = InputEventScreenTouch.new()
	detail_release.index = 32
	detail_release.position = detail_press.position
	detail_release.pressed = false
	hand_view._input(detail_release)
	checks.falsy(effect_preview.visible, "Releasing a held piece closes its effect preview")
	hand_view._select_card(906)
	checks.truthy(touch_selected_card_ids.is_empty(), "Viewing a held piece effect does not select that piece")
	hand_view.set_hand([_card(904, MONOMINO_PIECE)], 904)
	await get_tree().process_frame
	checks.equal(visual_board.size, initial_size, "Board size is stable with a one-card hand")
	for viewport_size: Vector2 in [Vector2(1920, 1080), Vector2(2560, 1080)]:
		run_scene.size = viewport_size
		await get_tree().process_frame
		var board_rectangle: Rect2 = visual_board.get_board_rect()
		checks.truthy(board_rectangle.size.x > 500.0 and board_rectangle.size.x == board_rectangle.size.y, "Square board remains readable at %s" % viewport_size)
	run_scene.size = Vector2(480, 800)
	await get_tree().process_frame
	await get_tree().process_frame
	for action_group: GridContainer in debug_action_groups:
		checks.equal(action_group.columns, run_scene.debug_overlay_compact_columns, "Compact debug actions use the configured column count")
	checks.truthy(debug_panel.get_global_rect().end.x <= run_scene.size.x - run_scene.debug_overlay_margin + 1.0, "Compact debug panel width remains inside the run viewport: %s within %s" % [debug_panel.get_global_rect(), run_scene.size])
	var place_parent: Node = place_button.get_parent()
	place_parent.remove_child(place_button)
	place_button.free()
	run_scene._update_place_button()
	checks.truthy(true, "Late preview updates are safe during combat-screen teardown")
	run_scene.queue_free()
	await get_tree().process_frame
	var live_run: RunState = RunState.new()
	live_run.player_health = 10
	var strength_definition: ItemDefinition = STRENGTH_TONIC_ITEM
	var strength_stack: ItemStack = ItemStack.new()
	strength_stack.definition = strength_definition
	strength_stack.quantity = 2
	live_run.inventory.add(strength_stack)
	var barrier_definition: ItemDefinition = BARRIER_POTION_ITEM
	var barrier_stack: ItemStack = ItemStack.new()
	barrier_stack.definition = barrier_definition
	barrier_stack.quantity = 1
	live_run.inventory.add(barrier_stack)
	var capsule_definition: ItemDefinition = BLOCK_CAPSULE_ITEM
	var capsule_stack: ItemStack = ItemStack.new()
	capsule_stack.definition = capsule_definition
	capsule_stack.bonus_piece = ContentRegistry.pieces[0]
	capsule_stack.quantity = 1
	live_run.inventory.add(capsule_stack)
	var bomb_definition: ItemDefinition = BOMB_FLASK_ITEM
	var bomb_stack: ItemStack = ItemStack.new()
	bomb_stack.definition = bomb_definition
	bomb_stack.quantity = 1
	live_run.inventory.add(bomb_stack)
	var live_scene: RunScreen = (load("res://scenes/run/run_screen.tscn") as PackedScene).instantiate() as RunScreen
	add_child(live_scene)
	live_scene.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	live_scene.size = Vector2(1280, 720)
	var inventory_events: Array[TutorialEventId.Value] = []
	var inventory_event_recorder: Callable = func(event: TutorialEvent) -> void: inventory_events.append(event.type)
	var previous_tutorials_enabled: bool = SaveService.profile.tutorial_progress.tutorials_enabled
	SaveService.profile.tutorial_progress.tutorials_enabled = false
	TutorialService.event_published.connect(inventory_event_recorder)
	live_scene.start(live_run, TRAINING_SLIME_ENEMY, PieceGenerator.new(7120))
	TutorialService.event_published.disconnect(inventory_event_recorder)
	SaveService.profile.tutorial_progress.tutorials_enabled = previous_tutorials_enabled
	checks.truthy(inventory_events.has(TutorialEventId.Value.ITEM_INVENTORY_VISIBLE), "Inventory tutorial waits for combat with a visible usable item")
	checks.truthy(inventory_events.has(TutorialEventId.Value.BONUS_BLOCK_INVENTORY_VISIBLE), "Bonus Block tutorial waits for combat with a visible capsule")
	checks.equal(ITEMS_INVENTORY_TUTORIAL.activation_event, TutorialEventId.Value.ITEM_INVENTORY_VISIBLE, "Item acquisition does not open the combat inventory tutorial on reward or route screens")
	await get_tree().process_frame
	await get_tree().process_frame
	var live_board: BoardView = live_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/BoardAspect/BoardView") as BoardView
	var live_discard: PiecePileView = live_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt/ItemBeltLayout/DiscardPileView") as PiecePileView
	var live_board_size: Vector2 = live_board.size
	var first_item_button: Button = live_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt/ItemBeltLayout/BeltSlots/Item1") as Button
	var third_item_button: Button = live_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt/ItemBeltLayout/BeltSlots/Item3") as Button
	checks.truthy(live_board.preview_visible and live_board.touch_armed and live_board.can_confirm_preview(), "The initially selected Block appears as a valid board preview")
	var initial_piece: PieceInstance = live_scene.controller.active_piece
	var switched_card_index: int = -1
	for card_index: int in live_scene.controller.deck_state.hand.size():
		if card_index != live_scene.controller.active_card_index and live_scene.controller.hand_placeable[card_index]:
			switched_card_index = card_index
			break
	checks.truthy(switched_card_index >= 0, "The preview switching test has another placeable hand card")
	if switched_card_index >= 0:
		live_scene.controller.select_choice(switched_card_index)
		checks.truthy(live_scene.controller.active_piece != initial_piece, "Switching hand cards creates the selected Block")
		checks.equal(live_board.active_piece, live_scene.controller.active_piece, "Switching hand cards updates the board preview Block")
		checks.truthy(live_board.preview_visible and live_board.touch_armed and live_board.can_confirm_preview(), "The switched Block immediately appears at a valid board position")
	checks.truthy(live_discard.get_global_rect().end.y <= live_scene.size.y - 8.0, "Live run discard pile fits at 720p")
	checks.equal(first_item_button.get("definition") as ItemDefinition, strength_definition, "Item rail renders the stored item's icon definition")
	checks.equal(first_item_button.icon, strength_definition.icon, "Item rail renders the generated Field Device texture")
	checks.equal((first_item_button.get("stack") as ItemStack).quantity, 2, "Item icon retains its visible charge count")
	checks.truthy(first_item_button.tooltip_text.contains(strength_definition.display_name), "Potion rail exposes the full item name")
	checks.equal((live_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt/ItemBeltLayout/ItemCaption") as Label).text, "ITEMS", "Shared inventory rail is labelled for every item type")
	checks.truthy(third_item_button.tooltip_text.contains(capsule_definition.display_name), "Non-potion items appear in the shared inventory rail")
	checks.truthy(first_item_button.size.x >= 70.0 and first_item_button.size.y >= 52.0, "Run item buttons provide a larger touch target")
	third_item_button.button_down.emit()
	live_scene.item_touch_started_msec = Time.get_ticks_msec() - roundi(live_scene.item_hold_duration * 1000.0) - 1
	live_scene._process(0.0)
	checks.truthy((live_scene.get_node("ItemInfoOverlay") as Control).visible, "Holding an item opens its information overlay")
	checks.truthy((live_scene.get_node("ItemInfoOverlay/Center/Panel/Layout/ItemInfoEffects") as Label).text.contains(capsule_definition.description), "Item information describes its usable effect")
	third_item_button.button_up.emit()
	third_item_button.pressed.emit()
	checks.truthy(live_run.inventory.slots[2] != null, "Releasing a held item does not use it behind the information overlay")
	live_scene._hide_item_info()
	var capsule_result: ItemUseResult = live_scene.controller.use_item(2)
	checks.truthy(capsule_result.used, "Block Capsule starts a bonus placement")
	checks.truthy(live_board.preview_visible and live_board.touch_armed, "Block Capsule immediately arms its board preview")
	checks.truthy(live_board.can_confirm_preview(), "Automatic Capsule preview starts at a valid placement")
	checks.truthy(live_scene.controller.cancel_bonus_placement(), "Capsule preview can be cancelled without consuming it")
	checks.truthy(live_run.inventory.slots[2] != null, "Cancelling a Capsule preview preserves the item")
	var enemy_health_before_item: int = live_scene.controller.enemy_health
	var fourth_item_button: Button = live_scene.get_node("MainMargin/ScreenLayout/MainLayout/BoardFrame/BoardFrameLayout/ItemBelt/ItemBeltLayout/BeltSlots/Item4") as Button
	fourth_item_button.button_down.emit()
	fourth_item_button.button_up.emit()
	fourth_item_button.pressed.emit()
	checks.equal(live_scene.controller.enemy_health, enemy_health_before_item - 6, "Short tapping a non-potion item applies its effect")
	checks.truthy(live_run.inventory.slots[3] == null, "Using a non-potion item consumes its shared inventory charge")
	live_scene.controller._set_state(EncounterController.TurnState.RESOLVING_ENEMY)
	checks.truthy(first_item_button.disabled, "Items pause only while a turn is resolving")
	live_scene.controller._set_state(EncounterController.TurnState.AWAITING_PLACEMENT)
	checks.falsy(first_item_button.disabled, "Items become usable again on every player turn")
	var swipe_piece: PieceInstance = PieceInstance.new(_piece(&"screen_swipe", [Vector2i.ZERO, Vector2i.RIGHT, Vector2i(0, 1)]))
	live_scene.controller.active_piece = swipe_piece
	live_scene.controller.state = EncounterController.TurnState.AWAITING_PLACEMENT
	live_board.set_active_piece(swipe_piece)
	_send_run_swipe(live_scene, Vector2(1120, 260), Vector2(1210, 262))
	checks.equal(swipe_piece.rotation_index, 1, "Right swiping rotates Blocks clockwise across the run screen")
	_send_run_swipe(live_scene, Vector2(1120, 270), Vector2(1122, 180))
	checks.equal(swipe_piece.rotation_index, 2, "Up swiping also rotates Blocks clockwise")
	_send_run_swipe(live_scene, Vector2(1120, 260), Vector2(1030, 258))
	checks.equal(swipe_piece.rotation_index, 3, "Left swiping remains clockwise regardless of direction")
	var invalid_drag_release: InputEventScreenTouch = InputEventScreenTouch.new()
	invalid_drag_release.index = 8
	invalid_drag_release.position = Vector2(120.0, 0.0)
	live_scene.screen_swipe_gesture.begin(invalid_drag_release.index, Vector2.ZERO, true)
	live_scene.screen_swipe_gesture.update(invalid_drag_release.index, invalid_drag_release.position)
	live_board.touch_active = true
	live_board.touch_started_armed = true
	live_scene._resolve_screen_swipe(invalid_drag_release)
	checks.equal(swipe_piece.rotation_index, 3, "Dragging an invalid first-touch preview does not also rotate the Block")
	checks.falsy(live_scene.screen_swipe_active, "Invalid preview dragging clears the competing screen swipe")
	live_board.touch_active = false
	live_board.touch_started_armed = false
	var pause_button: Button = live_scene.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/PauseButton") as Button
	var log_button: Button = live_scene.get_node("MainMargin/ScreenLayout/TopStatus/StatusRow/LogButton") as Button
	var rotation_before_header_touch: int = swipe_piece.rotation_index
	_send_run_swipe(live_scene, pause_button.get_global_rect().get_center(), pause_button.get_global_rect().get_center() + Vector2(90.0, 2.0))
	checks.equal(swipe_piece.rotation_index, rotation_before_header_touch, "Touch movement over Pause is never consumed as a gameplay swipe")
	checks.falsy(live_scene.screen_swipe_active, "Pause touches do not leave stale full-screen swipe state")
	_send_run_swipe(live_scene, log_button.get_global_rect().get_center(), log_button.get_global_rect().get_center() - Vector2(90.0, 2.0))
	checks.equal(swipe_piece.rotation_index, rotation_before_header_touch, "Touch movement over Log is never consumed as a gameplay swipe")
	checks.falsy(live_scene.screen_swipe_active, "Log touches do not leave stale full-screen swipe state")
	var pause_requests: Array[int] = [0]
	live_scene.pause_requested.connect(func() -> void: pause_requests[0] += 1)
	var priority_pause_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	priority_pause_touch.index = 9
	priority_pause_touch.position = pause_button.get_global_rect().get_center()
	priority_pause_touch.pressed = true
	live_scene.presentation.playing = true
	live_scene.controller.state = EncounterController.TurnState.RESOLVING_ENEMY
	live_scene._input(priority_pause_touch)
	checks.equal(pause_requests[0], 1, "Pause touch remains available while combat presentation owns gameplay input")
	live_scene.presentation.playing = false
	live_scene.controller.state = EncounterController.TurnState.AWAITING_PLACEMENT
	var tutorial_blocker: TutorialInputBlocker = TutorialInputBlocker.new()
	add_child(tutorial_blocker)
	tutorial_blocker.target_rect = Rect2()
	checks.truthy(tutorial_blocker.is_pointer_allowed(pause_button.get_global_rect().get_center(), TutorialInputMode.Value.TARGET_ONLY), "Tutorial input restrictions always allow Pause")
	checks.truthy(tutorial_blocker.is_pointer_allowed(log_button.get_global_rect().get_center(), TutorialInputMode.Value.TARGET_ONLY), "Tutorial input restrictions always allow Log")
	var pause_overlay: PauseScreen = (load("res://scenes/pause/pause_screen.tscn") as PackedScene).instantiate() as PauseScreen
	add_child(pause_overlay)
	await get_tree().process_frame
	checks.truthy(pause_overlay.visible and (pause_overlay.get_node("Shade") as Control).visible and (pause_overlay.get_node("Center") as Control).visible, "Pause overlay and its contents are visible when opened")
	var leave_button: Button = pause_overlay.get_node("Center/Panel/Layout/MainMenu") as Button
	checks.truthy(tutorial_blocker.is_pointer_allowed(leave_button.get_global_rect().get_center(), TutorialInputMode.Value.TARGET_ONLY), "Tutorial input restrictions allow pause-menu Leave controls")
	pause_overlay.queue_free()
	tutorial_blocker.queue_free()
	var previous_run_mode: RunMode.Value = live_run.run_mode
	live_run.run_mode = RunMode.Value.TUTORIAL
	live_scene._apply_mobile_layout(true)
	checks.truthy(TutorialService.start_tutorial(GUIDED_ONBOARDING_TUTORIAL, true), "Guided onboarding can start for the mobile rotation integration test")
	TutorialService.call("_jump_to_step", GUIDED_ONBOARDING_TUTORIAL.steps[3])
	checks.truthy(live_board.preview_visible and live_board.touch_armed, "The mobile rotation step starts with a visible armed piece preview")
	var mobile_rotate_right: Button = live_scene.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/DraftPanel/DraftLayout/Rotation/RotateRight") as Button
	mobile_rotate_right.pressed.emit()
	checks.equal(TutorialService.current_step(), GUIDED_ONBOARDING_TUTORIAL.steps[4], "Pressing the visible mobile rotate button publishes rotation and completes the tutorial step")
	TutorialService.cancel_active()
	live_scene._apply_mobile_layout(false)
	live_run.run_mode = previous_run_mode
	checks.truthy(live_scene.controller.use_item(0).used, "First potion can be used before placement")
	checks.equal(live_run.inventory.slots[0].quantity, 1, "Using a potion removes only one charge")
	checks.truthy(live_scene.controller.use_item(1).used, "A second potion can be used in the same turn")
	checks.equal(live_run.inventory.slots[0].quantity, 1, "Using another slot does not remove the first potion")
	checks.truthy(live_scene.controller.use_item(0).used, "Potion use has no per-turn or per-encounter limit")
	await get_tree().process_frame
	checks.equal(live_run.item_uses_remaining, -1, "Unlimited potion mode remains active")
	checks.equal(live_board.size, live_board_size, "Using items does not resize the board")
	checks.truthy(live_discard.get_global_rect().end.y <= live_scene.size.y - 8.0, "Using items keeps the run screen inside 720p")
	live_scene.queue_free()
	await get_tree().process_frame
	var reward_run: RunState = RunState.new()
	reward_run.pending_profile_fragments = 10
	reward_run.reward_rerolls = 1
	var reward_scene: RewardScreen = (load("res://scenes/rewards/reward_screen.tscn") as PackedScene).instantiate() as RewardScreen
	add_child(reward_scene)
	reward_scene.start(reward_run, PieceGenerator.new(9417))
	checks.truthy((reward_scene.get_node("Center/Panel/Layout/Summary") as Label).text.contains("+10 Fragments"), "Boss reward screen shows the permanent Fragment payout")
	var attached_index: int = -1
	for index: int in reward_scene.attached_items.size():
		if reward_scene.attached_items[index] != null:
			attached_index = index
			break
	checks.truthy(attached_index >= 0, "Reward generation attaches a potion")
	var attached_definition: ItemDefinition = reward_scene.attached_items[attached_index]
	reward_scene._select_reward(attached_index)
	var committed_rewards: Array[RelicDefinition] = reward_scene.rewards.duplicate()
	reward_scene._reroll_rewards()
	checks.equal(reward_run.reward_rerolls, 1, "Committed rewards cannot consume a reroll during their exit animation")
	checks.equal(reward_scene.rewards, committed_rewards, "Committed reward offers cannot change during their exit animation")
	checks.truthy((reward_scene.get_node("Center/Panel/Layout/Reroll") as Button).disabled, "Reward reroll control disables immediately after commitment")
	var reward_stack_found: bool = false
	for stack: ItemStack in reward_run.inventory.slots:
		if stack != null and stack.definition == attached_definition:
			reward_stack_found = true
	checks.truthy(reward_stack_found, "Selecting an attached reward adds its potion to inventory")
	var reward_confirmation: Label = reward_scene.get_node("Center/Panel/Layout/Confirmation") as Label
	checks.truthy(reward_confirmation.text.contains(reward_scene.attached_items[attached_index].display_name), "Reward confirmation names the granted potion")
	reward_scene.queue_free()
	await get_tree().process_frame
	var route_tree: RouteTreeView = RouteTreeView.new()
	add_child(route_tree)
	route_tree.size = Vector2(1000, 470)
	route_tree.symbol_set = load("res://content/presentation/route_symbol_set.tres") as RouteSymbolSet
	var route: GeneratedRoute = RouteGenerator.new().generate(9182, false)
	route_tree.setup(route, 0)
	await get_tree().process_frame
	var act_node_count: int = 0
	var boss_node: RouteNodeState
	for node: RouteNodeState in route.nodes:
		if node.act == 0:
			act_node_count += 1
			if node.type == RouteNodeState.NodeType.BOSS:
				boss_node = node
	checks.equal(route_tree.node_buttons.size(), act_node_count, "Route tree creates every act node")
	for route_button: Button in route_tree.node_buttons.values():
		var route_card: RouteNodeCard = route_button as RouteNodeCard
		checks.truthy(route_card.symbol_texture != null, "Every route room uses its configured themed symbol")
		checks.truthy(Rect2(Vector2.ZERO, route_card.size).encloses(route_card.get_icon_rect()), "Route symbols remain inside their touch targets")
		checks.truthy(route_card.text.is_empty(), "Route rooms no longer render card labels")
	var first_node: RouteNodeState = route.get_node_at(0, 0, 0)
	var first_button: Button = route_tree.node_buttons[first_node]
	var boss_button: Button = route_tree.node_buttons[boss_node]
	checks.truthy(boss_button.position.x > first_button.position.x, "Route tree advances horizontally")
	checks.equal(boss_button.position.y, (route_tree.size.y - boss_button.size.y) * 0.5, "Boss is centered in route tree")
	checks.truthy(route_tree.custom_minimum_size.x > 1000.0, "Route tree exposes scrollable horizontal content instead of compressing every column")
	route_tree.queue_free()

func _test_lethal_presentation_sequence() -> void:
	var lethal_run: RunState = RunState.new()
	lethal_run.player_health = 1
	lethal_run.maximum_health = 20
	var lethal_enemy: EnemyDefinition = EnemyDefinition.new()
	lethal_enemy.display_name = "Lethal Test"
	lethal_enemy.maximum_health = 100
	lethal_enemy.attack_interval = 1
	lethal_enemy.direct_damage = 2
	var screen: RunScreen = (load("res://scenes/run/run_screen.tscn") as PackedScene).instantiate() as RunScreen
	add_child(screen)
	screen.start(lethal_run, lethal_enemy, PieceGenerator.new(31337))
	screen.presentation.motion.animation_speed = 10.0
	screen.enemy_presentation.motion.animation_speed = 10.0
	var outward_loss: Array[bool] = [false]
	screen.run_lost.connect(func(_reason: String) -> void: outward_loss[0] = true)
	var placement_origin: Vector2i = Vector2i(-1, -1)
	for y: int in screen.controller.board.height:
		for x: int in screen.controller.board.width:
			var cells: Array[Vector2i] = []
			for offset: Vector2i in screen.controller.active_piece.get_cells():
				cells.append(Vector2i(x, y) + offset)
			if screen.controller.board.can_place(cells):
				placement_origin = Vector2i(x, y)
				break
		if placement_origin.x >= 0:
			break
	checks.truthy(placement_origin.x >= 0, "Lethal sequence finds a valid placement")
	screen.controller.place(placement_origin)
	checks.falsy(outward_loss[0], "Lethal run end waits for queued attack presentation")
	await screen.presentation.wait_until_idle()
	await get_tree().process_frame
	await get_tree().process_frame
	checks.truthy(outward_loss[0], "Lethal run end emits after attack presentation")
	screen.queue_free()

func _test_touch_board_controls() -> void:
	var touch_board: BoardView = BoardView.new()
	touch_board.size = Vector2(400, 400)
	add_child(touch_board)
	await get_tree().process_frame
	var touch_board_state: BoardState = BoardState.new(4, 4)
	touch_board_state.set_cell(Vector2i.ZERO, 1)
	touch_board.set_board(touch_board_state)
	var monomino: PieceDefinition = _piece(&"touch_one", [Vector2i.ZERO])
	touch_board.set_active_piece(PieceInstance.new(monomino))
	await get_tree().process_frame
	checks.truthy(touch_board.tile_renderer != null and touch_board.tile_renderer.get_tile_count() >= 16, "The run board renders its cells through the shared TileMap")
	checks.equal(touch_board.tile_renderer.tile_texture_size, 128, "Generated board tiles preserve the configured high-resolution Block texture")
	var tile_center: int = touch_board.tile_renderer.tile_texture_size / 2
	var bevel_edge: int = touch_board.tile_renderer.tile_texture_size - touch_board.tile_renderer.block_visual_settings.tile_bevel_inset - 2
	checks.truthy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.SOLID, Vector2i.ZERO), "Combat Block fills reach the tile edge without a margin")
	checks.truthy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.OUTLINE, Vector2i.ZERO), "Combat Block outlines follow the outer tile edge")
	checks.falsy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.OUTLINE, Vector2i.ONE * tile_center), "Combat Block outlines remain hollow and thin")
	checks.truthy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.BEVEL_HIGHLIGHT, Vector2i(3, tile_center)), "Combat Blocks brighten along their inset left edge")
	checks.truthy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.BEVEL_HIGHLIGHT, Vector2i(tile_center, 3)), "Combat Blocks brighten along their inset top edge")
	checks.truthy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.BEVEL_SHADOW, Vector2i(bevel_edge, tile_center)), "Combat Blocks darken along their inset right edge")
	checks.truthy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.BEVEL_SHADOW, Vector2i(tile_center, bevel_edge)), "Combat Blocks darken along their inset bottom edge")
	checks.falsy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.BEVEL_HIGHLIGHT, Vector2i.ONE * tile_center), "Combat Block bevels leave the center face clear")
	checks.truthy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.MECHANICAL_CORNER_CUT, Vector2i.ZERO), "Placed combat Blocks use clipped mechanical corners")
	checks.falsy(touch_board.tile_renderer._style_contains_pixel(BoardTileMapRenderer.TileStyle.MECHANICAL_CORNER_CUT, Vector2i.ONE * tile_center), "Mechanical corner cuts leave the Block face clean")
	var block_style_image: Image = touch_board.tile_renderer.block_visual_settings.block_style_texture.get_image()
	checks.equal(block_style_image.get_size(), Vector2i(256, 256), "Replacement Block textures preserve the configured source resolution")
	checks.equal(block_style_image.get_pixel(0, 0).a, 0.0, "Replacement Block textures preserve transparent corners")
	var empty_dot_count: int = 0
	var block_style_texture_count: int = 0
	for tile_entry: BoardTileMapRenderer.TileLayerEntry in touch_board.tile_renderer.tile_layers:
		if tile_entry.style == BoardTileMapRenderer.TileStyle.DOT:
			empty_dot_count += tile_entry.layer.get_used_cells().size()
		elif tile_entry.band == BoardTileMapRenderer.LayerBand.OCCUPIED and tile_entry.style == BoardTileMapRenderer.TileStyle.BLOCK_STYLE_TEXTURE:
			block_style_texture_count += tile_entry.layer.get_used_cells().size()
	checks.equal(empty_dot_count, 0, "Empty combat cells render without center circles")
	checks.equal(block_style_texture_count, 1, "Only placed combat Blocks receive the configured style texture")
	var marker_board: BoardState = BoardState.new(4, 4)
	var marker_cells: Array[Vector2i] = []
	var marker_styles: Array[int] = []
	for effect_index: int in ContentRegistry.card_effects.size():
		var effect: PieceCardEffectDefinition = ContentRegistry.card_effects[effect_index]
		var marker_cell: Vector2i = Vector2i(effect_index % marker_board.width, effect_index / marker_board.width)
		var marker_card: PieceCardState = _card(9000 + effect_index, monomino, effect)
		var marker_piece: PieceInstance = PieceInstance.new()
		marker_piece.bind_card(marker_card)
		checks.truthy(marker_board.place_piece(marker_cell, marker_piece).success, "Effect marker test places %s" % effect.display_name)
		checks.falsy(marker_styles.has(int(effect.marker_style)), "Each registered Block effect has a distinct board marker style")
		marker_styles.append(int(effect.marker_style))
		marker_cells.append(marker_cell)
	touch_board.set_board(marker_board)
	await get_tree().process_frame
	for marker_index: int in marker_cells.size():
		checks.equal(marker_board.get_occupant_card_effect(marker_cells[marker_index]), ContentRegistry.card_effects[marker_index], "Placed Block retains the effect used by its visual indicator")
	checks.truthy(touch_board.visual_settings.piece_effect_marker_radius_ratio > 0.0 and touch_board.visual_settings.piece_effect_marker_fill_opacity > 0.0, "Placed effect indicators use configurable combat visual settings")
	touch_board_state.set_cell(Vector2i.ZERO, BoardState.EMPTY)
	touch_board.set_board(touch_board_state)
	await get_tree().process_frame
	var placements: Array[Vector2i] = []
	var rotations: Array[bool] = []
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 0
	touch_board.placement_requested.connect(func(origin: Vector2i) -> void: placements.append(origin))
	touch_board.rotation_requested.connect(func(clockwise: bool) -> void: rotations.append(clockwise))
	_send_touch(touch_board, Vector2(50, 50), true)
	drag.position = Vector2(130, 52)
	drag.relative = Vector2(80, 2)
	touch_board._gui_input(drag)
	_send_touch(touch_board, Vector2(130, 52), false)
	checks.falsy(touch_board.touch_armed, "Dragging cannot begin before a preview is armed")
	checks.falsy(touch_board.preview_visible, "An unarmed swipe does not leave a misplaced preview")
	_send_touch(touch_board, Vector2(50, 50), true)
	_send_touch(touch_board, Vector2(50, 50), false)
	checks.equal(placements.size(), 0, "First touch tap arms placement without committing")
	checks.truthy(touch_board.can_confirm_preview(), "Armed touch preview can use Place action")
	_send_touch(touch_board, Vector2(50, 50), true)
	drag.position = Vector2(68, 52)
	drag.relative = Vector2(18, 2)
	touch_board._gui_input(drag)
	_send_touch(touch_board, Vector2(68, 52), false)
	checks.equal(placements.size(), 1, "Finger jitter still registers as a tap on an armed preview cell")
	touch_board.set_active_piece(PieceInstance.new(monomino))
	_send_touch(touch_board, Vector2(50, 50), true)
	_send_touch(touch_board, Vector2(50, 50), false)
	_send_touch(touch_board, Vector2(50, 50), true)
	drag.position = Vector2(130, 52)
	drag.relative = Vector2(80, 2)
	touch_board._gui_input(drag)
	_send_touch(touch_board, Vector2(130, 52), false)
	checks.equal(rotations.size(), 0, "Horizontal dragging from the preview never rotates on release")
	_send_touch(touch_board, Vector2(250, 250), true)
	drag.position = Vector2(330, 252)
	drag.relative = Vector2(80, 2)
	touch_board._gui_input(drag)
	_send_touch(touch_board, Vector2(330, 252), false)
	checks.equal(rotations.size(), 0, "Board dragging never interprets release as rotation")
	checks.equal(touch_board.preview_origin, Vector2i(1, 0), "Dragging cannot start away from the armed preview")
	_send_touch(touch_board, Vector2(250, 250), true)
	_send_touch(touch_board, Vector2(250, 250), false)
	checks.equal(touch_board.preview_origin, Vector2i(2, 2), "Tapping an empty board cell repositions the armed preview")
	checks.truthy(touch_board.touch_armed, "Repositioning by tap keeps the preview armed")
	touch_board.set_active_piece(PieceInstance.new(monomino))
	_send_touch(touch_board, Vector2(150, 150), true)
	_send_touch(touch_board, Vector2(150, 150), false)
	checks.equal(placements.size(), 1, "Touch release only arms the preview and never places immediately")
	touch_board.set_active_piece(PieceInstance.new(monomino))
	_send_touch(touch_board, Vector2(250, 250), true)
	_send_touch(touch_board, Vector2(250, 250), false)
	touch_board.confirm_preview()
	checks.equal(placements.size(), 2, "Place action commits an armed preview")
	var domino: PieceDefinition = _piece(&"touch_domino", [Vector2i.ZERO, Vector2i.RIGHT])
	touch_board.set_active_piece(PieceInstance.new(domino))
	_send_touch(touch_board, Vector2(50, 50), true)
	_send_touch(touch_board, Vector2(50, 50), false)
	_send_touch(touch_board, Vector2(150, 50), true)
	_send_touch(touch_board, Vector2(150, 50), false)
	checks.equal(placements.size(), 3, "Tap on any occupied preview cell confirms a multi-cell Block")
	touch_board.set_active_piece(PieceInstance.new(domino))
	_send_touch(touch_board, Vector2(50, 50), true)
	_send_touch(touch_board, Vector2(50, 50), false)
	_send_touch(touch_board, Vector2(50, 50), true)
	drag.position = Vector2(520, 520)
	drag.relative = Vector2(470, 470)
	touch_board._gui_input(drag)
	_send_touch(touch_board, Vector2(520, 520), false)
	checks.equal(touch_board.preview_origin, Vector2i(2, 3), "Touch dragging clamps every Block cell inside the board")
	var no_snap_board: BoardState = BoardState.new(4, 4)
	no_snap_board.set_cell(Vector2i(2, 3), 1)
	touch_board.set_board(no_snap_board)
	touch_board.set_active_piece(PieceInstance.new(monomino))
	_send_touch(touch_board, Vector2(250, 150), true)
	_send_touch(touch_board, Vector2(250, 150), false)
	checks.equal(touch_board.preview_origin, Vector2i(2, 1), "Touch placement stays on the selected cell without snapping toward occupied cells")
	var occupied_preview_board: BoardState = BoardState.new(4, 4)
	occupied_preview_board.set_cell(Vector2i(1, 1), 1)
	touch_board.set_board(occupied_preview_board)
	touch_board.set_active_piece(PieceInstance.new(monomino))
	_send_touch(touch_board, Vector2(150, 150), true)
	checks.falsy(touch_board.can_confirm_preview(), "Touch preview remains invalid on an occupied cell")
	drag.position = Vector2(250, 150)
	drag.relative = Vector2(100, 0)
	touch_board._gui_input(drag)
	_send_touch(touch_board, Vector2(250, 150), false)
	checks.equal(touch_board.preview_origin, Vector2i(2, 1), "An invalid first-touch preview can be dragged away from an occupied cell")
	checks.truthy(touch_board.touch_armed and touch_board.can_confirm_preview(), "Dragging an invalid first-touch preview arms it at the open destination")
	touch_board.set_board(BoardState.new(5, 5))
	var anchor_piece_definition: PieceDefinition = _piece(&"touch_anchor_j", [Vector2i(1, 2), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2)])
	var anchor_piece: PieceInstance = PieceInstance.new(anchor_piece_definition)
	touch_board.set_active_piece(anchor_piece)
	var anchor_pointer_position: Vector2 = Vector2(200, 200)
	var anchor_pointer_cell: Vector2i = touch_board.local_position_to_grid(anchor_pointer_position)
	var anchor_mouse_motion: InputEventMouseMotion = InputEventMouseMotion.new()
	anchor_mouse_motion.position = anchor_pointer_position
	touch_board._gui_input(anchor_mouse_motion)
	checks.equal(touch_board.preview_origin + touch_board.touch_anchor_offset, anchor_pointer_cell, "Mouse preview positions the authored anchor tile under the cursor")
	_send_touch(touch_board, anchor_pointer_position, true)
	_send_touch(touch_board, anchor_pointer_position, false)
	var anchored_board_cell: Vector2i = touch_board.preview_origin + touch_board.touch_anchor_offset
	checks.equal(anchored_board_cell, anchor_pointer_cell, "Touch preview positions the authored anchor tile under the touch point")
	checks.truthy(anchor_piece.get_cells().has(touch_board.touch_anchor_offset), "Initial touch anchor always belongs to an occupied Block tile")
	checks.equal(touch_board.touch_anchor_offset, anchor_piece.get_cells()[0], "Initial touch anchor uses the authored start tile")
	var preview_fill: Color = Color(0.25, 0.9, 0.55, 0.5)
	var anchor_fill: Color = touch_board._preview_cell_fill(touch_board.touch_anchor_offset, true, preview_fill)
	checks.equal(Color(anchor_fill, 1.0), Color(touch_board.visual_settings.preview_anchor_color, 1.0), "Touch preview anchor uses its configured darker green color")
	checks.equal(touch_board._preview_cell_fill(touch_board.touch_anchor_offset + Vector2i.ONE, true, preview_fill), preview_fill, "Only the preview anchor receives the darker fill")
	for rotation: int in 4:
		anchor_piece.rotate_clockwise()
		touch_board.set_active_piece(anchor_piece)
		checks.truthy(anchor_piece.get_cells().has(touch_board.touch_anchor_offset), "Touch anchor remains on an occupied tile after rotation %d" % rotation)
		checks.equal(touch_board.touch_anchor_offset, anchor_piece.get_cells()[0], "Rotation %d keeps the authored start tile anchored" % rotation)
		checks.equal(touch_board.preview_origin + touch_board.touch_anchor_offset, anchored_board_cell, "Rotation %d preserves the anchored board cell" % rotation)
		for offset: Vector2i in anchor_piece.get_cells():
			checks.truthy(touch_board.board.is_inside(touch_board.preview_origin + offset), "Rotated touch preview stays inside the board")
	var blocker_board: BoardState = BoardState.new(4, 4)
	blocker_board.set_special_cell(Vector2i(1, 1), CellType.Value.BLOCKER, 1)
	touch_board.set_board(blocker_board)
	await get_tree().process_frame
	var blocker_cross_tile_count: int = 0
	for tile_entry: BoardTileMapRenderer.TileLayerEntry in touch_board.tile_renderer.tile_layers:
		if tile_entry.band == BoardTileMapRenderer.LayerBand.MARKER and tile_entry.style == BoardTileMapRenderer.TileStyle.CROSS:
			blocker_cross_tile_count += tile_entry.layer.get_used_cells().size()
	checks.equal(blocker_cross_tile_count, 0, "Blockers use the smooth inset marker instead of a pixelated atlas cross")
	touch_board.queue_free()

func _test_status_effect_modal_touch() -> void:
	var overlay: StatusEffectInfoOverlay = (load("res://presentation/combat/status_effect_info_overlay.tscn") as PackedScene).instantiate() as StatusEffectInfoOverlay
	add_child(overlay)
	overlay.show_shield(6)
	var opening_release: InputEventScreenTouch = InputEventScreenTouch.new()
	opening_release.index = 2
	opening_release.position = Vector2(200, 200)
	opening_release.pressed = false
	checks.truthy(overlay.capture_modal_touch(opening_release), "Status modal consumes the long-press release")
	checks.truthy(overlay.visible, "Long-press release leaves status details open")
	var closing_press: InputEventScreenTouch = InputEventScreenTouch.new()
	closing_press.index = 3
	closing_press.position = Vector2(320, 320)
	closing_press.pressed = true
	checks.truthy(overlay.capture_modal_touch(closing_press), "Status modal consumes its closing touch")
	checks.falsy(overlay.visible, "Touching an open status modal closes it")
	var closing_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	closing_drag.index = closing_press.index
	closing_drag.position = closing_press.position + Vector2(40, 40)
	closing_drag.relative = Vector2(40, 40)
	checks.truthy(overlay.capture_modal_touch(closing_drag), "Status modal consumes closing-gesture movement")
	var closing_release: InputEventScreenTouch = InputEventScreenTouch.new()
	closing_release.index = closing_press.index
	closing_release.position = closing_drag.position
	closing_release.pressed = false
	checks.truthy(overlay.capture_modal_touch(closing_release), "Status modal consumes the complete closing gesture")
	checks.falsy(overlay.capture_modal_touch(closing_release), "Status modal releases touch capture after dismissal")
	overlay.queue_free()
	await get_tree().process_frame

func _test_scaled_enemy_damage() -> void:
	var scaled_run: RunState = RunState.new()
	scaled_run.difficulty = HOSTILE_DIFFICULTY
	var scaled_enemy: EnemyDefinition = EnemyDefinition.new()
	scaled_enemy.display_name = "Scaled Enemy"
	scaled_enemy.maximum_health = 10
	scaled_enemy.attack_interval = 100
	var scaled_controller: EncounterController = EncounterController.new()
	scaled_controller.deck_rules = _unscaled_deck_rules(scaled_controller.deck_rules)
	add_child(scaled_controller)
	scaled_controller.start_encounter(scaled_run, scaled_enemy, PieceGenerator.new(4242))
	checks.equal(scaled_controller.enemy_maximum_health, 12, "Difficulty scaling defines authoritative enemy maximum health")
	var single_block: PieceDefinition = _piece(&"damage_block", [Vector2i.ZERO])
	for iteration: int in 3:
		scaled_controller.board.clear_board()
		scaled_controller.board.set_cell(Vector2i(0, 1), 1)
		for x: int in scaled_controller.board.width - 1:
			scaled_controller.board.set_cell(Vector2i(x, 0), 1)
		_prepare_controller_card(scaled_controller, _card(800 + iteration, single_block))
		var health_before: int = scaled_controller.enemy_health
		scaled_controller.place(Vector2i(scaled_controller.board.width - 1, 0))
		var expected_damage: int = scaled_controller.rules.damage_for_lines(1) + iteration * scaled_controller.rules.combo_damage_bonus_per_level
		checks.equal(scaled_controller.enemy_health, maxi(0, health_before - expected_damage), "Repeated line clear applies increasing combo damage %d" % iteration)
	scaled_controller.queue_free()
	var screen_run: RunState = RunState.new()
	screen_run.difficulty = HOSTILE_DIFFICULTY
	var screen: RunScreen = (load("res://scenes/run/run_screen.tscn") as PackedScene).instantiate() as RunScreen
	add_child(screen)
	screen.controller.deck_rules = _unscaled_deck_rules(screen.controller.deck_rules)
	screen.start(screen_run, MASON_ENEMY, PieceGenerator.new(5150))
	var health_bar: ProgressBar = screen.get_node("MainMargin/ScreenLayout/MainLayout/RightCombatColumn/EnemyStage/EnemyLayout/EnemyVisualArea/EnemyHealthRow/VBoxContainer/EnemyHealthBar") as ProgressBar
	checks.equal(int(health_bar.max_value), screen.controller.enemy_maximum_health, "Enemy health bar uses scaled encounter maximum")
	var health_before_hit: int = screen.controller.enemy_health
	screen.controller.debug_damage_enemy()
	checks.equal(int(health_bar.value), health_before_hit - 10, "Enemy health bar reflects damage above base maximum")
	screen.queue_free()
	await get_tree().process_frame

func _test_touch_settings_layout() -> void:
	var settings_screen: SettingsScreen = (load("res://scenes/settings/settings_screen.tscn") as PackedScene).instantiate() as SettingsScreen
	add_child(settings_screen)
	settings_screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	settings_screen.size = Vector2(480, 800)
	settings_screen._apply_mobile_layout(true)
	await get_tree().process_frame
	await get_tree().process_frame
	var columns: GridContainer = settings_screen.get_node("Center/Panel/Layout/Scroll/Columns") as GridContainer
	var scroll: ScrollContainer = settings_screen.get_node("Center/Panel/Layout/Scroll") as ScrollContainer
	var master: HSlider = settings_screen.get_node("Center/Panel/Layout/Scroll/Columns/Audio/Master") as HSlider
	var back: Button = settings_screen.get_node("Center/Panel/Layout/Back") as Button
	var new_game: Button = settings_screen.get_node("Center/Panel/Layout/Scroll/Columns/Data/NewGame") as Button
	var confirm_new_game: ConfirmationDialog = settings_screen.get_node("ConfirmNewGame") as ConfirmationDialog
	checks.equal(columns.columns, 2, "Mobile settings retain a compact two-column layout")
	for unused_control_path: NodePath in [^"Audio/UIScale", ^"Motion/Animations", ^"Motion/HighContrast", ^"Motion/ColorblindMarkings", ^"Motion/TouchAutoAlignment", ^"Motion/TouchSnapRadiusLabel", ^"Motion/TouchSnapRadius"]:
		checks.falsy(columns.has_node(unused_control_path), "Unused setting control is removed: %s" % unused_control_path)
	var saved_settings: Dictionary = GameSettingsCodec.encode(SaveService.settings)
	checks.falsy(saved_settings.has("touch_auto_alignment") or saved_settings.has("touch_snap_radius"), "Obsolete touch snapping values are removed from saved settings")
	checks.truthy(master.size.y >= settings_screen.mobile_slider_height, "Mobile sliders expose a large touch target")
	checks.truthy(back.size.y >= settings_screen.mobile_control_height, "Mobile settings buttons expose a large touch target")
	checks.truthy(new_game.size.y >= settings_screen.mobile_control_height, "New game exposes a large mobile touch target")
	checks.truthy(scroll.get_v_scroll_bar().max_value > scroll.get_v_scroll_bar().page, "Mobile settings content is vertically scrollable")
	var new_game_request_count: Array[int] = [0]
	settings_screen.new_game_requested.connect(func() -> void: new_game_request_count[0] += 1)
	new_game.pressed.emit()
	checks.truthy(confirm_new_game.visible, "New game requires confirmation")
	confirm_new_game.confirmed.emit()
	checks.equal(new_game_request_count[0], 1, "Confirmed new game requests a progression reset")
	var scroll_press: InputEventScreenTouch = InputEventScreenTouch.new()
	scroll_press.index = 1
	scroll_press.position = scroll.get_global_rect().get_center()
	scroll_press.pressed = true
	settings_screen._input(scroll_press)
	var scroll_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	scroll_drag.index = 1
	scroll_drag.position = scroll_press.position - Vector2(0, 90)
	scroll_drag.relative = Vector2(0, -90)
	settings_screen._input(scroll_drag)
	checks.truthy(scroll.scroll_vertical > 0, "Vertical touch dragging scrolls the settings content")
	var original_value: float = master.value
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = 0
	press.position = Vector2(master.size.x * 0.2, master.size.y * 0.5)
	press.pressed = true
	settings_screen._handle_slider_touch(master, press)
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(master.size.x * 0.8, master.size.y * 0.5)
	drag.relative = drag.position - press.position
	settings_screen._handle_slider_touch(master, drag)
	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = 0
	release.position = drag.position
	release.pressed = false
	settings_screen._handle_slider_touch(master, release)
	checks.truthy(master.value > original_value or is_equal_approx(master.value, 0.8), "Horizontal touch dragging changes slider values")
	master.value = original_value
	settings_screen.queue_free()
	await get_tree().process_frame

func _test_touch_upgrade_tabs() -> void:
	var upgrade_screen: UpgradeTreeScreen = (load("res://scenes/upgrades/upgrade_tree_screen.tscn") as PackedScene).instantiate() as UpgradeTreeScreen
	add_child(upgrade_screen)
	upgrade_screen.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	upgrade_screen.size = Vector2(1280, 720)
	await get_tree().process_frame
	await get_tree().process_frame
	var board_view: UpgradeBoardView = upgrade_screen.get_node("Margin/Layout/Workspace/BoardPanel/BoardMargin/BoardLayer/BoardView") as UpgradeBoardView
	var matrix_back: Button = upgrade_screen.get_node("Margin/Layout/Header/HeaderLayout/Back") as Button
	checks.equal(matrix_back.get_index(), matrix_back.get_parent().get_child_count() - 1, "Upgrade Matrix Back action is the rightmost header control")
	checks.equal(upgrade_screen.layout.board_size, Vector2i(100, 100), "Upgrade matrix uses the 100 by 100 board")
	checks.equal(upgrade_screen.layout.regions.size(), ContentRegistry.upgrades.size(), "Upgrade matrix maps every current upgrade")
	checks.truthy(board_view.size.x >= 640.0 and board_view.size.y >= 380.0, "Upgrade matrix keeps a useful map viewport at 1280 by 720")
	checks.equal(board_view.tile_renderer.outline_texture_thickness, 6, "Upgrade matrix grid lines use the readable wide outline")
	checks.equal(board_view.tile_renderer.edge_texture_thickness, 6, "Upgrade matrix region lines use the readable wide edge")
	var zoom_anchor: Vector2 = board_view.size * 0.5
	var world_before_zoom: Vector2 = board_view.get_world_position_at(zoom_anchor)
	var zoom_before: float = board_view.get_camera_zoom()
	board_view.zoom_at(zoom_anchor, upgrade_screen.board_rules.mouse_wheel_zoom_factor)
	var world_after_zoom: Vector2 = board_view.get_world_position_at(zoom_anchor)
	checks.truthy(board_view.get_camera_zoom() > zoom_before, "Mouse-wheel camera math increases Upgrade Board zoom")
	checks.truthy(world_before_zoom.distance_to(world_after_zoom) < 0.01, "Cursor-anchored Upgrade Board zoom has no drift")
	var first_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	first_touch.index = 0
	first_touch.position = zoom_anchor - Vector2(100.0, 0.0)
	first_touch.pressed = true
	board_view._gui_input(first_touch)
	var second_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	second_touch.index = 1
	second_touch.position = zoom_anchor + Vector2(100.0, 0.0)
	second_touch.pressed = true
	board_view._gui_input(second_touch)
	var pinch_zoom_before: float = board_view.get_camera_zoom()
	var pinch_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	pinch_drag.index = 1
	pinch_drag.position = zoom_anchor + Vector2(150.0, 0.0)
	pinch_drag.relative = Vector2(50.0, 0.0)
	board_view._gui_input(pinch_drag)
	checks.truthy(board_view.get_camera_zoom() > pinch_zoom_before, "Two-finger pinch increases Upgrade Board zoom")
	second_touch.pressed = false
	second_touch.position = pinch_drag.position
	board_view._gui_input(second_touch)
	first_touch.pressed = false
	board_view._gui_input(first_touch)
	_test_completed_upgrade_area(upgrade_screen.layout, upgrade_screen.board_rules)
	upgrade_screen.queue_free()
	await get_tree().process_frame

func _test_completed_upgrade_area(layout: UpgradeBoardLayout, rules: UpgradeBoardRules) -> void:
	var wider_draft_upgrade: UpgradeDefinition = preload("res://content/upgrades/larger_showcase.tres")
	var region: UpgradeBoardRegion = layout.get_region(wider_draft_upgrade)
	checks.truthy(region != null, "Wider Draft has an Upgrade Matrix area")
	if region == null:
		return
	var thresholds: PackedInt32Array = region.get_thresholds(rules)
	var final_threshold: int = thresholds[thresholds.size() - 1]
	checks.equal(final_threshold, 104, "Wider Draft requires all 104 usable cells")
	checks.equal(final_threshold, region.usable_cells.size(), "Wider Draft requires its complete usable area")
	var service: UpgradeBoardService = UpgradeBoardService.new(rules, layout)
	var state: UpgradeBoardState = UpgradeBoardState.new(rules.layout_version)
	for cell_index: int in final_threshold - 1:
		state.add_placement(UpgradeBoardPlacement.new(MONOMINO_PIECE, region.usable_cells[cell_index], 0, 9000 + cell_index))
	var completing_placement: UpgradeBoardPlacement = UpgradeBoardPlacement.new(MONOMINO_PIECE, region.usable_cells[final_threshold - 1], 0, 9100)
	var legacy_levels: Array[UpgradeLevelState] = []
	checks.truthy(service.validate_placement(state, completing_placement, legacy_levels).valid, "The final usable cell can complete Wider Draft")

func _send_touch(board_view: BoardView, position: Vector2, pressed: bool) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	board_view._gui_input(event)

func _count_elite_route_nodes(route: GeneratedRoute) -> int:
	var count: int = 0
	for node: RouteNodeState in route.nodes:
		if node.type == RouteNodeState.NodeType.ELITE_COMBAT or node.type == RouteNodeState.NodeType.CHALLENGE:
			count += 1
	return count

func _send_main_touch(main_scene: Control, position: Vector2, index: int) -> void:
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = index
	press.position = position
	press.pressed = true
	main_scene.call("_input", press)
	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = index
	release.position = position
	release.pressed = false
	main_scene.call("_input", release)

func _send_viewport_touch(viewport: Viewport, position: Vector2, index: int) -> void:
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = index
	press.position = position
	press.pressed = true
	viewport.push_input(press, true)
	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = index
	release.position = position
	release.pressed = false
	viewport.push_input(release, true)

func _send_run_swipe(run_screen: RunScreen, start: Vector2, finish: Vector2) -> void:
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = 0
	press.position = start
	press.pressed = true
	run_screen._input(press)
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = 0
	drag.position = finish
	drag.relative = finish - start
	run_screen._input(drag)
	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = 0
	release.position = finish
	release.pressed = false
	run_screen._input(release)

func _send_guided_run_swipe(main_scene: Control, run_screen: RunScreen, start: Vector2, finish: Vector2, index: int) -> void:
	var press: InputEventScreenTouch = InputEventScreenTouch.new()
	press.index = index
	press.position = start
	press.pressed = true
	main_scene.call("_input", press)
	run_screen._input(press)
	var drag: InputEventScreenDrag = InputEventScreenDrag.new()
	drag.index = index
	drag.position = finish
	drag.relative = finish - start
	main_scene.call("_input", drag)
	run_screen._input(drag)
	var release: InputEventScreenTouch = InputEventScreenTouch.new()
	release.index = index
	release.position = finish
	release.pressed = false
	main_scene.call("_input", release)
	run_screen._input(release)
