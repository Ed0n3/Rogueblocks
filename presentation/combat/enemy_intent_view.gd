class_name EnemyIntentView
extends Control

const COUNTER_BADGE_WIDTH: float = 60.0
const COUNTER_BADGE_HEIGHT: float = 16.0
const COUNTER_BADGE_RIGHT_MARGIN: float = 8.0
const COUNTER_BADGE_TOP_MARGIN: float = 4.0
const COUNTER_BADGE_FONT_SIZE: int = 10
const COUNTER_BADGE_TEXT_BASELINE: float = 12.0
const COUNTER_TITLE_GAP: float = 4.0
const COUNTER_DETAIL_SEPARATOR: String = " · "

## Color used by the compact indicator shown for counterable enemy attacks.
@export var counter_indicator_color: Color = Color("67e8d2")
## Short label used by the counterable attack indicator.
@export var counter_indicator_label: String = "COUNTER"

var intent: ResolvedEnemyIntent
var counter: ActiveCounterState
var pulse_phase: float = 0.0

func display_intent(value: ResolvedEnemyIntent) -> void:
	intent = value
	tooltip_text = _build_tooltip(value)
	set_process(value != null and value.turns_remaining <= 1)
	queue_redraw()

func update_countdown(remaining: int) -> void:
	if intent != null:
		intent.turns_remaining = maxi(0, remaining)
		set_process(intent.turns_remaining <= 1)
		queue_redraw()

func set_counter_state(value: ActiveCounterState) -> void:
	counter = value
	queue_redraw()

func clear_intent() -> void:
	intent = null
	counter = null
	set_process(false)
	queue_redraw()

func _process(delta: float) -> void:
	pulse_phase += delta * 5.0
	queue_redraw()

func _draw() -> void:
	if intent == null:
		return
	var background: Color = Color("0b1225d9")
	var border: Color = intent.accent_color
	draw_style_box(_box(background, border), Rect2(Vector2.ZERO, size))
	_draw_icon(Vector2(18.0, size.y * 0.5), intent.icon_type, border)
	var detail: String = _detail_text()
	var title_width: float = size.x - 44.0
	if _is_counterable():
		var badge_rect: Rect2 = _counter_badge_rect()
		_draw_counter_indicator(badge_rect)
		title_width = maxf(0.0, badge_rect.position.x - 38.0 - COUNTER_TITLE_GAP)
	draw_string(ThemeDB.fallback_font, Vector2(38.0, 19.0), intent.display_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, title_width, 13, Color("e9edfa"))
	draw_string(ThemeDB.fallback_font, Vector2(38.0, 36.0), detail, HORIZONTAL_ALIGNMENT_LEFT, size.x - 44.0, 12, Color("a3acc5"))
	var pip_y: float = size.y - 7.0
	for index: int in maxi(1, intent.turns_remaining):
		var pulse: float = 1.5 * (0.5 + 0.5 * sin(pulse_phase)) if intent.turns_remaining == 1 else 0.0
		draw_circle(Vector2(size.x - 12.0 - float(index) * 12.0, pip_y), 3.0 + pulse, border)

func _detail_text() -> String:
	if _is_counterable():
		return _counter_detail_text()
	if counter != null and not counter.resolved:
		return "%d/%d  %dT%s" % [counter.current_progress, counter.required_progress, counter.turns_remaining, "  |  %d DMG" % intent.direct_damage if intent.direct_damage > 0 else ""]
	if intent.direct_damage > 0:
		var status_suffix: String = " + %s" % intent.applied_statuses[0].display_name.to_upper() if not intent.applied_statuses.is_empty() else ""
		return "%d DAMAGE%s" % [intent.direct_damage, status_suffix]
	if intent.shield_amount > 0:
		return "%d SHIELD" % intent.shield_amount
	if intent.healing_amount > 0:
		return "%d HEAL" % intent.healing_amount
	if not intent.applied_statuses.is_empty():
		var status: StatusDefinition = intent.applied_statuses[0]
		var damage_suffix: String = " | %d/T" % status.tick_amount if status.tick_amount > 0 else ""
		return "%s x1%s" % [status.display_name.to_upper(), damage_suffix]
	if intent.affected_cell_count > 0:
		return "%d CELLS" % intent.affected_cell_count
	return intent.description.to_upper()

