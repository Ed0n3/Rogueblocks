extends Control

@export_category("Content")
@export var empty_icon: Texture2D = preload("res://assets/icons/empty_texture.tres") as Texture2D
@export var guided_onboarding: TutorialDefinition = preload("res://content/tutorials/onboarding/guided_onboarding.tres") as TutorialDefinition
@export var training_slime: EnemyDefinition = preload("res://content/enemies/training_slime.tres") as EnemyDefinition
@export var architect_enemy: EnemyDefinition = preload("res://content/enemies/bosses/architect.tres") as EnemyDefinition
@export var game_rules: GameRules = preload("res://content/rules/default_game_rules.tres") as GameRules
@export var progression_rules: ProgressionRules = preload("res://content/rules/progression_rules.tres") as ProgressionRules

@export_category("Scenes")
@export var main_menu_scene: PackedScene = preload("res://scenes/menu/main_menu_screen.tscn") as PackedScene
@export var hub_scene: PackedScene = preload("res://scenes/hub/hub_screen.tscn") as PackedScene
@export var upgrade_tree_scene: PackedScene = preload("res://scenes/upgrades/upgrade_tree_screen.tscn") as PackedScene
@export var piece_draft_scene: PackedScene = preload("res://scenes/piece_draft/piece_draft_screen.tscn") as PackedScene
@export var tutorial_archive_scene: PackedScene = preload("res://scenes/tutorial/tutorial_archive_screen.tscn") as PackedScene
@export var shop_scene: PackedScene = preload("res://scenes/shops/shop_screen.tscn") as PackedScene
@export var reward_scene: PackedScene = preload("res://scenes/rewards/reward_screen.tscn") as PackedScene
@export var artifact_reward_scene: PackedScene = preload("res://scenes/rewards/artifact_reward_screen.tscn") as PackedScene
@export var run_scene: PackedScene = preload("res://scenes/run/run_screen.tscn") as PackedScene
@export var route_map_scene: PackedScene = preload("res://scenes/routes/route_map_screen.tscn") as PackedScene
@export var event_scene: PackedScene = preload("res://scenes/events/event_screen.tscn") as PackedScene
@export var run_end_scene: PackedScene = preload("res://scenes/run_end/run_end_screen.tscn") as PackedScene
@export var info_scene: PackedScene = preload("res://scenes/collection/info_screen.tscn") as PackedScene
@export var pause_scene: PackedScene = preload("res://scenes/pause/pause_screen.tscn") as PackedScene
@export var settings_scene: PackedScene = preload("res://scenes/settings/settings_screen.tscn") as PackedScene
@export var piece_addition_scene: PackedScene = preload("res://scenes/piece_draft/piece_addition_screen.tscn") as PackedScene
@export var piece_target_selection_scene: PackedScene = preload("res://scenes/rewards/piece_target_selection_overlay.tscn") as PackedScene
@export var debug_encounter_setup_scene: PackedScene = preload("res://scenes/debug/debug_encounter_setup_screen.tscn") as PackedScene
@export var debug_encounter_rules: DebugEncounterRules = preload("res://content/rules/debug_encounter_rules.tres") as DebugEncounterRules

@export_category("Run Tuning")
@export var touch_button_drag_threshold: float = 12.0
@export var default_seed: int = 1
@export var tutorial_seed: int = 470047
@export var tutorial_starting_shards: int = 50
@export var tutorial_artifact_act: int = 1
@export var recovery_healing_percent: float = 40.0
@export var encounter_reward_shards: int = 8
@export var percentage_multiplier: float = 100.0
@export var minimum_rate_denominator: int = 1

@export_category("Messages")
@export var unavailable_draft_error: String = "Cannot start route because the confirmed Block draft has no available resources"
@export var unavailable_enemy_error: String = "Encounter enemy resource is unavailable for route node %d/%d/%d"
@export var rejected_enemy_error: String = "Run screen rejected encounter resource %s"
@export var new_game_save_error: String = "New game profile could not be saved"
@export var daily_attempt_save_error: String = "Daily attempt could not be saved"
@export var default_defeat_reason: String = "Your core is destroyed!"
@export var collection_title: String = "COLLECTION"
@export var statistics_title: String = "STATISTICS"
@export_multiline var statistics_text: String = "Runs: %d\nVictories: %d\nWin rate: %.1f%%\nBest score: %d\nHighest combo: %d\nLines cleared: %d\nFragments earned: %d\nRecent runs retained: %d"
@export_multiline var collection_text: String = "Blocks found: %d / %d\nBlocks unlocked: %d\nRelics found: %d / %d\nRelics unlocked: %d\nEnemies found: %d / %d\nEvents unlocked: %d\nPermanent upgrades: %d"

@export_category("UI Contracts")
@export var tutorial_overlay_path: NodePath = ^"TutorialOverlay"
@export var dialog_name_pattern: String = "*"
@export var confirmation_dialog_class: String = "ConfirmationDialog"
@export var body_text_theme: StringName = &"BodyText"
@export var primary_button_theme: StringName = &"PrimaryButton"
@export var secondary_button_theme: StringName = &"SecondaryButton"
@export var required_small_piece_tag: StringName = &"small"

@onready var screen_container: Control = %ScreenContainer

var run_state: RunState
var generator: PieceGenerator
var current_screen: Control
var run_screen: RunScreen
var pause_screen: PauseScreen
var settings_return_to_run: bool = false
var current_shop_state: ShopState
var tutorial_return_to_archive: bool = false
var tutorial_replay_active: bool = false
var touch_button: BaseButton
var touch_button_index: int = -1
var touch_button_start: Vector2
var debug_encounter_configuration: DebugEncounterConfiguration

func _ready() -> void:
	TutorialService.tutorial_ended.connect(_on_tutorial_ended)
	show_main_menu()

func _input(event: InputEvent) -> void:
	var tutorial_overlay: TutorialOverlay = _tutorial_overlay()
	if tutorial_overlay != null and tutorial_overlay.blocker.capture_pointer_event(event):
		_cancel_button_touch(true)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch:
		_handle_button_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index == touch_button_index:
			if drag.position.distance_to(touch_button_start) >= touch_button_drag_threshold:
				_cancel_button_touch(true)

