class_name ArtifactCollectionView
extends Control

const CARD_SCENE: PackedScene = preload("res://presentation/artifacts/owned_artifact_card.tscn")

func setup(run_state: RunState) -> void:
	for child: Node in %ArtifactGrid.get_children():
		%ArtifactGrid.remove_child(child)
		child.queue_free()
	%EmptyState.visible = run_state.artifacts.is_empty()
	for state: BossArtifactState in run_state.artifacts:
		var definition: BossArtifactDefinition = state.definition
		if definition == null:
			continue
		var card: OwnedArtifactCard = CARD_SCENE.instantiate() as OwnedArtifactCard
		%ArtifactGrid.add_child(card)
		card.setup(state, definition, run_state.unviewed_artifacts.has(state.definition))
	_update_columns()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_columns()

func _update_columns() -> void:
	if is_node_ready():
		%ArtifactGrid.columns = maxi(1, floori(maxf(1.0, size.x - 20.0) / 260.0))
