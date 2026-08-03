class_name TutorialRuntimeService
extends Node

const TutorialActivationRequest = preload("res://core/tutorial/tutorial_activation_request.gd")

signal event_published(event: TutorialEvent)
signal tutorial_started(definition: TutorialDefinition)
signal step_changed(definition: TutorialDefinition, step: TutorialStepDefinition, index: int)
signal tutorial_ended(definition: TutorialDefinition, completed: bool)
signal hint_requested(definition: TutorialDefinition, title: String, body: String, accent: Color, duration: float)
signal hints_cleared()
signal presentation_action_requested(action: TutorialPresentationAction)
signal queue_changed()

var active_definition: TutorialDefinition
var active_request: TutorialActivationRequest
var runtime: TutorialRuntimeState
var queued: Array[TutorialActivationRequest] = []
var context: TutorialContext = TutorialContext.new()
var finished_this_run: Array[TutorialDefinition] = []
var finished_this_encounter: Array[TutorialDefinition] = []
var safe_to_interrupt: bool = true
var suspended: bool = false
var current_run_sequence: int = 0
var current_encounter_sequence: int = -1
var current_screen: TutorialScreen.Value = TutorialScreen.Value.NONE
var current_screen_owner: WeakRef
var enqueue_sequence: int = 0
var suppress_queue_start: bool = false
var restore_pending: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_ensure_overlay")
	call_deferred("_validate_content")
	call_deferred("_restore_saved_tutorial")

func _process(delta: float) -> void:
	if suspended:
		return
	if runtime == null or active_definition == null:
		_restore_saved_tutorial()
		_try_start_queued()
		return
	runtime.elapsed_in_step += delta
	SaveService.profile.tutorial_progress.active_runtime = runtime
	var step: TutorialStepDefinition = current_step()
	if step == null:
		_complete_active()
		return
	if runtime.phase == TutorialRuntimePhase.Value.WAITING_FOR_CONDITION and step.auto_advance_delay > 0.0 and runtime.elapsed_in_step >= _automatic_duration(step.auto_advance_delay):
		advance_step()
	elif step.fallback_timeout > 0.0 and runtime.elapsed_in_step >= step.fallback_timeout:
		_jump_to_step(step.fallback_step)

func publish_event(event: TutorialEvent) -> void:
	if event == null:
		return
	if event.screen == TutorialScreen.Value.NONE:
		event.screen = current_screen
	context.current_event = event
	if event.screen != TutorialScreen.Value.NONE:
		context.screen = event.screen
	event_published.emit(event)
	if active_definition != null:
		_evaluate_current_step()
	_queue_matching_tutorials(event)
	_try_start_queued()

func publish(event_type: TutorialEventId.Value, int_value: int = 0, source: Resource = null) -> void:
	var event: TutorialEvent = TutorialEvent.new(event_type)
	event.int_value = int_value
	event.source = source
	publish_event(event)

func enter_screen(screen: TutorialScreen.Value, owner: Node) -> void:
	if screen == TutorialScreen.Value.NONE or owner == null:
		return
	current_screen = screen
	current_screen_owner = weakref(owner)
	context.screen = screen
	_discard_out_of_scope_requests()
	_restore_saved_tutorial()
	_try_start_queued()

func leave_screen(screen: TutorialScreen.Value, owner: Node) -> void:
	if screen != current_screen or current_screen_owner == null or current_screen_owner.get_ref() != owner:
		return
	if runtime != null and runtime.screen == screen:
		_exit_current_step(true)
		_finish_active(false, TutorialRuntimePhase.Value.INACTIVE, false)
	current_screen = TutorialScreen.Value.NONE
	current_screen_owner = null
	context.screen = TutorialScreen.Value.NONE
	_discard_out_of_scope_requests()

func begin_run(run_sequence: int) -> void:
	if run_sequence == current_run_sequence:
		return
	if runtime != null and runtime.run_sequence != 0 and runtime.run_sequence != run_sequence:
		_exit_current_step(true)
		_finish_active(false, TutorialRuntimePhase.Value.INACTIVE, false)
	current_run_sequence = run_sequence
	current_encounter_sequence = -1
	finished_this_run.clear()
	finished_this_encounter.clear()
	_discard_out_of_scope_requests()

