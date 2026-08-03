class_name OwnedArtifactCard
extends Button

const ARCHITECT_HAND: BossArtifactDefinition = preload("res://content/artifacts/architect_hand.tres")
const TWIN_CORE: BossArtifactDefinition = preload("res://content/artifacts/twin_core.tres")
const VAULT_SHAPES: BossArtifactDefinition = preload("res://content/artifacts/vault_shapes.tres")
const INFINITE_MOLD: BossArtifactDefinition = preload("res://content/artifacts/infinite_mold.tres")

var definition: BossArtifactDefinition
var artifact_state: BossArtifactState

func setup(state: BossArtifactState, artifact: BossArtifactDefinition, is_new: bool) -> void:
	artifact_state = state
	definition = artifact
	%ArtifactIcon.setup(definition)
	%Name.text = definition.display_name
	%Effect.text = definition.benefit
	%State.text = _state_text()
	%New.visible = is_new
	tooltip_text = "%s\n\n%s\n\nRisk: %s\n\nObtained after Act %d\n%s" % [definition.display_name, definition.benefit, definition.drawback, artifact_state.obtained_act + 1, _state_text()]
	queue_redraw()

func _state_text() -> String:
	if artifact_state.definition == ARCHITECT_HAND:
		return "%d / 3 placements" % artifact_state.trigger_counter
	if artifact_state.definition == TWIN_CORE:
		return "READY" if artifact_state.ready else "%d / 4 placements" % artifact_state.trigger_counter
	if artifact_state.definition == VAULT_SHAPES:
		var stored_names: PackedStringArray = []
		for card: PieceCardState in artifact_state.stored_cards:
			if card == null or card.piece == null:
				continue
			var effect_name: String = card.intrinsic_effect.display_name if card.intrinsic_effect != null else "Filler"
			stored_names.append("%s [%s]" % [card.piece.display_name, effect_name])
		return "Stored: %s" % (", ".join(stored_names) if not stored_names.is_empty() else "Empty")
	if artifact_state.definition == INFINITE_MOLD:
		return "%d / 3 repeats" % artifact_state.repeat_count
	return "ACTIVE"

func _draw() -> void:
	if definition != null:
		draw_line(Vector2(8.0, 5.0), Vector2(size.x - 8.0, 5.0), definition.accent_color, 2.0, true)
