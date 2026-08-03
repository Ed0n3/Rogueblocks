class_name TimekeeperGearEffect
extends BossArtifactEffect

@export var pause_minimum_lines: int = 2
@export var paused_countdown_step: int = 0
@export var accelerated_countdown_step: int = 2
@export var paused_message: String = "Timekeeper's Gear paused the enemy countdown"
@export var accelerated_message: String = "Timekeeper's Gear accelerated the enemy countdown"

func modify_enemy_countdown(context: ArtifactEffectContext) -> void:
	if context.clear_result != null and context.clear_result.line_count >= pause_minimum_lines:
		context.countdown_step = paused_countdown_step
		context.activated = true
		context.activation_message = paused_message
	elif context.clear_result == null or context.clear_result.line_count == 0:
		context.countdown_step = accelerated_countdown_step
		context.activated = true
		context.activation_message = accelerated_message
