class_name StatusEffectInfoOverlay
extends Control

var captured_touch_index: int = -1

func _ready() -> void:
	%Close.pressed.connect(hide)
	%Shade.gui_input.connect(_on_shade_input)

func show_effect(definition: StatusDefinition, instance: StatusInstance) -> void:
	%Card.call("show_effect", definition, instance)
	show()

func show_shield(value: int) -> void:
	%Card.call("show_shield", value)
	show()

func capture_modal_touch(event: InputEvent) -> bool:
	var touch: InputEventScreenTouch = event as InputEventScreenTouch
	if touch != null:
		if visible:
			if touch.pressed:
				captured_touch_index = touch.index
				hide()
			return true
		if touch.index != captured_touch_index:
			return false
		if not touch.pressed:
			captured_touch_index = -1
		return true
	var drag: InputEventScreenDrag = event as InputEventScreenDrag
	if drag != null:
		return visible or drag.index == captured_touch_index
	return false

func _on_shade_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		hide()
	elif event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		hide()
