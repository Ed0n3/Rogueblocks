class_name BossArtifactDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export_multiline var benefit: String
@export_multiline var drawback: String
@export var boss_pool: Array[EnemyDefinition] = []
@export var effects: Array[BossArtifactEffect] = []
@export var incompatible_artifacts: Array[BossArtifactDefinition] = []
@export var accent_color: Color = Color("77e4ef")

func is_valid() -> bool:
	return not display_name.is_empty() and not benefit.is_empty()
