class_name VaultStorageService
extends RefCounted

@export var artifact: BossArtifactDefinition = preload("res://content/artifacts/vault_shapes.tres") as BossArtifactDefinition

func effective_interval(run_state: RunState) -> int:
	var effect: VaultShapesEffect = _get_effect()
	if effect == null:
		effect = VaultShapesEffect.new()
	return maxi(effect.minimum_storage_interval, effect.base_storage_interval - maxi(0, run_state.modifiers.vault_storage_cooldown_reduction))

func turns_remaining(run_state: RunState) -> int:
	var state: BossArtifactState = run_state.get_artifact_state(artifact)
	if state == null:
		return 0
	_synchronize_ready(run_state, state)
	return 0 if state.ready else maxi(0, effective_interval(run_state) - state.trigger_counter)

func capacity() -> int:
	var effect: VaultShapesEffect = _get_effect()
	return maxi(1, effect.storage_capacity if effect != null else 1)

func advance_primary_turn(run_state: RunState) -> void:
	var state: BossArtifactState = run_state.get_artifact_state(artifact)
	if state == null or state.ready:
		return
	state.trigger_counter = mini(effective_interval(run_state), state.trigger_counter + 1)
	_synchronize_ready(run_state, state)

func can_capture(run_state: RunState, bonus_placement: bool, secondary_placement: bool, vault_retrieval: bool) -> bool:
	var state: BossArtifactState = run_state.get_artifact_state(artifact)
	if state == null or bonus_placement or secondary_placement or vault_retrieval or state.stored_cards.size() >= capacity():
		return false
	_synchronize_ready(run_state, state)
	return state.ready

func capture(run_state: RunState, card: PieceCardState) -> bool:
	var state: BossArtifactState = run_state.get_artifact_state(artifact)
	if state == null or card == null or card.piece == null or state.stored_cards.size() >= capacity() or not state.ready:
		return false
	state.stored_cards.append(card)
	state.trigger_counter = 0
	state.ready = false
	return true

func _synchronize_ready(run_state: RunState, state: BossArtifactState) -> void:
	if state.trigger_counter >= effective_interval(run_state):
		state.ready = true

func _get_effect() -> VaultShapesEffect:
	var definition: BossArtifactDefinition = artifact
	if definition == null:
		return null
	for effect: BossArtifactEffect in definition.effects:
		if effect is VaultShapesEffect:
			return effect as VaultShapesEffect
	return null