func _handle_button_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if not _tutorial_allows_touch(event.position):
			return
		var button: BaseButton = _button_at(event.position)
		if button == null:
			return
		touch_button = button
		touch_button_index = event.index
		touch_button_start = event.position
		button.grab_focus()
		button.button_down.emit()
		get_viewport().set_input_as_handled()
		return
	if event.index != touch_button_index:
		return
	var released_button: BaseButton = touch_button
	_cancel_button_touch()
	get_viewport().set_input_as_handled()
	if not is_instance_valid(released_button) or released_button.disabled or not released_button.is_visible_in_tree():
		return
	released_button.button_up.emit()
	if not released_button.get_global_rect().has_point(event.position):
		return
	if released_button.toggle_mode:
		released_button.button_pressed = not released_button.button_pressed
	released_button.pressed.emit()

func _tutorial_allows_touch(position: Vector2) -> bool:
	if TutorialService.active_definition == null:
		return true
	var overlay: TutorialOverlay = _tutorial_overlay()
	if overlay == null or not overlay.root.visible or not overlay.blocker.visible:
		return true
	return overlay.blocker.is_pointer_allowed(position, TutorialService.allowed_input_mode())

func _button_at(position: Vector2) -> BaseButton:
	var overlay: TutorialOverlay = _tutorial_overlay()
	if overlay != null and overlay.root.visible:
		var tutorial_button: BaseButton = overlay.blocker.interactive_button_at(position)
		if tutorial_button != null:
			return tutorial_button
	if pause_screen != null and pause_screen.is_visible_in_tree():
		var pause_button: BaseButton = _button_in(pause_screen, position)
		if pause_button != null:
			return pause_button
	var screens: Array[Node] = screen_container.get_children()
	screens.reverse()
	for screen: Node in screens:
		var control: Control = screen as Control
		if control == null or not control.is_visible_in_tree():
			continue
		var button: BaseButton = _button_in(control, position)
		if button != null:
			return button
	return null

func _button_in(root: Node, position: Vector2) -> BaseButton:
	var control: Control = _top_control_at(root, position)
	while control != null:
		var button: BaseButton = control as BaseButton
		if button != null:
			return button if not button.disabled else null
		if control == root:
			break
		control = control.get_parent() as Control
	return null

func _top_control_at(root: Node, position: Vector2) -> Control:
	var children: Array[Node] = root.get_children()
	children.reverse()
	for child: Node in children:
		var canvas_item: CanvasItem = child as CanvasItem
		if canvas_item != null and not canvas_item.is_visible_in_tree():
			continue
		var descendant: Control = _top_control_at(child, position)
		if descendant != null:
			return descendant
	var control: Control = root as Control
	if control != null and control.mouse_filter != Control.MOUSE_FILTER_IGNORE and control.get_global_rect().has_point(position):
		return control
	return null

func _cancel_button_touch(emit_button_up: bool = false) -> void:
	var cancelled_button: BaseButton = touch_button
	touch_button = null
	touch_button_index = -1
	touch_button_start = Vector2.ZERO
	if emit_button_up and is_instance_valid(cancelled_button):
		cancelled_button.button_up.emit()

func _tutorial_overlay() -> TutorialOverlay:
	return get_tree().root.get_node_or_null(tutorial_overlay_path) as TutorialOverlay

func show_main_menu() -> void:
	get_tree().paused = false
	_clear_screens()
	var menu: MainMenuScreen = main_menu_scene.instantiate() as MainMenuScreen
	_set_screen(menu)
	menu.hub_requested.connect(show_hub)
	menu.new_run_requested.connect(start_new_run)
	menu.settings_requested.connect(func() -> void: settings_return_to_run = false; show_settings())
	menu.test_area_requested.connect(show_debug_test_area)

func show_debug_test_area() -> void:
	get_tree().paused = false
	_clear_screens()
	run_state = null
	generator = null
	var screen: DebugEncounterSetupScreen = debug_encounter_setup_scene.instantiate() as DebugEncounterSetupScreen
	_set_screen(screen)
	screen.start(debug_encounter_configuration)
	screen.encounter_requested.connect(_start_debug_encounter)
	screen.back_requested.connect(show_main_menu)

func _start_debug_encounter(configuration: DebugEncounterConfiguration) -> void:
	var builder: DebugEncounterBuilder = DebugEncounterBuilder.new()
	var debug_run: RunState = builder.create_run(configuration, debug_encounter_rules, game_rules)
	if debug_run == null:
		push_error(builder.last_error)
		show_debug_test_area()
		return
	debug_encounter_configuration = configuration.duplicate_configuration()
	if debug_encounter_configuration.enemy == null:
		debug_encounter_configuration.enemy = debug_encounter_rules.default_enemy
	run_state = debug_run
	generator = PieceGenerator.new(run_state.seed_value)
	_clear_screens()
	run_screen = run_scene.instantiate() as RunScreen
	run_screen.tutorials_enabled = false
	_set_screen(run_screen)
	_connect_debug_run_screen()
	if not run_screen.start(run_state, debug_encounter_configuration.enemy, generator):
		push_error(rejected_enemy_error % debug_encounter_configuration.enemy.resource_path)
		show_debug_test_area()

func _connect_debug_run_screen() -> void:
	run_screen.encounter_won.connect(show_debug_test_area)
	run_screen.run_lost.connect(func(_reason: String) -> void: show_debug_test_area())
	run_screen.pause_requested.connect(show_pause)

func show_hub() -> void:
	get_tree().paused = false
	_clear_screens()
	var hub: HubScreen = hub_scene.instantiate() as HubScreen
	_set_screen(hub)
	hub.new_run_requested.connect(_request_new_run)
	hub.continue_run_requested.connect(continue_run)
	hub.resume_fight_requested.connect(continue_run)
	hub.upgrades_requested.connect(show_upgrades)
	hub.collection_requested.connect(show_collection)
	hub.statistics_requested.connect(show_statistics)
	hub.daily_requested.connect(start_daily_run)
	hub.settings_requested.connect(func() -> void: settings_return_to_run = false; show_settings())
	hub.tutorials_requested.connect(show_tutorial_archive)
	hub.main_menu_requested.connect(show_main_menu)

