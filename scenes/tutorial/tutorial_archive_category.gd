class_name TutorialArchiveCategory
extends VBoxContainer

const TutorialArchiveCard = preload("res://scenes/tutorial/tutorial_archive_card.gd")
const CARD_SCENE: PackedScene = preload("res://scenes/tutorial/tutorial_archive_card.tscn")

signal replay_requested(tutorial: TutorialDefinition)

@export var single_column_breakpoint: float = 820.0

@onready var grid: GridContainer = %Grid

func _ready() -> void:
	resized.connect(_update_columns)
	_update_columns()

func configure(category: TutorialCategory.Value) -> void:
	%Heading.text = TutorialCategory.display_name(category).to_upper()

func add_tutorial(tutorial: TutorialDefinition, progress: TutorialProgress) -> void:
	var card: TutorialArchiveCard = CARD_SCENE.instantiate() as TutorialArchiveCard
	grid.add_child(card)
	card.configure(tutorial, progress)
	card.replay_requested.connect(func(definition: TutorialDefinition) -> void: replay_requested.emit(definition))

func _update_columns() -> void:
	grid.columns = 1 if size.x > 0.0 and size.x < single_column_breakpoint else 2
