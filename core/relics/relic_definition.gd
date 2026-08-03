class_name RelicDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var consumable: bool = false
@export var repeatable: bool = false
@export var effect: RelicEffect
@export var initially_unlocked: bool = true
@export var trigger_priority: int = 0
@export var trigger_effect: RelicTriggerEffect
@export var elite_defeat_reward_only: bool = false
@export var required_artifacts: Array[BossArtifactDefinition] = []
@export var default_acquisition_source: String = "Encounter reward"

func apply(run_state: RunState, source_description: String = String()) -> void:
	var resolved_source_description: String = source_description if not source_description.is_empty() else default_acquisition_source
	if not consumable:
		run_state.add_relic(self, resolved_source_description)
	if effect != null:
		effect.apply(run_state, self)
