class_name CombatVisualSettings
extends Resource

@export_group("Enemy Hits")
@export var enemy_hit_color: Color = Color("ff786f")
@export_range(0.0, 1.0) var enemy_hit_flash_strength: float = 1.0
@export_range(0.01, 1.0) var enemy_hit_flash_duration: float = 0.17
@export var enemy_damage_number_offset: Vector2 = Vector2(0.0, -28.0)
@export var enemy_damage_detail_offset: Vector2 = Vector2(0.0, 24.0)
@export_group("Player Hits")
@export var player_hit_color: Color = Color("ff786f")
@export_range(0.0, 1.0) var player_hit_blink_opacity: float = 0.16
@export_range(0.01, 1.0) var player_hit_blink_duration: float = 0.18
@export var player_damage_number_offset: Vector2 = Vector2(0.0, -8.0)
@export_range(0.0, 12.0) var player_hit_shake_strength: float = 3.0
@export_range(0.0, 1.0) var player_hit_shake_duration: float = 0.18
@export_range(0.0, 1.0) var enemy_attack_travel_duration: float = 0.2
@export var heavy_enemy_attack_damage: int = 8
@export_group("Damage Numbers")
@export var normal_damage_font_size: int = 25
@export var large_damage_font_size: int = 34
@export_range(0.0, 120.0) var damage_number_rise: float = 48.0
@export_range(0.01, 2.0) var damage_number_duration: float = 0.55
@export_group("Board Markers")
@export_range(1, 4) var maximum_cell_markers: int = 2
@export_range(0.0, 8.0) var marker_line_width: float = 2.4
@export_range(0.0, 1.0) var marker_fill_opacity: float = 0.16
@export_range(0.0, 1.0) var preview_marker_opacity: float = 0.78
@export_range(0.08, 0.3) var piece_effect_marker_radius_ratio: float = 0.14
@export_range(0.02, 0.2) var piece_effect_marker_inset_ratio: float = 0.06
@export_range(0.0, 8.0) var piece_effect_marker_line_width: float = 2.0
@export_range(0.0, 1.0) var piece_effect_marker_fill_opacity: float = 0.82
@export var preview_anchor_color: Color = Color("238a54")
@export var poisoned_block_color: Color = Color("9ee83f")
@export var electrified_block_color: Color = Color("33e1ff")
@export_group("Effect Pools")
@export_range(3, 16, 1) var maximum_projectile_count: int = 10
@export_group("Combo")
@export var combo: ComboVisualDefinition
