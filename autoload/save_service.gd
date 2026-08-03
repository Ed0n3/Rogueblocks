extends Node

const PROFILE_PATH: String = "user://profile.json"
const PROFILE_BACKUP_PATH: String = "user://profile.backup.json"
const SETTINGS_PATH: String = "user://settings.json"
const ACTIVE_RUN_PATH: String = "user://active_run.json"
const ACTIVE_RUN_BACKUP_PATH: String = "user://active_run.backup.json"
const ACTIVE_RUN_VERSION: int = 6

var profile: ProfileState = ProfileState.new()
var settings: GameSettings = GameSettings.new()

var last_used_seed: int:
	get:
		return settings.last_used_seed
	set(value):
		settings.last_used_seed = value

const SAVE_VERSION: int = ProfileState.CURRENT_VERSION

func _ready() -> void:
	load_settings()
	load_profile()

func load_profile() -> void:
	var data: Dictionary = _read_verified_json(PROFILE_PATH, "rogueblocks.profile")
	if data.is_empty():
		data = _read_verified_json(PROFILE_BACKUP_PATH, "rogueblocks.profile")
	if data.is_empty() and FileAccess.file_exists(PROFILE_PATH):
		var legacy_data: Dictionary = _read_legacy_json(PROFILE_PATH)
		if not legacy_data.has("schema") and not legacy_data.has("checksum"):
			data = legacy_data
	if not data.is_empty():
		var migrated: Dictionary = SaveMigrationService.new().migrate_profile(data)
		if not migrated.is_empty():
			profile = ProfileState.from_save_data(migrated)
	profile.sanitize(ContentRegistry.upgrades)
	save_profile()

func save_profile() -> bool:
	profile.last_played_at_unix = int(Time.get_unix_time_from_system())
	return _atomic_write(PROFILE_PATH, PROFILE_BACKUP_PATH, profile.to_save_data())

func load_settings() -> void:
	var data: Dictionary = _read_legacy_json(SETTINGS_PATH)
	if not data.is_empty():
		settings = GameSettingsCodec.decode(data.get("values", data) as Dictionary)

func save_settings() -> bool:
	return _atomic_write(SETTINGS_PATH, SETTINGS_PATH + ".backup", {"schema": "rogueblocks.settings", "version": 1, "values": GameSettingsCodec.encode(settings)})

func save_active_run(data: Dictionary) -> bool:
	var payload: Dictionary = data.duplicate(true)
	payload["schema"] = "rogueblocks.active_run"
	payload["version"] = ACTIVE_RUN_VERSION
	payload["last_modified_unix"] = int(Time.get_unix_time_from_system())
	return _atomic_write(ACTIVE_RUN_PATH, ACTIVE_RUN_BACKUP_PATH, payload)

func load_active_run() -> Dictionary:
	var data: Dictionary = _read_verified_json(ACTIVE_RUN_PATH, "rogueblocks.active_run")
	if data.is_empty():
		data = _read_verified_json(ACTIVE_RUN_BACKUP_PATH, "rogueblocks.active_run")
	if int(data.get("version", 0)) > ACTIVE_RUN_VERSION:
		return {}
	return data

func has_valid_active_run() -> bool:
	var data: Dictionary = load_active_run()
	if data.is_empty() or bool(data.get("ended", false)):
		return false
	var run_data: Dictionary = data.get("run_state", {}) as Dictionary
	var encounter_data: Dictionary = data.get("encounter", {}) as Dictionary
	var encounter_state: int = int(encounter_data.get("state", int(EncounterController.TurnState.INITIALIZING)))
	var terminal_state: bool = encounter_state == int(EncounterController.TurnState.ENCOUNTER_WON) or encounter_state == int(EncounterController.TurnState.RUN_LOST)
	return int(run_data.get("seed", 0)) != 0 and (terminal_state or int(run_data.get("player_health", 0)) > 0)

func has_resumable_encounter() -> bool:
	var data: Dictionary = load_active_run()
	if data.is_empty() or bool(data.get("ended", false)):
		return false
	var run_data: Dictionary = data.get("run_state", {}) as Dictionary
	var encounter_data: Dictionary = data.get("encounter", {}) as Dictionary
	var board_data: Dictionary = encounter_data.get("board", {}) as Dictionary
	var encounter_state: int = int(encounter_data.get("state", int(EncounterController.TurnState.INITIALIZING)))
	var terminal_state: bool = encounter_state == int(EncounterController.TurnState.ENCOUNTER_WON) or encounter_state == int(EncounterController.TurnState.RUN_LOST)
	return not terminal_state and int(run_data.get("player_health", 0)) > 0 and int(run_data.get("seed", 0)) != 0 and not String(encounter_data.get("enemy", encounter_data.get("enemy_id", ""))).is_empty() and not board_data.is_empty()

