class_name StatusStripView
extends Control

signal details_requested(definition: StatusDefinition, instance: StatusInstance, shield: int)

const STATUS_CARD: PackedScene = preload("res://presentation/combat/status_effect_card.tscn")

@export var slot_width: float = 52.0
@export var touch_hold_duration: float = 0.55

var statuses: StatusCollection = StatusCollection.new()
var shield_value: int = 0
var hovered_index: int = -1
var touch_index: int = -1
var touch_started_msec: int = 0
var hold_opened: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(true)

func set_effects(collection: StatusCollection, shield: int = 0) -> void:
	statuses = collection if collection != null else StatusCollection.new()
	shield_value = maxi(0, shield)
	hovered_index = -1
	tooltip_text = _all_tooltip()
	queue_redraw()

func dominant_color() -> Color:
	var selected_priority: int = -2147483648
	var selected_color: Color = Color("7ee7d8")
	for instance: StatusInstance in statuses.instances:
		var definition: StatusDefinition = instance.definition
		if definition == null or not definition.visible_to_player:
			continue
		var priority: int = definition.visual_definition.priority if definition.visual_definition != null else 0
		if priority > selected_priority:
			selected_priority = priority
			selected_color = definition.visual_definition.primary_color if definition.visual_definition != null else definition.accent_color
	if selected_priority == -2147483648 and shield_value > 0:
		return Color("56d8ff")
	return selected_color

func has_visible_effects() -> bool:
	if shield_value > 0:
		return true
	for instance: StatusInstance in statuses.instances:
		var definition: StatusDefinition = instance.definition
		if definition != null and definition.visible_to_player:
			return true
	return false

func _process(_delta: float) -> void:
	if touch_index >= 0 and not hold_opened and float(Time.get_ticks_msec() - touch_started_msec) / 1000.0 >= touch_hold_duration:
		hold_opened = true
		_show_details(touch_index)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		hovered_index = _effect_index_at(motion.position)
		tooltip_text = _tooltip_at(hovered_index)
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			touch_index = _effect_index_at(touch.position)
			touch_started_msec = Time.get_ticks_msec()
			hold_opened = false
		else:
			touch_index = -1
	accept_event()

func _make_custom_tooltip(for_text: String) -> Object:
	var card: PanelContainer = STATUS_CARD.instantiate() as PanelContainer
	var effect_index: int = hovered_index
	if effect_index < 0:
		effect_index = 0
	_configure_card(card, effect_index)
	return card

func _draw() -> void:
	var draw_index: int = 0
	if shield_value > 0:
		_draw_icon(Vector2(18.0, 20.0), StatusIconType.Value.SHIELD, Color("56d8ff"))
		_draw_counts(draw_index, "%d" % shield_value, "SH")
		draw_index += 1
	for instance: StatusInstance in _visible_instances():
		var definition: StatusDefinition = instance.definition
		if definition == null or not definition.visible_to_player:
			continue
		var origin: Vector2 = Vector2(float(draw_index) * slot_width, 0.0)
		_draw_icon(origin + Vector2(18.0, 20.0), definition.icon_type, definition.accent_color)
		_draw_counts(draw_index, "x%d" % instance.stacks, "%dT" % instance.remaining_turns)
		draw_index += 1

func _draw_counts(index: int, top: String, bottom: String) -> void:
	var origin_x: float = float(index) * slot_width
	draw_string(ThemeDB.fallback_font, Vector2(origin_x + 30.0, 18.0), top, HORIZONTAL_ALIGNMENT_LEFT, 21.0, 11, Color("e9edfa"))
	draw_string(ThemeDB.fallback_font, Vector2(origin_x + 30.0, 33.0), bottom, HORIZONTAL_ALIGNMENT_LEFT, 21.0, 10, Color("a3acc5"))

