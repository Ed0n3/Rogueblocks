class_name PieceModifierDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var trigger_mode: PieceModifierTriggerMode.Value = PieceModifierTriggerMode.Value.ON_ANY_CLEAR_PARTICIPATION
@export var trigger_limit: PieceModifierTriggerLimit.Value = PieceModifierTriggerLimit.Value.ONCE_PER_PLACEMENT
@export var effects: Array[GameplayEffect] = []
@export var visual_definition: PieceModifierVisualDefinition
@export var show_on_board_cells: bool = true
@export var priority: int = 0
@export var tags: Array[StringName] = []

func has_board_effect_marker() -> bool:
	return show_on_board_cells and visual_definition != null
