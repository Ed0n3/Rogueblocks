class_name UpgradeMatrixPresentationConfiguration
extends Resource

## Fill color of neutral Matrix cells.
@export var neutral_cell_color: Color = Color("101a30")
## Grid and background-outline color of the Matrix.
@export var neutral_grid_color: Color = Color("203355")
## Fill color of generated labyrinth walls.
@export var wall_color: Color = Color("080d1d")
## Preview color used for valid Block placements.
@export var valid_preview_color: Color = Color("6ce5dc")
## Preview color used for invalid Block placements.
@export var invalid_preview_color: Color = Color("ff657f")

@export_category("Upgrade Categories")
## Accent color for resilience regions.
@export var resilience_color: Color = Color("72e5d6")
## Accent color for drafting regions.
@export var drafting_color: Color = Color("67c8ff")
## Accent color for economy regions.
@export var economy_color: Color = Color("f2c66d")
## Accent color for discovery regions.
@export var discovery_color: Color = Color("c77dff")
## Accent color for inventory regions.
@export var inventory_color: Color = Color("ff8f70")
## Accent color for mastery regions.
@export var mastery_color: Color = Color("f7f3ff")

@export_category("Region Rendering")
## Width of the selected-region border in screen pixels.
@export_range(0.0, 16.0, 0.5) var region_border_width: float = 2.0
## Fill alpha applied to generated upgrade regions.
@export_range(0.0, 1.0, 0.01) var region_fill_alpha: float = 0.16
## Border alpha applied to generated upgrade regions.
@export_range(0.0, 1.0, 0.01) var region_border_alpha: float = 0.64
## Grid-outline alpha applied inside generated upgrade regions.
@export_range(0.0, 1.0, 0.01) var region_grid_alpha: float = 0.34
## Amount used to lighten the selected region.
@export_range(0.0, 1.0, 0.01) var selected_region_lighten_amount: float = 0.2
## Accent alpha mixed into labyrinth wall rendering.
@export_range(0.0, 1.0, 0.01) var wall_accent_alpha: float = 0.62
## Fill alpha used for legacy foundation cells.
@export_range(0.0, 1.0, 0.01) var legacy_fill_alpha: float = 0.52
## Fill alpha used for confirmed and staged Block placements.
@export_range(0.0, 1.0, 0.01) var placement_fill_alpha: float = 0.88
## Fill alpha used for valid placement previews.
@export_range(0.0, 1.0, 0.01) var preview_valid_alpha: float = 0.72
## Fill alpha used for invalid placement previews.
@export_range(0.0, 1.0, 0.01) var preview_invalid_alpha: float = 0.58
## Font size used by labels rendered over Matrix regions.
@export_range(6, 48, 1) var label_font_size: int = 12
## Minimum camera zoom at which region labels are shown.
@export_range(0.1, 3.0, 0.05) var region_label_zoom_threshold: float = 0.7
## Alpha applied to region label text.
@export_range(0.0, 1.0, 0.01) var region_label_alpha: float = 0.92
## Alpha applied to the cross marker over invalid previews.
@export_range(0.0, 1.0, 0.01) var invalid_preview_marker_alpha: float = 0.7

@export_category("Reserve Cards")
## Horizontal inset of the procedural Block preview.
@export_range(0.0, 64.0, 0.5) var reserve_preview_horizontal_inset: float = 8.0
## Top offset of the procedural Block preview.
@export_range(0.0, 64.0, 0.5) var reserve_preview_top_offset: float = 7.0
## Height of the procedural Block preview.
@export_range(1.0, 128.0, 0.5) var reserve_preview_height: float = 48.0
## Preview fill alpha for available reserve Blocks.
@export_range(0.0, 1.0, 0.01) var reserve_available_fill_alpha: float = 0.9
## Preview fill alpha for unavailable reserve Blocks.
@export_range(0.0, 1.0, 0.01) var reserve_unavailable_fill_alpha: float = 0.28
## Amount used to lighten reserve Block preview outlines.
@export_range(0.0, 1.0, 0.01) var reserve_outline_lighten_amount: float = 0.35
## Inset of the procedural reserve-card border.
@export_range(0.0, 16.0, 0.5) var reserve_border_inset: float = 1.0
## Width of the procedural reserve-card border.
@export_range(0.5, 16.0, 0.5) var reserve_border_width: float = 1.0
## Alpha of the procedural reserve-card border.
@export_range(0.0, 1.0, 0.01) var reserve_border_alpha: float = 0.35

@export_category("Foundry Cards")
## Rectangle used to render a procedural foundry Block preview.
@export var foundry_preview_rect: Rect2 = Rect2(10.0, 10.0, 62.0, 62.0)
## Border width of a selected foundry card.
@export_range(0.5, 16.0, 0.5) var foundry_selected_border_width: float = 3.0
## Border width of an unselected foundry card.
@export_range(0.5, 16.0, 0.5) var foundry_default_border_width: float = 1.0
## Border alpha of an unselected foundry card.
@export_range(0.0, 1.0, 0.01) var foundry_default_border_alpha: float = 0.4
## Fill alpha of foundry Block previews.
@export_range(0.0, 1.0, 0.01) var foundry_preview_fill_alpha: float = 0.9
## Amount used to lighten foundry Block preview outlines.
@export_range(0.0, 1.0, 0.01) var foundry_outline_lighten_amount: float = 0.35
## Inset of the procedural foundry-card border.
@export_range(0.0, 16.0, 0.5) var foundry_border_inset: float = 1.0

func get_category_color(category: UpgradeBoardCategory.Value) -> Color:
	match category:
		UpgradeBoardCategory.Value.RESILIENCE:
			return resilience_color
		UpgradeBoardCategory.Value.DRAFTING:
			return drafting_color
		UpgradeBoardCategory.Value.ECONOMY:
			return economy_color
		UpgradeBoardCategory.Value.DISCOVERY:
			return discovery_color
		UpgradeBoardCategory.Value.INVENTORY:
			return inventory_color
		UpgradeBoardCategory.Value.MASTERY:
			return mastery_color
	return mastery_color
