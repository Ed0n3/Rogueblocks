class_name DailyChallengeService
extends RefCounted

const PRESSURED_DIFFICULTY: DifficultyDefinition = preload("res://content/difficulties/pressured.tres")

static func get_date_key(unix_time: int = 0) -> String:
	var time: int = unix_time if unix_time > 0 else int(Time.get_unix_time_from_system())
	var date: Dictionary = Time.get_datetime_dict_from_unix_time(time)
	return "%04d-%02d-%02d" % [int(date["year"]), int(date["month"]), int(date["day"])]

static func get_seed_for_date(date_key: String) -> int:
	return absi(date_key.sha256_text().substr(0, 8).hex_to_int())

static func create_daily_run(date_key: String, practice: bool) -> RunState:
	var run: RunState = RunState.new()
	run.seed_value = get_seed_for_date(date_key)
	run.daily_mode = true
	run.daily_practice = practice
	run.daily_date_key = date_key
	run.run_mode = RunMode.Value.DAILY
	run.difficulty = PRESSURED_DIFFICULTY
	run.starting_modifiers = StartingRunModifiers.new()
	return run

static func infer_date_key(seed_value: int, run_sequence: int, saved_at_unix: int = 0) -> String:
	var candidate_times: Array[int] = []
	var run_started_at_unix: int = run_sequence / 1000
	if run_started_at_unix > 0:
		candidate_times.append(run_started_at_unix)
	if saved_at_unix > 0 and not candidate_times.has(saved_at_unix):
		candidate_times.append(saved_at_unix)
	for candidate_time: int in candidate_times:
		var date_key: String = get_date_key(candidate_time)
		if get_seed_for_date(date_key) == seed_value:
			return date_key
	return get_date_key(candidate_times[0]) if not candidate_times.is_empty() else String()
