class_name TwinCoreEffect
extends BossArtifactEffect

@export var placement_interval: int = 4
@export var activation_message: String = "Twin Core is ready for a second placement"

func on_encounter_started(context: ArtifactEffectContext) -> void:
	context.artifact_state.trigger_counter = 0
	context.artifact_state.ready = false

func after_piece_placement(context: ArtifactEffectContext) -> void:
	if context.piece_source_type != PieceSourceType.Value.DRAWN_CARD:
		return
	context.artifact_state.trigger_counter += 1
	if context.artifact_state.trigger_counter >= placement_interval:
		context.artifact_state.trigger_counter = 0
		context.artifact_state.ready = true
		context.activated = true
		context.activation_message = activation_message
