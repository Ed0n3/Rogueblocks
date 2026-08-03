class_name DeckRules
extends Resource

@export_category("Hand")
@export_range(1, 12, 1) var base_draw_count: int = 4
@export_range(1, 20, 1) var maximum_hand_size: int = 8
@export var discard_unplayed_cards: bool = true

@export_category("Placement Economy")
@export_range(1, 12, 1) var base_placement_points_per_turn: int = 4
@export_range(0, 12, 1) var redraw_placement_point_cost: int = 1

@export_category("Draw Pile")
@export var reshuffle_discard_when_empty: bool = true
@export var shuffle_at_encounter_start: bool = true

@export_category("Encounter Balance")
@export_range(0.5, 2.0, 0.01) var base_enemy_health_multiplier: float = 1.08
@export_range(0.0, 0.1, 0.005) var enemy_health_bonus_per_effect_weight: float = 0.015
@export_range(0.0, 1.0, 0.01) var maximum_effect_deck_health_bonus: float = 0.18