func _counter_detail_text() -> String:
	if counter != null and counter.is_completed:
		return "COUNTERED"
	if counter != null and counter.is_failed:
		return "COUNTER FAILED"
	var definition: CounterDefinition = intent.counter_definition
	var current_progress: int = counter.current_progress if counter != null else 0
	var required_progress: int = counter.required_progress if counter != null else maxi(1, definition.required_progress)
	var turns_remaining: int = counter.turns_remaining if counter != null else maxi(1, definition.duration_turns)
	var objective: String = definition.short_intent_description.strip_edges()
	if objective.is_empty():
		objective = _default_counter_objective(definition.counter_type)
	var detail_parts: PackedStringArray = [
		"%s %d/%d" % [objective.to_upper(), current_progress, required_progress],
		"%dT" % turns_remaining,
	]
	if intent.direct_damage > 0:
		detail_parts.append("%d DMG" % intent.direct_damage)
	return COUNTER_DETAIL_SEPARATOR.join(detail_parts)

func _default_counter_objective(counter_type: CounterType.Value) -> String:
	match counter_type:
		CounterType.Value.CLEAR_SPECIFIC_ROW:
			return "CLEAR ROW"
		CounterType.Value.CLEAR_SPECIFIC_COLUMN:
			return "CLEAR COLUMN"
		CounterType.Value.CLEAR_TARGET_AREA:
			return "CLEAR AREA"
		CounterType.Value.FILL_TARGET_AREA:
			return "FILL AREA"
		CounterType.Value.CLEAR_TOTAL_LINES:
			return "CLEAR LINES"
		CounterType.Value.CROSS_CLEAR:
			return "CROSS CLEAR"
		CounterType.Value.DEAL_DAMAGE:
			return "DEAL DMG"
		CounterType.Value.BREAK_SHIELD:
			return "BREAK SHIELD"
		CounterType.Value.CLEAR_SPECIAL_CELLS:
			return "CLEAR MARKS"
		CounterType.Value.USE_COUNTER_ITEM:
			return "USE ITEM"
	return "COMPLETE GOAL"

func _is_counterable() -> bool:
	return intent != null and intent.counter_definition != null

func _counter_badge_rect() -> Rect2:
	return Rect2(
		Vector2(size.x - COUNTER_BADGE_WIDTH - COUNTER_BADGE_RIGHT_MARGIN, COUNTER_BADGE_TOP_MARGIN),
		Vector2(COUNTER_BADGE_WIDTH, COUNTER_BADGE_HEIGHT)
	)

func _draw_counter_indicator(badge_rect: Rect2) -> void:
	draw_style_box(_box(Color(counter_indicator_color, 0.14), counter_indicator_color), badge_rect)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(badge_rect.position.x, badge_rect.position.y + COUNTER_BADGE_TEXT_BASELINE),
		counter_indicator_label,
		HORIZONTAL_ALIGNMENT_CENTER,
		badge_rect.size.x,
		COUNTER_BADGE_FONT_SIZE,
		counter_indicator_color
	)

func _build_tooltip(value: ResolvedEnemyIntent) -> String:
	if value == null:
		return ""
	var attack_description: String = value.description.strip_edges()
	if value.counter_definition == null:
		return attack_description
	var counter_description: String = value.counter_definition.description.strip_edges()
	if counter_description.is_empty():
		return attack_description
	var labeled_counter_description: String = "Counter: %s" % counter_description
	return labeled_counter_description if attack_description.is_empty() else "%s\n%s" % [attack_description, labeled_counter_description]

func _draw_icon(center: Vector2, type: EnemyIntentIcon.Value, color: Color) -> void:
	if type == EnemyIntentIcon.Value.SHIELD:
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -10), center + Vector2(9, -5), center + Vector2(7, 6), center + Vector2(0, 11), center + Vector2(-7, 6), center + Vector2(-9, -5)]), Color(color, 0.35))
	elif type == EnemyIntentIcon.Value.POISON:
		draw_circle(center + Vector2(0, 3), 7.0, Color(color, 0.7))
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -10), center + Vector2(6, 1), center + Vector2(-6, 1)]), color)
	elif type == EnemyIntentIcon.Value.ROW:
		draw_rect(Rect2(center - Vector2(10, 3), Vector2(20, 6)), color)
	elif type == EnemyIntentIcon.Value.COLUMN:
		draw_rect(Rect2(center - Vector2(3, 10), Vector2(6, 20)), color)
	elif type == EnemyIntentIcon.Value.AREA:
		for y: int in 3:
			for x: int in 3:
				draw_rect(Rect2(center + Vector2(float(x - 1) * 7.0 - 2.5, float(y - 1) * 7.0 - 2.5), Vector2(5, 5)), color)
	else:
		draw_colored_polygon(PackedVector2Array([center + Vector2(-9, -7), center + Vector2(9, 0), center + Vector2(-9, 7)]), color)

func _box(background: Color, border: Color) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(7)
	return box