func show_upgrades() -> void:
	_clear_screens()
	var screen: UpgradeTreeScreen = upgrade_tree_scene.instantiate() as UpgradeTreeScreen
	_set_screen(screen)
	screen.back_requested.connect(show_hub)

func start_new_run(seed_value: int, difficulty: DifficultyDefinition = null) -> void:
	run_state = RunState.new()
	run_state.seed_value = seed_value if seed_value != 0 else default_seed
	if difficulty != null:
		run_state.difficulty = difficulty
	var service: ProgressionService = ProgressionService.new(ContentRegistry.upgrades)
	run_state.apply_starting_modifiers(service.resolve_starting_modifiers(SaveService.profile), game_rules.starting_player_health)
	generator = PieceGenerator.new(run_state.seed_value)
	var draft_rules: PieceDraftRules = _resolved_piece_draft_rules(run_state, game_rules.piece_draft_rules)
	run_state.piece_draft = PieceDraftService.new().generate_starting_draft(_run_content_profile(), run_state.seed_value, draft_rules, run_state.starting_modifiers.unlocked_pieces)
	TutorialService.begin_run(run_state.run_sequence)
	SaveService.last_used_seed = run_state.seed_value
	SaveService.save_settings()
	_save_active_run()
	var run_started_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.RUN_STARTED)
	run_started_event.difficulty = run_state.difficulty
	TutorialService.publish_event(run_started_event)
	if run_state.piece_draft.candidates.size() <= draft_rules.selection_count:
		var draft_result: PiecePoolChangeResult = PieceDraftService.new().confirm_draft(run_state.piece_draft, run_state, draft_rules)
		if draft_result.changed:
			_finish_starting_piece_draft()
		else:
			show_piece_draft()
	else:
		show_piece_draft()

func show_piece_draft() -> void:
	_clear_screens()
	var screen: PieceDraftScreen = piece_draft_scene.instantiate() as PieceDraftScreen
	_set_screen(screen)
	screen.start(run_state, _resolved_piece_draft_rules(run_state, game_rules.piece_draft_rules))
	screen.draft_confirmed.connect(_finish_starting_piece_draft)
	screen.draft_changed.connect(_save_active_run)
	screen.back_requested.connect(func() -> void: _save_active_run(); show_hub())

func _finish_starting_piece_draft() -> void:
	run_state.ensure_active_piece_pool()
	if run_state.deck_cards.is_empty():
		push_error(unavailable_draft_error)
		show_hub()
		return
	if run_state.route == null:
		run_state.route = RouteGenerator.new().generate(run_state.seed_value, run_state.starting_modifiers.unlocked_route_node_types.has(RouteNodeState.NodeType.CHALLENGE), run_state.starting_modifiers.elite_nodes_per_route_bonus)
	_save_active_run()
	show_route()

func _request_new_run(difficulty: DifficultyDefinition) -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if progress.tutorials_enabled and not progress.completed_tutorials.has(guided_onboarding):
		start_tutorial_sandbox(guided_onboarding, false)
	else:
		start_new_run(int(Time.get_unix_time_from_system()), difficulty)

func show_tutorial_archive() -> void:
	_clear_screens()
	var archive: TutorialArchiveScreen = tutorial_archive_scene.instantiate() as TutorialArchiveScreen
	_set_screen(archive)
	archive.back_requested.connect(show_hub)
	archive.replay_requested.connect(_replay_tutorial)

func _replay_tutorial(definition: TutorialDefinition) -> void:
	if definition == null:
		show_tutorial_archive()
		return
	if definition.replay_context == TutorialReplayContext.Value.COMBAT:
		start_tutorial_sandbox(definition, true)
		return
	TutorialService.begin_replay_setup()
	_prepare_tutorial_context()
	match definition.replay_context:
		TutorialReplayContext.Value.DRAFT:
			_show_tutorial_draft()
		TutorialReplayContext.Value.ROUTE:
			show_route()
		TutorialReplayContext.Value.SHOP:
			_show_tutorial_shop()
		TutorialReplayContext.Value.REWARD:
			_show_tutorial_reward()
		TutorialReplayContext.Value.ARTIFACT:
			_show_tutorial_artifact_reward()
		TutorialReplayContext.Value.UPGRADES:
			show_upgrades()
		_:
			show_hub()
	if not TutorialService.start_prepared_replay(definition):
		_finish_tutorial_replay_navigation()

func _prepare_tutorial_context() -> void:
	run_state = RunState.new()
	run_state.seed_value = tutorial_seed
	run_state.debug_run = true
	run_state.run_mode = RunMode.Value.TUTORIAL
	run_state.shards = tutorial_starting_shards
	run_state.apply_starting_modifiers(StartingRunModifiers.new(), game_rules.starting_player_health)
	run_state.route = RouteGenerator.new().generate(run_state.seed_value, true)
	_initialize_automatic_piece_pool(run_state)
	generator = PieceGenerator.new(run_state.seed_value)
	tutorial_return_to_archive = true
	tutorial_replay_active = true

func _show_tutorial_draft() -> void:
	_clear_screens()
	var draft_rules: PieceDraftRules = _resolved_piece_draft_rules(run_state, game_rules.piece_draft_rules)
	run_state.deck_cards.clear()
	run_state.piece_draft = PieceDraftService.new().generate_starting_draft(SaveService.profile, run_state.seed_value, draft_rules, run_state.starting_modifiers.unlocked_pieces)
	var screen: PieceDraftScreen = piece_draft_scene.instantiate() as PieceDraftScreen
	_set_screen(screen)
	screen.start(run_state, draft_rules)
	screen.draft_changed.connect(_save_active_run)
	screen.back_requested.connect(TutorialService.cancel_active)

