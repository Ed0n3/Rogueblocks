class_name PieceModifierVisualDefinition
extends Resource

@export var accent_color: Color = Color("ff8d6b")
@export var secondary_color: Color = Color("ffd17a")
@export var marker_style: PieceModifierMarkerStyle.Value = PieceModifierMarkerStyle.Value.DIAGONAL
@export_range(0.0, 4.0) var pulse_speed: float = 1.0
@export_range(0.0, 1.0) var glow_strength: float = 0.4
@export_range(0.0, 6.0) var outline_width: float = 2.0
@export var board_overlay_priority: int = 0
