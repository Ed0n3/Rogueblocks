class_name EventScreen
extends Control

signal event_resolved()

const CONTENT_CARD_SCENE: PackedScene = preload("res://presentation/cards/content_card.tscn")

var run_state: RunState
var event: RunEventDefinition
var rng: RandomNumberGenerator

func start(current_run: RunState, definition: RunEventDefinition, run_rng: RandomNumberGenerator) -> void:
	run_state = current_run
	event = definition
	rng = run_rng
	var service: EventService = EventService.new()
	%Title.text = event.title
	%Description.text = event.description
	for choice: EventChoiceDefinition in event.choices:
		var button: ContentCard = CONTENT_CARD_SCENE.instantiate() as ContentCard
		button.card_kind = ContentCard.CardKind.EVENT_CHOICE
		button.text = "%s\n%s" % [choice.choice_text, choice.result_preview]
		button.disabled = not service.can_apply_choice(choice, run_state, rng)
		button.pressed.connect(_choose.bind(choice))
		%Choices.add_child(button)

func _choose(choice: EventChoiceDefinition) -> void:
	if EventService.new().apply_choice(choice, run_state, rng):
		event_resolved.emit()
