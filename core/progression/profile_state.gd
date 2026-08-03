class_name ProfileState
extends RefCounted

const CURRENT_VERSION: int = 9
const SCHEMA: String = "rogueblocks.profile"

@export_category("Content")
@export var standard_difficulty: DifficultyDefinition = preload("res://content/difficulties/standard.tres") as DifficultyDefinition

@export_category("Profile Limits")
@export var maximum_run_history: int = 50
@export var maximum_daily_history: int = 50
@export var maximum_ranked_daily_attempt_dates: int = 400
@export var maximum_claimed_boss_rewards: int = 500

@export_category("Validation Messages")
@export var invalid_sequence_message: String = "Profile sequence is invalid"
@export var negative_fragments_message: String = "Fragments cannot be negative"
@export var unsupported_version_message: String = "Profile version is newer than supported"

var save_version: int = CURRENT_VERSION
var profile_sequence: int = 0
var created_at_unix: int = 0
var last_played_at_unix: int = 0
var fragments: int = 0
var total_fragments_earned: int = 0
var total_fragments_spent: int = 0
var upgrade_progress: Array[UpgradeLevelState] = []
var legacy_upgrade_progress: Array[LegacyUpgradeLevel] = []
var upgrade_piece_inventory: UpgradePieceInventory = UpgradePieceInventory.new()
var upgrade_board_state: UpgradeBoardState = UpgradeBoardState.new()
var upgrade_board_legacy_progress: Array[UpgradeLevelState] = []
var unlocked_pieces: Array[PieceDefinition] = []
var unlocked_relics: Array[RelicDefinition] = []
var unlocked_enemies: Array[EnemyDefinition] = []
var unlocked_events: Array[RunEventDefinition] = []
var unlocked_difficulties: Array[DifficultyDefinition] = []
var completed_runs: int = 0
var victories: int = 0
var defeats: int = 0
var abandoned_runs: int = 0
var total_play_time_seconds: float = 0.0
var total_enemies_defeated: int = 0
var total_lines_cleared: int = 0
var total_cross_clears: int = 0
var total_perfect_clears: int = 0
var highest_combo: int = 0
var highest_score: int = 0
var highest_difficulty_completed: int = 0
var discovered_pieces: Array[PieceDefinition] = []
var discovered_relics: Array[RelicDefinition] = []
var discovered_enemies: Array[EnemyDefinition] = []
var defeated_enemies: Array[EnemyDefinition] = []
var run_history: Array[RunHistoryEntry] = []
var daily_history: Array[DailyRunEntry] = []
var ranked_daily_attempt_dates: Array[String] = []
var debug_modified: bool = false
var discovered_items: Array[ItemDefinition] = []
var total_items_purchased: int = 0
var total_items_used: int = 0
var total_boss_actions_countered: int = 0
var highest_items_held: int = 0
var claimed_boss_rewards: Array[BossRewardClaim] = []
var tutorial_progress: TutorialProgress = TutorialProgress.new()

func _init() -> void:
	var now: int = int(Time.get_unix_time_from_system())
	profile_sequence = now * 1000 + Time.get_ticks_msec() % 1000
	created_at_unix = now
	last_played_at_unix = now

func get_upgrade_level(upgrade: UpgradeDefinition) -> int:
	var progress: UpgradeLevelState = get_upgrade_progress(upgrade)
	return progress.level if progress != null else 0

func get_upgrade_progress(upgrade: UpgradeDefinition) -> UpgradeLevelState:
	for progress: UpgradeLevelState in upgrade_progress:
		if progress.upgrade == upgrade:
			return progress
	return null

func set_upgrade_level(upgrade: UpgradeDefinition, level: int) -> void:
	if upgrade == null:
		return
	var progress: UpgradeLevelState = get_upgrade_progress(upgrade)
	if progress == null:
		progress = UpgradeLevelState.new(upgrade)
		upgrade_progress.append(progress)
	progress.level = clampi(level, 0, upgrade.max_level)

