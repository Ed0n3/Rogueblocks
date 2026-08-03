class_name RunScreen
extends Control

const VAULT_ARTIFACT: BossArtifactDefinition = preload("res://content/artifacts/vault_shapes.tres")
const STATUS_EFFECTS_TUTORIAL: TutorialDefinition = preload("res://content/tutorials/contextual/status_effects.tres")

const BoardSwipeGesture = preload("res://presentation/board/board_swipe_gesture.gd")
const RunTutorialEventAdapter = preload("res://core/tutorial/run_tutorial_event_adapter.gd")

signal encounter_won()
signal run_lost(reason: String)
signal pause_requested()
signal safe_point_reached(encounter_data: Dictionary)

@export var item_hold_duration: float = 0.55
@export var visual_settings: CombatVisualSettings
@export var mobile_breakpoint_width: float = 900.0
@export var mobile_place_area_ratio: float = 0.25
@export var mobile_place_minimum_height: float = 82.0
@export var tutorials_enabled: bool = true

@export_category("Debug Overlay")
@export var debug_overlay_margin: float = 24.0
@export var debug_overlay_top: float = 94.0
@export var debug_overlay_desktop_width: float = 760.0
@export var debug_overlay_height: float = 602.0
@export var debug_overlay_compact_breakpoint_width: float = 700.0
@export_range(1, 4, 1) var debug_overlay_desktop_columns: int = 4
@export_range(1, 4, 1) var debug_overlay_compact_columns: int = 2

@onready var board_view: BoardView = %BoardView
@onready var controller: EncounterController = %EncounterController
@onready var hand_view: PieceHandView = %PieceHandView
@onready var draw_pile_view: PiecePileView = %DrawPileView
@onready var discard_pile_view: PiecePileView = %DiscardPileView
@onready var event_log: RichTextLabel = %EventLog
@onready var debug_panel: PanelContainer = %DebugPanel
@onready var enemy_presentation: EnemyPresentation = %EnemyPresentation
@onready var enemy_intent_view: EnemyIntentView = %EnemyIntentView
@onready var presentation: CombatPresentationController = %CombatPresentationController
@onready var vfx: VFXLayer = %VFXLayer
@onready var status_effect_info_overlay: StatusEffectInfoOverlay = %StatusEffectInfoOverlay

var run_state: RunState
var generator: PieceGenerator
var motion: MotionSettings
var loss_pending: bool = false
var screen_swipe_gesture: BoardSwipeGesture = BoardSwipeGesture.new(BoardView.TOUCH_SWIPE_THRESHOLD)
var screen_swipe_active: bool:
	get:
		return screen_swipe_gesture.active
var item_touch_slot: int = -1
var item_touch_started_msec: int = 0
var item_info_opened: bool = false
var suppressed_item_press_slot: int = -1
var mobile_layout: bool = false
var tutorial_encounter_sequence: int = -1
var tutorial_events: RunTutorialEventAdapter = RunTutorialEventAdapter.new()

func start(current_run: RunState, enemy: EnemyDefinition, shared_generator: PieceGenerator) -> bool:
	return _open_encounter(current_run, enemy, shared_generator, {}, false)

func restore(current_run: RunState, enemy: EnemyDefinition, shared_generator: PieceGenerator, data: Dictionary) -> bool:
	return _open_encounter(current_run, enemy, shared_generator, data, true)

func _open_encounter(current_run: RunState, enemy: EnemyDefinition, shared_generator: PieceGenerator, data: Dictionary, restoring: bool) -> bool:
	if current_run == null or enemy == null or shared_generator == null:
		push_error("Cannot open run screen because encounter resources are unavailable")
		return false
	run_state = current_run
	generator = shared_generator
	tutorial_encounter_sequence = run_state.encounter_index
	if tutorials_enabled:
		TutorialService.begin_run(run_state.run_sequence)
		TutorialService.begin_encounter(tutorial_encounter_sequence)
		TutorialService.enter_screen(TutorialScreen.Value.COMBAT, self)
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	_connect_controller()
	if tutorials_enabled:
		tutorial_events.setup(run_state, controller, board_view)
		TutorialService.set_gameplay_context(run_state, controller, board_view)
	%ArtifactStrip.setup(run_state)
	enemy_presentation.configure(enemy, enemy.visual)
	presentation.configure(enemy_presentation, board_view, vfx, %MainLayout, %PlayerHealthBar)
	presentation.busy_changed.connect(_set_presentation_busy)
	var opened: bool = controller.restore_encounter(run_state, enemy, generator, data) if restoring else controller.start_encounter(run_state, enemy, generator)
	if not opened:
		if tutorials_enabled:
			TutorialService.clear_gameplay_context(controller)
		return false
	board_view.set_board(controller.board)
	_show_piece_preview(controller.active_piece)
	if tutorials_enabled:
		TutorialService.publish(TutorialEventId.Value.ENCOUNTER_STARTED, run_state.encounter_index, enemy)
		tutorial_events.publish_inventory_events()
	_update_status()
	_log(("Encounter resumed: %s" if restoring else "Encounter started: %s") % enemy.display_name)
	MotionPresets.pop_in(%BoardFrame, 0.04, motion)
	MotionPresets.pop_in(%EnemyStage, 0.12, motion)
	return true

