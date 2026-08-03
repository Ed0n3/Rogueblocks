class_name EnemyPhaseDefinition
extends Resource

@export_range(0.0, 1.0) var health_threshold_percent: float = 1.0
@export var attack_interval: int = 4
@export var action_pattern: Array[EnemyActionDefinition] = []
@export var phase_start_actions: Array[EnemyActionDefinition] = []
@export var display_name_suffix: String = ""
