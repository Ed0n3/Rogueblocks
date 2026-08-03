class_name SettingsScreen
extends Control

signal back_requested()
signal new_game_requested()

@export var desktop_panel_size: Vector2 = Vector2(860, 640)
@export var mobile_breakpoint_width: float = 900.0
@export var mobile_edge_margin: float = 12.0
@export var mobile_control_height: float = 56.0
@export var mobile_slider_height: float = 52.0
@export var mobile_font_size: int = 22
@export var touch_direction_threshold: float = 12.0
@export var mobile_column_count: int = 2
@export var desktop_column_count: int = 2

var slider_touch: HSlider
var slider_touch_index: int = -1
var slider_touch_start: Vector2
var slider_touch_horizontal: bool = false
var scroll_touch_index: int = -1
var scroll_touch_start: Vector2
var scroll_touch_vertical: bool = false

func _ready() -> void:
	%Master.value = SaveService.settings.master_volume
	%Music.value = SaveService.settings.music_volume
	%Effects.value = SaveService.settings.effects_volume
	%Fullscreen.button_pressed = SaveService.settings.fullscreen
	%ScreenShake.button_pressed = SaveService.settings.screen_shake
	%ReducedMotion.button_pressed = SaveService.settings.reduced_motion
	%Flashes.button_pressed = SaveService.settings.flashes_enabled
	%ParticleDensity.value = SaveService.settings.particle_density
	%AnimationSpeed.value = SaveService.settings.combat_animation_speed
	%LargerText.button_pressed = SaveService.settings.larger_combat_text
	%TutorialsEnabled.button_pressed = SaveService.profile.tutorial_progress.tutorials_enabled
	%ContextualTips.button_pressed = SaveService.profile.tutorial_progress.contextual_tips_enabled
	%HintsEnabled.button_pressed = SaveService.profile.tutorial_progress.hints_enabled
	%TutorialManualAdvance.button_pressed = SaveService.settings.tutorial_manual_advance
	%TutorialLargeText.button_pressed = SaveService.settings.tutorial_large_text
	%TutorialHighContrast.button_pressed = SaveService.settings.tutorial_high_contrast
	%TutorialDuration.value = SaveService.settings.tutorial_message_duration
	%Master.value_changed.connect(_set_master_volume)
	%Music.value_changed.connect(_set_music_volume)
	%Effects.value_changed.connect(_set_effects_volume)
	%Fullscreen.toggled.connect(_set_fullscreen)
	%ScreenShake.toggled.connect(_set_screen_shake)
	%ReducedMotion.toggled.connect(_set_reduced_motion)
	%Flashes.toggled.connect(_set_flashes_enabled)
	%ParticleDensity.value_changed.connect(_set_particle_density)
	%AnimationSpeed.value_changed.connect(_set_combat_animation_speed)
	%LargerText.toggled.connect(_set_larger_combat_text)
	%TutorialsEnabled.toggled.connect(TutorialService.set_tutorials_enabled)
	%ContextualTips.toggled.connect(TutorialService.set_contextual_tips_enabled)
	%HintsEnabled.toggled.connect(TutorialService.set_hints_enabled)
	%TutorialManualAdvance.toggled.connect(_set_tutorial_manual_advance)
	%TutorialLargeText.toggled.connect(_set_tutorial_large_text)
	%TutorialHighContrast.toggled.connect(_set_tutorial_high_contrast)
	%TutorialDuration.value_changed.connect(_set_tutorial_message_duration)
	%ResetTutorials.pressed.connect(_reset_tutorials)
	%ReplayBasics.pressed.connect(_replay_basics_next_run)
	%NewGame.pressed.connect(func() -> void: %ConfirmNewGame.popup_centered())
	%ConfirmNewGame.confirmed.connect(func() -> void: new_game_requested.emit())
	%Back.pressed.connect(func() -> void: back_requested.emit())
	for slider: HSlider in _get_sliders():
		slider.gui_input.connect(func(event: InputEvent) -> void: _handle_slider_touch(slider, event))
	resized.connect(_refresh_responsive_layout)
	call_deferred("_refresh_responsive_layout")

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var scroll: ScrollContainer = $Center/Panel/Layout/Scroll as ScrollContainer
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and scroll.get_global_rect().has_point(touch.position):
			scroll_touch_index = touch.index
			scroll_touch_start = touch.position
			scroll_touch_vertical = false
		elif not touch.pressed and touch.index == scroll_touch_index:
			if scroll_touch_vertical:
				get_viewport().set_input_as_handled()
			_clear_scroll_touch()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != scroll_touch_index:
			return
		var movement: Vector2 = drag.position - scroll_touch_start
		if not scroll_touch_vertical and movement.length() >= touch_direction_threshold:
			if absf(movement.y) <= absf(movement.x):
				_clear_scroll_touch()
				return
			scroll_touch_vertical = true
			_clear_slider_touch()
		if scroll_touch_vertical:
			scroll.scroll_vertical -= roundi(drag.relative.y)
			get_viewport().set_input_as_handled()

func _clear_scroll_touch() -> void:
	scroll_touch_index = -1
	scroll_touch_vertical = false

func _get_sliders() -> Array[HSlider]:
	var sliders: Array[HSlider] = []
	for slider: HSlider in [%Master, %Music, %Effects, %ParticleDensity, %AnimationSpeed, %TutorialDuration]:
		sliders.append(slider)
	return sliders