func _ready() -> void:
	if visual_settings == null:
		visual_settings = load("res://content/presentation/combat_visual_settings.tres") as CombatVisualSettings
	hand_view.card_selected.connect(_select_card)
	%RotateLeft.pressed.connect(_rotate_piece.bind(false))
	%RotateRight.pressed.connect(_rotate_piece.bind(true))
	%PlaceButton.pressed.connect(board_view.confirm_preview)
	%RerollButton.pressed.connect(controller.redraw_hand)
	%EndTurnButton.pressed.connect(controller.end_player_turn)
	%EmergencyButton.pressed.connect(func() -> void: controller.use_emergency_clearance(); board_view.queue_redraw(); _update_status(); _update_hand())
	%VaultButton.pressed.connect(_use_vault_piece)
	%VaultPieceList.piece_requested.connect(_use_vault_piece)
	%PlayerStatuses.details_requested.connect(_show_status_details)
	%EnemyStatuses.details_requested.connect(_show_status_details)
	%TwinSkipButton.pressed.connect(func() -> void: controller.skip_twin_core_placement(); _update_status(); _update_hand())
	%PauseButton.pressed.connect(func() -> void: pause_requested.emit())
	%LogButton.toggled.connect(_set_debug_overlay_visible)
	%DebugClose.pressed.connect(_close_debug_overlay)
	board_view.placement_requested.connect(controller.place)
	board_view.rotation_requested.connect(func(clockwise: bool) -> void:
		_rotate_piece(clockwise))
	board_view.preview_confirmation_changed.connect(func(_available: bool) -> void: _update_place_button())
	board_view.preview_confirmation_changed.connect(_publish_preview_state)
	%DebugDamage.pressed.connect(controller.debug_damage_enemy)
	%DebugHeal.pressed.connect(controller.debug_heal_player)
	%DebugBlocker.pressed.connect(func() -> void: controller.board.add_blockers(1, generator.rng); board_view.queue_redraw(); _update_status())
	%DebugClear.pressed.connect(func() -> void: controller.debug_clear_board(); board_view.queue_redraw())
	%DebugPrint.pressed.connect(controller.debug_print_board)
	%DebugWin.pressed.connect(controller.debug_win_encounter)
	%DebugRestart.pressed.connect(func() -> void: controller.debug_restart_encounter(); board_view.set_board(controller.board); _update_status())
	%DebugModifier.pressed.connect(func() -> void: controller.debug_toggle_ember_for_active_piece(); board_view.queue_redraw(); _update_hand())
	%DebugTutorial.pressed.connect(func() -> void: TutorialService.start_tutorial(STATUS_EFFECTS_TUTORIAL, true))
	%DebugTutorialNext.pressed.connect(TutorialService.debug_force_complete_current)
	%DebugTutorialReset.pressed.connect(TutorialService.reset_progress)
	%DebugTutorialValidate.pressed.connect(func() -> void: print("Tutorial validation: %s" % [TutorialService.debug_validation_report()]))
	_set_debug_overlay_visible(false)
	for index: int in _item_buttons().size():
		var button: Button = _item_buttons()[index]
		button.pressed.connect(_on_item_pressed.bind(index))
		button.button_down.connect(_on_item_button_down.bind(index))
		button.button_up.connect(_on_item_button_up.bind(index))
	_apply_responsive_layout()
	%ItemInfoClose.pressed.connect(_hide_item_info)
	%ItemInfoOverlay.visibility_changed.connect(_update_tutorial_interrupt_safety)
	%StatusEffectInfoOverlay.visibility_changed.connect(_update_tutorial_interrupt_safety)
	if tutorials_enabled:
		_register_tutorial_targets()
		tree_exiting.connect(_unregister_tutorial_targets)
	%VFXLayer.visible = true

func _process(delta: float) -> void:
	if run_state != null and not get_tree().paused:
		run_state.elapsed_play_time += delta
	if debug_panel.visible and controller != null and controller.board != null:
		%DebugText.text = "Seed %d | RNG calls %d\nState %s | Occupied %d\nHand %s\nDiscard %s\nModifiers %s\nContributions %d\nTutorial %s | Queue %d\nTargets %d\nFPS %d | VFX %s" % [run_state.seed_value, generator.call_count, EncounterController.TurnState.keys()[controller.state], controller.board.width * controller.board.height - controller.board.count_empty_cells(), _hand_names(), _discard_names(), _piece_modifier_report(), controller.last_clear_result.piece_contributions.size() if controller.last_clear_result != null else 0, TutorialService.active_definition.display_name if TutorialService.active_definition != null else "none", TutorialService.queued_tutorials().size(), TutorialTargetRegistry.registered_targets().size(), Engine.get_frames_per_second(), "busy" if presentation.playing else "idle"]
	if item_touch_slot >= 0 and not item_info_opened and float(Time.get_ticks_msec() - item_touch_started_msec) / 1000.0 >= item_hold_duration:
		_show_item_info(item_touch_slot)
		item_info_opened = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var special_placement_cancelled: bool = controller.cancel_bonus_placement()
		if not special_placement_cancelled:
			special_placement_cancelled = controller.cancel_vault_placement()
		if not special_placement_cancelled:
			pause_requested.emit()
	elif event.is_action_pressed("fast_forward"):
		presentation.skip_to_end()
	elif event.is_action_pressed("debug_overlay") and OS.is_debug_build():
		_set_debug_overlay_visible(not debug_panel.visible)
	elif presentation.playing:
		return
	elif event.is_action_pressed("rotate_left"):
		_rotate_piece(false)
	elif event.is_action_pressed("rotate_right"):
		_rotate_piece(true)
	elif event.is_action_pressed("switch_block"):
		var previous_card_id: int = controller.active_card.card_id if controller.active_card != null else 0
		controller.select_next_choice()
		if controller.active_card != null and controller.active_card.card_id != previous_card_id:
			_publish_piece_selected()
	elif event is InputEventKey and event.pressed and not event.echo:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_8:
			_use_item(int(key_event.keycode - KEY_1))

