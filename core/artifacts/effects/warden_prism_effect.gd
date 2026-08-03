class_name WardenPrismEffect
extends BossArtifactEffect

@export var additional_draws: int = 1

func modify_draw_count(context: ArtifactEffectContext) -> void:
	context.draw_count += additional_draws
