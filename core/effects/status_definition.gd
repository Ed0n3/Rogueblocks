class_name StatusDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var category: StatusCategory.Value = StatusCategory.Value.NEGATIVE
@export var tags: Array[StringName] = []
@export var default_duration_turns: int = 1
@export var maximum_duration_turns: int = 0
@export var maximum_stacks: int = 1
@export var stacking_rule: StatusStackingRule.Value = StatusStackingRule.Value.REFRESH_DURATION
@export var tick_phase: StatusTickPhase.Value = StatusTickPhase.Value.NONE
@export var duration_phase: StatusTickPhase.Value = StatusTickPhase.Value.END_PLAYER_TURN
@export var tick_amount: int = 0
@export var control_effect: StatusControlEffect.Value = StatusControlEffect.Value.NONE
@export var damage_modifiers: Array[DamageModifierDefinition] = []
@export var is_dispellable: bool = true
@export var is_cleansable: bool = true
@export var visible_to_player: bool = true
@export var accent_color: Color = Color.WHITE
@export var icon_type: StatusIconType.Value = StatusIconType.Value.NONE
@export var visual_definition: StatusVisualDefinition
