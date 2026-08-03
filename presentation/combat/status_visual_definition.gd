class_name StatusVisualDefinition
extends Resource

@export var channel: StatusVisualChannel.Value = StatusVisualChannel.Value.NONE
@export var primary_color: Color = Color.WHITE
@export var secondary_color: Color = Color.WHITE
@export var priority: int = 0
@export_range(0.0, 1.0) var base_strength: float = 0.18
@export_range(0.0, 1.0) var strength_per_stack: float = 0.08
@export_range(0.0, 1.0) var maximum_strength: float = 0.55
@export_range(0.0, 6.0) var pulse_speed: float = 1.0
@export var applies_to_enemy: bool = true
@export var applies_to_health: bool = true

func strength_for_stacks(stacks: int) -> float:
	return minf(maximum_strength, base_strength + float(maxi(0, stacks - 1)) * strength_per_stack)