func to_save_data() -> Dictionary:
	return {
		"schema": SCHEMA,
		"version": CURRENT_VERSION,
		"profile_sequence": profile_sequence,
		"created_at_unix": created_at_unix,
		"last_modified_unix": int(Time.get_unix_time_from_system()),
		"fragments": fragments,
		"total_fragments_earned": total_fragments_earned,
		"total_fragments_spent": total_fragments_spent,
		"upgrade_progress": _upgrade_levels_to_data(upgrade_progress),
		"legacy_upgrade_progress": _legacy_levels_to_data(legacy_upgrade_progress),
		"upgrade_piece_inventory": upgrade_piece_inventory.to_save_data(),
		"upgrade_board_state": upgrade_board_state.to_save_data(),
		"upgrade_board_legacy_progress": _upgrade_levels_to_data(upgrade_board_legacy_progress),
		"unlocked_pieces": StartingRunModifiers._resources_to_references(unlocked_pieces),
		"unlocked_relics": StartingRunModifiers._resources_to_references(unlocked_relics),
		"unlocked_enemies": StartingRunModifiers._resources_to_references(unlocked_enemies),
		"unlocked_events": StartingRunModifiers._resources_to_references(unlocked_events),
		"unlocked_difficulties": StartingRunModifiers._resources_to_references(unlocked_difficulties),
		"completed_runs": completed_runs,
		"victories": victories,
		"defeats": defeats,
		"abandoned_runs": abandoned_runs,
		"total_play_time_seconds": total_play_time_seconds,
		"total_enemies_defeated": total_enemies_defeated,
		"total_lines_cleared": total_lines_cleared,
		"total_cross_clears": total_cross_clears,
		"total_perfect_clears": total_perfect_clears,
		"highest_combo": highest_combo,
		"highest_score": highest_score,
		"highest_difficulty_completed": highest_difficulty_completed,
		"discovered_pieces": StartingRunModifiers._resources_to_references(discovered_pieces),
		"discovered_relics": StartingRunModifiers._resources_to_references(discovered_relics),
		"discovered_enemies": StartingRunModifiers._resources_to_references(discovered_enemies),
		"defeated_enemies": StartingRunModifiers._resources_to_references(defeated_enemies),
		"run_history": _run_history_to_data(run_history),
		"daily_history": _daily_history_to_data(daily_history),
		"ranked_daily_attempt_dates": ranked_daily_attempt_dates.duplicate(),
		"debug_modified": debug_modified,
		"discovered_items": StartingRunModifiers._resources_to_references(discovered_items),
		"total_items_purchased": total_items_purchased,
		"total_items_used": total_items_used,
		"total_boss_actions_countered": total_boss_actions_countered,
		"highest_items_held": highest_items_held,
		"claimed_boss_rewards": _boss_claims_to_data(claimed_boss_rewards),
		"tutorial_progress": tutorial_progress.to_save_data()
	}

