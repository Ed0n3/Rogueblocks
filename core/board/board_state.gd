class_name BoardState
extends RefCounted

const CELL_FLAG_DEFINITION: Script = preload("res://core/cells/cell_flag.gd")
const EMPTY: int = -1
const BLOCKER: int = -2

var width: int
var height: int
var cells: PackedInt32Array
var cell_types: PackedByteArray
var cell_flags: PackedInt32Array
var cell_values: PackedInt32Array
var occupant_pieces: Array[PieceDefinition] = []
var occupant_card_ids: PackedInt64Array
var occupant_card_effects: Array[PieceCardEffectDefinition] = []
var occupant_instance_ids: PackedInt64Array
var occupant_source_types: PackedByteArray
var occupant_modifiers: Array[Array] = []
var next_piece_value: int = 1
var behaviors: CellBehaviorRegistry = CellBehaviorRegistry.new()

func _init(board_width: int = 10, board_height: int = 10) -> void:
	width = board_width
	height = board_height
	cells = PackedInt32Array()
	cell_types = PackedByteArray()
	cell_flags = PackedInt32Array()
	cell_values = PackedInt32Array()
	occupant_instance_ids = PackedInt64Array()
	occupant_card_ids = PackedInt64Array()
	occupant_source_types = PackedByteArray()
	clear_board()

func clear_board() -> void:
	cells.resize(width * height)
	cells.fill(EMPTY)
	cell_types.resize(width * height)
	cell_types.fill(CellType.Value.EMPTY)
	cell_flags.resize(width * height)
	cell_flags.fill(0)
	cell_values.resize(width * height)
	cell_values.fill(0)
	occupant_pieces.resize(width * height)
	occupant_pieces.fill(null)
	occupant_card_ids.resize(width * height)
	occupant_card_ids.fill(0)
	occupant_card_effects.resize(width * height)
	occupant_card_effects.fill(null)
	occupant_instance_ids.resize(width * height)
	occupant_instance_ids.fill(0)
	occupant_source_types.resize(width * height)
	occupant_source_types.fill(PieceSourceType.Value.DRAWN_CARD)
	occupant_modifiers.resize(width * height)
	for index: int in occupant_modifiers.size():
		occupant_modifiers[index] = []
	next_piece_value = 1

func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height

func get_cell(cell: Vector2i) -> int:
	return cells[_index(cell)] if is_inside(cell) else EMPTY

func set_cell(cell: Vector2i, value: int) -> void:
	assert(is_inside(cell), "Board coordinate is outside the board")
	var index: int = _index(cell)
	cells[index] = value
	if value == BLOCKER:
		cell_flags[index] = 0
		cell_types[index] = CellType.Value.BLOCKER
		cell_values[index] = 1
	elif value == EMPTY:
		_clear_occupant(index)
		cell_values[index] = 0
		if cell_types[index] == CellType.Value.OCCUPIED:
			cell_types[index] = CellType.Value.EMPTY
	else:
		cell_flags[index] = 0
		if cell_types[index] != CellType.Value.TARGET:
			cell_values[index] = 0
		if cell_types[index] == CellType.Value.EMPTY:
			cell_types[index] = CellType.Value.OCCUPIED

func is_empty(cell: Vector2i) -> bool:
	if not is_inside(cell):
		return false
	var index: int = _index(cell)
	return behaviors.get_behavior(cell_types[index]).permits_placement(self, index)

func set_special_cell(cell: Vector2i, type: CellType.Value, value: int = 0) -> void:
	assert(is_inside(cell), "Board coordinate is outside the board")
	var index: int = _index(cell)
	cell_types[index] = type
	cell_values[index] = value
	_clear_occupant(index)
	if type == CellType.Value.BLOCKER or type == CellType.Value.ARMORED:
		cells[index] = BLOCKER
	elif type == CellType.Value.LOCKED:
		cells[index] = EMPTY

func get_cell_type(cell: Vector2i) -> CellType.Value:
	return cell_types[_index(cell)] as CellType.Value if is_inside(cell) else CellType.Value.EMPTY

