class_name PiecePoolView
extends Control

const CARD_SCENE: PackedScene = preload("res://ui/piece_pool_card.tscn")

var entries: Array[PiecePoolEntry] = []

func setup(pool_entries: Array[PiecePoolEntry]) -> void:
	entries = pool_entries
	_refresh()

func _refresh() -> void:
	for child: Node in %PieceGrid.get_children():
		%PieceGrid.remove_child(child)
		child.queue_free()
	for entry: PiecePoolEntry in entries:
		var card: PiecePoolCard = CARD_SCENE.instantiate() as PiecePoolCard
		%PieceGrid.add_child(card)
		card.setup(entry)
		if entry.is_new:
			MotionPresets.pop_in(card, 0.0, MotionSettings.from_saved_settings(SaveService.settings))
	_update_columns()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_columns()

func _update_columns() -> void:
	if not is_node_ready():
		return
	%PieceGrid.columns = maxi(1, floori(maxf(1.0, size.x - 20.0) / 150.0))