static func from_save_data(data: Dictionary) -> ProfileState:
	var profile: ProfileState = ProfileState.new()
	profile.save_version = int(data.get("version", CURRENT_VERSION))
	profile.profile_sequence = int(data.get("profile_sequence", String(data.get("profile_id", "")).hash() if data.has("profile_id") else profile.profile_sequence))
	profile.created_at_unix = int(data.get("created_at_unix", profile.created_at_unix))
	profile.last_played_at_unix = int(data.get("last_modified_unix", Time.get_unix_time_from_system()))
	profile.fragments = int(data.get("fragments", data.get("meta_currency", 0)))
	profile.total_fragments_earned = int(data.get("total_fragments_earned", profile.fragments))
	profile.total_fragments_spent = int(data.get("total_fragments_spent", 0))
	profile.upgrade_progress = _data_to_upgrade_levels(data.get("upgrade_progress", data.get("purchased_upgrade_levels", {})))
	profile.legacy_upgrade_progress = _data_to_legacy_levels(data.get("legacy_upgrade_progress", data.get("legacy_upgrade_levels", {})))
	profile.upgrade_piece_inventory = UpgradePieceInventory.from_save_data(data.get("upgrade_piece_inventory", {}) as Dictionary)
	profile.upgrade_board_state = UpgradeBoardState.from_save_data(data.get("upgrade_board_state", {}) as Dictionary)
	profile.upgrade_board_legacy_progress = _data_to_upgrade_levels(data.get("upgrade_board_legacy_progress", data.get("upgrade_board_legacy_levels", {})))
	profile.unlocked_pieces = StartingRunModifiers._references_to_pieces(data.get("unlocked_pieces", data.get("unlocked_piece_ids", data.get("unlocked_content_ids", []))) as Array)
	profile.unlocked_relics = StartingRunModifiers._references_to_relics(data.get("unlocked_relics", data.get("unlocked_relic_ids", [])) as Array)
	profile.unlocked_enemies = StartingRunModifiers._references_to_enemies(data.get("unlocked_enemies", data.get("unlocked_enemy_ids", [])) as Array)
	profile.unlocked_events = StartingRunModifiers._references_to_events(data.get("unlocked_events", data.get("unlocked_event_ids", [])) as Array)
	var default_difficulty_references: Array[String] = [ContentReferenceCodec.encode(profile.standard_difficulty)]
	profile.unlocked_difficulties = _references_to_difficulties(data.get("unlocked_difficulties", data.get("unlocked_difficulty_levels", default_difficulty_references)) as Array)
	profile.completed_runs = int(data.get("completed_runs", data.get("total_runs", 0)))
	profile.victories = int(data.get("victories", 0))
	profile.defeats = int(data.get("defeats", maxi(0, profile.completed_runs - profile.victories)))
	profile.abandoned_runs = int(data.get("abandoned_runs", 0))
	profile.total_play_time_seconds = float(data.get("total_play_time_seconds", 0.0))
	profile.total_enemies_defeated = int(data.get("total_enemies_defeated", 0))
	profile.total_lines_cleared = int(data.get("total_lines_cleared", data.get("total_lines_cleared", 0)))
	profile.total_cross_clears = int(data.get("total_cross_clears", 0))
	profile.total_perfect_clears = int(data.get("total_perfect_clears", 0))
	profile.highest_combo = int(data.get("highest_combo", 0))
	profile.highest_score = int(data.get("highest_score", data.get("best_score", 0)))
	profile.highest_difficulty_completed = int(data.get("highest_difficulty_completed", 0))
	profile.discovered_pieces = StartingRunModifiers._references_to_pieces(data.get("discovered_pieces", data.get("discovered_piece_ids", [])) as Array)
	profile.discovered_relics = StartingRunModifiers._references_to_relics(data.get("discovered_relics", data.get("discovered_relic_ids", [])) as Array)
	profile.discovered_enemies = StartingRunModifiers._references_to_enemies(data.get("discovered_enemies", data.get("discovered_enemy_ids", [])) as Array)
	profile.defeated_enemies = StartingRunModifiers._references_to_enemies(data.get("defeated_enemies", data.get("defeated_enemy_ids", [])) as Array)
	for value: Variant in data.get("run_history", []) as Array:
		profile.run_history.append(RunHistoryEntry.from_save_data(value as Dictionary))
	for value: Variant in data.get("daily_history", []) as Array:
		profile.daily_history.append(DailyRunEntry.from_save_data(value as Dictionary))
	for value: Variant in data.get("ranked_daily_attempt_dates", []) as Array:
		var date_key: String = String(value)
		if not date_key.is_empty() and not profile.ranked_daily_attempt_dates.has(date_key):
			profile.ranked_daily_attempt_dates.append(date_key)
	for entry: DailyRunEntry in profile.daily_history:
		if not entry.practice and not entry.date.is_empty() and not profile.ranked_daily_attempt_dates.has(entry.date):
			profile.ranked_daily_attempt_dates.append(entry.date)
	profile.debug_modified = bool(data.get("debug_modified", false))
	profile.discovered_items = _references_to_items(data.get("discovered_items", data.get("discovered_item_ids", [])) as Array)
	profile.total_items_purchased = maxi(0, int(data.get("total_items_purchased", 0)))
	profile.total_items_used = maxi(0, int(data.get("total_items_used", 0)))
	profile.total_boss_actions_countered = maxi(0, int(data.get("total_boss_actions_countered", 0)))
	profile.highest_items_held = maxi(0, int(data.get("highest_items_held", 0)))
	for value: Variant in data.get("claimed_boss_rewards", []) as Array:
		profile.claimed_boss_rewards.append(BossRewardClaim.from_save_data(value as Dictionary))
	for value: Variant in data.get("claimed_boss_reward_ids", []) as Array:
		var legacy_claim: BossRewardClaim = BossRewardClaim.from_legacy(String(value))
		if legacy_claim != null:
			profile.claimed_boss_rewards.append(legacy_claim)
	profile.tutorial_progress = TutorialProgress.from_save_data(data.get("tutorial_progress", {}) as Dictionary)
	return profile

