class_name DamageCalculationContext
extends RefCounted

var source: Resource
var event_type: DamageEventType.Value = DamageEventType.Value.DIRECT_EFFECT
var attacker: EffectTarget.Value = EffectTarget.Value.PLAYER
var target: EffectTarget.Value = EffectTarget.Value.ENEMY
var base_damage: int = 0
var combo_level: int = 0
var clear_result: ClearResult
var rules: GameRules
var run_state: RunState
var encounter_state: EncounterEffectState

static func for_clear(run: RunState, encounter: EncounterEffectState, clear: ClearResult, combo: int, game_rules: GameRules) -> DamageCalculationContext:
	var context: DamageCalculationContext = DamageCalculationContext.new()
	context.source = game_rules
	context.event_type = DamageEventType.Value.CLEAR
	context.attacker = EffectTarget.Value.PLAYER
	context.target = EffectTarget.Value.ENEMY
	context.base_damage = game_rules.damage_for_lines(clear.line_count)
	context.combo_level = maxi(0, combo)
	context.clear_result = clear
	context.rules = game_rules
	context.run_state = run
	context.encounter_state = encounter
	return context

static func for_effect(effect_context: EffectContext, damage: int) -> DamageCalculationContext:
	var context: DamageCalculationContext = DamageCalculationContext.new()
	context.source = effect_context.source
	context.event_type = effect_context.damage_event_type
	context.target = effect_context.target
	context.attacker = EffectTarget.Value.ENEMY if effect_context.target == EffectTarget.Value.PLAYER else EffectTarget.Value.PLAYER
	context.base_damage = maxi(0, damage)
	context.run_state = effect_context.run_state
	context.encounter_state = effect_context.encounter_state
	return context
