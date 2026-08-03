class_name BoardSwipeGesture
extends RefCounted

const DEFAULT_MINIMUM_DISTANCE: float = 48.0

var minimum_distance: float
var active: bool = false
var touch_index: int = -1
var start_position: Vector2
var current_position: Vector2

func _init(swipe_minimum_distance: float = DEFAULT_MINIMUM_DISTANCE) -> void:
	minimum_distance = swipe_minimum_distance

func begin(index: int, position: Vector2, enabled: bool) -> bool:
	reset()
	if not enabled:
		return false
	active = true
	touch_index = index
	start_position = position
	current_position = position
	return true

func update(index: int, position: Vector2) -> bool:
	if not active or index != touch_index:
		return false
	current_position = position
	return true

func finish(index: int, position: Vector2) -> bool:
	if not active or index != touch_index:
		return false
	current_position = position
	var completed: bool = current_position.distance_to(start_position) >= minimum_distance
	reset()
	return completed

func cancel_on_release(event: InputEvent) -> void:
	var touch: InputEventScreenTouch = event as InputEventScreenTouch
	if touch != null and not touch.pressed and touch.index == touch_index:
		reset()

func reset() -> void:
	active = false
	touch_index = -1