func end_run(run_sequence: int) -> void:
	if run_sequence != current_run_sequence:
		return
	if runtime != null and runtime.run_sequence == run_sequence:
		_exit_current_step(true)
		_finish_active(false, TutorialRuntimePhase.Value.INACTIVE, false)
	current_encounter_sequence = -1
	current_run_sequence = 0
	finished_this_run.clear()
	finished_this_encounter.clear()
	_discard_out_of_scope_requests()

func begin_encounter(encounter_sequence: int) -> void:
	if encounter_sequence == current_encounter_sequence:
		return
	if runtime != null and runtime.encounter_sequence >= 0 and runtime.encounter_sequence != encounter_sequence:
		_exit_current_step(true)
		_finish_active(false, TutorialRuntimePhase.Value.INACTIVE, false)
	current_encounter_sequence = encounter_sequence
	finished_this_encounter.clear()
	_discard_out_of_scope_requests()

func end_encounter(encounter_sequence: int) -> void:
	if encounter_sequence != current_encounter_sequence:
		return
	if runtime != null and runtime.encounter_sequence == encounter_sequence:
		_exit_current_step(true)
		_finish_active(false, TutorialRuntimePhase.Value.INACTIVE, false)
	current_encounter_sequence = -1
	_discard_out_of_scope_requests()

func set_gameplay_context(run_state: RunState, controller: EncounterController, board_view: BoardView) -> void:
	context.run_state = run_state
	context.encounter_controller = controller
	context.board_view = board_view

func clear_gameplay_context(controller: EncounterController) -> void:
	if context.encounter_controller == controller:
		context.run_state = null
		context.encounter_controller = null
		context.board_view = null

func set_safe_to_interrupt(value: bool) -> void:
	safe_to_interrupt = value
	if value:
		_try_start_queued()

func set_suspended(value: bool) -> void:
	suspended = value
	if not suspended:
		_try_start_queued()

func set_tutorials_enabled(value: bool) -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	progress.tutorials_enabled = value
	if not value:
		_cancel_without_queue_advance()
		queued.clear()
		queue_changed.emit()
	_save_progress()

func set_contextual_tips_enabled(value: bool) -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	progress.contextual_tips_enabled = value
	if not value:
		_remove_contextual_requests()
		if active_definition != null and active_definition.activation_mode == TutorialActivationMode.Value.CONTEXTUAL_EVENT:
			_cancel_without_queue_advance()
	_save_progress()

func set_hints_enabled(value: bool) -> void:
	SaveService.profile.tutorial_progress.hints_enabled = value
	if not value:
		hints_cleared.emit()
		_remove_passive_requests()
	_save_progress()

func start_tutorial(definition: TutorialDefinition, replay: bool = false, request: TutorialActivationRequest = null) -> bool:
	var event: TutorialEvent = request.event if request != null else null
	if definition == null or active_definition != null or definition.steps.is_empty():
		return false
	if not replay and not _is_available(definition, event):
		return false
	_clear_saved_runtime_if_different(definition)
	active_definition = definition
	active_request = request
	runtime = TutorialRuntimeState.new()
	runtime.tutorial = definition
	runtime.phase = TutorialRuntimePhase.Value.PREPARING
	runtime.replay = replay
	runtime.screen = request.screen if request != null else current_screen
	runtime.run_sequence = request.run_sequence if request != null else current_run_sequence
	runtime.encounter_sequence = request.encounter_sequence if request != null else current_encounter_sequence
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	progress.active_tutorial = definition
	progress.record_attempt(definition)
	context.active_tutorial = definition
	context.current_event = event
	tutorial_started.emit(definition)
	_enter_step(0, true)
	_save_progress()
	return true

func begin_replay_setup() -> void:
	suppress_queue_start = true
	queued.clear()
	queue_changed.emit()

func start_prepared_replay(definition: TutorialDefinition) -> bool:
	queued.clear()
	var started: bool = start_tutorial(definition, true)
	suppress_queue_start = false
	queue_changed.emit()
	return started

