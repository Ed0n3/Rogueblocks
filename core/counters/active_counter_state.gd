class_name ActiveCounterState
extends RefCounted

var definition: CounterDefinition
var source_enemy: EnemyDefinition
var turns_remaining: int = 0
var current_progress: int = 0
var required_progress: int = 1
var target_cells: Array[Vector2i] = []
var target_rows: PackedInt32Array = PackedInt32Array()
var target_columns: PackedInt32Array = PackedInt32Array()
var is_completed: bool = false
var is_failed: bool = false
var resolved: bool = false

func to_save_data() -> Dictionary:
	var cells: Array[Array] = []
	for cell: Vector2i in target_cells:
		cells.append([cell.x, cell.y])
	return {"definition": ContentReferenceCodec.encode(definition), "source_enemy": ContentReferenceCodec.encode(source_enemy), "turns_remaining": turns_remaining, "current_progress": current_progress, "required_progress": required_progress, "target_cells": cells, "target_rows": Array(target_rows), "target_columns": Array(target_columns), "is_completed": is_completed, "is_failed": is_failed, "resolved": resolved}

static func from_save_data(data: Dictionary) -> ActiveCounterState:
	var state: ActiveCounterState = ActiveCounterState.new()
	var definition_reference: String = String(data.get("definition", data.get("definition_id", "")))
	state.definition = ContentReferenceCodec.decode_legacy(definition_reference, CounterDefinition, ContentRegistry.catalog) as CounterDefinition
	var enemy_reference: String = String(data.get("source_enemy", data.get("source_enemy_id", "")))
	state.source_enemy = ContentReferenceCodec.decode_legacy(enemy_reference, EnemyDefinition, ContentRegistry.catalog) as EnemyDefinition
	state.turns_remaining = maxi(0, int(data.get("turns_remaining", 0)))
	state.current_progress = maxi(0, int(data.get("current_progress", 0)))
	state.required_progress = maxi(1, int(data.get("required_progress", 1)))
	for value: Variant in data.get("target_cells", []) as Array:
		var pair: Array = value as Array
		if pair.size() >= 2:
			state.target_cells.append(Vector2i(int(pair[0]), int(pair[1])))
	state.target_rows = PackedInt32Array(data.get("target_rows", []) as Array)
	state.target_columns = PackedInt32Array(data.get("target_columns", []) as Array)
	state.is_completed = bool(data.get("is_completed", false))
	state.is_failed = bool(data.get("is_failed", false))
	state.resolved = bool(data.get("resolved", false))
	return state