func _input(event: InputEvent) -> void:
	if status_effect_info_overlay.capture_modal_touch(event):
		_reset_screen_swipe()
		get_viewport().set_input_as_handled()
		return
	if _handle_system_touch(event):
		return
	if _is_debug_overlay_input(event):
		_reset_screen_swipe()
		return
	if %ItemInfoOverlay.visible:
		if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
			_hide_item_info()
			get_viewport().set_input_as_handled()
			return
	if run_state == null or controller == null or presentation == null or presentation.playing or controller.state != EncounterController.TurnState.AWAITING_PLACEMENT:
		_cancel_screen_swipe_on_release(event)
		return
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			if _is_touch_over_button(touch.position) or _is_touch_over_effect_control(touch.position):
				_reset_screen_swipe()
				return
			var local_position: Vector2 = board_view.get_global_transform_with_canvas().affine_inverse() * touch.position
			var rotation_tutorial_swipe: bool = _captures_rotation_tutorial_swipe(touch.position)
			screen_swipe_gesture.begin(touch.index, touch.position, rotation_tutorial_swipe or not board_view.touch_armed or not board_view.is_position_near_preview(local_position))
			if rotation_tutorial_swipe:
				get_viewport().set_input_as_handled()
		elif screen_swipe_gesture.active and touch.index == screen_swipe_gesture.touch_index:
			_resolve_screen_swipe(touch)
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if screen_swipe_gesture.update(drag.index, drag.position) and _captures_rotation_tutorial_swipe(drag.position):
			get_viewport().set_input_as_handled()

func _resolve_screen_swipe(event: InputEventScreenTouch) -> void:
	if board_view.touch_active and board_view.touch_started_armed:
		screen_swipe_gesture.reset()
		return
	if screen_swipe_gesture.finish(event.index, event.position):
		_rotate_piece(true)
		get_viewport().set_input_as_handled()

func _captures_rotation_tutorial_swipe(position: Vector2) -> bool:
	if not tutorials_enabled or not mobile_layout or not board_view.get_global_rect().has_point(position):
		return false
	var step: TutorialStepDefinition = TutorialService.current_step()
	return step != null and step.target != null and step.target.target_key == TutorialTargetKey.Value.COMBAT_ROTATE_TUTORIAL

func _is_touch_over_button(position: Vector2) -> bool:
	for node: Node in find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button != null and button.is_visible_in_tree() and button.get_global_rect().has_point(position):
			return true
	return false

func _is_touch_over_effect_control(position: Vector2) -> bool:
	for control: Control in [%PlayerStatuses as Control, %EnemyStatuses as Control, %VaultPieceList as Control]:
		if control.is_visible_in_tree() and control.get_global_rect().has_point(position):
			return true
	return false

func _cancel_screen_swipe_on_release(event: InputEvent) -> void:
	screen_swipe_gesture.cancel_on_release(event)

func _reset_screen_swipe() -> void:
	screen_swipe_gesture.reset()

func _handle_system_touch(event: InputEvent) -> bool:
	var touch: InputEventScreenTouch = event as InputEventScreenTouch
	if touch == null or not touch.pressed:
		return false
	if %PauseButton.get_global_rect().has_point(touch.position):
		_reset_screen_swipe()
		pause_requested.emit()
		get_viewport().set_input_as_handled()
		return true
	if %LogButton.get_global_rect().has_point(touch.position):
		_reset_screen_swipe()
		%LogButton.button_pressed = not %LogButton.button_pressed
		get_viewport().set_input_as_handled()
		return true
	return false

func _is_debug_overlay_input(event: InputEvent) -> bool:
	if not debug_panel.visible:
		return false
	var position: Vector2
	if event is InputEventScreenTouch:
		position = (event as InputEventScreenTouch).position
	elif event is InputEventScreenDrag:
		position = (event as InputEventScreenDrag).position
	else:
		return false
	return debug_panel.get_global_rect().has_point(position) or %EventLogPanel.get_global_rect().has_point(position)

func set_paused(paused: bool) -> void:
	controller.set_paused(paused)
	board_view.interaction_enabled = not paused and not presentation.playing
	_update_place_button()