func cancel_replay_setup() -> void:
	suppress_queue_start = false
	queued.clear()
	queue_changed.emit()

func confirm_current_step() -> void:
	if runtime != null and runtime.phase == TutorialRuntimePhase.Value.WAITING_FOR_CONFIRMATION:
		advance_step()

func advance_step() -> void:
	if active_definition == null or runtime == null:
		return
	var step: TutorialStepDefinition = current_step()
	if step != null:
		runtime.phase = TutorialRuntimePhase.Value.COMPLETING_STEP
		_execute_actions(step.completion_actions)
		_exit_current_step(false)
	_enter_step(runtime.step_index + 1, true)

func skip_active() -> void:
	if active_definition == null or not active_definition.can_skip:
		return
	var step: TutorialStepDefinition = current_step()
	if step != null and not step.skippable:
		return
	var definition: TutorialDefinition = active_definition
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if not progress.skipped_tutorials.has(definition):
		progress.skipped_tutorials.append(definition)
	if definition.mark_complete_on_skip and not progress.completed_tutorials.has(definition):
		progress.completed_tutorials.append(definition)
	_record_scoped_finish(definition)
	_exit_current_step(true)
	_finish_active(false, TutorialRuntimePhase.Value.SKIPPED, true)

func cancel_active() -> void:
	if active_definition == null:
		return
	_exit_current_step(true)
	_finish_active(false, TutorialRuntimePhase.Value.INACTIVE, true)

func dismiss_hint(definition: TutorialDefinition) -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if not progress.dismissed_hints.has(definition):
		progress.dismissed_hints.append(definition)
	hints_cleared.emit()
	_save_progress()

func reset_progress() -> void:
	suppress_queue_start = true
	_cancel_without_queue_advance()
	queued.clear()
	restore_pending = false
	SaveService.profile.tutorial_progress.reset()
	finished_this_run.clear()
	finished_this_encounter.clear()
	hints_cleared.emit()
	_save_progress()
	suppress_queue_start = false
	queue_changed.emit()

func reset_encounter_repeats() -> void:
	finished_this_encounter.clear()

func save_runtime() -> void:
	_save_progress()

func current_step() -> TutorialStepDefinition:
	if active_definition == null or runtime == null or runtime.step_index < 0 or runtime.step_index >= active_definition.steps.size():
		return null
	return active_definition.steps[runtime.step_index]

func allowed_input_mode() -> TutorialInputMode.Value:
	var step: TutorialStepDefinition = current_step()
	return step.input_mode if step != null else TutorialInputMode.Value.NORMAL_GAMEPLAY

func is_action_allowed(action: StringName) -> bool:
	var step: TutorialStepDefinition = current_step()
	return step == null or step.input_mode == TutorialInputMode.Value.NORMAL_GAMEPLAY or step.input_mode == TutorialInputMode.Value.NORMAL_WITH_HINT or step.allowed_input_actions.has(action)

func step_requires_confirmation(step: TutorialStepDefinition) -> bool:
	if step == null:
		return false
	return step.wait_for_player_confirmation or SaveService.settings.tutorial_manual_advance and step.auto_advance_delay > 0.0 and step.input_mode != TutorialInputMode.Value.NORMAL_WITH_HINT

func queued_tutorials() -> Array[TutorialDefinition]:
	var tutorials: Array[TutorialDefinition] = []
	for request: TutorialActivationRequest in queued:
		tutorials.append(request.definition)
	return tutorials

func debug_force_complete_current() -> void:
	advance_step()

func debug_validation_report() -> PackedStringArray:
	return TutorialValidator.new().validate_all(ContentRegistry.tutorials)

