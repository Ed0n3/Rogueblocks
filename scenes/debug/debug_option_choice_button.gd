class_name DebugOptionChoiceButton
extends Button

signal choice_requested(index: int)

var choice_index: int = -1

func _ready() -> void:
	pressed.connect(func() -> void: choice_requested.emit(choice_index))

func configure(index: int, choice: DebugOptionChoice, selected: bool, empty_icon: Texture2D) -> void:
	choice_index = index
	text = choice.title
	icon = choice.icon if choice.icon != null else empty_icon
	tooltip_text = choice.description
	theme_type_variation = &"PrimaryButton" if selected else &"SecondaryButton"
