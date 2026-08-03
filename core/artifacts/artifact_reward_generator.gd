class_name ArtifactRewardGenerator
extends RefCounted

func generate(run_state: RunState, boss: EnemyDefinition, act: int, count: int = 3) -> Array[BossArtifactDefinition]:
	var pool: Array[BossArtifactDefinition] = []
	for definition: BossArtifactDefinition in ContentRegistry.artifacts:
		if run_state.get_artifact_state(definition) != null:
			continue
		if not definition.boss_pool.is_empty() and not definition.boss_pool.has(boss):
			continue
		if _conflicts_with_owned(definition, run_state):
			continue
		pool.append(definition)
	pool.sort_custom(func(left: BossArtifactDefinition, right: BossArtifactDefinition) -> bool: return left.resource_path < right.resource_path)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = run_state.seed_value ^ boss.resource_path.hash() ^ ((act + 1) * 104729)
	var rewards: Array[BossArtifactDefinition] = []
	while not pool.is_empty() and rewards.size() < count:
		var candidate: BossArtifactDefinition = pool.pop_at(rng.randi_range(0, pool.size() - 1))
		if _conflicts_with_rewards(candidate, rewards):
			continue
		rewards.append(candidate)
	return rewards

func _conflicts_with_owned(definition: BossArtifactDefinition, run_state: RunState) -> bool:
	for state: BossArtifactState in run_state.artifacts:
		var owned: BossArtifactDefinition = state.definition
		if definition.incompatible_artifacts.has(owned) or owned != null and owned.incompatible_artifacts.has(definition):
			return true
	return false

func _conflicts_with_rewards(definition: BossArtifactDefinition, rewards: Array[BossArtifactDefinition]) -> bool:
	for reward: BossArtifactDefinition in rewards:
		if definition.incompatible_artifacts.has(reward) or reward.incompatible_artifacts.has(definition):
			return true
	return false
