class_name TutorialHintToast
extends PanelContainer

signal dismissed(tutorial: TutorialDefinition)

var active_tween: Tween
var tutorial: TutorialDefinition

func _ready() -> void:
	%Dismiss.pressed.connect(_dismiss)

func show_hint(definition: TutorialDefinition, title: String, body: String, accent: Color, duration: float) -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	tutorial = definition
	%Title.text = title
	%Body.text = body
	%Accent.color = accent
	visible = true
	modulate.a = 0.0
	position.x = 18.0
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate:a", 1.0, 0.16)
	active_tween.parallel().tween_property(self, "position:x", 0.0, 0.16)
	if duration > 0.0:
		active_tween.tween_interval(duration)
		active_tween.tween_property(self, "modulate:a", 0.0, 0.2)
		active_tween.tween_callback(func() -> void: visible = false)

func hide_hint() -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	visible = false

func _dismiss() -> void:
	var dismissed_tutorial: TutorialDefinition = tutorial
	hide_hint()
	dismissed.emit(dismissed_tutorial)
