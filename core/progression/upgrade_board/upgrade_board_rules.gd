class_name UpgradeBoardRules
extends UpgradeMatrixConfiguration

## Compatibility path retained for callers that still load the former flat rules resource.
var default_resource_path: String:
	get:
		return DEFAULT_RESOURCE_PATH

var layout_version: int:
	get:
		return progression.layout_version
	set(value):
		progression.layout_version = value

var board_size: Vector2i:
	get:
		return layout.board_size
	set(value):
		layout.board_size = value

var region_columns: int:
	get:
		return layout.region_columns
	set(value):
		layout.region_columns = value

var region_rows: int:
	get:
		return layout.region_rows
	set(value):
		layout.region_rows = value

var region_slots: Array[UpgradeBoardRegionSlot]:
	get:
		return layout.region_slots
	set(value):
		layout.region_slots = value

var threshold_reference_cell_count: int:
	get:
		return progression.threshold_reference_cell_count
	set(value):
		progression.threshold_reference_cell_count = value

var default_level_thresholds: PackedInt32Array:
	get:
		return progression.default_level_thresholds
	set(value):
		progression.default_level_thresholds = value

var territory_zone_margin: int:
	get:
		return layout.territory_zone_margin
	set(value):
		layout.territory_zone_margin = value

var labyrinth_wall_spacing: int:
	get:
		return layout.labyrinth_wall_spacing
	set(value):
		layout.labyrinth_wall_spacing = value

var labyrinth_gate_spacing: int:
	get:
		return layout.labyrinth_gate_spacing
	set(value):
		layout.labyrinth_gate_spacing = value

var shop_offer_count: int:
	get:
		return economy.shop_offer_count
	set(value):
		economy.shop_offer_count = value

var shop_first_cell_fragment_cost: int:
	get:
		return economy.first_cell_fragment_cost
	set(value):
		economy.first_cell_fragment_cost = value

var shop_additional_cell_start_fragment_cost: int:
	get:
		return economy.additional_cell_start_fragment_cost
	set(value):
		economy.additional_cell_start_fragment_cost = value

var shop_additional_cell_fragment_cost_reduction: int:
	get:
		return economy.additional_cell_fragment_cost_reduction
	set(value):
		economy.additional_cell_fragment_cost_reduction = value

var shop_minimum_additional_cell_fragment_cost: int:
	get:
		return economy.minimum_additional_cell_fragment_cost
	set(value):
		economy.minimum_additional_cell_fragment_cost = value

var shop_minimum_fragment_cost: int:
	get:
		return economy.minimum_fragment_cost
	set(value):
		economy.minimum_fragment_cost = value

var maximum_shop_discount: float:
	get:
		return economy.maximum_shop_discount
	set(value):
		economy.maximum_shop_discount = value

var cell_pixel_size: float:
	get:
		return interaction.cell_pixel_size
	set(value):
		interaction.cell_pixel_size = value

var minimum_zoom: float:
	get:
		return interaction.minimum_zoom
	set(value):
		interaction.minimum_zoom = value

var maximum_zoom: float:
	get:
		return interaction.maximum_zoom
	set(value):
		interaction.maximum_zoom = value

var region_focus_zoom: float:
	get:
		return interaction.region_focus_zoom
	set(value):
		interaction.region_focus_zoom = value

var mouse_wheel_zoom_factor: float:
	get:
		return interaction.mouse_wheel_zoom_factor
	set(value):
		interaction.mouse_wheel_zoom_factor = value

var trackpad_pan_multiplier: float:
	get:
		return interaction.trackpad_pan_multiplier
	set(value):
		interaction.trackpad_pan_multiplier = value

var camera_edge_padding: float:
	get:
		return interaction.camera_edge_padding
	set(value):
		interaction.camera_edge_padding = value

var drag_start_distance: float:
	get:
		return interaction.drag_start_distance
	set(value):
		interaction.drag_start_distance = value

var minimum_pinch_distance: float:
	get:
		return interaction.minimum_pinch_distance
	set(value):
		interaction.minimum_pinch_distance = value

var neutral_cell_color: Color:
	get:
		return presentation.neutral_cell_color
	set(value):
		presentation.neutral_cell_color = value

var neutral_grid_color: Color:
	get:
		return presentation.neutral_grid_color
	set(value):
		presentation.neutral_grid_color = value

var wall_color: Color:
	get:
		return presentation.wall_color
	set(value):
		presentation.wall_color = value

var valid_preview_color: Color:
	get:
		return presentation.valid_preview_color
	set(value):
		presentation.valid_preview_color = value

var invalid_preview_color: Color:
	get:
		return presentation.invalid_preview_color
	set(value):
		presentation.invalid_preview_color = value

static func load_default() -> UpgradeBoardRules:
	var loaded_rules: UpgradeBoardRules = ResourceLoader.load(DEFAULT_RESOURCE_PATH) as UpgradeBoardRules
	if loaded_rules != null:
		return loaded_rules
	return UpgradeBoardRules.new()

func get_category_color(category: UpgradeBoardCategory.Value) -> Color:
	return presentation.get_category_color(category)

func get_default_threshold(level_index: int) -> int:
	return progression.get_default_threshold(level_index)
