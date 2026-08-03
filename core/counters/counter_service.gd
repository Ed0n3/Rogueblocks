class_name CounterService
extends RefCounted

func create(definition: CounterDefinition, enemy: EnemyDefinition, board: BoardState, rng: RandomNumberGenerator) -> ActiveCounterState:
	var state: ActiveCounterState = ActiveCounterState.new()
	state.definition = definition
	state.source_enemy = enemy
	state.turns_remaining = maxi(1, definition.duration_turns)
	state.required_progress = maxi(1, definition.required_progress)
	if definition.counter_type == CounterType.Value.CLEAR_SPECIFIC_ROW:
		state.target_rows.append(_select_fair_row(board, rng))
	elif definition.counter_type == CounterType.Value.CLEAR_SPECIFIC_COLUMN:
		state.target_columns.append(_select_fair_column(board, rng))
	elif definition.counter_type == CounterType.Value.CLEAR_TARGET_AREA or definition.counter_type == CounterType.Value.FILL_TARGET_AREA:
		state.target_cells = _select_center_area(board, definition.target_area_size)
	return state

func apply_clear(state: ActiveCounterState, definition: CounterDefinition, clear: ClearResult) -> void:
	if state == null or state.resolved:
		return
	if definition.counter_type == CounterType.Value.CLEAR_TOTAL_LINES:
		state.current_progress += clear.line_count
	elif definition.counter_type == CounterType.Value.CROSS_CLEAR and clear.cross_clear:
		state.current_progress = state.required_progress
	elif definition.counter_type == CounterType.Value.CLEAR_SPECIFIC_ROW:
		for row: int in state.target_rows:
			if clear.completed_rows.has(row):
				state.current_progress += 1
	elif definition.counter_type == CounterType.Value.CLEAR_SPECIFIC_COLUMN:
		for column: int in state.target_columns:
			if clear.completed_columns.has(column):
				state.current_progress += 1
	elif definition.counter_type == CounterType.Value.CLEAR_TARGET_AREA or definition.counter_type == CounterType.Value.CLEAR_SPECIAL_CELLS:
		for cell: Vector2i in clear.cleared_cells:
			if state.target_cells.has(cell):
				state.current_progress += 1
	state.current_progress = mini(state.required_progress, state.current_progress)
	state.is_completed = state.current_progress >= state.required_progress

func apply_damage(state: ActiveCounterState, definition: CounterDefinition, health_damage: int, shield_damage: int) -> void:
	if state == null or state.resolved:
		return
	if definition.counter_type == CounterType.Value.DEAL_DAMAGE:
		state.current_progress += health_damage
	elif definition.counter_type == CounterType.Value.BREAK_SHIELD:
		state.current_progress += shield_damage
	state.current_progress = mini(state.required_progress, state.current_progress)
	state.is_completed = state.current_progress >= state.required_progress

func apply_item_tags(state: ActiveCounterState, definition: CounterDefinition, tags: Array[StringName]) -> void:
	if state == null or state.resolved:
		return
	for tag: StringName in tags:
		if definition.valid_item_counter_tags.has(tag):
			state.current_progress = state.required_progress
			state.is_completed = true
			return

func advance_deadline(state: ActiveCounterState) -> void:
	if state == null or state.resolved or state.is_completed:
		return
	state.turns_remaining -= 1
	state.is_failed = state.turns_remaining <= 0

func resolve(state: ActiveCounterState, definition: CounterDefinition, context: EffectContext) -> EffectResult:
	if state == null or state.resolved:
		return EffectResult.new()
	var effects: Array[GameplayEffect] = []
	if state.is_completed:
		effects = definition.success_effects
	elif state.is_failed and state.current_progress >= definition.partial_success_threshold and definition.partial_success_threshold > 0:
		effects = definition.partial_success_effects
	elif state.is_failed:
		effects = definition.failure_effects
	else:
		return EffectResult.new()
	state.resolved = true
	context.source = definition
	return EffectResolver.new().resolve(effects, context)

func _select_fair_row(board: BoardState, rng: RandomNumberGenerator) -> int:
	var candidates: Array[int] = []
	var best_distance: int = board.width
	for y: int in board.height:
		var occupied: int = 0
		for x: int in board.width:
			occupied += 0 if board.is_empty(Vector2i(x, y)) else 1
		if occupied >= board.width:
			continue
		var distance: int = absi(occupied * 2 - board.width)
		if distance < best_distance:
			best_distance = distance
			candidates = [y]
		elif distance == best_distance:
			candidates.append(y)
	return candidates[rng.randi_range(0, candidates.size() - 1)] if not candidates.is_empty() else rng.randi_range(0, board.height - 1)

func _select_fair_column(board: BoardState, rng: RandomNumberGenerator) -> int:
	var candidates: Array[int] = []
	var best_distance: int = board.height
	for x: int in board.width:
		var occupied: int = 0
		for y: int in board.height:
			occupied += 0 if board.is_empty(Vector2i(x, y)) else 1
		if occupied >= board.height:
			continue
		var distance: int = absi(occupied * 2 - board.height)
		if distance < best_distance:
			best_distance = distance
			candidates = [x]
		elif distance == best_distance:
			candidates.append(x)
	return candidates[rng.randi_range(0, candidates.size() - 1)] if not candidates.is_empty() else rng.randi_range(0, board.width - 1)

func _select_center_area(board: BoardState, requested_size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var area_size: Vector2i = Vector2i(mini(maxi(1, requested_size.x), board.width), mini(maxi(1, requested_size.y), board.height))
	var origin: Vector2i = Vector2i(maxi(0, (board.width - area_size.x) / 2), maxi(0, (board.height - area_size.y) / 2))
	for y: int in area_size.y:
		for x: int in area_size.x:
			cells.append(origin + Vector2i(x, y))
	return cells
