class_name BlockVisualSettings
extends Resource

const DEFAULT_RESOURCE_PATH: String = "res://content/presentation/block_visual_settings.tres"

@export_group("Outline")
@export var outline_color: Color = Color("090d19")
@export_range(0.5, 8.0, 0.5) var canvas_outline_width: float = 2.0
@export_group("Texture Override")
@export var block_style_texture: Texture2D
@export var tint_block_style_texture: bool = true
@export_group("Bevel")
@export_range(0.0, 1.0, 0.01) var highlight_opacity: float = 0.24
@export_range(0.0, 1.0, 0.01) var shadow_opacity: float = 0.32
@export_range(1, 12, 1) var tile_bevel_inset: int = 2
@export_range(1, 12, 1) var tile_bevel_thickness: int = 2
@export_range(0.01, 0.25, 0.01) var canvas_bevel_width_ratio: float = 0.07
@export_range(0.5, 8.0, 0.5) var canvas_minimum_bevel_width: float = 1.0
@export_range(0.5, 12.0, 0.5) var canvas_maximum_bevel_width: float = 2.0
@export_group("Mechanical Edge")
@export_range(0.01, 0.15, 0.005) var mechanical_corner_cut_ratio: float = 0.05
@export_range(0.0, 1.0, 0.01) var mechanical_corner_cut_opacity: float = 0.9

static func load_default() -> BlockVisualSettings:
	return load(DEFAULT_RESOURCE_PATH) as BlockVisualSettings