func clear_active_run() -> void:
	for path: String in [ACTIVE_RUN_PATH, ACTIVE_RUN_BACKUP_PATH]:
		_remove_file(path)

func start_new_game() -> bool:
	var previous_profile: ProfileState = profile
	var fresh_profile: ProfileState = ProfileState.new()
	fresh_profile.sanitize(ContentRegistry.upgrades)
	profile = fresh_profile
	if not save_profile():
		profile = previous_profile
		return false
	_remove_file(PROFILE_BACKUP_PATH)
	clear_active_run()
	return true

func claim_ranked_daily_attempt(date_key: String) -> bool:
	if date_key.is_empty():
		return false
	if profile.has_ranked_daily_attempt(date_key):
		return true
	profile.ranked_daily_attempt_dates.append(date_key)
	if save_profile():
		return true
	profile.ranked_daily_attempt_dates.erase(date_key)
	return false

func award_boss_fragments(run_state: RunState, route_node: RouteNodeState, base_amount: int) -> int:
	if run_state == null or run_state.debug_run or run_state.daily_mode or base_amount <= 0:
		return 0
	if profile.claimed_boss_rewards.any(func(existing: BossRewardClaim) -> bool: return existing.matches(run_state.run_sequence, route_node)):
		return 0
	var amount: int = floori(float(base_amount) * _fragment_reward_multiplier(run_state))
	if amount <= 0:
		return 0
	profile.fragments += amount
	profile.total_fragments_earned += amount
	var claim: BossRewardClaim = BossRewardClaim.new()
	claim.run_sequence = run_state.run_sequence
	claim.act = route_node.act
	claim.column = route_node.column
	claim.row = route_node.row
	profile.claimed_boss_rewards.append(claim)
	if save_profile():
		return amount
	profile.fragments -= amount
	profile.total_fragments_earned -= amount
	profile.claimed_boss_rewards.erase(claim)
	return 0

func record_run(run_state: RunState, won: bool, reason: String = "") -> RunRecordResult:
	var result: RunRecordResult = RunRecordResult.new()
	var profile_snapshot: ProfileState = ProfileState.from_save_data(profile.to_save_data())
	var multiplier: float = _fragment_reward_multiplier(run_state) if not run_state.debug_run and not run_state.daily_mode else 0.0
	var rules: ProgressionRules = load("res://content/rules/progression_rules.tres") as ProgressionRules
	var fragments_earned: int = rules.calculate_run_fragments(run_state, won, multiplier)
	profile.completed_runs += 1
	profile.victories += 1 if won else 0
	profile.defeats += 0 if won else 1
	profile.fragments += fragments_earned
	profile.total_fragments_earned += fragments_earned
	profile.total_play_time_seconds += run_state.elapsed_play_time
	profile.total_enemies_defeated += run_state.enemies_defeated
	profile.total_lines_cleared += run_state.cleared_lines
	profile.total_cross_clears += run_state.cross_clears
	profile.total_perfect_clears += run_state.perfect_clears
	profile.highest_combo = maxi(profile.highest_combo, run_state.highest_combo)
	profile.highest_score = maxi(profile.highest_score, run_state.score)
	if won and not run_state.debug_run and not run_state.daily_mode:
		_unlock_next_difficulty(run_state.difficulty)
	profile.run_history.append(_create_run_record(run_state, won, reason, fragments_earned + run_state.boss_fragments_earned))
	if run_state.daily_mode:
		var daily_entry: DailyRunEntry = DailyRunEntry.new()
		daily_entry.date = run_state.daily_date_key
		if daily_entry.date.is_empty():
			daily_entry.date = DailyChallengeService.infer_date_key(run_state.seed_value, run_state.run_sequence)
		if daily_entry.date.is_empty():
			daily_entry.date = DailyChallengeService.get_date_key()
		daily_entry.seed_value = run_state.seed_value
		daily_entry.score = run_state.score
		daily_entry.victory = won
		daily_entry.practice = run_state.daily_practice
		profile.daily_history.append(daily_entry)
		while profile.daily_history.size() > profile.maximum_daily_history:
			profile.daily_history.pop_front()
	while profile.run_history.size() > rules.run_history_limit:
		profile.run_history.pop_front()
	if not save_profile():
		profile = profile_snapshot
		return result
	clear_active_run()
	result.success = true
	result.fragments_earned = fragments_earned
	return result

