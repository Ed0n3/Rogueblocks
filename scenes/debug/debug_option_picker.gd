class_name DebugOptionPicker
extends Control

signal choice_selected(index: int)
signal closed()

@export var choice_button_scene: PackedScene = preload("res://scenes/debug/debug_option_choice_button.tscn") as PackedScene
@export var empty_icon: Texture2D = preload("res://assets/icons/empty_texture.tres") as Texture2D
@export var compact_breakpoint_width: float = 760.0
@export var short_viewport_breakpoint_height: float = 600.0
@export_range(1, 4, 1) var desktop_columns: int = 2
@export_range(1, 4, 1) var compact_columns: int = 1
@export_range(1, 24, 1) var desktop_page_size: int = 12
@export_range(1, 24, 1) var compact_page_size: int = 7
@export_range(1, 8, 1) var short_viewport_rows: int = 3
@export var desktop_panel_width: float = 680.0

var choices: Array[DebugOptionChoice] = []
var choice_buttons: Array[DebugOptionChoiceButton] = []
var selected_index: int = -1
var page_index: int = 0
var restore_focus: Control

func _ready() -> void:
	%Backdrop.pressed.connect(close_picker)
	%Close.pressed.connect(close_picker)
	%Previous.pressed.connect(_show_previous_page)
	%Next.pressed.connect(_show_next_page)
	resized.connect(_apply_responsive_layout)
	visible = false

func open_picker(title: String, options: Array[DebugOptionChoice], current_index: int) -> void:
	var current_focus: Control = get_viewport().gui_get_focus_owner()
	if current_focus != null and not is_ancestor_of(current_focus):
		restore_focus = current_focus
	choices.assign(options)
	selected_index = current_index
	page_index = maxi(0, floori(float(selected_index) / float(_page_size()))) if selected_index >= 0 else 0
	%Title.text = title
	visible = true
	move_to_front()
	_apply_responsive_layout()

func close_picker() -> void:
	if not visible:
		return
	visible = false
	if is_instance_valid(restore_focus) and restore_focus.is_visible_in_tree():
		restore_focus.grab_focus()
	restore_focus = null
	closed.emit()

func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return
	var compact: bool = _is_compact_width()
	%PickerPanel.custom_minimum_size.x = 0.0 if compact else desktop_panel_width
	%Choices.columns = _column_count()
	if visible:
		page_index = clampi(page_index, 0, maxi(0, _page_count() - 1))
		_rebuild_choices()

func _rebuild_choices() -> void:
	if not is_node_ready():
		return
	for child: Node in %Choices.get_children():
		%Choices.remove_child(child)
		child.queue_free()
	choice_buttons.clear()
	var page_size: int = _page_size()
	var first_index: int = page_index * page_size
	var end_index: int = mini(choices.size(), first_index + page_size)
	for index: int in range(first_index, end_index):
		var button: DebugOptionChoiceButton = choice_button_scene.instantiate() as DebugOptionChoiceButton
		%Choices.add_child(button)
		button.configure(index, choices[index], index == selected_index, empty_icon)
		button.choice_requested.connect(_select_choice)
		choice_buttons.append(button)
	var page_count: int = _page_count()
	%Page.text = "%d / %d" % [page_index + 1, maxi(1, page_count)]
	%Previous.disabled = page_index <= 0
	%Next.disabled = page_index >= page_count - 1
	_configure_focus_loop()
	_focus_initial_choice.call_deferred()

func _select_choice(index: int) -> void:
	if index < 0 or index >= choices.size():
		return
	choice_selected.emit(index)
	close_picker()

func _show_previous_page() -> void:
	if page_index <= 0:
		return
	page_index -= 1
	_rebuild_choices()

func _show_next_page() -> void:
	if page_index >= _page_count() - 1:
		return
	page_index += 1
	_rebuild_choices()

func _page_size() -> int:
	var configured_page_size: int = compact_page_size if _is_compact_width() else desktop_page_size
	if size.y < short_viewport_breakpoint_height:
		return mini(configured_page_size, _column_count() * short_viewport_rows)
	return configured_page_size

func _page_count() -> int:
	var page_size: int = _page_size()
	return maxi(1, ceili(float(choices.size()) / float(page_size)))

func _column_count() -> int:
	return compact_columns if _is_compact_width() else desktop_columns

func _is_compact_width() -> bool:
	return size.x < compact_breakpoint_width

func _configure_focus_loop() -> void:
	var controls: Array[Control] = [%Close as Control]
	for button: DebugOptionChoiceButton in choice_buttons:
		controls.append(button)
	if not %Previous.disabled:
		controls.append(%Previous as Control)
	if not %Next.disabled:
		controls.append(%Next as Control)
	for index: int in controls.size():
		var previous: Control = controls[posmod(index - 1, controls.size())]
		var next: Control = controls[(index + 1) % controls.size()]
		var control: Control = controls[index]
		control.focus_previous = control.get_path_to(previous)
		control.focus_neighbor_top = control.get_path_to(previous)
		control.focus_neighbor_left = control.get_path_to(previous)
		control.focus_next = control.get_path_to(next)
		control.focus_neighbor_bottom = control.get_path_to(next)
		control.focus_neighbor_right = control.get_path_to(next)

func _focus_initial_choice() -> void:
	if not visible:
		return
	for button: DebugOptionChoiceButton in choice_buttons:
		if button.choice_index == selected_index:
			button.grab_focus()
			return
	if not choice_buttons.is_empty():
		choice_buttons.front().grab_focus()
	else:
		%Close.grab_focus()
