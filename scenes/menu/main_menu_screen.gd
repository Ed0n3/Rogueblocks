class_name MainMenuScreen
extends Control

signal new_run_requested(seed_value: int)
signal hub_requested()
signal settings_requested()
signal test_area_requested()

@export var test_area_requires_debug_build: bool = true

@export_category("Responsive Layout")
@export var compact_breakpoint_width: float = 760.0
@export var compact_edge_margin: float = 16.0
@export var compact_control_height: float = 52.0
@export var compact_title_font_size: int = 48
@export var desktop_title_font_size: int = 72
@export var desktop_composition_size: Vector2 = Vector2(1020.0, 490.0)
@export var desktop_composition_separation: int = 80
@export var compact_composition_separation: int = 12
@export var desktop_logo_width: float = 500.0
@export var desktop_description_width: float = 430.0
@export var desktop_menu_width: float = 370.0

@onready var seed_input: LineEdit = %SeedInput
@onready var composition: GridContainer = %Composition
@onready var logo_area: VBoxContainer = %LogoArea
@onready var title_label: Label = $Composition/LogoArea/Title as Label
@onready var description_label: Label = $Composition/LogoArea/Description as Label
@onready var menu_card: PanelContainer = %MenuCard
@onready var profile_summary: Label = %ProfileSummary
@onready var version_label: Label = $Version as Label

var motion: MotionSettings
var responsive_controls: Array[Control] = []
var desktop_control_minimum_sizes: Array[Vector2] = []

func _ready() -> void:
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	_capture_responsive_controls()
	%NewRunButton.pressed.connect(func() -> void: hub_requested.emit())
	%SeededToggle.pressed.connect(_toggle_seed_area)
	%SeededRunButton.pressed.connect(_start_seeded)
	%TestAreaButton.pressed.connect(func() -> void: test_area_requested.emit())
	%SettingsButton.pressed.connect(func() -> void: settings_requested.emit())
	%QuitButton.pressed.connect(func() -> void: get_tree().quit())
	seed_input.text = str(SaveService.last_used_seed)
	%SeedArea.visible = false
	%TestAreaButton.visible = not test_area_requires_debug_build or OS.is_debug_build()
	%ProfileSummary.text = "%d FRAGMENTS\n%d RUNS  |  %d VICTORIES" % [SaveService.profile.fragments, SaveService.profile.completed_runs, SaveService.profile.victories]
	%NewRunButton.grab_focus()
	resized.connect(_refresh_responsive_layout)
	_refresh_responsive_layout()
	MotionPresets.pop_in(%LogoArea, 0.02, motion)
	MotionPresets.pop_in(%MenuCard, 0.1, motion)

func _toggle_seed_area() -> void:
	if %SeedArea.visible:
		%SeedArea.visible = false
		%SeededToggle.tooltip_text = "Show Seeded Run"
	else:
		%SeedArea.visible = true
		%SeededToggle.tooltip_text = "Hide Seeded Run"
		MotionPresets.pop_in(%SeedArea, 0.0, motion)
		seed_input.grab_focus()

func _start_seeded() -> void:
	var seed_value: int = seed_input.text.to_int()
	new_run_requested.emit(seed_value if seed_value != 0 else 1)

func _capture_responsive_controls() -> void:
	responsive_controls = [
		%NewRunButton as Control,
		%SeededToggle as Control,
		%SeedInput as Control,
		%SeededRunButton as Control,
		%TestAreaButton as Control,
		%SettingsButton as Control,
		%QuitButton as Control,
	]
	desktop_control_minimum_sizes.clear()
	for control: Control in responsive_controls:
		desktop_control_minimum_sizes.append(control.custom_minimum_size)

func _refresh_responsive_layout() -> void:
	if not is_node_ready():
		return
	var compact: bool = size.x <= compact_breakpoint_width
	composition.columns = 1 if compact else 2
	composition.add_theme_constant_override(&"h_separation", 0 if compact else desktop_composition_separation)
	composition.add_theme_constant_override(&"v_separation", compact_composition_separation if compact else 0)
	var composition_size: Vector2 = Vector2(maxf(0.0, size.x - compact_edge_margin * 2.0), maxf(0.0, size.y - compact_edge_margin * 2.0)) if compact else desktop_composition_size
	_set_centered_offsets(composition, composition_size)
	logo_area.custom_minimum_size.x = 0.0 if compact else desktop_logo_width
	description_label.custom_minimum_size.x = 0.0 if compact else desktop_description_width
	menu_card.custom_minimum_size.x = 0.0 if compact else desktop_menu_width
	title_label.add_theme_font_size_override(&"font_size", compact_title_font_size if compact else desktop_title_font_size)
	profile_summary.visible = not compact
	version_label.visible = not compact
	for index: int in responsive_controls.size():
		var control: Control = responsive_controls[index]
		var desktop_size: Vector2 = desktop_control_minimum_sizes[index]
		control.custom_minimum_size = Vector2(desktop_size.x, maxf(desktop_size.y, compact_control_height)) if compact else desktop_size

func _set_centered_offsets(control: Control, target_size: Vector2) -> void:
	control.offset_left = -target_size.x * 0.5
	control.offset_top = -target_size.y * 0.5
	control.offset_right = target_size.x * 0.5
	control.offset_bottom = target_size.y * 0.5