func _fragment_reward_multiplier(run_state: RunState) -> float:
	var difficulty_multiplier: float = run_state.difficulty.fragment_reward_multiplier if run_state.difficulty != null else 1.0
	return run_state.starting_modifiers.fragment_reward_multiplier * difficulty_multiplier

func _unlock_next_difficulty(completed_difficulty: DifficultyDefinition) -> void:
	var completed_index: int = ContentRegistry.difficulties.find(completed_difficulty)
	if completed_index < 0:
		return
	profile.highest_difficulty_completed = maxi(profile.highest_difficulty_completed, completed_index + 1)
	var next_index: int = completed_index + 1
	if next_index < ContentRegistry.difficulties.size():
		var next_difficulty: DifficultyDefinition = ContentRegistry.difficulties[next_index]
		if next_difficulty != null and not profile.unlocked_difficulties.has(next_difficulty):
			profile.unlocked_difficulties.append(next_difficulty)

func _create_run_record(run_state: RunState, won: bool, reason: String, fragments_earned: int) -> RunHistoryEntry:
	var entry: RunHistoryEntry = RunHistoryEntry.new()
	entry.run_sequence = run_state.run_sequence
	entry.timestamp = int(Time.get_unix_time_from_system())
	entry.seed_value = run_state.seed_value
	entry.difficulty = run_state.difficulty
	entry.victory = won
	entry.defeat_reason = reason
	entry.score = run_state.score
	entry.duration = run_state.elapsed_play_time
	entry.encounters_completed = run_state.enemies_defeated
	entry.bosses_defeated = run_state.bosses_defeated
	entry.lines_cleared = run_state.cleared_lines
	entry.cross_clears = run_state.cross_clears
	entry.perfect_clears = run_state.perfect_clears
	entry.highest_combo = run_state.highest_combo
	entry.fragments_earned = fragments_earned
	entry.relics = run_state.relics.duplicate()
	entry.modifier_snapshot_hash = JSON.stringify(run_state.starting_modifiers.to_save_data()).sha256_text()
	return entry

func _atomic_write(final_path: String, backup_path: String, payload: Dictionary) -> bool:
	var data: Dictionary = payload.duplicate(true)
	data.erase("checksum")
	var normalized: Variant = JSON.parse_string(JSON.stringify(data, "", true, true))
	if not normalized is Dictionary:
		return false
	data = normalized as Dictionary
	data["checksum"] = _checksum(data)
	var temporary_path: String = final_path + ".tmp"
	var temporary_absolute: String = ProjectSettings.globalize_path(temporary_path)
	var final_absolute: String = ProjectSettings.globalize_path(final_path)
	var backup_absolute: String = ProjectSettings.globalize_path(backup_path)
	var file: FileAccess = FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	file.close()
	if _read_legacy_json(temporary_path).is_empty():
		DirAccess.remove_absolute(temporary_absolute)
		return false
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_absolute)
	if FileAccess.file_exists(final_path):
		DirAccess.rename_absolute(final_absolute, backup_absolute)
	if DirAccess.rename_absolute(temporary_absolute, final_absolute) != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_absolute, final_absolute)
		return false
	return true

func _read_verified_json(path: String, expected_schema: String) -> Dictionary:
	var data: Dictionary = _read_legacy_json(path)
	if data.is_empty() or String(data.get("schema", "")) != expected_schema:
		return {}
	var expected_checksum: String = String(data.get("checksum", ""))
	if expected_checksum.is_empty():
		return data
	data.erase("checksum")
	var actual_checksum: String = _checksum(data)
	if actual_checksum != expected_checksum:
		push_warning("Checksum mismatch for %s: expected %s, received %s" % [path, expected_checksum, actual_checksum])
		return {}
	return data

func _checksum(data: Dictionary) -> String:
	return _canonical_value(data).sha256_text()

func _canonical_value(value: Variant) -> String:
	if value is Dictionary:
		var dictionary: Dictionary = value as Dictionary
		var keys: Array[String] = []
		for key: Variant in dictionary:
			keys.append(String(key))
		keys.sort()
		var entries: PackedStringArray = []
		for key: String in keys:
			entries.append(JSON.stringify(key) + ":" + _canonical_value(dictionary.get(key)))
		return "{" + ",".join(entries) + "}"
	if value is Array:
		var entries: PackedStringArray = []
		for item: Variant in value as Array:
			entries.append(_canonical_value(item))
		return "[" + ",".join(entries) + "]"
	if value is float:
		return String.num(float(value), 12)
	if value is StringName:
		return JSON.stringify(String(value))
	return JSON.stringify(value, "", true, true)

func _read_legacy_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if parsed is Dictionary else {}

func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