func _enter_step(index: int, execute_entry: bool) -> void:
	if active_definition == null or runtime == null:
		return
	if index >= active_definition.steps.size():
		_complete_active()
		return
	runtime.step_index = maxi(0, index)
	runtime.elapsed_in_step = 0.0
	runtime.phase = TutorialRuntimePhase.Value.ENTERING_STEP
	var step: TutorialStepDefinition = current_step()
	context.active_step = step
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	progress.active_step_index = runtime.step_index
	if execute_entry:
		_execute_actions(step.entry_actions)
	runtime.phase = TutorialRuntimePhase.Value.WAITING_FOR_CONFIRMATION if step_requires_confirmation(step) else TutorialRuntimePhase.Value.WAITING_FOR_CONDITION
	progress.active_runtime = runtime
	step_changed.emit(active_definition, step, runtime.step_index)
	_save_progress()
	if not step.wait_for_player_confirmation and step.completion_conditions.is_empty() and step.auto_advance_delay <= 0.0:
		advance_step.call_deferred()

func _restore_saved_tutorial() -> void:
	if active_definition != null or not SaveService.profile.tutorial_progress.tutorials_enabled:
		return
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if progress.active_tutorial == null or progress.active_runtime == null:
		restore_pending = false
		return
	var definition: TutorialDefinition = progress.active_tutorial
	if definition == null or definition.steps.is_empty():
		_clear_saved_runtime()
		return
	var restored: TutorialRuntimeState = progress.active_runtime
	if restored.screen != TutorialScreen.Value.NONE and restored.screen != current_screen:
		restore_pending = true
		return
	if restored.run_sequence != 0 and current_run_sequence != 0 and restored.run_sequence != current_run_sequence:
		_clear_saved_runtime()
		return
	if not _definition_target_ready(definition):
		restore_pending = true
		return
	active_definition = definition
	runtime = restored
	runtime.step_index = _restored_step_index(definition, restored)
	var step: TutorialStepDefinition = current_step()
	if step == null:
		_clear_saved_runtime()
		active_definition = null
		runtime = null
		return
	runtime.phase = TutorialRuntimePhase.Value.WAITING_FOR_CONFIRMATION if step_requires_confirmation(step) else TutorialRuntimePhase.Value.WAITING_FOR_CONDITION
	context.active_tutorial = definition
	context.active_step = step
	restore_pending = false
	tutorial_started.emit(definition)
	step_changed.emit(definition, step, runtime.step_index)

func _evaluate_current_step() -> void:
	if runtime == null or runtime.phase != TutorialRuntimePhase.Value.WAITING_FOR_CONDITION:
		return
	var step: TutorialStepDefinition = current_step()
	if step == null or step.completion_conditions.is_empty():
		return
	for condition: TutorialCondition in step.completion_conditions:
		if condition == null or not condition.is_satisfied(context):
			return
	advance_step()

func _jump_to_step(step: TutorialStepDefinition) -> void:
	if step == null:
		skip_active()
		return
	var index: int = active_definition.steps.find(step)
	if index >= 0:
		_exit_current_step(true)
		_enter_step(index, true)
		return
	_exit_current_step(true)
	_finish_active(false, TutorialRuntimePhase.Value.FAILED, true)

func _complete_active() -> void:
	if active_definition == null:
		return
	var definition: TutorialDefinition = active_definition
	_record_completion(definition)
	_finish_active(true, TutorialRuntimePhase.Value.COMPLETED, true)

func _record_completion(definition: TutorialDefinition) -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if not progress.completed_tutorials.has(definition):
		progress.completed_tutorials.append(definition)
	progress.record_completion(definition, int(Time.get_unix_time_from_system()))
	_record_scoped_finish(definition)

func _record_scoped_finish(definition: TutorialDefinition) -> void:
	if not finished_this_run.has(definition):
		finished_this_run.append(definition)
	if not finished_this_encounter.has(definition):
		finished_this_encounter.append(definition)

func _finish_active(completed: bool, phase: TutorialRuntimePhase.Value, start_next: bool) -> void:
	var definition: TutorialDefinition = active_definition
	if runtime != null:
		runtime.phase = phase
	active_definition = null
	active_request = null
	runtime = null
	context.active_tutorial = null
	context.active_step = null
	_clear_saved_runtime()
	_save_progress()
	tutorial_ended.emit(definition, completed)
	if start_next and not suppress_queue_start:
		_try_start_queued()

