class_name RunHistoryEntry
extends RefCounted

var run_sequence: int
var timestamp: int
var seed_value: int
var difficulty: DifficultyDefinition
var victory: bool
var defeat_reason: String
var score: int
var duration: float
var encounters_completed: int
var bosses_defeated: int
var lines_cleared: int
var cross_clears: int
var perfect_clears: int
var highest_combo: int
var fragments_earned: int
var relics: Array[RelicDefinition] = []
var modifier_snapshot_hash: String

func to_save_data() -> Dictionary:
	return {"run_sequence": run_sequence, "timestamp": timestamp, "seed": seed_value, "difficulty": ContentReferenceCodec.encode(difficulty), "victory": victory, "defeat_reason": defeat_reason, "score": score, "duration": duration, "encounters_completed": encounters_completed, "bosses_defeated": bosses_defeated, "lines_cleared": lines_cleared, "cross_clears": cross_clears, "perfect_clears": perfect_clears, "highest_combo": highest_combo, "fragments_earned": fragments_earned, "relics": StartingRunModifiers._resources_to_references(relics), "modifier_snapshot_hash": modifier_snapshot_hash}

static func from_save_data(data: Dictionary) -> RunHistoryEntry:
	var entry: RunHistoryEntry = RunHistoryEntry.new()
	entry.run_sequence = int(data.get("run_sequence", String(data.get("run_id", "")).hash()))
	entry.timestamp = int(data.get("timestamp", 0))
	entry.seed_value = int(data.get("seed", 0))
	entry.difficulty = ContentReferenceCodec.decode_legacy(String(data.get("difficulty", "standard")), DifficultyDefinition, ContentRegistry.catalog) as DifficultyDefinition
	entry.victory = bool(data.get("victory", false))
	entry.defeat_reason = String(data.get("defeat_reason", ""))
	entry.score = int(data.get("score", 0))
	entry.duration = float(data.get("duration", 0.0))
	entry.encounters_completed = int(data.get("encounters_completed", 0))
	entry.bosses_defeated = int(data.get("bosses_defeated", 0))
	entry.lines_cleared = int(data.get("lines_cleared", 0))
	entry.cross_clears = int(data.get("cross_clears", 0))
	entry.perfect_clears = int(data.get("perfect_clears", 0))
	entry.highest_combo = int(data.get("highest_combo", 0))
	entry.fragments_earned = int(data.get("fragments_earned", 0))
	entry.relics = StartingRunModifiers._references_to_relics(data.get("relics", []) as Array)
	entry.modifier_snapshot_hash = String(data.get("modifier_snapshot_hash", ""))
	return entry
