class_name MomentumLatticeEffect
extends BossArtifactEffect

@export var activation_message: String = "Momentum Lattice preserved the combo"

func on_encounter_started(context: ArtifactEffectContext) -> void:
	context.artifact_state.ready = false

func modify_combo_resolution(context: ArtifactEffectContext) -> void:
	if context.clear_result.line_count > 0:
		context.artifact_state.ready = true
		return
	if context.combo_level <= 0 or not context.artifact_state.ready:
		return
	context.artifact_state.ready = false
	context.preserve_combo = true
	context.activated = true
	context.activation_message = activation_message
