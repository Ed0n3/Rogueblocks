class_name PieceCardEffectService
extends RefCounted

var effect_resolver: EffectResolver = EffectResolver.new()

func resolve_placement(card: PieceCardState, context: EffectContext) -> EffectResult:
	if card == null or card.intrinsic_effect == null or card.intrinsic_effect.trigger != PieceCardEffectTrigger.Value.ON_PLACEMENT:
		return EffectResult.new()
	return _resolve(card.intrinsic_effect, context)

func resolve_clear(card: PieceCardState, contribution: PieceClearContribution, clear: ClearResult, context: EffectContext) -> EffectResult:
	if card == null or card.intrinsic_effect == null or contribution == null or clear == null:
		return EffectResult.new()
	if not _matches_clear_trigger(card.intrinsic_effect.trigger, contribution, clear):
		return EffectResult.new()
	return _resolve(card.intrinsic_effect, context)

func resolve_clear_contributions(clear: ClearResult, context: EffectContext) -> EffectResult:
	var result: EffectResult = EffectResult.new()
	if clear == null:
		return result
	var contributions: Array[PieceClearContribution] = []
	for contribution: PieceClearContribution in clear.piece_contributions:
		if contribution != null and contribution.card != null and contribution.card.intrinsic_effect != null:
			contributions.append(contribution)
	contributions.sort_custom(func(left: PieceClearContribution, right: PieceClearContribution) -> bool:
		var left_priority: int = left.card.intrinsic_effect.priority
		var right_priority: int = right.card.intrinsic_effect.priority
		return left_priority < right_priority or left_priority == right_priority and left.piece_instance_id < right.piece_instance_id)
	for contribution: PieceClearContribution in contributions:
		result.merge(resolve_clear(contribution.card, contribution, clear, context))
	return result

func _resolve(definition: PieceCardEffectDefinition, context: EffectContext) -> EffectResult:
	if definition == null or context == null or not definition.is_valid():
		return EffectResult.new()
	context.source = definition
	return effect_resolver.resolve(definition.effects, context)

func _matches_clear_trigger(trigger: PieceCardEffectTrigger.Value, contribution: PieceClearContribution, clear: ClearResult) -> bool:
	match trigger:
		PieceCardEffectTrigger.Value.ON_CLEAR_PARTICIPATION:
			return not contribution.cleared_cells.is_empty()
		PieceCardEffectTrigger.Value.ON_FULL_PIECE_CLEAR:
			return contribution.all_remaining_cells_cleared
		PieceCardEffectTrigger.Value.ON_CROSS_CLEAR:
			return contribution.participated_in_cross_clear
		PieceCardEffectTrigger.Value.ON_PERFECT_CLEAR:
			return clear.perfect_clear
	return false