func _handle_slider_touch(slider: HSlider, event: InputEvent) -> void:
	if not slider.editable:
		return
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			slider_touch = slider
			slider_touch_index = touch.index
			slider_touch_start = touch.position
			slider_touch_horizontal = false
		elif slider_touch == slider and touch.index == slider_touch_index:
			var movement: Vector2 = touch.position - slider_touch_start
			if slider_touch_horizontal or movement.length() < touch_direction_threshold:
				_set_slider_value_from_touch(slider, touch.position.x)
				slider.accept_event()
			_clear_slider_touch()
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if slider_touch != slider or drag.index != slider_touch_index:
			return
		var movement: Vector2 = drag.position - slider_touch_start
		if not slider_touch_horizontal and movement.length() >= touch_direction_threshold:
			if absf(movement.y) > absf(movement.x):
				_clear_slider_touch()
				return
			slider_touch_horizontal = true
		if slider_touch_horizontal:
			_set_slider_value_from_touch(slider, drag.position.x)
			slider.accept_event()

func _set_slider_value_from_touch(slider: HSlider, horizontal_position: float) -> void:
	if slider.size.x <= 0.0:
		return
	var ratio: float = clampf(horizontal_position / slider.size.x, 0.0, 1.0)
	slider.value = lerpf(slider.min_value, slider.max_value, ratio)

func _clear_slider_touch() -> void:
	slider_touch = null
	slider_touch_index = -1
	slider_touch_horizontal = false

func _refresh_responsive_layout() -> void:
	var mobile_layout: bool = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() or size.x <= mobile_breakpoint_width and size.y > size.x
	_apply_mobile_layout(mobile_layout)

func _apply_mobile_layout(enabled: bool) -> void:
	var panel: PanelContainer = $Center/Panel as PanelContainer
	var columns: GridContainer = %Columns as GridContainer
	columns.columns = maxi(1, mobile_column_count if enabled else desktop_column_count)
	panel.custom_minimum_size = Vector2(maxf(size.x - mobile_edge_margin * 2.0, 0.0), maxf(size.y - mobile_edge_margin * 2.0, 0.0)) if enabled else desktop_panel_size
	for control: Control in _get_resizable_controls($Center/Panel/Layout):
		if enabled:
			if control is BaseButton:
				control.custom_minimum_size.y = mobile_control_height
			if control is HSlider:
				control.custom_minimum_size.y = mobile_slider_height
			if control is Label or control is BaseButton:
				control.add_theme_font_size_override("font_size", maxi(control.get_theme_font_size("font_size"), mobile_font_size))
		else:
			control.custom_minimum_size.y = 0.0
			control.remove_theme_font_size_override("font_size")

func _get_resizable_controls(root: Node) -> Array[Control]:
	var controls: Array[Control] = []
	for child: Node in root.get_children():
		if child is Control:
			controls.append(child as Control)
		controls.append_array(_get_resizable_controls(child))
	return controls

func _set_master_volume(value: float) -> void:
	SaveService.settings.master_volume = value
	AudioService.set_volume(&"Master", value)
	SaveService.save_settings()

func _set_music_volume(value: float) -> void:
	SaveService.settings.music_volume = value
	AudioService.set_volume(&"Music", value)
	SaveService.save_settings()

func _set_effects_volume(value: float) -> void:
	SaveService.settings.effects_volume = value
	AudioService.set_volume(&"Effects", value)
	SaveService.save_settings()

func _set_fullscreen(value: bool) -> void:
	SaveService.settings.fullscreen = value
	SaveService.save_settings()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)

func _set_screen_shake(value: bool) -> void:
	SaveService.settings.screen_shake = value
	SaveService.save_settings()

func _set_reduced_motion(value: bool) -> void:
	SaveService.settings.reduced_motion = value
	SaveService.save_settings()

func _set_flashes_enabled(value: bool) -> void:
	SaveService.settings.flashes_enabled = value
	SaveService.save_settings()

func _set_particle_density(value: float) -> void:
	SaveService.settings.particle_density = value
	SaveService.save_settings()

func _set_combat_animation_speed(value: float) -> void:
	SaveService.settings.combat_animation_speed = value
	SaveService.save_settings()

func _set_larger_combat_text(value: bool) -> void:
	SaveService.settings.larger_combat_text = value
	SaveService.save_settings()

func _set_tutorial_manual_advance(value: bool) -> void:
	SaveService.settings.tutorial_manual_advance = value
	SaveService.save_settings()

func _set_tutorial_large_text(value: bool) -> void:
	SaveService.settings.tutorial_large_text = value
	SaveService.save_settings()

func _set_tutorial_high_contrast(value: bool) -> void:
	SaveService.settings.tutorial_high_contrast = value
	SaveService.save_settings()

func _set_tutorial_message_duration(value: float) -> void:
	SaveService.settings.tutorial_message_duration = value
	SaveService.save_settings()

func _reset_tutorials() -> void:
	TutorialService.reset_progress()
	%TutorialFeedback.text = "Tutorial progress reset."

func _replay_basics_next_run() -> void:
	var guided_onboarding: TutorialDefinition = preload("res://content/tutorials/onboarding/guided_onboarding.tres")
	SaveService.profile.tutorial_progress.completed_tutorials.erase(guided_onboarding)
	SaveService.profile.tutorial_progress.skipped_tutorials.erase(guided_onboarding)
	SaveService.profile.tutorial_progress.tutorials_enabled = true
	SaveService.save_profile()
	%TutorialFeedback.text = "Guided onboarding will start before the next new run."