func _connect_controller() -> void:
	controller.hand_changed.connect(_on_hand_changed)
	controller.placement_economy_changed.connect(_on_placement_economy_changed)
	controller.active_piece_changed.connect(_on_active_piece_changed)
	controller.piece_placed.connect(_on_piece_placed)
	controller.lines_cleared.connect(_show_clear_feedback)
	controller.score_awarded.connect(func(_result: ScoreResult) -> void: _update_status())
	controller.enemy_damaged.connect(_on_enemy_damaged)
	controller.enemy_attacked.connect(_on_enemy_attacked)
	controller.enemy_phase_changed.connect(func(phase: EnemyPhaseDefinition) -> void: presentation.enqueue_enemy_phase_change(phase))
	controller.status_changed.connect(_update_status)
	controller.event_logged.connect(_log)
	controller.encounter_won.connect(_on_encounter_won)
	controller.run_lost.connect(_on_run_lost)
	controller.safe_point_reached.connect(func(data: Dictionary) -> void: safe_point_reached.emit(data))
	controller.counter_changed.connect(_on_counter_changed)
	controller.item_used.connect(_show_item_feedback)
	controller.turn_state_changed.connect(func(_previous: int, _current: int) -> void: _update_item_belt(); _update_rotation_controls())
	controller.artifact_activated.connect(_show_artifact_activation)
	controller.intent_changed.connect(_on_intent_changed)
	controller.special_preview_requested.connect(_on_special_preview_requested)

func _on_hand_changed(_cards: Array[PieceCardState], _placeable: Array[bool]) -> void:
	_update_hand()

func _on_placement_economy_changed(_remaining: int, _maximum: int, _redraw_cost: int, _free_redraws: int) -> void:
	_update_hand()

func _on_active_piece_changed(piece: PieceInstance) -> void:
	var piece_changed: bool = board_view.active_piece != piece
	var previous_origin: Vector2i = board_view.preview_origin
	var had_preview: bool = board_view.preview_visible
	board_view.set_active_piece(piece)
	if piece_changed:
		_show_piece_preview(piece, previous_origin if had_preview else Vector2i(-1, -1))
	_update_hand()

func _show_piece_preview(piece: PieceInstance, preferred_origin: Vector2i = Vector2i(-1, -1)) -> void:
	if piece == null or controller.board == null or board_view.board == null:
		return
	if controller.bonus_placement_mode or controller.vault_piece_placement_active:
		return
	var candidate: PiecePlacementCandidate = controller.board.find_piece_placement(piece.definition, preferred_origin, piece.rotation_index)
	if candidate.found:
		board_view.arm_preview(candidate)

func _on_special_preview_requested(candidate: PiecePlacementCandidate) -> void:
	board_view.arm_preview(candidate)
	_update_place_button()

func restore_special_preview() -> void:
	if controller.active_piece == null or not controller.bonus_placement_mode and not controller.vault_piece_placement_active:
		return
	var candidate: PiecePlacementCandidate = controller.board.find_piece_placement(controller.active_piece.definition, Vector2i(-1, -1), controller.active_piece.rotation_index)
	if candidate.found:
		board_view.arm_preview(candidate)

func _on_piece_placed(result: PlacementResult) -> void:
	board_view.play_placement(result, motion)

func _on_enemy_damaged(result: DamageResult) -> void:
	presentation.enqueue_enemy_damage(result)

func _on_enemy_attacked(damage: int, blockers: Array[Vector2i]) -> void:
	presentation.enqueue_enemy_attack(damage, blockers)
	board_view.queue_redraw()

func _on_counter_changed(counter: ActiveCounterState, definition: CounterDefinition) -> void:
	board_view.set_counter(counter, definition)
	_update_status()

func _on_intent_changed(intent: ResolvedEnemyIntent) -> void:
	enemy_intent_view.display_intent(intent)