func _show_tutorial_shop() -> void:
	_clear_screens()
	var node: RouteNodeState = RouteNodeState.new()
	node.type = RouteNodeState.NodeType.SHOP
	current_shop_state = ShopService.new().generate_shop(run_state.seed_value, node, run_state, ContentRegistry.relics)
	var screen: ShopScreen = shop_scene.instantiate() as ShopScreen
	_set_screen(screen)
	screen.start(run_state, current_shop_state)

func _show_tutorial_reward() -> void:
	_clear_screens()
	var screen: RewardScreen = reward_scene.instantiate() as RewardScreen
	_set_screen(screen)
	screen.start(run_state, generator)

func _show_tutorial_artifact_reward() -> void:
	_clear_screens()
	var screen: ArtifactRewardScreen = artifact_reward_scene.instantiate() as ArtifactRewardScreen
	_set_screen(screen)
	screen.start(run_state, architect_enemy, tutorial_artifact_act)

func start_tutorial_sandbox(definition: TutorialDefinition, return_to_archive: bool) -> void:
	if definition == null:
		show_tutorial_archive()
		return
	TutorialService.begin_replay_setup()
	tutorial_return_to_archive = return_to_archive
	tutorial_replay_active = true
	run_state = RunState.new()
	run_state.seed_value = tutorial_seed
	run_state.debug_run = true
	run_state.run_mode = RunMode.Value.TUTORIAL
	run_state.apply_starting_modifiers(StartingRunModifiers.new(), game_rules.starting_player_health)
	_initialize_automatic_piece_pool(run_state)
	generator = PieceGenerator.new(run_state.seed_value)
	_clear_screens()
	run_screen = run_scene.instantiate() as RunScreen
	_set_screen(run_screen)
	run_screen.pause_requested.connect(show_pause)
	run_screen.encounter_won.connect(_finish_tutorial_sandbox)
	run_screen.run_lost.connect(func(_reason: String) -> void: _finish_tutorial_sandbox())
	var enemy: EnemyDefinition = training_slime
	if enemy == null or not run_screen.start(run_state, enemy, generator):
		_finish_tutorial_replay_navigation()
		return
	if not TutorialService.start_prepared_replay(definition):
		_finish_tutorial_replay_navigation()

func _finish_tutorial_sandbox() -> void:
	if TutorialService.active_definition != null:
		TutorialService.skip_active()
	else:
		_finish_tutorial_replay_navigation()

func _on_tutorial_ended(_definition: TutorialDefinition, _completed: bool) -> void:
	if not tutorial_replay_active:
		return
	_finish_tutorial_replay_navigation()

func _finish_tutorial_replay_navigation() -> void:
	var return_to_archive: bool = tutorial_return_to_archive
	TutorialService.cancel_replay_setup()
	tutorial_replay_active = false
	tutorial_return_to_archive = false
	_clear_screens()
	run_state = null
	generator = null
	current_shop_state = null
	if return_to_archive:
		show_tutorial_archive.call_deferred()
	else:
		show_hub.call_deferred()

func start_daily_run() -> void:
	var date_key: String = DailyChallengeService.get_date_key()
	var practice: bool = _has_daily_attempt(date_key)
	if not practice and not SaveService.claim_ranked_daily_attempt(date_key):
		push_error(daily_attempt_save_error)
		return
	_start_daily_run(date_key, practice)

func _start_daily_run(date_key: String, practice: bool) -> void:
	run_state = DailyChallengeService.create_daily_run(date_key, practice)
	TutorialService.begin_run(run_state.run_sequence)
	run_state.apply_starting_modifiers(StartingRunModifiers.new(), game_rules.starting_player_health)
	_initialize_automatic_piece_pool(run_state)
	run_state.route = RouteGenerator.new().generate(run_state.seed_value, false)
	generator = PieceGenerator.new(run_state.seed_value)
	_save_active_run()
	show_route()

func continue_run() -> void:
	var data: Dictionary = SaveService.load_active_run()
	if data.is_empty():
		show_hub()
		return
	run_state = RunState.from_save_data(data.get("run_state", {}) as Dictionary)
	if int(data.get("version", 0)) < SaveService.ACTIVE_RUN_VERSION and not run_state.daily_mode:
		ProgressionService.new().snapshot_content_unlocks(SaveService.profile, run_state.starting_modifiers)
	if run_state.daily_mode and run_state.daily_date_key.is_empty():
		run_state.daily_date_key = DailyChallengeService.infer_date_key(run_state.seed_value, run_state.run_sequence, int(data.get("last_modified_unix", 0)))
	TutorialService.begin_run(run_state.run_sequence)
	generator = PieceGenerator.new(run_state.seed_value)
	generator.restore(data.get("rng", {}) as Dictionary)
	var encounter_data: Dictionary = data.get("encounter", {}) as Dictionary
	var reward_data: Dictionary = data.get("reward", {}) as Dictionary
	var artifact_reward_data: Dictionary = data.get("artifact_reward", {}) as Dictionary
	var shop_data: Dictionary = data.get("shop", {}) as Dictionary
	current_shop_state = ShopState.from_save_data(shop_data, run_state.route) if not shop_data.is_empty() else null
	if run_state.piece_draft != null and not run_state.piece_draft.is_confirmed:
		show_piece_draft()
		return
	if run_state.pending_piece_addition != null and _resume_pending_piece_addition():
		return
	if run_state.pending_piece_selection_flow != PieceSelectionFlow.Value.NONE:
		_resume_pending_piece_selection()
		return
	if bool(artifact_reward_data.get("selected", false)):
		_finish_post_combat_rewards()
	elif not artifact_reward_data.is_empty():
		_resume_artifact_reward(artifact_reward_data)
	elif bool(reward_data.get("selected", false)):
		_finish_combat_reward()
	elif not reward_data.is_empty():
		_resume_reward(reward_data)
	elif not encounter_data.is_empty():
		var saved_encounter_state: EncounterController.TurnState = clampi(int(encounter_data.get("state", int(EncounterController.TurnState.INITIALIZING))), int(EncounterController.TurnState.INITIALIZING), int(EncounterController.TurnState.PAUSED)) as EncounterController.TurnState
		if saved_encounter_state == EncounterController.TurnState.ENCOUNTER_WON:
			_on_encounter_won()
		elif saved_encounter_state == EncounterController.TurnState.RUN_LOST:
			show_run_end(false, String(encounter_data.get("defeat_reason", default_defeat_reason)))
		else:
			_resume_encounter(encounter_data)
	else:
		_resume_current_node()

