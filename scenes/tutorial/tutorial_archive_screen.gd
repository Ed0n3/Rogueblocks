class_name TutorialArchiveScreen
extends Control

const TutorialArchiveCategory = preload("res://scenes/tutorial/tutorial_archive_category.gd")
const CATEGORY_SCENE: PackedScene = preload("res://scenes/tutorial/tutorial_archive_category.tscn")

signal back_requested()
signal replay_requested(tutorial: TutorialDefinition)

@export var touch_scroll_threshold: float = 12.0

var scroll_touch_index: int = -1
var scroll_touch_start: Vector2
var scroll_touch_vertical: bool = false

func _ready() -> void:
	%Back.pressed.connect(func() -> void: back_requested.emit())
	%Reset.pressed.connect(_reset_progress)
	_build_archive()

func _build_archive() -> void:
	for child: Node in %Lessons.get_children():
		child.queue_free()
	var categories: Array[TutorialCategory.Value] = []
	for tutorial: TutorialDefinition in ContentRegistry.tutorials:
		if not categories.has(tutorial.category):
			categories.append(tutorial.category)
	categories.sort()
	for category: TutorialCategory.Value in categories:
		var category_view: TutorialArchiveCategory = CATEGORY_SCENE.instantiate() as TutorialArchiveCategory
		%Lessons.add_child(category_view)
		category_view.configure(category)
		category_view.replay_requested.connect(func(definition: TutorialDefinition) -> void: replay_requested.emit(definition))
		for tutorial: TutorialDefinition in ContentRegistry.tutorials:
			if tutorial.category == category:
				category_view.add_tutorial(tutorial, SaveService.profile.tutorial_progress)
	var progress: TutorialProgress = SaveService.profile.tutorial_progress
	%Summary.text = "%d / %d completed  |  %d skipped" % [progress.completed_tutorials.size(), ContentRegistry.tutorials.size(), progress.skipped_tutorials.size()]

func _reset_progress() -> void:
	TutorialService.reset_progress()
	%Feedback.text = "Tutorial progress reset. Run progression was not changed."
	_build_archive()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var scroll: ScrollContainer = %Scroll
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed and scroll.get_global_rect().has_point(touch.position):
			scroll_touch_index = touch.index
			scroll_touch_start = touch.position
			scroll_touch_vertical = false
		elif not touch.pressed and touch.index == scroll_touch_index:
			scroll_touch_index = -1
	elif event is InputEventScreenDrag:
		var drag: InputEventScreenDrag = event as InputEventScreenDrag
		if drag.index != scroll_touch_index:
			return
		var movement: Vector2 = drag.position - scroll_touch_start
		if not scroll_touch_vertical and movement.length() >= touch_scroll_threshold:
			scroll_touch_vertical = absf(movement.y) > absf(movement.x)
		if scroll_touch_vertical:
			scroll.scroll_vertical -= roundi(drag.relative.y)
			get_viewport().set_input_as_handled()
