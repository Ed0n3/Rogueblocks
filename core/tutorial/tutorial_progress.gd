class_name TutorialProgress
extends RefCounted

var completed_tutorials: Array[TutorialDefinition] = []
var skipped_tutorials: Array[TutorialDefinition] = []
var dismissed_hints: Array[TutorialDefinition] = []
var active_tutorial: TutorialDefinition
var active_step_index: int = -1
var active_runtime: TutorialRuntimeState
var history: Array[TutorialProgressEntry] = []
var tutorials_enabled: bool = true
var contextual_tips_enabled: bool = true
var hints_enabled: bool = true

func to_save_data() -> Dictionary:
	return {
		"completed_tutorials": StartingRunModifiers._resources_to_references(completed_tutorials),
		"skipped_tutorials": StartingRunModifiers._resources_to_references(skipped_tutorials),
		"dismissed_hints": StartingRunModifiers._resources_to_references(dismissed_hints),
		"active_tutorial": ContentReferenceCodec.encode(active_tutorial),
		"active_step_index": active_step_index,
		"active_runtime": active_runtime.to_save_data() if active_runtime != null else {},
		"history": _history_to_data(),
		"tutorials_enabled": tutorials_enabled,
		"contextual_tips_enabled": contextual_tips_enabled,
		"hints_enabled": hints_enabled
	}

static func from_save_data(data: Dictionary) -> TutorialProgress:
	var progress: TutorialProgress = TutorialProgress.new()
	progress.completed_tutorials = _decode_tutorials(data.get("completed_tutorials", data.get("completed_tutorial_ids", [])) as Array)
	progress.skipped_tutorials = _decode_tutorials(data.get("skipped_tutorials", data.get("skipped_tutorial_ids", [])) as Array)
	progress.dismissed_hints = _decode_tutorials(data.get("dismissed_hints", data.get("dismissed_hint_ids", [])) as Array)
	progress.active_tutorial = ContentReferenceCodec.decode_legacy(String(data.get("active_tutorial", data.get("active_tutorial_id", ""))), TutorialDefinition, ContentRegistry.catalog) as TutorialDefinition
	progress.active_step_index = int(data.get("active_step_index", -1))
	var runtime_data: Dictionary = data.get("active_runtime", {}) as Dictionary
	progress.active_runtime = TutorialRuntimeState.from_save_data(runtime_data) if not runtime_data.is_empty() else null
	for entry_value: Variant in data.get("history", []) as Array:
		var entry: TutorialProgressEntry = TutorialProgressEntry.from_save_data(entry_value as Dictionary)
		if entry.tutorial != null:
			progress.history.append(entry)
	progress._restore_legacy_history(data.get("tutorial_attempt_counts", {}) as Dictionary, data.get("tutorial_completion_times", {}) as Dictionary)
	progress.tutorials_enabled = bool(data.get("tutorials_enabled", true))
	progress.contextual_tips_enabled = bool(data.get("contextual_tips_enabled", true))
	progress.hints_enabled = bool(data.get("hints_enabled", true))
	return progress

func reset() -> void:
	completed_tutorials.clear()
	skipped_tutorials.clear()
	dismissed_hints.clear()
	active_tutorial = null
	active_step_index = -1
	active_runtime = null
	history.clear()

func sanitize(definitions: Array[TutorialDefinition]) -> void:
	completed_tutorials = _known_tutorials(completed_tutorials, definitions)
	skipped_tutorials = _known_tutorials(skipped_tutorials, definitions)
	dismissed_hints = _known_tutorials(dismissed_hints, definitions)
	if active_tutorial != null and not definitions.has(active_tutorial):
		active_tutorial = null
		active_step_index = -1
		active_runtime = null
	for index: int in range(history.size() - 1, -1, -1):
		if not definitions.has(history[index].tutorial):
			history.remove_at(index)

func record_attempt(tutorial: TutorialDefinition) -> void:
	var entry: TutorialProgressEntry = _entry(tutorial, true)
	entry.attempt_count += 1

func attempt_count(tutorial: TutorialDefinition) -> int:
	var entry: TutorialProgressEntry = _entry(tutorial, false)
	return entry.attempt_count if entry != null else 0

func record_completion(tutorial: TutorialDefinition, unix_time: int) -> void:
	var entry: TutorialProgressEntry = _entry(tutorial, true)
	entry.completion_unix_time = maxi(0, unix_time)

func completion_time(tutorial: TutorialDefinition) -> int:
	var entry: TutorialProgressEntry = _entry(tutorial, false)
	return entry.completion_unix_time if entry != null else 0

func erase_history(tutorial: TutorialDefinition) -> void:
	for index: int in range(history.size() - 1, -1, -1):
		if history[index].tutorial == tutorial:
			history.remove_at(index)

func _entry(tutorial: TutorialDefinition, create: bool) -> TutorialProgressEntry:
	for entry: TutorialProgressEntry in history:
		if entry.tutorial == tutorial:
			return entry
	if not create or tutorial == null:
		return null
	var new_entry: TutorialProgressEntry = TutorialProgressEntry.new(tutorial)
	history.append(new_entry)
	return new_entry

func _history_to_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for entry: TutorialProgressEntry in history:
		data.append(entry.to_save_data())
	return data

func _restore_legacy_history(attempts: Dictionary, completions: Dictionary) -> void:
	for key: Variant in attempts:
		var tutorial: TutorialDefinition = ContentReferenceCodec.decode_legacy(String(key), TutorialDefinition, ContentRegistry.catalog) as TutorialDefinition
		if tutorial != null:
			_entry(tutorial, true).attempt_count = maxi(0, int(attempts[key]))
	for key: Variant in completions:
		var tutorial: TutorialDefinition = ContentReferenceCodec.decode_legacy(String(key), TutorialDefinition, ContentRegistry.catalog) as TutorialDefinition
		if tutorial != null:
			_entry(tutorial, true).completion_unix_time = maxi(0, int(completions[key]))

static func _decode_tutorials(values: Array) -> Array[TutorialDefinition]:
	var result: Array[TutorialDefinition] = []
	for value: Variant in values:
		var tutorial: TutorialDefinition = ContentReferenceCodec.decode_legacy(String(value), TutorialDefinition, ContentRegistry.catalog) as TutorialDefinition
		if tutorial != null and not result.has(tutorial):
			result.append(tutorial)
	return result

static func _known_tutorials(values: Array[TutorialDefinition], definitions: Array[TutorialDefinition]) -> Array[TutorialDefinition]:
	var result: Array[TutorialDefinition] = []
	for tutorial: TutorialDefinition in values:
		if definitions.has(tutorial) and not result.has(tutorial):
			result.append(tutorial)
	return result