func _update_hand() -> void:
	var actions_available: bool = not presentation.playing
	hand_view.set_interaction_enabled(actions_available)
	var blocked_card_ids: Array[int] = []
	if controller.deck_state != null:
		for index: int in controller.deck_state.hand.size():
			if index >= controller.hand_placeable.size() or not controller.hand_placeable[index]:
				blocked_card_ids.append(controller.deck_state.hand[index].card_id)
	var active_card_id: int = controller.active_card.card_id if controller.active_card != null else -1
	var cards: Array[PieceCardState] = controller.deck_state.hand if controller.deck_state != null else []
	hand_view.set_hand(cards, active_card_id, blocked_card_ids)
	hand_view.set_placement_points(controller.placement_points_remaining, controller.maximum_placement_points)
	for card: PieceCardState in cards:
		var card_control: PieceHandCard = hand_view.card_control(card.card_id)
		if card_control != null:
			card_control.set_modifiers(run_state.get_piece_modifiers(card.piece))
	if tutorials_enabled:
		_refresh_hand_tutorial_targets(cards)
	var redraw_available: bool = actions_available and controller.can_redraw_hand()
	var redraw_cost: int = controller.current_redraw_placement_point_cost()
	%RerollButton.disabled = not redraw_available
	%RerollButton.modulate.a = 1.0 if redraw_available else 0.42
	%RerollButton.tooltip_text = "Redraw all drawn pieces for free" if redraw_cost == 0 else "Redraw all drawn pieces for %d PM" % redraw_cost
	_set_action_badge(%RerollButton as Button, "FREE" if redraw_cost == 0 else "%d PM" % redraw_cost)
	var emergency_available: bool = actions_available and run_state.emergency_clear_charges > 0
	%EmergencyButton.disabled = not emergency_available
	%EmergencyButton.modulate.a = 1.0 if emergency_available else 0.42
	_set_action_badge(%EmergencyButton as Button, "%d" % run_state.emergency_clear_charges)
	var can_end_turn: bool = actions_available and (controller.state == EncounterController.TurnState.AWAITING_SELECTION or controller.state == EncounterController.TurnState.AWAITING_PLACEMENT) and not controller.bonus_placement_mode and not controller.vault_piece_placement_active and not controller.twin_core_second_placement
	%EndTurnButton.disabled = not can_end_turn
	%EndTurnButton.modulate.a = 1.0 if can_end_turn else 0.42
	_set_action_badge(%EndTurnButton as Button, "")
	var vault: BossArtifactState = run_state.get_artifact_state(VAULT_ARTIFACT)
	%VaultButton.visible = vault != null
	%VaultPieceList.visible = vault != null
	%VaultButton.disabled = not actions_available or vault == null or vault.stored_cards.is_empty() or controller.state != EncounterController.TurnState.AWAITING_PLACEMENT or controller.bonus_placement_mode or controller.vault_piece_placement_active or controller.twin_core_second_placement
	var vault_turns: int = controller.vault_storage_service.turns_remaining(run_state) if vault != null else 0
	var vault_usable: bool = vault != null and not vault.stored_cards.is_empty() and not %VaultButton.disabled
	%VaultPieceList.set_vault(vault, controller.vault_storage_service.capacity(), vault_turns, vault_usable, controller.vault_piece_placement_active)
	if vault == null:
		_set_action_badge(%VaultButton as Button, "")
		%VaultButton.tooltip_text = ""
	elif controller.vault_piece_placement_active:
		_set_action_badge(%VaultButton as Button, "ACTIVE")
		%VaultButton.tooltip_text = "Place the active Vault Block"
	elif not vault.stored_cards.is_empty():
		_set_action_badge(%VaultButton as Button, "%d" % vault.stored_cards.size())
		%VaultButton.tooltip_text = "Place the stored Vault Block"
	else:
		_set_action_badge(%VaultButton as Button, "READY" if vault_turns == 0 else "%dT" % vault_turns)
		%VaultButton.tooltip_text = "Ready to store an unplayed Block" if vault_turns == 0 else "%d turn(s) until the Vault can store a Block" % vault_turns
	%TwinSkipButton.visible = controller.twin_core_second_placement
	_update_piles()
	_update_place_button()

func _update_status() -> void:
	if run_state == null or controller.enemy == null:
		return
	%PlayerHealth.text = "%d / %d" % [run_state.player_health, run_state.maximum_health]
	%PlayerHealthBar.max_value = run_state.maximum_health
	%PlayerHealthBar.value = run_state.player_health
	%EnemyName.text = controller.enemy.display_name
	%EnemyHealth.text = "%d / %d" % [controller.enemy_health, controller.enemy_maximum_health]
	%EnemyHealthBar.max_value = controller.enemy_maximum_health
	%EnemyHealthBar.value = controller.enemy_health
	if controller.resolved_enemy_intent != null:
		enemy_intent_view.display_intent(controller.resolved_enemy_intent)
		enemy_intent_view.update_countdown(controller.enemy_countdown)
		enemy_intent_view.set_counter_state(controller.active_counter)
	_update_combo_color(controller.combo)
	%Encounter.text = ""#"E%d" % (run_state.encounter_index + 1)
	%Seed.text = "Seed %d" % run_state.seed_value
	%Shards.text = "%d" % run_state.shards
	%PlayerStatuses.set_effects(run_state.player_statuses, run_state.player_shield)
	%EnemyStatuses.set_effects(controller.effect_state.enemy_statuses, controller.effect_state.enemy_shield)
	(%PlayerHealthBar as StatusHealthBar).set_effects(run_state.player_statuses)
	(%EnemyHealthBar as StatusHealthBar).set_effects(controller.effect_state.enemy_statuses)
	_apply_status_health_colors()
	enemy_presentation.set_combat_state(controller.resolved_enemy_intent, controller.effect_state.enemy_shield, controller.effect_state.enemy_statuses)
	_update_item_belt()
	_update_piles()
	board_view.queue_redraw()
	%ArtifactStrip.refresh()
	_update_rotation_controls()

func _update_piles() -> void:
	if controller.deck_state == null:
		return
	var discard_top: PieceCardState = controller.deck_state.discard_pile.back() as PieceCardState if not controller.deck_state.discard_pile.is_empty() else null
	draw_pile_view.set_pile(PiecePileView.PileKind.DRAW, controller.deck_state.draw_pile.size())
	discard_pile_view.set_pile(PiecePileView.PileKind.DISCARD, controller.deck_state.discard_pile.size(), discard_top)

func _show_artifact_activation(artifact: BossArtifactDefinition, _message: String) -> void:
	%ArtifactStrip.pulse(artifact, motion)
	_update_status()

func _update_combo_color(combo_value: int) -> void:
	%Combo.text = "COMBO x%d" % combo_value
	if visual_settings == null or visual_settings.combo == null:
		return
	%Combo.add_theme_color_override("font_color", visual_settings.combo.color_for_combo(combo_value))

func _log(message: String) -> void:
	event_log.append_text("- %s\n" % message)
	event_log.scroll_to_line(event_log.get_line_count())
	%Toast.text = message
	%Toast.visible = true
	%Toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(motion.duration(1.25) if motion != null else 1.25)
	tween.tween_property(%Toast, "modulate:a", 0.0, motion.duration(0.22) if motion != null else 0.22)
	tween.tween_callback(func() -> void: %Toast.visible = false)