func get_occupant_modifiers(cell: Vector2i) -> Array[PieceModifierDefinition]:
	var modifiers: Array[PieceModifierDefinition] = []
	if is_inside(cell):
		modifiers.assign(occupant_modifiers[_index(cell)])
	return modifiers

func get_occupant_card_effect(cell: Vector2i) -> PieceCardEffectDefinition:
	if not is_inside(cell):
		return null
	return occupant_card_effects[_index(cell)]

func is_cell_poisoned(cell: Vector2i) -> bool:
	return _cell_has_flag(cell, CELL_FLAG_DEFINITION.Value.POISONED)

func is_cell_electrified(cell: Vector2i) -> bool:
	return _cell_has_flag(cell, CELL_FLAG_DEFINITION.Value.ELECTRIFIED)

func get_cell_poison_damage(cell: Vector2i) -> int:
	return cell_values[_index(cell)] if is_cell_poisoned(cell) else 0

func poison_random_blocks(count: int, damage_on_clear: int, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var candidate_instance_ids: Array[int] = _candidate_instance_ids_without_flag(CELL_FLAG_DEFINITION.Value.POISONED)
	var affected_cells: Array[Vector2i] = []
	for block_index: int in mini(maxi(0, count), candidate_instance_ids.size()):
		var selected_index: int = rng.randi_range(0, candidate_instance_ids.size() - 1)
		var selected_instance_id: int = candidate_instance_ids.pop_at(selected_index)
		affected_cells.append_array(_poison_block(selected_instance_id, damage_on_clear))
	return affected_cells

func electrify_random_blocks(count: int, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var candidate_instance_ids: Array[int] = _candidate_instance_ids_without_flag(CELL_FLAG_DEFINITION.Value.ELECTRIFIED)
	var affected_cells: Array[Vector2i] = []
	for block_index: int in mini(maxi(0, count), candidate_instance_ids.size()):
		var selected_index: int = rng.randi_range(0, candidate_instance_ids.size() - 1)
		var selected_instance_id: int = candidate_instance_ids.pop_at(selected_index)
		affected_cells.append_array(_mark_block_flag(selected_instance_id, CELL_FLAG_DEFINITION.Value.ELECTRIFIED))
	return affected_cells

func has_block_without_flag(flag: CellFlag.Value) -> bool:
	for index: int in occupant_instance_ids.size():
		if occupant_instance_ids[index] > 0 and (cell_flags[index] & int(flag)) == 0:
			return true
	return false

func can_place(cells_to_place: Array[Vector2i]) -> bool:
	if cells_to_place.is_empty():
		return false
	for cell: Vector2i in cells_to_place:
		if not is_empty(cell):
			return false
	return true

func place_piece(origin: Vector2i, piece: PieceInstance) -> PlacementResult:
	var result: PlacementResult = PlacementResult.new()
	result.origin = origin
	result.piece = piece.definition
	result.card_id = piece.card.card_id if piece.card != null else 0
	result.piece_instance_id = piece.instance_id if piece.instance_id > 0 else next_piece_value
	result.source_type = piece.source_type
	for offset: Vector2i in piece.get_cells():
		result.placed_cells.append(origin + offset)
	if not can_place(result.placed_cells):
		result.failure_reason = "Invalid placement"
		return result
	for cell: Vector2i in result.placed_cells:
		var index: int = _index(cell)
		set_cell(cell, result.piece_instance_id)
		occupant_pieces[index] = piece.definition
		occupant_card_ids[index] = result.card_id
		occupant_card_effects[index] = piece.card.intrinsic_effect if piece.card != null else null
		occupant_instance_ids[index] = result.piece_instance_id
		occupant_source_types[index] = piece.source_type
		occupant_modifiers[index] = piece.modifiers.duplicate()
	piece.instance_id = result.piece_instance_id
	next_piece_value = maxi(next_piece_value, result.piece_instance_id + 1)
	result.success = true
	return result

func find_completed_rows() -> PackedInt32Array:
	var rows: PackedInt32Array = PackedInt32Array()
	for y: int in height:
		var complete: bool = true
		for x: int in width:
			var index: int = _index(Vector2i(x, y))
			if not behaviors.get_behavior(cell_types[index]).counts_for_line(self, index):
				complete = false
				break
		if complete:
			rows.append(y)
	return rows

func find_completed_columns() -> PackedInt32Array:
	var columns: PackedInt32Array = PackedInt32Array()
	for x: int in width:
		var complete: bool = true
		for y: int in height:
			var index: int = _index(Vector2i(x, y))
			if not behaviors.get_behavior(cell_types[index]).counts_for_line(self, index):
				complete = false
				break
		if complete:
			columns.append(x)
	return columns

func resolve_completed_lines() -> ClearResult:
	var result: ClearResult = ClearResult.new()
	result.completed_rows = find_completed_rows()
	result.completed_columns = find_completed_columns()
	var unique_cells: Dictionary[Vector2i, bool] = {}
	for y: int in result.completed_rows:
		for x: int in width:
			unique_cells[Vector2i(x, y)] = true
	for x: int in result.completed_columns:
		for y: int in height:
			unique_cells[Vector2i(x, y)] = true
	result.cleared_cells.assign(unique_cells.keys())
	var contributions: Dictionary[int, PieceClearContribution] = {}
	for cell: Vector2i in result.cleared_cells:
		_collect_contribution(contributions, cell, result.completed_rows, result.completed_columns)
	_collect_poisoned_block_damage(result, result.cleared_cells)
	_collect_electrified_blocks(result, result.cleared_cells)
	var removed_cells: Array[Vector2i] = []
	for cell: Vector2i in result.cleared_cells:
		var index: int = _index(cell)
		var outcome: CellClearOutcome = behaviors.get_behavior(cell_types[index]).clear_cell(self, index)
		result.shard_reward += outcome.shard_reward
		result.player_damage += outcome.player_damage
		result.targets_cleared += outcome.target_cleared
		result.blockers_destroyed += outcome.blocker_destroyed
		if outcome.removed:
			removed_cells.append(cell)
			_clear_occupant(index)
	result.cleared_cells = removed_cells
	result.line_count = result.completed_rows.size() + result.completed_columns.size()
	result.cleared_cell_count = result.cleared_cells.size()
	result.cross_clear = not result.completed_rows.is_empty() and not result.completed_columns.is_empty()
	result.perfect_clear = result.line_count > 0 and is_board_empty()
	_finalize_contributions(result, contributions)
	return result

func advance_special_cells(turn_count: int) -> int:
	var damage: int = 0
	for index: int in cell_types.size():
		damage += behaviors.get_behavior(cell_types[index]).advance_turn(self, index, turn_count)
	return damage

func remove_random_occupied_cells(count: int, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	for y: int in height:
		for x: int in width:
			var cell: Vector2i = Vector2i(x, y)
			var index: int = _index(cell)
			if cells[index] >= 0 and cell_types[index] != CellType.Value.BLOCKER and cell_types[index] != CellType.Value.ARMORED:
				candidates.append(cell)
	var removed: Array[Vector2i] = []
	for removal_index: int in mini(count, candidates.size()):
		var cell: Vector2i = candidates.pop_at(rng.randi_range(0, candidates.size() - 1))
		set_cell(cell, EMPTY)
		removed.append(cell)
	return removed

func to_save_data() -> Dictionary:
	var saved_pieces: Array[String] = []
	for piece: PieceDefinition in occupant_pieces:
		saved_pieces.append(ContentReferenceCodec.encode(piece))
	var saved_card_effects: Array[String] = []
	for effect: PieceCardEffectDefinition in occupant_card_effects:
		saved_card_effects.append(ContentReferenceCodec.encode(effect))
	var saved_modifiers: Array[Array] = []
	for modifiers: Array in occupant_modifiers:
		var saved_cell_modifiers: Array[String] = []
		for modifier: PieceModifierDefinition in modifiers:
			saved_cell_modifiers.append(ContentReferenceCodec.encode(modifier))
		saved_modifiers.append(saved_cell_modifiers)
	return {"width": width, "height": height, "cells": Array(cells), "cell_types": Array(cell_types), "cell_flags": Array(cell_flags), "cell_values": Array(cell_values), "occupant_pieces": saved_pieces, "occupant_card_ids": Array(occupant_card_ids), "occupant_card_effects": saved_card_effects, "occupant_instance_ids": Array(occupant_instance_ids), "occupant_source_types": Array(occupant_source_types), "occupant_modifiers": saved_modifiers, "next_piece_value": next_piece_value}

static func from_save_data(data: Dictionary) -> BoardState:
	var board_width: int = int(data.get("width", 0))
	var board_height: int = int(data.get("height", 0))
	if board_width <= 0 or board_height <= 0 or board_width > 32 or board_height > 32:
		return null
	var saved_cells: Array = data.get("cells", []) as Array
	if saved_cells.size() != board_width * board_height:
		return null
	var board: BoardState = BoardState.new(board_width, board_height)
	board.cells = PackedInt32Array(saved_cells)
	var saved_types: Array = data.get("cell_types", []) as Array
	if saved_types.size() == saved_cells.size():
		board.cell_types = PackedByteArray(saved_types)
	var saved_flags: Array = data.get("cell_flags", []) as Array
	if saved_flags.size() == saved_cells.size():
		board.cell_flags = PackedInt32Array(saved_flags)
	var saved_values: Array = data.get("cell_values", []) as Array
	if saved_values.size() == saved_cells.size():
		board.cell_values = PackedInt32Array(saved_values)
	var saved_pieces: Array = data.get("occupant_pieces", data.get("occupant_piece_ids", [])) as Array
	if saved_pieces.size() == saved_cells.size():
		for index: int in saved_pieces.size():
			board.occupant_pieces[index] = ContentReferenceCodec.decode_legacy(String(saved_pieces[index]), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
	var saved_card_ids: Array = data.get("occupant_card_ids", []) as Array
	if saved_card_ids.size() == saved_cells.size():
		board.occupant_card_ids = PackedInt64Array(saved_card_ids)
	var saved_card_effects: Array = data.get("occupant_card_effects", []) as Array
	if saved_card_effects.size() == saved_cells.size():
		for index: int in saved_card_effects.size():
			board.occupant_card_effects[index] = ContentReferenceCodec.decode(String(saved_card_effects[index]), PieceCardEffectDefinition) as PieceCardEffectDefinition
	var saved_instance_ids: Array = data.get("occupant_instance_ids", []) as Array
	if saved_instance_ids.size() == saved_cells.size():
		board.occupant_instance_ids = PackedInt64Array(saved_instance_ids)
	else:
		for index: int in board.cells.size():
			board.occupant_instance_ids[index] = maxi(0, board.cells[index])
	var saved_source_types: Array = data.get("occupant_source_types", []) as Array
	if saved_source_types.size() == saved_cells.size():
		board.occupant_source_types = PackedByteArray(saved_source_types)
	var saved_modifiers: Array = data.get("occupant_modifiers", data.get("occupant_modifier_ids", [])) as Array
	if saved_modifiers.size() == saved_cells.size():
		for index: int in saved_modifiers.size():
			var cell_modifiers: Array[PieceModifierDefinition] = []
			for modifier_value: Variant in saved_modifiers[index] as Array:
				var modifier: PieceModifierDefinition = ContentReferenceCodec.decode_legacy(String(modifier_value), PieceModifierDefinition, ContentRegistry.catalog) as PieceModifierDefinition
				if modifier != null:
					cell_modifiers.append(modifier)
			board.occupant_modifiers[index] = cell_modifiers
	board.next_piece_value = maxi(1, int(data.get("next_piece_value", 1)))
	return board

func add_blockers(count: int, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var empty_cells: Array[Vector2i] = []
	for y: int in height:
		for x: int in width:
			var cell: Vector2i = Vector2i(x, y)
			if is_empty(cell):
				empty_cells.append(cell)
	var added: Array[Vector2i] = []
	for index: int in mini(count, empty_cells.size()):
		var selected_index: int = rng.randi_range(0, empty_cells.size() - 1)
		var selected: Vector2i = empty_cells.pop_at(selected_index)
		set_cell(selected, BLOCKER)
		added.append(selected)
	return added

func can_place_piece_anywhere(piece: PieceDefinition) -> bool:
	return find_piece_placement(piece).found

func find_piece_placement(piece: PieceDefinition, preferred_origin: Vector2i = Vector2i(-1, -1), preferred_rotation_index: int = -1) -> PiecePlacementCandidate:
	var result: PiecePlacementCandidate = PiecePlacementCandidate.new()
	if piece == null:
		return result
	var target: Vector2i = preferred_origin
	if target.x < 0 or target.y < 0:
		target = Vector2i(width / 2, height / 2)
	var best_score: int = 2147483647
	var rotations: Array[Array] = PieceRotationService.get_unique_rotations(piece)
	for rotation_index: int in rotations.size():
		var rotation: Array = rotations[rotation_index]
		var offsets: Array[Vector2i] = []
		for value: Variant in rotation:
			offsets.append(value as Vector2i)
		for y: int in height:
			for x: int in width:
				var placed: Array[Vector2i] = []
				for offset: Vector2i in offsets:
					placed.append(Vector2i(x, y) + offset)
				if not can_place(placed):
					continue
				var distance: int = absi(x - target.x) + absi(y - target.y)
				var rotation_priority: int = 0 if preferred_rotation_index < 0 or rotation_index == preferred_rotation_index else 1
				var score: int = rotation_priority * 100000000 + distance * 10000 + rotation_index * 1000 + y * width + x
				if score < best_score:
					best_score = score
					result.found = true
					result.origin = Vector2i(x, y)
					result.rotation_index = rotation_index
	return result

func is_board_empty() -> bool:
	for value: int in cells:
		if value != EMPTY:
			return false
	return true

func count_empty_cells() -> int:
	var count: int = 0
	for y: int in height:
		for x: int in width:
			count += 1 if is_empty(Vector2i(x, y)) else 0
	return count

func _index(cell: Vector2i) -> int:
	return cell.y * width + cell.x

func _clear_occupant(index: int) -> void:
	occupant_pieces[index] = null
	occupant_card_ids[index] = 0
	occupant_card_effects[index] = null
	occupant_instance_ids[index] = 0
	occupant_source_types[index] = PieceSourceType.Value.DRAWN_CARD
	occupant_modifiers[index] = []
	cell_flags[index] = 0

func _collect_contribution(contributions: Dictionary[int, PieceClearContribution], cell: Vector2i, rows: PackedInt32Array, columns: PackedInt32Array) -> void:
	var index: int = _index(cell)
	var instance_id: int = occupant_instance_ids[index]
	if instance_id <= 0 or occupant_pieces[index] == null:
		return
	var contribution: PieceClearContribution = contributions.get(instance_id) as PieceClearContribution
	if contribution == null:
		contribution = PieceClearContribution.new()
		contribution.piece = occupant_pieces[index]
		if occupant_card_ids[index] > 0 or occupant_card_effects[index] != null:
			contribution.card = PieceCardState.new()
			contribution.card.card_id = occupant_card_ids[index]
			contribution.card.piece = occupant_pieces[index]
			contribution.card.intrinsic_effect = occupant_card_effects[index]
		contribution.piece_instance_id = instance_id
		contribution.source_type = occupant_source_types[index] as PieceSourceType.Value
		contribution.modifiers.assign(occupant_modifiers[index])
		contributions[instance_id] = contribution
	contribution.cleared_cells.append(cell)
	if rows.has(cell.y) and not contribution.affected_rows.has(cell.y):
		contribution.affected_rows.append(cell.y)
	if columns.has(cell.x) and not contribution.affected_columns.has(cell.x):
		contribution.affected_columns.append(cell.x)

func _finalize_contributions(result: ClearResult, contributions: Dictionary[int, PieceClearContribution]) -> void:
	var instance_ids: Array[int] = contributions.keys()
	instance_ids.sort()
	for instance_id: int in instance_ids:
		var contribution: PieceClearContribution = contributions[instance_id]
		contribution.participated_in_cross_clear = not contribution.affected_rows.is_empty() and not contribution.affected_columns.is_empty()
		contribution.all_remaining_cells_cleared = not occupant_instance_ids.has(instance_id)
		result.piece_contributions.append(contribution)
		result.cleared_piece_instance_ids.append(instance_id)
		if not result.cleared_pieces.has(contribution.piece):
			result.cleared_pieces.append(contribution.piece)

func _collect_poisoned_block_damage(result: ClearResult, cleared_cells: Array[Vector2i]) -> void:
	var damage_by_instance_id: Dictionary[int, int] = {}
	var source_cell_by_instance_id: Dictionary[int, Vector2i] = {}
	for cell: Vector2i in cleared_cells:
		if not is_cell_poisoned(cell):
			continue
		var instance_id: int = occupant_instance_ids[_index(cell)]
		if instance_id <= 0:
			continue
		damage_by_instance_id[instance_id] = maxi(damage_by_instance_id.get(instance_id, 0), get_cell_poison_damage(cell))
		if not source_cell_by_instance_id.has(instance_id):
			source_cell_by_instance_id[instance_id] = cell
	var instance_ids: Array[int] = damage_by_instance_id.keys()
	instance_ids.sort()
	result.poisoned_block_count = instance_ids.size()
	for instance_id: int in instance_ids:
		result.poisoned_block_damage += damage_by_instance_id[instance_id]
		result.poison_damage_source_cells.append(source_cell_by_instance_id[instance_id])
	result.player_damage += result.poisoned_block_damage

func _cell_has_flag(cell: Vector2i, flag: CellFlag.Value) -> bool:
	return is_inside(cell) and (cell_flags[_index(cell)] & int(flag)) != 0

func _candidate_instance_ids_without_flag(flag: CellFlag.Value) -> Array[int]:
	var candidate_instance_ids: Array[int] = []
	for instance_id: int in occupant_instance_ids:
		if instance_id > 0 and not candidate_instance_ids.has(instance_id) and not _is_block_flagged(instance_id, flag):
			candidate_instance_ids.append(instance_id)
	return candidate_instance_ids

func _is_block_flagged(instance_id: int, flag: CellFlag.Value) -> bool:
	for index: int in occupant_instance_ids.size():
		if occupant_instance_ids[index] == instance_id and (cell_flags[index] & int(flag)) != 0:
			return true
	return false

func _poison_block(instance_id: int, damage_on_clear: int) -> Array[Vector2i]:
	var affected_cells: Array[Vector2i] = _mark_block_flag(instance_id, CELL_FLAG_DEFINITION.Value.POISONED)
	for cell: Vector2i in affected_cells:
		cell_values[_index(cell)] = maxi(1, damage_on_clear)
	return affected_cells

func _mark_block_flag(instance_id: int, flag: CellFlag.Value) -> Array[Vector2i]:
	var affected_cells: Array[Vector2i] = []
	for index: int in occupant_instance_ids.size():
		if occupant_instance_ids[index] == instance_id:
			cell_flags[index] |= int(flag)
			affected_cells.append(Vector2i(index % width, index / width))
	return affected_cells

func _collect_electrified_blocks(result: ClearResult, cleared_cells: Array[Vector2i]) -> void:
	var source_cell_by_instance_id: Dictionary[int, Vector2i] = {}
	for cell: Vector2i in cleared_cells:
		if not is_cell_electrified(cell):
			continue
		var instance_id: int = occupant_instance_ids[_index(cell)]
		if instance_id > 0 and not source_cell_by_instance_id.has(instance_id):
			source_cell_by_instance_id[instance_id] = cell
	var instance_ids: Array[int] = source_cell_by_instance_id.keys()
	instance_ids.sort()
	result.electrified_block_count = instance_ids.size()
	for instance_id: int in instance_ids:
		result.electrified_source_cells.append(source_cell_by_instance_id[instance_id])
