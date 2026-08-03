class_name ArtifactCombatBadge
extends Button

const ARCHITECT_HAND: BossArtifactDefinition = preload("res://content/artifacts/architect_hand.tres")
const TWIN_CORE: BossArtifactDefinition = preload("res://content/artifacts/twin_core.tres")
const VAULT_SHAPES: BossArtifactDefinition = preload("res://content/artifacts/vault_shapes.tres")
const INFINITE_MOLD: BossArtifactDefinition = preload("res://content/artifacts/infinite_mold.tres")
const MOMENTUM_LATTICE: BossArtifactDefinition = preload("res://content/artifacts/momentum_lattice.tres")

var artifact_state: BossArtifactState
var definition: BossArtifactDefinition

func setup(state: BossArtifactState, artifact: BossArtifactDefinition) -> void:
	artifact_state = state
	definition = artifact
	%ArtifactIcon.setup(definition)
	%Counter.text = _counter_text()
	tooltip_text = "%s\n\n%s\n\nRisk: %s\n%s" % [definition.display_name, definition.benefit, definition.drawback, _counter_text()]

func _counter_text() -> String:
	if artifact_state.definition == ARCHITECT_HAND:
		return "%d/3" % artifact_state.trigger_counter
	if artifact_state.definition == TWIN_CORE:
		return "READY" if artifact_state.ready else "%d/4" % artifact_state.trigger_counter
	if artifact_state.definition == VAULT_SHAPES:
		return "STORED %d" % artifact_state.stored_cards.size() if not artifact_state.stored_cards.is_empty() else "EMPTY"
	if artifact_state.definition == INFINITE_MOLD:
		return "%d/3" % artifact_state.repeat_count
	if artifact_state.definition == MOMENTUM_LATTICE:
		return "GRACE" if artifact_state.ready else "SPENT"
	return "ACTIVE"