func _draw_icon(center: Vector2, type: StatusIconType.Value, color: Color) -> void:
	if type == StatusIconType.Value.FLAME or type == StatusIconType.Value.FLAME_UP:
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -13), center + Vector2(10, 3), center + Vector2(4, 12), center + Vector2(-8, 8), center + Vector2(-10, 0)]), color)
	elif type == StatusIconType.Value.DROP or type == StatusIconType.Value.TOXIC_BUBBLE:
		draw_circle(center + Vector2(0, 3), 10.0, Color(color, 0.8))
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -13), center + Vector2(8, 2), center + Vector2(-8, 2)]), color)
	elif type == StatusIconType.Value.SHIELD:
		draw_colored_polygon(PackedVector2Array([center + Vector2(0, -12), center + Vector2(10, -5), center + Vector2(7, 8), center + Vector2(0, 13), center + Vector2(-7, 8), center + Vector2(-10, -5)]), Color(color, 0.8))
	elif type == StatusIconType.Value.PLUS:
		draw_rect(Rect2(center - Vector2(3, 12), Vector2(6, 24)), color)
		draw_rect(Rect2(center - Vector2(12, 3), Vector2(24, 6)), color)
	elif type == StatusIconType.Value.BOLT:
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(2, -14),
			center + Vector2(-8, 1),
			center + Vector2(-1, 1),
			center + Vector2(-4, 14),
			center + Vector2(9, -4),
			center + Vector2(2, -4),
		]), color)
	elif type == StatusIconType.Value.BROKEN_SWORD:
		draw_line(center + Vector2(-8, 10), center + Vector2(-1, 3), color, 4.0, true)
		draw_line(center + Vector2(2, 0), center + Vector2(9, -10), color, 4.0, true)
		draw_line(center + Vector2(-6, -7), center + Vector2(8, 7), color, 3.0, true)
	elif type == StatusIconType.Value.HAND:
		draw_rect(Rect2(center + Vector2(-8, -2), Vector2(16, 13)), Color(color, 0.8))
		for finger_index: int in 4:
			draw_rect(Rect2(center + Vector2(-8 + finger_index * 5, -11), Vector2(3, 11)), color)
	elif type == StatusIconType.Value.SPIKES:
		for spike_index: int in 3:
			var spike_x: float = float(spike_index - 1) * 8.0
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(spike_x - 5.0, 10.0),
				center + Vector2(spike_x, -11.0),
				center + Vector2(spike_x + 5.0, 10.0),
			]), Color(color, 0.8))
	else:
		draw_circle(center, 10.0, Color(color, 0.8))
		draw_line(center + Vector2(-5, 0), center + Vector2(5, 0), Color("08101f"), 2.0)

func _effect_index_at(position: Vector2) -> int:
	var index: int = floori(position.x / slot_width)
	var effect_count: int = _visible_instances().size() + (1 if shield_value > 0 else 0)
	return index if index >= 0 and index < effect_count else -1

func _show_details(index: int) -> void:
	if index < 0:
		return
	if shield_value > 0:
		if index == 0:
			details_requested.emit(null, null, shield_value)
			return
		index -= 1
	var visible_instances: Array[StatusInstance] = _visible_instances()
	if index < 0 or index >= visible_instances.size():
		return
	var instance: StatusInstance = visible_instances[index]
	var definition: StatusDefinition = instance.definition
	if definition != null:
		details_requested.emit(definition, instance, 0)

func _configure_card(card: PanelContainer, index: int) -> void:
	if shield_value > 0:
		if index == 0:
			card.call("show_shield", shield_value)
			return
		index -= 1
	var visible_instances: Array[StatusInstance] = _visible_instances()
	if index < 0 or index >= visible_instances.size():
		return
	var instance: StatusInstance = visible_instances[index]
	var definition: StatusDefinition = instance.definition
	if definition != null:
		card.call("show_effect", definition, instance)

func _tooltip_at(index: int) -> String:
	if index < 0:
		return _all_tooltip()
	if shield_value > 0:
		if index == 0:
			return "Shield %d\nAbsorbs incoming damage before health." % shield_value
		index -= 1
	var visible_instances: Array[StatusInstance] = _visible_instances()
	if index < 0 or index >= visible_instances.size():
		return _all_tooltip()
	var instance: StatusInstance = visible_instances[index]
	var definition: StatusDefinition = instance.definition
	return "%s x%d | %d turn(s)\n%s" % [definition.display_name, instance.stacks, instance.remaining_turns, definition.description] if definition != null else ""

func _all_tooltip() -> String:
	var values: PackedStringArray = []
	if shield_value > 0:
		values.append("Shield %d\nAbsorbs incoming damage before health." % shield_value)
	for instance: StatusInstance in statuses.instances:
		var definition: StatusDefinition = instance.definition
		if definition != null and definition.visible_to_player:
			values.append("%s x%d | %d turn(s)\n%s" % [definition.display_name, instance.stacks, instance.remaining_turns, definition.description])
	return "\n\n".join(values)

func _visible_instances() -> Array[StatusInstance]:
	var visible_instances: Array[StatusInstance] = []
	for instance: StatusInstance in statuses.instances:
		var definition: StatusDefinition = instance.definition
		if definition != null and definition.visible_to_player:
			visible_instances.append(instance)
	return visible_instances
