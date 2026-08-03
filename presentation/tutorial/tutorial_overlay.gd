class_name TutorialOverlay
extends CanvasLayer

@export var desktop_panel_width: float = 680.0
@export var mobile_panel_width: float = 520.0
@export var desktop_hint_width: float = 416.0
@export var mobile_hint_width: float = 360.0
@export var mobile_side_margin: float = 24.0

@onready var root: Control = %Root
@onready var spotlight: TutorialSpotlight = %Spotlight
@onready var pointer: TutorialPointer = %Pointer
@onready var blocker: TutorialInputBlocker = %InputBlocker
@onready var message_panel: PanelContainer = %MessagePanel
@onready var hint: TutorialHintToast = %HintToast
@onready var hint_layer: MarginContainer = %HintLayer
@onready var actions: BoxContainer = %Actions

var active_target: TutorialTarget
var active_step: TutorialStepDefinition
var layout_refresh_pending: bool = false
var suspended: bool = false
var fixed_target_rectangle: Rect2

func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	TutorialService.step_changed.connect(_show_step)
	TutorialService.tutorial_ended.connect(_hide_tutorial)
	TutorialService.hint_requested.connect(_show_hint)
	TutorialService.hints_cleared.connect(hint.hide_hint)
	TutorialService.presentation_action_requested.connect(_apply_presentation_action)
	TutorialTargetRegistry.targets_changed.connect(_refresh_target)
	%Continue.pressed.connect(TutorialService.confirm_current_step)
	%Skip.pressed.connect(TutorialService.skip_active)
	var interactive_controls: Array[BaseButton] = [%Skip as BaseButton, %Continue as BaseButton]
	blocker.set_interactive_controls(interactive_controls)
	hint.dismissed.connect(TutorialService.dismiss_hint)
	get_viewport().size_changed.connect(_refresh_layout)
	if TutorialService.active_definition != null and TutorialService.current_step() != null:
		_show_step(TutorialService.active_definition, TutorialService.current_step(), TutorialService.runtime.step_index)

func _process(_delta: float) -> void:
	if not root.visible or active_step == null:
		return
	_refresh_target()

func _show_step(definition: TutorialDefinition, step: TutorialStepDefinition, index: int) -> void:
	blocker.reset_pointer_capture()
	active_step = step
	active_target = step.target
	fixed_target_rectangle = Rect2()
	root.visible = not suspended
	%Title.text = step.title
	%Body.text = TutorialInputFormatter.format_text(step.body)
	%Speaker.text = step.speaker_name
	%Speaker.visible = not step.speaker_name.is_empty()
	%StepText.text = "%d / %d" % [index + 1, definition.steps.size()]
	%Progress.setup(index, definition.steps.size())
	var requires_confirmation: bool = TutorialService.step_requires_confirmation(step)
	%Continue.visible = requires_confirmation
	%Continue.disabled = not requires_confirmation
	%Skip.visible = definition.steps.size() > 1 and definition.can_skip and step.skippable
	var passive: bool = step.input_mode == TutorialInputMode.Value.NORMAL_WITH_HINT
	message_panel.visible = not passive
	spotlight.visible = not passive and step.target != null
	pointer.visible = not passive and step.target != null
	blocker.visible = definition.blocks_gameplay and not passive
	spotlight.high_contrast = SaveService.settings.tutorial_high_contrast
	pointer.reduced_motion = SaveService.settings.reduced_motion
	var large_text: bool = SaveService.settings.tutorial_large_text
	%Title.add_theme_font_size_override("font_size", 30 if large_text else 24)
	%Body.add_theme_font_size_override("font_size", 21 if large_text else 17)
	_refresh_layout()
	_queue_layout_refresh()

func _hide_tutorial(_definition: TutorialDefinition, _completed: bool) -> void:
	blocker.reset_pointer_capture()
	root.visible = false
	active_step = null
	active_target = null

func set_suspended(value: bool) -> void:
	suspended = value
	if suspended:
		blocker.reset_pointer_capture()
	root.visible = not suspended and active_step != null
	TutorialService.set_suspended(value)

func _refresh_target() -> void:
	if active_step == null:
		spotlight.set_target(Rect2())
		pointer.set_target(Rect2())
		blocker.target_rect = Rect2()
		blocker.set_additional_target_rects([])
		return
	blocker.set_additional_target_rects(_resolve_additional_input_rects(active_step))
	if active_target == null:
		spotlight.set_target(Rect2())
		pointer.set_target(Rect2())
		blocker.target_rect = Rect2()
		_position_message(Rect2())
		return
	var rectangle: Rect2 = fixed_target_rectangle if fixed_target_rectangle.size.x > 0.0 else TutorialTargetRegistry.resolve_rect(active_target)
	if not active_target.follow_target and fixed_target_rectangle.size.x <= 0.0:
		fixed_target_rectangle = rectangle
	spotlight.set_target(rectangle)
	pointer.set_target(rectangle)
	blocker.target_rect = rectangle
	_position_message(rectangle)

