class_name RelicTriggerService
extends RefCounted

func resolve_after_clear(context: AfterClearContext) -> void:
	for relic: RelicDefinition in _active_relics(context.run_state):
		relic.trigger_effect.after_clear(context)

func rerolls_after_discard(run_state: RunState) -> int:
	var rerolls: int = 0
	for relic: RelicDefinition in _active_relics(run_state):
		var effect: RelicTriggerEffect = relic.trigger_effect
		if effect.discard_interval > 0 and run_state.discarded_piece_count % effect.discard_interval == 0:
			rerolls += effect.rerolls_per_discard_trigger
	return rerolls

func apply_spawned_blocker_durability(run_state: RunState, board: BoardState, cells: Array[Vector2i]) -> void:
	var durability: int = 0
	for relic: RelicDefinition in _active_relics(run_state):
		durability = maxi(durability, relic.trigger_effect.spawned_blocker_durability)
	if durability <= 1:
		return
	for cell: Vector2i in cells:
		if board.get_cell_type(cell) == CellType.Value.BLOCKER:
			board.set_special_cell(cell, CellType.Value.ARMORED, durability)

func _active_relics(run_state: RunState) -> Array[RelicDefinition]:
	var active: Array[RelicDefinition] = []
	if run_state == null:
		return active
	for relic: RelicDefinition in run_state.relics:
		if relic != null and relic.trigger_effect != null:
			active.append(relic)
	active.sort_custom(func(left: RelicDefinition, right: RelicDefinition) -> bool: return left.trigger_priority < right.trigger_priority or left.trigger_priority == right.trigger_priority and left.resource_path < right.resource_path)
	return active