func _exit_current_step(undo_entry: bool) -> void:
	var step: TutorialStepDefinition = current_step()
	if step == null:
		return
	if runtime != null:
		runtime.phase = TutorialRuntimePhase.Value.EXITING_STEP
	_execute_actions(step.exit_actions)
	if undo_entry:
		for index: int in range(step.entry_actions.size() - 1, -1, -1):
			var action: TutorialAction = step.entry_actions[index]
			if action != null:
				action.undo(context)

func _queue_matching_tutorials(event: TutorialEvent) -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if not progress.tutorials_enabled:
		return
	for definition: TutorialDefinition in ContentRegistry.tutorials:
		if definition.activation_event != event.type or _is_active_or_queued(definition):
			continue
		if not _is_available(definition, event):
			continue
		enqueue_sequence += 1
		var screen: TutorialScreen.Value = event.screen if event.screen != TutorialScreen.Value.NONE else current_screen
		queued.append(TutorialActivationRequest.new(definition, event, screen, current_run_sequence, current_encounter_sequence, enqueue_sequence))
	_sort_queue()
	queue_changed.emit()

func _is_available(definition: TutorialDefinition, event: TutorialEvent) -> bool:
	if definition == null or definition.steps.is_empty():
		return false
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if not progress.tutorials_enabled:
		return false
	if event != null and (definition.activation_mode == TutorialActivationMode.Value.MANUAL or definition.activation_mode == TutorialActivationMode.Value.DEBUG_ONLY):
		return false
	if definition.activation_mode == TutorialActivationMode.Value.FIRST_RUN and SaveService.profile.completed_runs > 0:
		return false
	if definition.activation_mode == TutorialActivationMode.Value.DEBUG_ONLY and not OS.is_debug_build():
		return false
	if event != null and definition.activation_mode == TutorialActivationMode.Value.CONTEXTUAL_EVENT and not progress.contextual_tips_enabled:
		return false
	if _is_passive(definition) and (not progress.hints_enabled or progress.dismissed_hints.has(definition)):
		return false
	for prerequisite: TutorialDefinition in definition.prerequisite_tutorials:
		if not progress.completed_tutorials.has(prerequisite):
			return false
	match definition.repeat_policy:
		TutorialRepeatPolicy.Value.MANUAL_ONLY:
			if event != null:
				return false
		TutorialRepeatPolicy.Value.ONCE_PER_PROFILE:
			if progress.completed_tutorials.has(definition) or progress.skipped_tutorials.has(definition):
				return false
		TutorialRepeatPolicy.Value.ONCE_PER_RUN:
			if finished_this_run.has(definition):
				return false
		TutorialRepeatPolicy.Value.ONCE_PER_ENCOUNTER:
			if finished_this_encounter.has(definition):
				return false
		TutorialRepeatPolicy.Value.UNTIL_COMPLETED:
			if progress.completed_tutorials.has(definition) or finished_this_run.has(definition):
				return false
		TutorialRepeatPolicy.Value.ALWAYS:
			pass
	var previous_event: TutorialEvent = context.current_event
	context.current_event = event
	for condition: TutorialCondition in definition.availability_conditions:
		if condition == null or not condition.is_satisfied(context):
			context.current_event = previous_event
			return false
	context.current_event = previous_event
	return true

func _try_start_queued() -> void:
	if active_definition != null or queued.is_empty() or not safe_to_interrupt or suspended or suppress_queue_start:
		return
	var changed: bool = false
	var index: int = 0
	while index < queued.size():
		var request: TutorialActivationRequest = queued[index]
		if not request.is_in_scope(current_screen, current_run_sequence, current_encounter_sequence) or not _is_available(request.definition, request.event):
			queued.remove_at(index)
			changed = true
			continue
		if not _definition_target_ready(request.definition):
			index += 1
			continue
		queued.remove_at(index)
		changed = true
		if _is_passive(request.definition):
			_show_passive_tutorial(request.definition)
		else:
			start_tutorial(request.definition, false, request)
		break
	if changed:
		queue_changed.emit()

