class_name RunTutorialEventAdapter
extends RefCounted

var run_state: RunState
var controller: EncounterController
var known_player_statuses: Array[StatusDefinition] = []
var known_enemy_statuses: Array[StatusDefinition] = []
var previous_enemy_health: int = -1
var previous_enemy_shield: int = 0
var previous_draw_pile_size: int = -1
var previous_discard_pile_size: int = -1
var previous_hand_card_ids: Array[int] = []

func setup(current_run: RunState, encounter_controller: EncounterController, board_view: BoardView) -> void:
	run_state = current_run
	controller = encounter_controller
	controller.hand_changed.connect(_on_hand_changed)
	controller.piece_placed.connect(_on_piece_placed)
	controller.lines_cleared.connect(_on_lines_cleared)
	controller.enemy_damaged.connect(_on_enemy_damaged)
	controller.enemy_attacked.connect(_on_enemy_attacked)
	controller.counter_changed.connect(_on_counter_changed)
	controller.intent_changed.connect(_on_intent_changed)
	controller.item_used.connect(_on_item_used)
	controller.status_changed.connect(publish_status_changes)
	board_view.invalid_placement_attempted.connect(func() -> void: TutorialService.publish(TutorialEventId.Value.INVALID_PLACEMENT_ATTEMPTED))

func publish_inventory_events() -> void:
	var has_item: bool = false
	var has_bonus_block: bool = false
	for stack: ItemStack in run_state.inventory.slots:
		if stack == null or stack.quantity <= 0:
			continue
		var definition: ItemDefinition = stack.definition
		if definition == null:
			continue
		has_item = true
		has_bonus_block = has_bonus_block or definition.category == ItemCategory.Value.BONUS_BLOCK
	if has_item:
		TutorialService.publish(TutorialEventId.Value.ITEM_INVENTORY_VISIBLE)
	if has_bonus_block:
		TutorialService.publish(TutorialEventId.Value.BONUS_BLOCK_INVENTORY_VISIBLE)

func publish_piece_rotated(piece: PieceInstance, clockwise: bool) -> void:
	if piece == null:
		return
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.PIECE_ROTATED)
	event.piece = piece.definition
	event.bool_value = clockwise
	TutorialService.publish_event(event)

func publish_piece_selected(piece: PieceInstance, choice_index: int) -> void:
	if piece == null:
		return
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.PIECE_SELECTED)
	event.piece = piece.definition
	event.int_value = choice_index
	TutorialService.publish_event(event)

func publish_preview_state(valid: bool) -> void:
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.PLACEMENT_PREVIEW_CHANGED)
	event.bool_value = valid
	TutorialService.publish_event(event)

func publish_status_changes() -> void:
	if controller == null or controller.effect_state == null or controller.enemy == null:
		return
	if previous_enemy_health >= 0 and controller.enemy_health > previous_enemy_health:
		TutorialService.publish(TutorialEventId.Value.ENEMY_HEALED, controller.enemy_health - previous_enemy_health, controller.enemy)
	previous_enemy_health = controller.enemy_health
	var shield: int = controller.effect_state.enemy_shield
	if shield > previous_enemy_shield:
		TutorialService.publish(TutorialEventId.Value.ENEMY_SHIELD_GAINED, shield - previous_enemy_shield, controller.enemy)
	previous_enemy_shield = shield
	_publish_new_statuses(run_state.player_statuses, EffectTarget.Value.PLAYER, known_player_statuses)
	_publish_new_statuses(controller.effect_state.enemy_statuses, EffectTarget.Value.ENEMY, known_enemy_statuses)

func _on_hand_changed(cards: Array[PieceCardState], _placeable: Array[bool]) -> void:
	var hand_card_ids: Array[int] = []
	var drawn_card_count: int = 0
	for card: PieceCardState in cards:
		hand_card_ids.append(card.card_id)
		if not previous_hand_card_ids.has(card.card_id):
			drawn_card_count += 1
	if drawn_card_count > 0:
		TutorialService.publish(TutorialEventId.Value.PIECE_CHOICES_GENERATED, cards.size())
		var hand_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.HAND_DRAWN)
		hand_event.int_value = drawn_card_count
		hand_event.secondary_int_value = cards.size()
		TutorialService.publish_event(hand_event)
	previous_hand_card_ids.assign(hand_card_ids)
	_publish_pile_changes()

func _on_piece_placed(result: PlacementResult) -> void:
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.PIECE_PLACED)
	event.piece = result.piece
	event.cells = result.placed_cells.duplicate()
	TutorialService.publish_event.call_deferred(event)

