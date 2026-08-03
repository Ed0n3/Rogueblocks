class_name ScoreService
extends RefCounted

static func calculate(clear: ClearResult, combo_level: int, rules: GameRules) -> ScoreResult:
	var result: ScoreResult = ScoreResult.new()
	result.base_score = rules.score_for_lines(clear.line_count)
	result.cross_bonus = rules.cross_score_bonus if clear.cross_clear else 0
	result.perfect_clear_bonus = rules.perfect_clear_score_bonus if clear.perfect_clear else 0
	result.combo_multiplier = 1.0 + maxf(0.0, float(combo_level) * rules.combo_score_multiplier_step)
	result.final_score = roundi(float(result.base_score + result.cross_bonus + result.perfect_clear_bonus) * result.combo_multiplier)
	return result
