class_name TutorialInputBlocker
extends Control

var target_rect: Rect2
var additional_target_rects: Array[Rect2] = []
var interactive_controls: Array[BaseButton] = []
var blocked_touch_indices: Array[int] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or TutorialService.active_definition == null:
		return
	if capture_pointer_event(event):
		get_viewport().set_input_as_handled()
		return
	var mode: TutorialInputMode.Value = TutorialService.allowed_input_mode()
	if mode == TutorialInputMode.Value.NONE or mode == TutorialInputMode.Value.NORMAL_GAMEPLAY or mode == TutorialInputMode.Value.NORMAL_WITH_HINT:
		return
	for action: StringName in InputMap.get_actions():
		if event.is_action(action) and TutorialService.is_action_allowed(action):
			return
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()

func set_interactive_controls(controls: Array[BaseButton]) -> void:
	interactive_controls.assign(controls)

func set_additional_target_rects(rectangles: Array[Rect2]) -> void:
	additional_target_rects.assign(rectangles)

func interactive_button_at(position: Vector2) -> BaseButton:
	for button: BaseButton in interactive_controls:
		if is_instance_valid(button) and button.is_visible_in_tree() and not button.disabled and button.get_global_rect().has_point(position):
			return button
	return null

func capture_pointer_event(event: InputEvent) -> bool:
	if not is_visible_in_tree() or TutorialService.active_definition == null:
		return false
	var mode: TutorialInputMode.Value = TutorialService.allowed_input_mode()
	if mode == TutorialInputMode.Value.NONE or mode == TutorialInputMode.Value.NORMAL_GAMEPLAY or mode == TutorialInputMode.Value.NORMAL_WITH_HINT:
		return false
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			if is_pointer_allowed(touch.position, mode):
				return false
			if not blocked_touch_indices.has(touch.index):
				blocked_touch_indices.append(touch.index)
			return true
		if blocked_touch_indices.has(touch.index):
			blocked_touch_indices.erase(touch.index)
			return true
		return false
	if event is InputEventScreenDrag:
		return blocked_touch_indices.has((event as InputEventScreenDrag).index)
	if event is InputEventMouse:
		return not is_pointer_allowed((event as InputEventMouse).position, mode)
	return false

func reset_pointer_capture() -> void:
	blocked_touch_indices.clear()

func is_pointer_allowed(position: Vector2, mode: TutorialInputMode.Value) -> bool:
	if _is_system_navigation_position(position):
		return true
	if interactive_button_at(position) != null:
		return true
	if mode == TutorialInputMode.Value.TARGET_ONLY or mode == TutorialInputMode.Value.ACTIONS_ONLY:
		if target_rect.has_point(position):
			return true
		for rectangle: Rect2 in additional_target_rects:
			if rectangle.has_point(position):
				return true
		return false
	return mode == TutorialInputMode.Value.NONE or mode == TutorialInputMode.Value.NORMAL_GAMEPLAY or mode == TutorialInputMode.Value.NORMAL_WITH_HINT

func _is_system_navigation_position(position: Vector2) -> bool:
	for node: Node in get_tree().get_nodes_in_group(&"tutorial_input_passthrough"):
		var control: Control = node as Control
		if control != null and control.is_visible_in_tree() and control.get_global_rect().has_point(position):
			return true
	return false
