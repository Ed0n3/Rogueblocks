class_name RelicCollectionView
extends Control

const CARD_SCENE: PackedScene = preload("res://ui/owned_relic_card.tscn")

var relics: Array[OwnedRelicState] = []

func setup(owned_relics: Array[OwnedRelicState]) -> void:
	relics = owned_relics
	_refresh()

func _refresh() -> void:
	for child: Node in %RelicGrid.get_children():
		%RelicGrid.remove_child(child)
		child.queue_free()
	%EmptyState.visible = relics.is_empty()
	for state: OwnedRelicState in relics:
		var card: OwnedRelicCard = CARD_SCENE.instantiate() as OwnedRelicCard
		%RelicGrid.add_child(card)
		card.setup(state)
		if state.is_new:
			MotionPresets.pop_in(card, 0.0, MotionSettings.from_saved_settings(SaveService.settings))
	_update_columns()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_columns()

func _update_columns() -> void:
	if not is_node_ready():
		return
	%RelicGrid.columns = maxi(1, floori(maxf(1.0, size.x - 20.0) / 232.0))
