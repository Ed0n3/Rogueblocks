class_name VaultCooldownRelicEffect
extends RelicEffect

@export_range(1, 5, 1) var cooldown_reduction: int = 1

func apply(run_state: RunState, source_relic: RelicDefinition = null) -> void:
	super.apply(run_state, source_relic)
	run_state.modifiers.vault_storage_cooldown_reduction += cooldown_reduction