func _show_clear_feedback(result: ClearResult) -> void:
	presentation.enqueue_clear(result)
	presentation.enqueue_poisoned_block_damage(result)
	var message: String = "PERFECT CLEAR" if result.perfect_clear else ("CROSS CLEAR" if result.cross_clear else "%d LINE CLEAR" % result.line_count)
	%ClearBanner.text = message
	%ClearBanner.visible = true
	%ClearBanner.modulate = Color.WHITE
	var tween: Tween = create_tween()
	tween.tween_interval(motion.duration(0.45))
	tween.tween_property(%ClearBanner, "modulate:a", 0.0, motion.duration(0.25))
	tween.tween_callback(func() -> void: %ClearBanner.visible = false)

func _on_encounter_won() -> void:
	board_view.interaction_enabled = false
	await presentation.play_enemy_defeat()
	encounter_won.emit()

func _on_run_lost(reason: String) -> void:
	if loss_pending:
		return
	loss_pending = true
	board_view.interaction_enabled = false
	await presentation.wait_until_idle()
	run_lost.emit(reason)

func _set_presentation_busy(busy: bool) -> void:
	board_view.interaction_enabled = not busy and controller.state == EncounterController.TurnState.AWAITING_PLACEMENT
	_update_place_button()
	_update_hand()
	_update_item_belt()
	_update_rotation_controls()
	if tutorials_enabled:
		TutorialService.set_safe_to_interrupt(not busy and not %ItemInfoOverlay.visible and not %StatusEffectInfoOverlay.visible)

func _update_tutorial_interrupt_safety() -> void:
	if tutorials_enabled:
		TutorialService.set_safe_to_interrupt(not presentation.playing and not %ItemInfoOverlay.visible and not %StatusEffectInfoOverlay.visible)

func _update_rotation_controls() -> void:
	if run_state == null or controller == null:
		return
	var slowed: bool = run_state.player_statuses.get_status(preload("res://content/statuses/slowed_hands.tres") as StatusDefinition) != null
	var unavailable: bool = slowed or controller.state != EncounterController.TurnState.AWAITING_PLACEMENT or presentation.playing
	%RotateLeft.disabled = unavailable
	%RotateRight.disabled = unavailable
	%RotateLeft.tooltip_text = "Slowed Hands prevents rotation" if slowed else "Rotate left (Q)"
	%RotateRight.tooltip_text = "Slowed Hands prevents rotation" if slowed else "Rotate right (E)"

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_apply_responsive_layout.call_deferred()

func _apply_responsive_layout() -> void:
	var touch_layout: bool = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() or size.x <= mobile_breakpoint_width and size.y > size.x
	_apply_mobile_layout(touch_layout)
	_apply_debug_overlay_layout()

func _apply_mobile_layout(enabled: bool) -> void:
	mobile_layout = enabled
	%RotateLeft.visible = true
	%RotateRight.visible = true
	_register_rotation_tutorial_target()
	var rotation: HBoxContainer = %PlaceButton.get_parent() as HBoxContainer
	var target_height: float = maxf(mobile_place_minimum_height, %DraftPanel.size.y * mobile_place_area_ratio) if enabled else 56.0
	rotation.custom_minimum_size.y = target_height
	%PlaceButton.custom_minimum_size.y = target_height
	%PlaceButton.set("icon_size", 38.0 if enabled else 30.0)
	%PlaceButton.queue_redraw()

func _set_debug_overlay_visible(open: bool) -> void:
	debug_panel.visible = open
	%EventLogPanel.visible = open
	if %LogButton.button_pressed != open:
		%LogButton.set_pressed_no_signal(open)
	if open:
		%DebugClose.grab_focus()

func _close_debug_overlay() -> void:
	_set_debug_overlay_visible(false)
	%LogButton.grab_focus()

func _apply_debug_overlay_layout() -> void:
	var available_width: float = maxf(0.0, size.x - debug_overlay_margin * 2.0)
	var columns: int = debug_overlay_compact_columns if available_width < debug_overlay_compact_breakpoint_width else debug_overlay_desktop_columns
	%CombatActions.columns = columns
	%EncounterActions.columns = columns
	%TutorialActions.columns = columns
	_apply_debug_overlay_width.call_deferred()

func _apply_debug_overlay_width() -> void:
	var available_width: float = maxf(0.0, size.x - debug_overlay_margin * 2.0)
	var panel_width: float = minf(debug_overlay_desktop_width, available_width)
	var compact: bool = available_width < debug_overlay_compact_breakpoint_width
	var panel_top: float = debug_overlay_margin if compact else debug_overlay_top
	var panel_height: float = minf(debug_overlay_height, maxf(0.0, size.y - panel_top - debug_overlay_margin))
	debug_panel.offset_left = debug_overlay_margin
	debug_panel.offset_top = panel_top
	debug_panel.offset_right = debug_overlay_margin + panel_width
	debug_panel.offset_bottom = panel_top + panel_height

func _set_action_badge(button: Button, value: String) -> void:
	button.call("set_badge", value)