func show_route() -> void:
	_clear_screens()
	var screen: RouteMapScreen = route_map_scene.instantiate() as RouteMapScreen
	_set_screen(screen)
	screen.start(run_state)
	screen.node_selected.connect(_enter_route_node)
	screen.hub_requested.connect(func() -> void: _save_active_run(); show_hub())
	_save_active_run()

func _enter_route_node(node: RouteNodeState) -> void:
	if not run_state.route.enter_node(node):
		return
	_save_active_run()
	_dispatch_current_node()

func _dispatch_current_node() -> void:
	var node: RouteNodeState = run_state.route.current_node
	if node == null:
		show_route()
		return
	if node.type == RouteNodeState.NodeType.SHOP:
		show_shop(node)
	elif node.type == RouteNodeState.NodeType.EVENT:
		show_event(node)
	elif node.type == RouteNodeState.NodeType.RECOVERY:
		run_state.heal_percent(recovery_healing_percent)
		_complete_current_node()
	else:
		start_encounter(node)

func start_encounter(node: RouteNodeState) -> void:
	var enemy: EnemyDefinition = _enemy_for_node(node)
	if enemy == null:
		push_error(unavailable_enemy_error % [node.act, node.column, node.row])
		return
	_clear_screens()
	run_screen = run_scene.instantiate() as RunScreen
	_set_screen(run_screen)
	_connect_run_screen()
	if not run_screen.start(run_state, enemy, generator):
		push_error(rejected_enemy_error % enemy.resource_path)
		show_hub()
		return
	if not SaveService.profile.discovered_enemies.has(enemy):
		SaveService.profile.discovered_enemies.append(enemy)
		SaveService.save_profile()

func _resume_encounter(encounter_data: Dictionary) -> void:
	var enemy_reference: String = String(encounter_data.get("enemy", encounter_data.get("enemy_id", "")))
	var enemy: EnemyDefinition = ContentReferenceCodec.decode_legacy(enemy_reference, EnemyDefinition, ContentRegistry.catalog) as EnemyDefinition
	var route_node: RouteNodeState = run_state.route.current_node if run_state.route != null else null
	if route_node != null and (enemy == null or not enemy.is_available_in_act(route_node.act)):
		enemy = _enemy_for_node(route_node)
	if enemy == null:
		SaveService.clear_active_run()
		show_hub()
		return
	_clear_screens()
	run_screen = run_scene.instantiate() as RunScreen
	_set_screen(run_screen)
	_connect_run_screen()
	if not run_screen.restore(run_state, enemy, generator, encounter_data):
		SaveService.clear_active_run()
		show_hub()
		return
	run_screen.board_view.set_board(run_screen.controller.board)
	run_screen.board_view.set_active_piece(run_screen.controller.active_piece)
	run_screen.restore_special_preview()
	_save_active_run(run_screen.controller.to_save_data())

func _connect_run_screen() -> void:
	run_screen.encounter_won.connect(_on_encounter_won)
	run_screen.run_lost.connect(func(reason: String) -> void: show_run_end(false, reason))
	run_screen.pause_requested.connect(show_pause)
	run_screen.safe_point_reached.connect(func(data: Dictionary) -> void: _save_active_run(data))

func _on_encounter_won() -> void:
	run_state.shards += encounter_reward_shards
	var route_node: RouteNodeState = run_state.route.current_node if run_state.route != null else null
	if route_node != null and route_node.type == RouteNodeState.NodeType.BOSS:
		run_state.bosses_defeated += 1
		run_state.pending_profile_fragments = SaveService.award_boss_fragments(run_state, route_node, progression_rules.boss_fragments)
		run_state.boss_fragments_earned += run_state.pending_profile_fragments
	_show_reward_screen()

func _show_reward_screen(saved_data: Dictionary = {}) -> void:
	_clear_screens()
	var reward_screen: RewardScreen = reward_scene.instantiate() as RewardScreen
	_set_screen(reward_screen)
	if saved_data.is_empty():
		reward_screen.start(run_state, generator)
	elif not reward_screen.restore(run_state, generator, saved_data):
		SaveService.clear_active_run()
		show_hub()
		return
	reward_screen.reward_selected.connect(_finish_combat_reward)
	reward_screen.reward_changed.connect(_save_combat_reward)
	_save_active_run({}, reward_screen.to_save_data())

func _save_combat_reward(data: Dictionary) -> void:
	if run_state.pending_piece_addition != null:
		run_state.pending_piece_addition.continuation_flow = PieceSelectionFlow.Value.COMBAT_REWARD
	_save_active_run({}, data)

func _resume_reward(data: Dictionary) -> void:
	_show_reward_screen(data)

func _finish_combat_reward() -> void:
	if _show_pending_piece_addition(_finish_combat_reward, PieceSelectionFlow.Value.COMBAT_REWARD):
		return
	if _show_pending_piece_selection(_finish_combat_reward, PieceSelectionFlow.Value.COMBAT_REWARD):
		return
	var node: RouteNodeState = run_state.route.current_node
	if node == null:
		show_route()
		return
	var artifact_for_act: bool = false
	for artifact: BossArtifactState in run_state.artifacts:
		if artifact.obtained_act == node.act:
			artifact_for_act = true
			break
	if node != null and node.type == RouteNodeState.NodeType.BOSS and not artifact_for_act and run_state.artifacts.size() < game_rules.maximum_active_boss_artifacts:
		_show_artifact_reward_screen(node)
		return
	_finish_post_combat_rewards()

