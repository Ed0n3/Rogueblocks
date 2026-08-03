class_name DailyRunEntry
extends RefCounted

var date: String
var seed_value: int
var score: int
var victory: bool
var practice: bool

func to_save_data() -> Dictionary:
	return {"date": date, "seed": seed_value, "score": score, "victory": victory, "practice": practice}

static func from_save_data(data: Dictionary) -> DailyRunEntry:
	var entry: DailyRunEntry = DailyRunEntry.new()
	entry.date = String(data.get("date", ""))
	entry.seed_value = int(data.get("seed", 0))
	entry.score = int(data.get("score", 0))
	entry.victory = bool(data.get("victory", false))
	entry.practice = bool(data.get("practice", false))
	return entry
