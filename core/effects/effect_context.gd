class_name EffectContext
extends RefCounted

var source: Resource
var target: EffectTarget.Value = EffectTarget.Value.ENEMY
var current_turn: int = 0
var encounter: EnemyDefinition
var run_seed: int = 0
var magnitude_multiplier: float = 1.0
var duration_modifier: int = 0
var stack_modifier: int = 0
var board_state: BoardState
var run_state: RunState
var encounter_state: EncounterEffectState
var rng: RandomNumberGenerator
var deck_state: EncounterDeckState
var maximum_hand_size: int = 0
var active_counter: ActiveCounterState
var damage_event_type: DamageEventType.Value = DamageEventType.Value.DIRECT_EFFECT
var last_reserve_health: int = 1
var last_reserve_message: String = "Last Reserve prevented defeat"
