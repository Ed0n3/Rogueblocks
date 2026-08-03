class_name PlacementEconomyArtifactEffect
extends BossArtifactEffect

@export var draw_count_bonus: int = 0
@export var placement_point_bonus: int = 0
@export var redraw_placement_point_cost_modifier: int = 0
@export var free_redraws_per_turn_bonus: int = 0

func modify_draw_count(context: ArtifactEffectContext) -> void:
	context.draw_count += draw_count_bonus

func modify_placement_economy(context: ArtifactEffectContext) -> void:
	context.maximum_placement_points += placement_point_bonus
	context.redraw_placement_point_cost += redraw_placement_point_cost_modifier
	context.free_redraws_per_turn += free_redraws_per_turn_bonus
