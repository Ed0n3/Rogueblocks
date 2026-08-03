class_name UpgradeDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var category: UpgradeBoardCategory.Value = UpgradeBoardCategory.Value.MASTERY
@export var icon: Texture2D
@export_range(1, 20) var max_level: int = 1
@export var base_cost: int = 1
@export var cost_growth: float = 1.0
@export var explicit_costs: PackedInt32Array = PackedInt32Array()
@export var prerequisite_upgrades: Array[UpgradeDefinition] = []
@export var prerequisite_levels: PackedInt32Array = PackedInt32Array()
@export var required_victories: int = 0
@export var required_highest_difficulty: int = 0
@export var incompatible_upgrades: Array[UpgradeDefinition] = []
@export var hidden_until_available: bool = false
@export var effects: Array[PermanentUpgradeEffect] = []
@export var tags: Array[StringName] = []
@export var tree_column: int = 0
@export var tree_row: int = 0
@export var final_level_requires_full_area: bool = true
@export var board_level_thresholds: PackedInt32Array = PackedInt32Array()

func get_cost_for_level(current_level: int) -> int:
	if current_level >= 0 and current_level < explicit_costs.size():
		return maxi(0, explicit_costs[current_level])
	return maxi(0, roundi(float(base_cost) * pow(cost_growth, current_level)))

func is_valid() -> bool:
	return not display_name.is_empty() and max_level > 0 and prerequisite_upgrades.size() == prerequisite_levels.size()

func has_unlock_effect() -> bool:
	for effect: PermanentUpgradeEffect in effects:
		if effect is UnlockContentEffect:
			return true
	return false

func get_board_level_thresholds(configuration: UpgradeMatrixConfiguration, usable_cell_count: int = 0) -> PackedInt32Array:
	var resolved: PackedInt32Array = PackedInt32Array()
	var active_configuration: UpgradeMatrixConfiguration = configuration if configuration != null else UpgradeMatrixConfiguration.load_default()
	var progression_configuration: UpgradeMatrixProgressionConfiguration = active_configuration.progression
	var region_capacity: int = usable_cell_count if usable_cell_count > 0 else progression_configuration.threshold_reference_cell_count
	var previous_threshold: int = 0
	for level_index: int in max_level:
		var final_level: bool = level_index == max_level - 1
		var reference_threshold: int = _get_reference_board_threshold(progression_configuration, level_index)
		var scaled_threshold_numerator: int = reference_threshold * region_capacity
		var threshold: int = region_capacity if final_level and final_level_requires_full_area else ceili(float(scaled_threshold_numerator) / float(progression_configuration.threshold_reference_cell_count))
		var minimum_threshold: int = previous_threshold + 1
		var remaining_level_count: int = max_level - level_index - 1
		var maximum_threshold: int = maxi(minimum_threshold, region_capacity - remaining_level_count)
		threshold = clampi(threshold, minimum_threshold, maximum_threshold)
		resolved.append(threshold)
		previous_threshold = threshold
	return resolved

func resolve_board_level_thresholds(configuration: UpgradeMatrixConfiguration, usable_cell_count: int = 0) -> PackedInt32Array:
	return get_board_level_thresholds(configuration, usable_cell_count)

func _get_reference_board_threshold(configuration: UpgradeMatrixProgressionConfiguration, level_index: int) -> int:
	return board_level_thresholds[level_index] if level_index < board_level_thresholds.size() else configuration.get_default_threshold(level_index)