func _show_artifact_reward_screen(node: RouteNodeState, saved_data: Dictionary = {}) -> void:
	_clear_screens()
	var screen: ArtifactRewardScreen = artifact_reward_scene.instantiate() as ArtifactRewardScreen
	_set_screen(screen)
	if saved_data.is_empty():
		screen.start(run_state, _enemy_for_node(node), node.act)
	elif not screen.restore(run_state, saved_data):
		SaveService.clear_active_run()
		show_hub()
		return
	screen.artifact_selected.connect(_finish_post_combat_rewards)
	screen.reward_changed.connect(func(data: Dictionary) -> void: _save_active_run({}, {}, data))
	_save_active_run({}, {}, screen.to_save_data())

func _resume_artifact_reward(data: Dictionary) -> void:
	var node: RouteNodeState = run_state.route.current_node
	if node == null:
		show_route()
		return
	_show_artifact_reward_screen(node, data)

func _finish_post_combat_rewards() -> void:
	run_state.encounter_index += 1
	run_state.heal(run_state.starting_modifiers.encounter_healing)
	run_state.pending_profile_fragments = 0
	var node: RouteNodeState = run_state.route.current_node
	if node != null and node.type == RouteNodeState.NodeType.BOSS:
		run_state.expire_piece_modifiers_after_act(node.act)
	var final_boss: bool = node != null and node.type == RouteNodeState.NodeType.BOSS and node.connections.is_empty()
	if final_boss:
		show_run_end(true, String())
	else:
		_complete_current_node()

func show_shop(node: RouteNodeState) -> void:
	_clear_screens()
	if current_shop_state == null or current_shop_state.route_node != node or current_shop_state.has_board_pieces():
		current_shop_state = ShopService.new().generate_shop(run_state.seed_value, node, run_state, ContentRegistry.relics)
	var screen: ShopScreen = shop_scene.instantiate() as ShopScreen
	_set_screen(screen)
	screen.start(run_state, current_shop_state)
	screen.shop_changed.connect(_on_shop_changed.bind(node))
	screen.left_shop.connect(_complete_current_node)

func _on_shop_changed(node: RouteNodeState) -> void:
	_save_active_run()
	if _show_pending_piece_addition(show_shop.bind(node), PieceSelectionFlow.Value.SHOP):
		return
	_show_pending_piece_selection(show_shop.bind(node), PieceSelectionFlow.Value.SHOP)

func show_event(node: RouteNodeState) -> void:
	_clear_screens()
	var event: RunEventDefinition = EventService.new().select_event(
		run_state.seed_value,
		node,
		ContentRegistry.events,
		_run_content_profile(),
		run_state.starting_modifiers.unlocked_events
	)
	if event == null:
		_complete_current_node()
		return
	var screen: EventScreen = event_scene.instantiate() as EventScreen
	_set_screen(screen)
	screen.start(run_state, event, generator.rng)
	screen.event_resolved.connect(_complete_current_node)

func _complete_current_node() -> void:
	if _show_pending_piece_addition(_complete_current_node, PieceSelectionFlow.Value.COMPLETE_NODE):
		return
	if _show_pending_piece_selection(_complete_current_node, PieceSelectionFlow.Value.COMPLETE_NODE):
		return
	var node: RouteNodeState = run_state.route.current_node
	if node != null:
		node.completed = true
	current_shop_state = null
	_save_active_run()
	show_route()

func _resume_current_node() -> void:
	var node: RouteNodeState = run_state.route.current_node if run_state.route != null else null
	if node != null and node.entered and not node.completed:
		_dispatch_current_node()
	else:
		show_route()

func show_run_end(won: bool, reason: String) -> void:
	TutorialService.publish(TutorialEventId.Value.RUN_COMPLETED if won else TutorialEventId.Value.RUN_FAILED)
	TutorialService.end_run(run_state.run_sequence)
	_record_and_show_run_end(won, reason)

func _record_and_show_run_end(won: bool, reason: String) -> void:
	var record_result: RunRecordResult = SaveService.record_run(run_state, won, reason)
	_clear_screens()
	var end_screen: RunEndScreen = run_end_scene.instantiate() as RunEndScreen
	_set_screen(end_screen)
	end_screen.start(run_state, won, reason, not record_result.success)
	if not record_result.success:
		end_screen.save_retry_requested.connect(_record_and_show_run_end.bind(won, reason))
		return
	end_screen.new_run_requested.connect(func() -> void: start_new_run(int(Time.get_unix_time_from_system())))
	end_screen.retry_requested.connect(_retry_current_run)
	end_screen.main_menu_requested.connect(show_hub)

func show_collection() -> void:
	_show_info(collection_title, _collection_text())

func show_statistics() -> void:
	var profile: ProfileState = SaveService.profile
	var rate: float = percentage_multiplier * float(profile.victories) / float(maxi(minimum_rate_denominator, profile.completed_runs))
	_show_info(statistics_title, statistics_text % [profile.completed_runs, profile.victories, rate, profile.highest_score, profile.highest_combo, profile.total_lines_cleared, profile.total_fragments_earned, profile.run_history.size()])

func _show_info(title: String, body: String) -> void:
	_clear_screens()
	var screen: InfoScreen = info_scene.instantiate() as InfoScreen
	_set_screen(screen)
	screen.start(title, body)
	screen.back_requested.connect(show_hub)

func _collection_text() -> String:
	var profile: ProfileState = SaveService.profile
	return collection_text % [profile.discovered_pieces.size(), ContentRegistry.pieces.size(), profile.unlocked_pieces.size(), profile.discovered_relics.size(), ContentRegistry.relics.size(), profile.unlocked_relics.size(), profile.discovered_enemies.size(), ContentRegistry.enemies.size(), profile.unlocked_events.size(), ContentRegistry.upgrades.size()]

func show_pause() -> void:
	if run_screen == null or pause_screen != null:
		return
	run_screen.set_paused(true)
	_set_tutorial_overlay_suspended(true)
	pause_screen = pause_scene.instantiate() as PauseScreen
	add_child(pause_screen)
	pause_screen.show()
	_style_confirmation_dialogs(pause_screen)
	if run_state.run_mode == RunMode.Value.DEBUG:
		pause_screen.configure_for_test_area()
	pause_screen.resume_requested.connect(_resume_run)
	pause_screen.restart_requested.connect(_restart_current_run)
	pause_screen.settings_requested.connect(func() -> void: settings_return_to_run = true; pause_screen.queue_free(); pause_screen = null; show_settings())
	pause_screen.main_menu_requested.connect(_leave_current_combat)