func _apply_status_health_colors() -> void:
	var player_statuses: StatusStripView = %PlayerStatuses as StatusStripView
	var player_color: Color = player_statuses.dominant_color() if player_statuses.has_visible_effects() else Color("74e5f2ff")
	_set_health_color(%PlayerTitle, %PlayerHealth, %PlayerHealthBar, player_color)
	var enemy_statuses: StatusStripView = %EnemyStatuses as StatusStripView
	var enemy_color: Color = enemy_statuses.dominant_color() if enemy_statuses.has_visible_effects() else Color("c58bff")
	_set_health_color(%EnemyName, %EnemyHealth, %EnemyHealthBar, enemy_color)

func _set_health_color(title: Label, value_label: Label, bar: ProgressBar, color: Color) -> void:
	title.add_theme_color_override("font_color", color)
	value_label.add_theme_color_override("font_color", color.lightened(0.18))
	var status_bar: StatusHealthBar = bar as StatusHealthBar
	if status_bar != null:
		status_bar.set_base_color(color)

func _show_status_details(definition: StatusDefinition, instance: StatusInstance, shield: int) -> void:
	if shield > 0:
		status_effect_info_overlay.show_shield(shield)
	elif definition != null and instance != null:
		status_effect_info_overlay.show_effect(definition, instance)

func _update_place_button() -> void:
	var place_button: Button = get_node_or_null("%PlaceButton") as Button
	if place_button == null or not is_instance_valid(board_view):
		return
	place_button.disabled = not board_view.can_confirm_preview()

func _hand_names() -> String:
	var names: PackedStringArray = []
	if controller.deck_state != null:
		for card: PieceCardState in controller.deck_state.hand:
			names.append(card.piece.display_name)
	return ", ".join(names)

func _discard_names() -> String:
	var names: PackedStringArray = []
	if controller.deck_state != null:
		for card: PieceCardState in controller.deck_state.discard_pile:
			names.append(card.piece.display_name)
	return ", ".join(names)

func _piece_modifier_report() -> String:
	var values: PackedStringArray = []
	for state: PieceModifierState in run_state.piece_modifiers:
		var targets: PackedStringArray = []
		for piece: PieceDefinition in state.target_pieces:
			targets.append(piece.display_name)
		values.append("%s=%s" % [state.definition.display_name, ",".join(targets)])
	return "none" if values.is_empty() else " | ".join(values)

func _item_buttons() -> Array[Button]:
	return [%Item1, %Item2, %Item3, %Item4, %Item5, %Item6, %Item7, %Item8]

func _on_item_pressed(slot_index: int) -> void:
	if suppressed_item_press_slot == slot_index:
		suppressed_item_press_slot = -1
		return
	_use_item(slot_index)

func _on_item_button_down(slot_index: int) -> void:
	if run_state == null or slot_index < 0 or slot_index >= run_state.inventory.slots.size() or run_state.inventory.slots[slot_index] == null:
		return
	suppressed_item_press_slot = -1
	item_touch_slot = slot_index
	item_touch_started_msec = Time.get_ticks_msec()
	item_info_opened = false

func _on_item_button_up(slot_index: int) -> void:
	if item_touch_slot != slot_index:
		return
	if item_info_opened:
		suppressed_item_press_slot = slot_index
	_clear_item_touch()

func _clear_item_touch() -> void:
	item_touch_slot = -1
	item_info_opened = false

func _show_item_info(slot_index: int) -> void:
	if run_state == null or slot_index < 0 or slot_index >= run_state.inventory.slots.size():
		return
	var stack: ItemStack = run_state.inventory.slots[slot_index]
	var definition: ItemDefinition = stack.definition if stack != null else null
	if definition == null:
		return
	var category_name: String = ItemCategory.display_name(definition.category)
	var target_name: String = String(ItemTargetMode.Value.keys()[int(definition.target_mode)]).replace("_", " ").capitalize()
	%ItemInfoName.text = definition.display_name
	%ItemInfoMeta.text = "%s  |  %s  |  %d charge(s)" % [category_name, target_name, stack.quantity]
	%ItemInfoEffects.text = definition.description
	if stack.bonus_piece != null:
		var piece: PieceDefinition = stack.bonus_piece
		if piece != null:
			%ItemInfoEffects.text += "\nStored Block: %s" % piece.display_name
	%ItemInfoOverlay.visible = true

func _hide_item_info() -> void:
	%ItemInfoOverlay.visible = false
	suppressed_item_press_slot = -1
	_clear_item_touch()

func _update_item_belt() -> void:
	var buttons: Array[Button] = _item_buttons()
	for index: int in buttons.size():
		var button: Button = buttons[index]
		button.visible = index < run_state.inventory.capacity
		if not button.visible:
			continue
		var stack: ItemStack = run_state.inventory.slots[index]
		var definition: ItemDefinition = stack.definition if stack != null else null
		var piece_modifiers: Array[PieceModifierState] = []
		if stack != null and stack.bonus_piece != null:
			piece_modifiers = run_state.get_piece_modifiers(stack.bonus_piece)
		button.call("set_item", index, stack, definition, piece_modifiers)
		button.tooltip_text = "%s\n%s" % [definition.display_name, definition.description] if definition != null else "Empty item slot"
		button.disabled = stack == null or run_state.inventory.locked_slots.has(index) or run_state.item_uses_remaining == 0 or controller.state != EncounterController.TurnState.AWAITING_PLACEMENT or presentation.playing

