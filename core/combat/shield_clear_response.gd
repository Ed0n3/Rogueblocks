class_name ShieldClearResponse
extends Resource

@export var break_on_perfect_clear: bool = false
@export var cross_clear_damage: int = 0
@export var multi_line_damage: int = 0
@export var minimum_lines_for_multi_line_damage: int = 2

func remaining_shield(current_shield: int, clear: ClearResult) -> int:
	if current_shield <= 0 or clear == null:
		return maxi(0, current_shield)
	if break_on_perfect_clear and clear.perfect_clear:
		return 0
	var damage: int = cross_clear_damage if clear.cross_clear else (multi_line_damage if clear.line_count >= minimum_lines_for_multi_line_damage else 0)
	return maxi(0, current_shield - damage)