func show_settings() -> void:
	if not settings_return_to_run:
		_clear_screens()
	elif current_screen != null:
		current_screen.visible = false
	var settings_screen: SettingsScreen = settings_scene.instantiate() as SettingsScreen
	screen_container.add_child(settings_screen)
	_style_confirmation_dialogs(settings_screen)
	settings_screen.back_requested.connect(func() -> void: settings_screen.queue_free(); _return_from_settings())
	settings_screen.new_game_requested.connect(_start_new_game)

func _start_new_game() -> void:
	TutorialService.cancel_active()
	if not SaveService.start_new_game():
		push_error(new_game_save_error)
		return
	TutorialService.reset_progress()
	run_state = null
	generator = null
	current_shop_state = null
	settings_return_to_run = false
	show_hub()

func _return_from_settings() -> void:
	if settings_return_to_run and run_screen != null:
		run_screen.visible = true
		show_pause()
	else:
		show_hub()

func _resume_run() -> void:
	if pause_screen != null:
		pause_screen.queue_free()
		pause_screen = null
	_set_tutorial_overlay_suspended(false)
	run_screen.set_paused(false)

func _restart_current_run() -> void:
	if pause_screen != null:
		pause_screen.queue_free()
		pause_screen = null
	if run_state != null and run_state.run_mode == RunMode.Value.DEBUG:
		_start_debug_encounter(debug_encounter_configuration)
	elif run_state != null and run_state.run_mode == RunMode.Value.TUTORIAL:
		var tutorial: TutorialDefinition = TutorialService.active_definition if TutorialService.active_definition != null else guided_onboarding
		if TutorialService.active_definition != null:
			TutorialService.cancel_active()
		start_tutorial_sandbox.call_deferred(tutorial, tutorial_return_to_archive)
	elif run_state != null and run_state.daily_mode:
		var date_key: String = _daily_date_key(run_state)
		_start_daily_run(date_key, true)
	else:
		start_new_run(run_state.seed_value, run_state.difficulty)

func _retry_current_run() -> void:
	if run_state.run_mode == RunMode.Value.DEBUG:
		_start_debug_encounter(debug_encounter_configuration)
	elif run_state.daily_mode:
		var date_key: String = _daily_date_key(run_state)
		_start_daily_run(date_key, true)
	else:
		start_new_run(run_state.seed_value, run_state.difficulty)

func _leave_current_combat() -> void:
	if run_state != null and run_state.run_mode == RunMode.Value.DEBUG:
		show_debug_test_area()
	else:
		_save_fight_and_show_hub()

func _save_fight_and_show_hub() -> void:
	if run_screen != null and run_screen.controller != null:
		_save_active_run(run_screen.controller.to_save_data())
	show_hub()

func _save_active_run(encounter_data: Dictionary = {}, reward_data: Dictionary = {}, artifact_reward_data: Dictionary = {}) -> void:
	if run_state == null or run_state.run_mode == RunMode.Value.TUTORIAL or run_state.run_mode == RunMode.Value.DEBUG:
		return
	SaveService.save_active_run({"run_state": run_state.to_save_data(), "rng": generator.to_save_data(), "encounter": encounter_data, "reward": reward_data, "artifact_reward": artifact_reward_data, "shop": current_shop_state.to_save_data() if current_shop_state != null else {}, "ended": false})
	SaveService.save_profile()

func _notification(what: int) -> void:
	if what != NOTIFICATION_APPLICATION_PAUSED and what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	if run_screen != null and run_screen.controller != null and run_screen.controller.board != null and run_screen.controller.deck_state != null:
		_save_active_run(run_screen.controller.to_save_data())
	else:
		SaveService.save_profile()

func _enemy_for_node(node: RouteNodeState) -> EnemyDefinition:
	return EnemyPoolService.new().select_for_node(run_state, node, _run_content_profile(), ContentRegistry.enemies)

func _has_daily_attempt(date_key: String) -> bool:
	if SaveService.profile.has_ranked_daily_attempt(date_key):
		return true
	var active_data: Dictionary = SaveService.load_active_run()
	var active_run_data: Dictionary = active_data.get("run_state", {}) as Dictionary
	if bool(active_run_data.get("daily_mode", false)) and not bool(active_run_data.get("daily_practice", false)):
		var active_date_key: String = String(active_run_data.get("daily_date_key", ""))
		if active_date_key.is_empty():
			active_date_key = DailyChallengeService.infer_date_key(int(active_run_data.get("seed", 0)), int(active_run_data.get("run_sequence", 0)), int(active_data.get("last_modified_unix", 0)))
		if active_date_key == date_key:
			return true
	return false

func _initialize_automatic_piece_pool(target_run: RunState) -> void:
	var draft_rules: PieceDraftRules = _resolved_piece_draft_rules(target_run, game_rules.piece_draft_rules)
	var draft: PieceDraftState = PieceDraftService.new().generate_starting_draft(_run_content_profile(), target_run.seed_value, draft_rules, target_run.starting_modifiers.unlocked_pieces)
	if draft.selected_cards().size() < draft.required_selection_count:
		PieceDraftService.new().randomize_selection(draft, target_run.seed_value)
	PieceDraftService.new().confirm_draft(draft, target_run, draft_rules)
	target_run.piece_draft = draft

func _run_content_profile() -> ProfileState:
	return ProfileState.new()

func _daily_date_key(target_run: RunState) -> String:
	if target_run == null:
		return DailyChallengeService.get_date_key()
	if not target_run.daily_date_key.is_empty():
		return target_run.daily_date_key
	var inferred: String = DailyChallengeService.infer_date_key(target_run.seed_value, target_run.run_sequence)
	return inferred if not inferred.is_empty() else DailyChallengeService.get_date_key()

