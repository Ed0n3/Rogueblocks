class_name ArtifactCombatStrip
extends HBoxContainer

const BADGE_SCENE: PackedScene = preload("res://presentation/artifacts/artifact_combat_badge.tscn")

var run_state: RunState
var badges: Array[ArtifactCombatBadge] = []

func setup(run: RunState) -> void:
	run_state = run
	_refresh_badges()

func refresh() -> void:
	for badge: ArtifactCombatBadge in badges:
		badge.setup(badge.artifact_state, badge.definition)

func pulse(artifact: BossArtifactDefinition, motion: MotionSettings) -> void:
	for badge: ArtifactCombatBadge in badges:
		if badge.artifact_state.definition == artifact:
			MotionPresets.pulse(badge, 1.08, motion)
			return

func _refresh_badges() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	badges.clear()
	for state: BossArtifactState in run_state.artifacts:
		var definition: BossArtifactDefinition = state.definition
		if definition == null:
			continue
		var badge: ArtifactCombatBadge = BADGE_SCENE.instantiate() as ArtifactCombatBadge
		add_child(badge)
		badge.setup(state, definition)
		badges.append(badge)
	visible = not badges.is_empty()
