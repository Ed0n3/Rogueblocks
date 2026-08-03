class_name RelicAcquisitionState
extends RefCounted

var definition: RelicDefinition
var source_description: String

func to_save_data() -> Dictionary:
	return {
		"definition": ContentReferenceCodec.encode(definition),
		"source_description": source_description
	}

static func from_save_data(data: Dictionary) -> RelicAcquisitionState:
	var state: RelicAcquisitionState = RelicAcquisitionState.new()
	state.definition = ContentReferenceCodec.decode_legacy(String(data.get("definition", data.get("relic_id", ""))), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
	state.source_description = String(data.get("source_description", "Unknown source"))
	return state