func _use_item(index: int) -> void:
	if presentation.playing:
		return
	var result: ItemUseResult = controller.use_item(index)
	if result.used:
		_log(result.message if not result.message.is_empty() else "Item used")
	elif not result.message.is_empty():
		_log(result.message)
	_update_status()

func _use_vault_piece(stored_index: int = 0) -> void:
	if presentation.playing:
		return
	var result: SpecialPieceActivationResult = controller.use_vault_piece(stored_index)
	if not result.message.is_empty():
		_log(result.message)
	_update_status()
	_update_hand()

func _status_text(collection: StatusCollection) -> String:
	var values: PackedStringArray = []
	for instance: StatusInstance in collection.instances:
		var definition: StatusDefinition = instance.definition
		if definition != null and definition.visible_to_player:
			values.append("%s x%d | %d" % [definition.display_name, instance.stacks, instance.remaining_turns])
	return "  ".join(values) if not values.is_empty() else " "

func _status_tooltip(collection: StatusCollection) -> String:
	var values: PackedStringArray = []
	for instance: StatusInstance in collection.instances:
		var definition: StatusDefinition = instance.definition
		if definition != null and definition.visible_to_player:
			values.append("%s x%d | %d turn(s)\n%s" % [definition.display_name, instance.stacks, instance.remaining_turns, definition.description])
	return "\n\n".join(values)

func _show_item_feedback(result: ItemUseResult, slot_index: int) -> void:
	var buttons: Array[Button] = _item_buttons()
	if slot_index >= 0 and slot_index < buttons.size():
		MotionPresets.pulse(buttons[slot_index], 1.08, motion)
	var target: Control = %EnemyStage if result.effect_result.health_damage + result.effect_result.shield_damage > 0 else %PlayerPanel
	MotionPresets.pulse(target, 1.025, motion)

func _rotate_piece(clockwise: bool) -> void:
	var previous_rotation: int = controller.active_piece.rotation_index if controller.active_piece != null else -1
	if clockwise:
		controller.rotate_clockwise()
	else:
		controller.rotate_counterclockwise()
	board_view.clamp_preview_to_board()
	if controller.active_piece != null and controller.active_piece.rotation_index != previous_rotation:
		if tutorials_enabled:
			tutorial_events.publish_piece_rotated(controller.active_piece, clockwise)

func _select_card(card_id: int) -> void:
	controller.select_card(card_id)
	_update_hand()
	if controller.active_card != null and controller.active_card.card_id == card_id:
		_publish_piece_selected()

func _publish_piece_selected() -> void:
	if tutorials_enabled:
		tutorial_events.publish_piece_selected(controller.active_piece, controller.active_card_index)

func _publish_preview_state(valid: bool) -> void:
	if tutorials_enabled:
		tutorial_events.publish_preview_state(valid)

func _register_tutorial_targets() -> void:
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_BOARD, board_view, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_PIECE_CHOICE_FIRST, hand_view, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_PIECE_CHOICE_SECOND, hand_view, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ROTATE_LEFT, %RotateLeft, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ROTATE_RIGHT, %RotateRight, self)
	_register_rotation_tutorial_target()
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_PLACE, %PlaceButton, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_REROLL, %RerollButton, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_DISCARD_QUEUE, discard_pile_view, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ENEMY, %EnemyStage, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ENEMY_INTENT, enemy_intent_view, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_PLAYER_HEALTH, %PlayerPanel, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ENEMY_HEALTH, %EnemyHealthBar, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ITEM_BELT, %ItemBelt, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_STATUS_PLAYER, %PlayerStatuses, self)
	TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_STATUS_ENEMY, %EnemyStatuses, self)

func _refresh_hand_tutorial_targets(cards: Array[PieceCardState]) -> void:
	var first_card: PieceHandCard = hand_view.card_control(cards[0].card_id) if not cards.is_empty() else null
	var second_card: PieceHandCard = hand_view.card_control(cards[1].card_id) if cards.size() > 1 else null
	_register_tutorial_target(TutorialTargetKey.Value.COMBAT_PIECE_CHOICE_FIRST, first_card if first_card != null else hand_view)
	_register_tutorial_target(TutorialTargetKey.Value.COMBAT_PIECE_CHOICE_SECOND, second_card if second_card != null else hand_view)

func _register_tutorial_target(key: TutorialTargetKey.Value, target: Control) -> void:
	if TutorialTargetRegistry.resolve_node(key) != target:
		TutorialTargetRegistry.register_target(key, target, self)

func _register_rotation_tutorial_target() -> void:
	var target: Control = %RotateRight
	if TutorialTargetRegistry.resolve_node(TutorialTargetKey.Value.COMBAT_ROTATE_TUTORIAL) != target:
		TutorialTargetRegistry.register_target(TutorialTargetKey.Value.COMBAT_ROTATE_TUTORIAL, target, self)

func _unregister_tutorial_targets() -> void:
	TutorialService.clear_gameplay_context(controller)
	TutorialService.set_safe_to_interrupt(true)
	TutorialService.leave_screen(TutorialScreen.Value.COMBAT, self)
	TutorialService.end_encounter(tutorial_encounter_sequence)
	TutorialTargetRegistry.unregister_owner(self)