func sanitize(upgrades: Array[UpgradeDefinition]) -> void:
	fragments = maxi(0, fragments)
	total_fragments_earned = maxi(0, total_fragments_earned)
	total_fragments_spent = maxi(0, total_fragments_spent)
	completed_runs = maxi(0, completed_runs)
	victories = clampi(victories, 0, completed_runs)
	defeats = maxi(0, defeats)
	created_at_unix = created_at_unix if created_at_unix > 0 else int(Time.get_unix_time_from_system())
	last_played_at_unix = int(Time.get_unix_time_from_system())
	var sanitized: Array[UpgradeLevelState] = []
	for progress: UpgradeLevelState in upgrade_progress:
		if progress.upgrade != null and upgrades.has(progress.upgrade):
			progress.level = clampi(progress.level, 0, progress.upgrade.max_level)
			if sanitized.all(func(existing: UpgradeLevelState) -> bool: return existing.upgrade != progress.upgrade):
				sanitized.append(progress)
	upgrade_progress = sanitized
	var sanitized_board_progress: Array[UpgradeLevelState] = []
	for progress: UpgradeLevelState in upgrade_board_legacy_progress:
		if progress.upgrade != null and upgrades.has(progress.upgrade):
			progress.level = clampi(progress.level, 0, progress.upgrade.max_level)
			if sanitized_board_progress.all(func(existing: UpgradeLevelState) -> bool: return existing.upgrade != progress.upgrade):
				sanitized_board_progress.append(progress)
	upgrade_board_legacy_progress = sanitized_board_progress
	upgrade_piece_inventory.sanitize(ContentRegistry.pieces)
	upgrade_board_state.sanitize(ContentRegistry.pieces)
	_deduplicate_all()
	if standard_difficulty != null and not unlocked_difficulties.has(standard_difficulty):
		unlocked_difficulties.append(standard_difficulty)
	while run_history.size() > maximum_run_history:
		run_history.pop_front()
	while daily_history.size() > maximum_daily_history:
		daily_history.pop_front()
	var sanitized_daily_attempts: Array[String] = []
	for date_key: String in ranked_daily_attempt_dates:
		if not date_key.is_empty() and not sanitized_daily_attempts.has(date_key):
			sanitized_daily_attempts.append(date_key)
	ranked_daily_attempt_dates = sanitized_daily_attempts
	while ranked_daily_attempt_dates.size() > maximum_ranked_daily_attempt_dates:
		ranked_daily_attempt_dates.pop_front()
	while claimed_boss_rewards.size() > maximum_claimed_boss_rewards:
		claimed_boss_rewards.pop_front()
	tutorial_progress.sanitize(ContentRegistry.tutorials)

func has_ranked_daily_attempt(date_key: String) -> bool:
	if date_key.is_empty():
		return false
	if ranked_daily_attempt_dates.has(date_key):
		return true
	for entry: DailyRunEntry in daily_history:
		if entry.date == date_key and not entry.practice:
			return true
	return false

func validate() -> PackedStringArray:
	var errors: PackedStringArray = []
	if profile_sequence <= 0:
		errors.append(invalid_sequence_message)
	if fragments < 0:
		errors.append(negative_fragments_message)
	if save_version > CURRENT_VERSION:
		errors.append(unsupported_version_message)
	return errors