func _publish_pile_changes() -> void:
	if controller.deck_state == null:
		return
	var draw_pile_size: int = controller.deck_state.draw_pile.size()
	var discard_pile_size: int = controller.deck_state.discard_pile.size()
	if previous_draw_pile_size >= 0 and previous_draw_pile_size != draw_pile_size:
		var draw_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.DRAW_PILE_CHANGED)
		draw_event.int_value = draw_pile_size
		draw_event.secondary_int_value = previous_draw_pile_size
		TutorialService.publish_event(draw_event)
	if previous_discard_pile_size >= 0 and previous_discard_pile_size != discard_pile_size:
		var discard_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.DISCARD_PILE_CHANGED)
		discard_event.int_value = discard_pile_size
		discard_event.secondary_int_value = maxi(0, discard_pile_size - maxi(0, previous_discard_pile_size))
		TutorialService.publish_event(discard_event)
		if discard_pile_size > maxi(0, previous_discard_pile_size):
			var legacy_event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.DISCARD_PIECE_ADDED)
			legacy_event.int_value = discard_pile_size
			legacy_event.secondary_int_value = discard_event.secondary_int_value
			TutorialService.publish_event(legacy_event)
	previous_draw_pile_size = draw_pile_size
	previous_discard_pile_size = discard_pile_size

func _on_lines_cleared(result: ClearResult) -> void:
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.LINES_CLEARED)
	event.int_value = result.line_count
	event.secondary_int_value = result.cleared_cell_count
	event.bool_value = result.cross_clear
	event.cells = result.cleared_cells.duplicate()
	TutorialService.publish_event(event)
	if result.cross_clear:
		TutorialService.publish(TutorialEventId.Value.CROSS_CLEAR_COMPLETED, result.line_count)
	if result.perfect_clear:
		TutorialService.publish(TutorialEventId.Value.PERFECT_CLEAR_COMPLETED, result.line_count)

func _on_enemy_damaged(result: DamageResult) -> void:
	var source: Resource = result.sources[0] if not result.sources.is_empty() else null
	TutorialService.publish(TutorialEventId.Value.ENEMY_DAMAGED, result.health_damage + result.shield_damage, source)

func _on_enemy_attacked(damage: int, blockers: Array[Vector2i]) -> void:
	TutorialService.publish(TutorialEventId.Value.ENEMY_ATTACKED, damage, controller.enemy)
	if not blockers.is_empty():
		TutorialService.publish(TutorialEventId.Value.BLOCKERS_PLACED, blockers.size(), controller.enemy)
	if damage > 0:
		TutorialService.publish(TutorialEventId.Value.PLAYER_DAMAGED, damage, controller.enemy)

func _on_counter_changed(counter: ActiveCounterState, definition: CounterDefinition) -> void:
	if counter == null:
		return
	var event_type: TutorialEventId.Value = TutorialEventId.Value.COUNTER_STARTED
	if counter.is_completed:
		event_type = TutorialEventId.Value.COUNTER_COMPLETED
	elif counter.is_failed:
		event_type = TutorialEventId.Value.COUNTER_FAILED
	elif counter.current_progress > 0:
		event_type = TutorialEventId.Value.COUNTER_PROGRESSED
	TutorialService.publish(event_type, counter.current_progress, definition)

func _on_intent_changed(intent: ResolvedEnemyIntent) -> void:
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.ENEMY_INTENT_CHANGED)
	event.source = intent.action if intent != null else null
	event.int_value = intent.turns_remaining if intent != null else 0
	TutorialService.publish_event(event)

func _on_item_used(result: ItemUseResult, slot_index: int) -> void:
	var event: TutorialEvent = TutorialEvent.new(TutorialEventId.Value.ITEM_USED)
	event.int_value = slot_index
	event.bool_value = result.used
	TutorialService.publish_event(event)

func _publish_new_statuses(collection: StatusCollection, target: EffectTarget.Value, known_statuses: Array[StatusDefinition]) -> void:
	var current_statuses: Array[StatusDefinition] = []
	for instance: StatusInstance in collection.instances:
		if not current_statuses.has(instance.definition):
			current_statuses.append(instance.definition)
		if known_statuses.has(instance.definition):
			continue
		var event: TutorialEvent = _status_event(TutorialEventId.Value.STATUS_APPLIED, instance, target)
		TutorialService.publish_event(event)
		var definition: StatusDefinition = instance.definition
		if definition != null and definition.tags.has(&"damage_over_time"):
			TutorialService.publish_event(_status_event(TutorialEventId.Value.DAMAGE_OVER_TIME_APPLIED, instance, target))
	known_statuses.clear()
	known_statuses.append_array(current_statuses)

func _status_event(event_type: TutorialEventId.Value, instance: StatusInstance, target: EffectTarget.Value) -> TutorialEvent:
	var event: TutorialEvent = TutorialEvent.new(event_type)
	event.status = instance.definition
	event.target = target
	event.int_value = instance.stacks
	return event