func _resolved_piece_draft_rules(target_run: RunState, base_rules: PieceDraftRules) -> PieceDraftRules:
	var rules: PieceDraftRules = base_rules.duplicate(true) as PieceDraftRules
	rules.candidate_count += target_run.starting_modifiers.draft_candidate_count_bonus
	rules.selection_count += target_run.starting_modifiers.draft_selection_count_bonus
	if target_run.starting_modifiers.guarantee_small_draft_candidate and not rules.required_piece_tags.has(required_small_piece_tag):
		rules.required_piece_tags.append(required_small_piece_tag)
	return rules

func _show_pending_piece_addition(continuation: Callable, flow: PieceSelectionFlow.Value = PieceSelectionFlow.Value.NONE) -> bool:
	if run_state.pending_piece_addition == null or run_state.pending_piece_addition.candidate_pieces.is_empty():
		return false
	if flow != PieceSelectionFlow.Value.NONE:
		run_state.pending_piece_addition.continuation_flow = flow
	_clear_screens()
	var screen: PieceAdditionScreen = piece_addition_scene.instantiate() as PieceAdditionScreen
	_set_screen(screen)
	screen.start(run_state)
	screen.selection_completed.connect(func() -> void: _save_active_run(); continuation.call())
	screen.selection_changed.connect(_save_active_run)
	_save_active_run()
	return true

func _resume_pending_piece_addition() -> bool:
	match run_state.pending_piece_addition.continuation_flow:
		PieceSelectionFlow.Value.COMBAT_REWARD:
			return _show_pending_piece_addition(_finish_combat_reward, PieceSelectionFlow.Value.COMBAT_REWARD)
		PieceSelectionFlow.Value.COMPLETE_NODE:
			return _show_pending_piece_addition(_complete_current_node, PieceSelectionFlow.Value.COMPLETE_NODE)
		PieceSelectionFlow.Value.SHOP:
			var node: RouteNodeState = run_state.route.current_node if run_state.route != null else null
			if node != null:
				return _show_pending_piece_addition(show_shop.bind(node), PieceSelectionFlow.Value.SHOP)
			return _show_pending_piece_addition(_resume_current_node, PieceSelectionFlow.Value.SHOP)
		_:
			return _show_pending_piece_addition(_resume_current_node)

func _show_pending_piece_selection(continuation: Callable, flow: PieceSelectionFlow.Value) -> bool:
	var pending: PieceModifierState
	for state: PieceModifierState in run_state.piece_modifiers:
		if state.pending_selection:
			pending = state
			break
	if pending == null:
		run_state.pending_piece_selection_flow = PieceSelectionFlow.Value.NONE
		return false
	if pending.candidate_pieces.is_empty():
		pending.pending_selection = false
		run_state.pending_piece_selection_flow = PieceSelectionFlow.Value.NONE
		return false
	run_state.pending_piece_selection_flow = flow
	_clear_screens()
	var overlay: PieceTargetSelectionOverlay = piece_target_selection_scene.instantiate() as PieceTargetSelectionOverlay
	_set_screen(overlay)
	overlay.start(run_state, pending)
	overlay.selection_completed.connect(func() -> void:
		run_state.pending_piece_selection_flow = PieceSelectionFlow.Value.NONE
		_save_active_run()
		if not _show_pending_piece_selection(continuation, flow):
			continuation.call())
	_save_active_run()
	return true

func _resume_pending_piece_selection() -> void:
	match run_state.pending_piece_selection_flow:
		PieceSelectionFlow.Value.COMBAT_REWARD:
			_show_pending_piece_selection(_finish_combat_reward, PieceSelectionFlow.Value.COMBAT_REWARD)
		PieceSelectionFlow.Value.COMPLETE_NODE:
			_show_pending_piece_selection(_complete_current_node, PieceSelectionFlow.Value.COMPLETE_NODE)
		PieceSelectionFlow.Value.SHOP:
			var node: RouteNodeState = run_state.route.current_node
			if node != null:
				_show_pending_piece_selection(show_shop.bind(node), PieceSelectionFlow.Value.SHOP)
			else:
				show_route()
		_:
			run_state.pending_piece_selection_flow = PieceSelectionFlow.Value.NONE
			_resume_current_node()

func _set_screen(screen: Control) -> void:
	current_screen = screen
	screen_container.add_child(screen)
	_style_confirmation_dialogs(screen)
	ScreenTransitionController.enter(screen, MotionSettings.from_saved_settings(SaveService.settings))

func _style_confirmation_dialogs(root: Node) -> void:
	var dialog_nodes: Array[Node] = root.find_children(dialog_name_pattern, confirmation_dialog_class, true, false)
	for dialog_node: Node in dialog_nodes:
		var dialog: ConfirmationDialog = dialog_node as ConfirmationDialog
		if dialog == null:
			continue
		dialog.theme = theme
		dialog.get_label().theme_type_variation = body_text_theme
		var confirm_button: Button = dialog.get_ok_button()
		confirm_button.theme_type_variation = primary_button_theme
		confirm_button.icon = empty_icon
		var cancel_button: Button = dialog.get_cancel_button()
		cancel_button.theme_type_variation = secondary_button_theme
		cancel_button.icon = empty_icon

func _clear_screens() -> void:
	_cancel_button_touch()
	_set_tutorial_overlay_suspended(false)
	if pause_screen != null:
		pause_screen.visible = false
		pause_screen.set_process_input(false)
		pause_screen.set_process_unhandled_input(false)
		pause_screen.queue_free()
		pause_screen = null
	for child: Node in screen_container.get_children():
		child.set_process_input(false)
		child.set_process_unhandled_input(false)
		var control: Control = child as Control
		if control != null:
			control.visible = false
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		child.queue_free()
	current_screen = null
	run_screen = null

func _set_tutorial_overlay_suspended(suspended: bool) -> void:
	var overlay: TutorialOverlay = get_tree().root.get_node_or_null(tutorial_overlay_path) as TutorialOverlay
	if overlay != null:
		overlay.set_suspended(suspended)