func _deduplicate_all() -> void:
	unlocked_pieces.assign(_unique_resources(unlocked_pieces))
	unlocked_relics.assign(_unique_resources(unlocked_relics))
	unlocked_enemies.assign(_unique_resources(unlocked_enemies))
	unlocked_events.assign(_unique_resources(unlocked_events))
	unlocked_difficulties.assign(_unique_resources(unlocked_difficulties))
	discovered_pieces.assign(_unique_resources(discovered_pieces))
	discovered_relics.assign(_unique_resources(discovered_relics))
	discovered_enemies.assign(_unique_resources(discovered_enemies))
	defeated_enemies.assign(_unique_resources(defeated_enemies))
	discovered_items.assign(_unique_resources(discovered_items))

static func _upgrade_levels_to_data(levels: Array[UpgradeLevelState]) -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for progress: UpgradeLevelState in levels:
		if progress.upgrade != null:
			data.append(progress.to_save_data())
	return data

static func _legacy_levels_to_data(levels: Array[LegacyUpgradeLevel]) -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for progress: LegacyUpgradeLevel in levels:
		data.append(progress.to_save_data())
	return data

static func _data_to_upgrade_levels(value: Variant) -> Array[UpgradeLevelState]:
	var levels: Array[UpgradeLevelState] = []
	if value is Dictionary:
		var legacy_data: Dictionary = value as Dictionary
		for key: Variant in legacy_data:
			var upgrade: UpgradeDefinition = ContentReferenceCodec.decode_legacy(String(key), UpgradeDefinition, ContentRegistry.catalog) as UpgradeDefinition
			if upgrade != null:
				levels.append(UpgradeLevelState.new(upgrade, int(legacy_data[key])))
	elif value is Array:
		for entry_value: Variant in value as Array:
			var progress: UpgradeLevelState = UpgradeLevelState.from_save_data(entry_value as Dictionary)
			if progress.upgrade != null:
				levels.append(progress)
	return levels

static func _data_to_legacy_levels(value: Variant) -> Array[LegacyUpgradeLevel]:
	var levels: Array[LegacyUpgradeLevel] = []
	if value is Dictionary:
		var legacy_data: Dictionary = value as Dictionary
		for key: Variant in legacy_data:
			levels.append(LegacyUpgradeLevel.new(StringName(String(key)), int(legacy_data[key])))
	elif value is Array:
		for entry_value: Variant in value as Array:
			levels.append(LegacyUpgradeLevel.from_save_data(entry_value as Dictionary))
	return levels

static func _run_history_to_data(entries: Array[RunHistoryEntry]) -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for entry: RunHistoryEntry in entries:
		data.append(entry.to_save_data())
	return data

static func _daily_history_to_data(entries: Array[DailyRunEntry]) -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for entry: DailyRunEntry in entries:
		data.append(entry.to_save_data())
	return data

static func _boss_claims_to_data(claims: Array[BossRewardClaim]) -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for claim: BossRewardClaim in claims:
		data.append(claim.to_save_data())
	return data

static func _unique_resources(values: Array) -> Array:
	var result: Array = []
	for value: Resource in values:
		if value != null and not result.has(value):
			result.append(value)
	return result

static func _references_to_difficulties(values: Array) -> Array[DifficultyDefinition]:
	var result: Array[DifficultyDefinition] = []
	for value: Variant in values:
		var definition: DifficultyDefinition = ContentReferenceCodec.decode_legacy(String(value), DifficultyDefinition, ContentRegistry.catalog) as DifficultyDefinition
		if definition != null and not result.has(definition):
			result.append(definition)
	return result

static func _references_to_items(values: Array) -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for value: Variant in values:
		var definition: ItemDefinition = ContentReferenceCodec.decode_legacy(String(value), ItemDefinition, ContentRegistry.catalog) as ItemDefinition
		if definition != null and not result.has(definition):
			result.append(definition)
	return result
