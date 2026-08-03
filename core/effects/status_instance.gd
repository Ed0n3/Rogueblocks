class_name StatusInstance
extends RefCounted

var definition: StatusDefinition
var source: Resource
var remaining_turns: int = 1
var stacks: int = 1
var magnitude: float = 1.0
var applied_turn: int = 0

func to_save_data() -> Dictionary:
	return {"definition": ContentReferenceCodec.encode(definition), "source": ContentReferenceCodec.encode(source), "remaining_turns": remaining_turns, "stacks": stacks, "magnitude": magnitude, "applied_turn": applied_turn}

static func from_save_data(data: Dictionary) -> StatusInstance:
	var instance: StatusInstance = StatusInstance.new()
	var reference: String = String(data.get("definition", data.get("definition_id", "")))
	instance.definition = ContentReferenceCodec.decode_legacy(reference, StatusDefinition, ContentRegistry.catalog) as StatusDefinition
	var source_reference: String = String(data.get("source", ""))
	instance.source = load(source_reference) as Resource if not source_reference.is_empty() else null
	instance.remaining_turns = maxi(0, int(data.get("remaining_turns", 1)))
	instance.stacks = maxi(1, int(data.get("stacks", 1)))
	instance.magnitude = float(data.get("magnitude", 1.0))
	instance.applied_turn = maxi(0, int(data.get("applied_turn", 0)))
	return instance
