class_name TutorialProgressEntry
extends RefCounted

var tutorial: TutorialDefinition
var attempt_count: int = 0
var completion_unix_time: int = 0

func _init(definition: TutorialDefinition = null) -> void:
	tutorial = definition

func to_save_data() -> Dictionary:
	return {"tutorial": ContentReferenceCodec.encode(tutorial), "attempt_count": attempt_count, "completion_unix_time": completion_unix_time}

static func from_save_data(data: Dictionary) -> TutorialProgressEntry:
	var entry: TutorialProgressEntry = TutorialProgressEntry.new(ContentReferenceCodec.decode_legacy(String(data.get("tutorial", "")), TutorialDefinition, ContentRegistry.catalog) as TutorialDefinition)
	entry.attempt_count = maxi(0, int(data.get("attempt_count", 0)))
	entry.completion_unix_time = maxi(0, int(data.get("completion_unix_time", 0)))
	return entry