func _resolve_additional_input_rects(step: TutorialStepDefinition) -> Array[Rect2]:
	var rectangles: Array[Rect2] = []
	for target: TutorialTarget in step.additional_input_targets:
		if target != null:
			rectangles.append(TutorialTargetRegistry.resolve_rect(target))
	return rectangles

func _position_message(target: Rect2) -> void:
	if active_step == null:
		return
	var panel_size: Vector2 = message_panel.size
	var viewport_size: Vector2 = root.size
	var position: Vector2 = Vector2((viewport_size.x - panel_size.x) * 0.5, viewport_size.y - panel_size.y - 28.0)
	match active_step.message_position:
		TutorialMessagePosition.Value.TOP:
			position.y = 24.0
		TutorialMessagePosition.Value.LEFT:
			position = Vector2(24.0, (viewport_size.y - panel_size.y) * 0.5)
		TutorialMessagePosition.Value.RIGHT:
			position = Vector2(viewport_size.x - panel_size.x - 24.0, (viewport_size.y - panel_size.y) * 0.5)
		TutorialMessagePosition.Value.CENTER:
			position = (viewport_size - panel_size) * 0.5
		TutorialMessagePosition.Value.AUTO:
			if target.get_center().y > viewport_size.y * 0.58:
				position.y = 24.0
	position.x = clampf(position.x, 16.0, maxf(16.0, viewport_size.x - panel_size.x - 16.0))
	position.y = clampf(position.y, 16.0, maxf(16.0, viewport_size.y - panel_size.y - 16.0))
	message_panel.position = position

func _refresh_layout() -> void:
	if not is_node_ready():
		return
	if root.size.x <= mobile_side_margin * 2.0 or root.size.y <= 1.0:
		_queue_layout_refresh()
		return
	var mobile: bool = OS.has_feature("mobile") or root.size.x < 900.0
	var large_text: bool = SaveService.settings.tutorial_large_text
	var panel_width: float = get_panel_width(root.size.x, mobile)
	var panel_height: float = 280.0 if large_text else 240.0
	actions.vertical = mobile
	message_panel.custom_minimum_size = Vector2(panel_width, panel_height)
	message_panel.size = Vector2(panel_width, panel_height)
	var hint_width: float = get_hint_width(root.size.x, mobile)
	hint.custom_minimum_size.x = hint_width
	hint_layer.offset_left = -hint_width - mobile_side_margin
	hint_layer.offset_right = -mobile_side_margin
	if active_step != null:
		_refresh_target()

func _queue_layout_refresh() -> void:
	if layout_refresh_pending:
		return
	layout_refresh_pending = true
	call_deferred("_run_queued_layout_refresh")

func _run_queued_layout_refresh() -> void:
	layout_refresh_pending = false
	_refresh_layout()

func get_panel_width(viewport_width: float, mobile: bool) -> float:
	var maximum_width: float = mobile_panel_width if mobile else desktop_panel_width
	return minf(maxf(1.0, viewport_width - mobile_side_margin * 2.0), maximum_width)

func get_hint_width(viewport_width: float, mobile: bool) -> float:
	var maximum_width: float = mobile_hint_width if mobile else desktop_hint_width
	return minf(maxf(1.0, viewport_width - mobile_side_margin * 2.0), maximum_width)

func _show_hint(definition: TutorialDefinition, title: String, body: String, accent: Color, duration: float) -> void:
	if not SaveService.profile.tutorial_progress.hints_enabled:
		return
	hint.show_hint(definition, title, TutorialInputFormatter.format_text(body), accent, duration)

func _apply_presentation_action(action: TutorialPresentationAction) -> void:
	match action.command:
		TutorialPresentationAction.Command.HIDE_SPOTLIGHT:
			spotlight.visible = false
		TutorialPresentationAction.Command.SHOW_SPOTLIGHT:
			spotlight.visible = true
		TutorialPresentationAction.Command.HIDE_POINTER:
			pointer.visible = false
		TutorialPresentationAction.Command.SHOW_POINTER:
			pointer.visible = true
		TutorialPresentationAction.Command.HIGHLIGHT_CELLS:
			spotlight.visible = true
			pointer.visible = true
		TutorialPresentationAction.Command.CLEAR_HIGHLIGHTS:
			active_target = null
			fixed_target_rectangle = Rect2()
			_refresh_target()
	if action.target != null:
		active_target = action.target
		fixed_target_rectangle = Rect2()
