class_name RunLoadoutDrawer
extends PanelContainer

enum Tab { PIECES, RELICS, ARTIFACTS }

@export var touch_scroll_direction_threshold: float = 12.0
@export var compact_width_breakpoint: float = 640.0

var run_state: RunState
var active_tab: Tab = Tab.PIECES
var motion: MotionSettings
var transition: Tween
var scroll_touch_index: int = -1
var scroll_touch_start: Vector2
var scroll_touch_vertical: bool = false

func _ready() -> void:
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	%PieceTab.pressed.connect(func() -> void: open_tab(Tab.PIECES))
	%RelicTab.pressed.connect(func() -> void: open_tab(Tab.RELICS))
	%ArtifactTab.pressed.connect(func() -> void: open_tab(Tab.ARTIFACTS))
	%Close.pressed.connect(close)
	resized.connect(_refresh_responsive_layout)
	_refresh_responsive_layout()
	visible = false

func setup(current_run: RunState) -> void:
	run_state = current_run
	if not run_state.piece_pool_changed.is_connected(_refresh):
		run_state.piece_pool_changed.connect(_refresh)
	if not run_state.relics_changed.is_connected(_refresh):
		run_state.relics_changed.connect(_refresh)
	if not run_state.run_modifiers_changed.is_connected(_refresh):
		run_state.run_modifiers_changed.connect(_refresh)
	if not run_state.artifacts_changed.is_connected(_refresh):
		run_state.artifacts_changed.connect(_refresh)
	_refresh()

func open_tab(tab: Tab) -> void:
	if visible and active_tab == tab:
		close()
		return
	var previous_view: Control = _active_view()
	active_tab = tab
	_refresh()
	if visible:
		_switch_tab(previous_view)
	else:
		_show_active_tab()
		_open()
	get_tree().create_timer(motion.duration(0.35)).timeout.connect(func() -> void: _mark_tab_viewed(tab))

func _switch_tab(previous_view: Control) -> void:
	if transition != null and transition.is_valid():
		transition.kill()
	transition = create_tween()
	transition.tween_property(previous_view, "modulate:a", 0.0, motion.duration(0.06))
	transition.tween_callback(_prepare_active_tab)
	transition.tween_property(_active_view(), "modulate:a", 1.0, motion.duration(0.06))

func _prepare_active_tab() -> void:
	_show_active_tab()
	_active_view().modulate.a = 0.0

func _show_active_tab() -> void:
	_clear_scroll_touch()
	%PiecePoolView.visible = active_tab == Tab.PIECES
	%RelicCollectionView.visible = active_tab == Tab.RELICS
	%ArtifactCollectionView.visible = active_tab == Tab.ARTIFACTS
	%PiecePoolView.modulate.a = 1.0 if active_tab == Tab.PIECES else 0.0
	%RelicCollectionView.modulate.a = 1.0 if active_tab == Tab.RELICS else 0.0
	%ArtifactCollectionView.modulate.a = 1.0 if active_tab == Tab.ARTIFACTS else 0.0
	%PieceTab.theme_type_variation = &"PrimaryButton" if active_tab == Tab.PIECES else &"SecondaryButton"
	%RelicTab.theme_type_variation = &"PrimaryButton" if active_tab == Tab.RELICS else &"SecondaryButton"
	%ArtifactTab.theme_type_variation = &"PrimaryButton" if active_tab == Tab.ARTIFACTS else &"SecondaryButton"

func _active_view() -> Control:
	if active_tab == Tab.PIECES:
		return %PiecePoolView
	return %RelicCollectionView if active_tab == Tab.RELICS else %ArtifactCollectionView

func close() -> void:
	if not visible:
		return
	_clear_scroll_touch()
	if transition != null and transition.is_valid():
		transition.kill()
	transition = create_tween()
	transition.tween_property(self, "modulate:a", 0.0, motion.duration(0.12))
	transition.tween_callback(func() -> void: visible = false)

func _open() -> void:
	visible = true
	modulate.a = 0.0
	var resting_position: Vector2 = position
	position = resting_position - Vector2(0.0, 8.0 if not motion.reduced_motion else 0.0)
	if transition != null and transition.is_valid():
		transition.kill()
	transition = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	transition.tween_property(self, "modulate:a", 1.0, motion.duration(0.18))
	transition.tween_property(self, "position", resting_position, motion.duration(0.18))

func _refresh() -> void:
	if run_state == null:
		return
	%PiecePoolView.setup(run_state.get_current_piece_pool())
	%RelicCollectionView.setup(run_state.get_owned_relics())
	%ArtifactCollectionView.setup(run_state)

func _mark_tab_viewed(tab: Tab) -> void:
	if run_state == null:
		return
	if tab == Tab.PIECES:
		run_state.mark_pieces_viewed()
	elif tab == Tab.RELICS:
		run_state.mark_relics_viewed()
	else:
		run_state.mark_artifacts_viewed()

func _input(event: InputEvent) -> void:
	if not visible or not is_visible_in_tree():
		return
	var scroll: ScrollContainer = _active_scroll()
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
		if not scroll_touch_vertical and movement.length() >= touch_scroll_direction_threshold:
			if absf(movement.y) <= absf(movement.x):
				_clear_scroll_touch()
				return
			scroll_touch_vertical = true
		if scroll_touch_vertical:
			scroll.scroll_vertical -= roundi(drag.relative.y)
			get_viewport().set_input_as_handled()

func _active_scroll() -> ScrollContainer:
	if active_tab == Tab.PIECES:
		return %PiecePoolView.get_node("PiecePoolScroll") as ScrollContainer
	return %RelicCollectionView.get_node("RelicCollectionScroll") as ScrollContainer if active_tab == Tab.RELICS else %ArtifactCollectionView.get_node("ArtifactCollectionScroll") as ScrollContainer

func _clear_scroll_touch() -> void:
	scroll_touch_index = -1
	scroll_touch_vertical = false

func _refresh_responsive_layout() -> void:
	var parent_control: Control = get_parent() as Control
	var available_width: float = parent_control.size.x if parent_control != null and parent_control.size.x > 0.0 else size.x
	var compact: bool = available_width < compact_width_breakpoint
	($Layout/Header/Title as Label).visible = not compact
	%PieceTab.custom_minimum_size.x = 72.0 if compact else 120.0
	%RelicTab.custom_minimum_size.x = 72.0 if compact else 120.0
	%ArtifactTab.custom_minimum_size.x = 72.0 if compact else 120.0
	%Close.custom_minimum_size.x = 52.0 if compact else 80.0

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
