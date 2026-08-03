class_name UpgradeMatrixConfiguration
extends Resource

const DEFAULT_RESOURCE_PATH: String = "res://content/upgrade_matrix/default_upgrade_matrix_configuration.tres"

## Board dimensions, authored regions, and deterministic generation tuning.
@export var layout: UpgradeMatrixLayoutConfiguration = UpgradeMatrixLayoutConfiguration.new()
## Save-layout version and upgrade-level threshold scaling.
@export var progression: UpgradeMatrixProgressionConfiguration = UpgradeMatrixProgressionConfiguration.new()
## Foundry offers, Fragment prices, and discount constraints.
@export var economy: UpgradeMatrixEconomyConfiguration = UpgradeMatrixEconomyConfiguration.new()
## Camera, pointer, touch, and gesture tuning.
@export var interaction: UpgradeMatrixInteractionConfiguration = UpgradeMatrixInteractionConfiguration.new()
## Matrix colors and generated rendering style.
@export var presentation: UpgradeMatrixPresentationConfiguration = UpgradeMatrixPresentationConfiguration.new()

static func load_default() -> UpgradeMatrixConfiguration:
	var loaded_configuration: UpgradeMatrixConfiguration = ResourceLoader.load(DEFAULT_RESOURCE_PATH) as UpgradeMatrixConfiguration
	if loaded_configuration != null:
		return loaded_configuration
	return UpgradeMatrixConfiguration.new()

func get_validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if layout == null:
		errors.append("Matrix layout configuration is missing.")
	if progression == null:
		errors.append("Matrix progression configuration is missing.")
	if economy == null:
		errors.append("Matrix economy configuration is missing.")
	if interaction == null:
		errors.append("Matrix interaction configuration is missing.")
	if presentation == null:
		errors.append("Matrix presentation configuration is missing.")
	if not errors.is_empty():
		return errors
	if layout.board_size.x <= 0 or layout.board_size.y <= 0:
		errors.append("Matrix board dimensions must be positive.")
	if layout.get_region_capacity() <= 0:
		errors.append("Matrix region grid must contain at least one slot.")
	if layout.cardinal_directions.is_empty():
		errors.append("Matrix layout generation requires at least one neighbor direction.")
	if layout.hash_modulus <= 0:
		errors.append("Matrix deterministic hash modulus must be positive.")
	if progression.threshold_reference_cell_count <= 0:
		errors.append("Matrix threshold reference capacity must be positive.")
	if interaction.minimum_zoom > interaction.maximum_zoom:
		errors.append("Matrix minimum zoom cannot exceed maximum zoom.")
	if interaction.region_focus_zoom < interaction.minimum_zoom or interaction.region_focus_zoom > interaction.maximum_zoom:
		errors.append("Matrix region focus zoom must be inside the configured zoom range.")
	if interaction.cell_pixel_size <= 0.0:
		errors.append("Matrix cell pixel size must be positive.")
	if economy.minimum_fragment_cost <= 0:
		errors.append("Matrix minimum Fragment price must be positive.")
	if economy.maximum_shop_discount < 0.0 or economy.maximum_shop_discount >= 1.0:
		errors.append("Matrix maximum shop discount must stay between zero and one.")
	if progression.default_level_thresholds.is_empty():
		errors.append("Matrix default level thresholds cannot be empty.")
	var previous_threshold: int = 0
	for threshold: int in progression.default_level_thresholds:
		if threshold <= previous_threshold:
			errors.append("Matrix default level thresholds must be strictly increasing.")
			break
		previous_threshold = threshold
	return errors