func _show_passive_tutorial(definition: TutorialDefinition) -> void:
	var step: TutorialStepDefinition = definition.steps[0]
	var duration: float = 0.0 if SaveService.settings.tutorial_manual_advance else _automatic_duration(step.auto_advance_delay if step.auto_advance_delay > 0.0 else 3.5)
	hint_requested.emit(definition, step.title, step.body, Color("72e7d4"), duration)
	_record_completion(definition)
	_save_progress()

func _is_passive(definition: TutorialDefinition) -> bool:
	if definition.steps.is_empty():
		return false
	for step: TutorialStepDefinition in definition.steps:
		if step == null or step.input_mode != TutorialInputMode.Value.NORMAL_WITH_HINT:
			return false
	return true

func _definition_target_ready(definition: TutorialDefinition) -> bool:
	if definition.steps.is_empty() or definition.steps[0].target == null:
		return true
	var target: TutorialTarget = definition.steps[0].target
	return target.target_key == TutorialTargetKey.Value.NONE or TutorialTargetRegistry.resolve_node(target.target_key) != null

func _discard_out_of_scope_requests() -> void:
	var kept: Array[TutorialActivationRequest] = []
	for request: TutorialActivationRequest in queued:
		if request.is_in_scope(current_screen, current_run_sequence, current_encounter_sequence):
			kept.append(request)
	if kept.size() != queued.size():
		queued = kept
		queue_changed.emit()

func _remove_contextual_requests() -> void:
	var kept: Array[TutorialActivationRequest] = []
	for request: TutorialActivationRequest in queued:
		if request.definition.activation_mode != TutorialActivationMode.Value.CONTEXTUAL_EVENT:
			kept.append(request)
	if kept.size() != queued.size():
		queued = kept
		queue_changed.emit()

func _remove_passive_requests() -> void:
	var kept: Array[TutorialActivationRequest] = []
	for request: TutorialActivationRequest in queued:
		if not _is_passive(request.definition):
			kept.append(request)
	if kept.size() != queued.size():
		queued = kept
		queue_changed.emit()

func _cancel_without_queue_advance() -> void:
	if active_definition == null:
		return
	_exit_current_step(true)
	_finish_active(false, TutorialRuntimePhase.Value.INACTIVE, false)

func _is_active_or_queued(definition: TutorialDefinition) -> bool:
	if active_definition == definition:
		return true
	for request: TutorialActivationRequest in queued:
		if request.definition == definition:
			return true
	return false

func _sort_queue() -> void:
	queued.sort_custom(func(left: TutorialActivationRequest, right: TutorialActivationRequest) -> bool:
		if left.definition.priority != right.definition.priority:
			return left.definition.priority > right.definition.priority
		if left.enqueue_sequence != right.enqueue_sequence:
			return left.enqueue_sequence < right.enqueue_sequence
		return left.definition.resource_path < right.definition.resource_path)

func _restored_step_index(definition: TutorialDefinition, restored: TutorialRuntimeState) -> int:
	return mini(restored.step_index, definition.steps.size() - 1)

func _clear_saved_runtime_if_different(definition: TutorialDefinition) -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	if progress.active_tutorial != null and progress.active_tutorial != definition:
		_clear_saved_runtime()

func _clear_saved_runtime() -> void:
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	progress.active_tutorial = null
	progress.active_step_index = -1
	progress.active_runtime = null

func _execute_actions(actions: Array[TutorialAction]) -> void:
	for action: TutorialAction in actions:
		if action != null:
			action.execute(context)

func _save_progress() -> void:
	if runtime != null:
		SaveService.profile.tutorial_progress.active_runtime = runtime
	SaveService.save_profile()

func _automatic_duration(value: float) -> float:
	return value * SaveService.settings.tutorial_message_duration

func _validate_content() -> void:
	var errors: PackedStringArray = TutorialValidator.new().validate_all(ContentRegistry.tutorials)
	for error: String in errors:
		push_error("Tutorial validation: %s" % error)

func _ensure_overlay() -> void:
	if get_tree().root.get_node_or_null("TutorialOverlay") != null:
		return
	var overlay: CanvasLayer = (load("res://presentation/tutorial/tutorial_overlay.tscn") as PackedScene).instantiate() as CanvasLayer
	get_tree().root.add_child(overlay)
