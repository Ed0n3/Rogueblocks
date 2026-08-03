class_name PieceCardEffectDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D = preload("res://assets/icons/empty_texture.tres") as Texture2D
@export var accent_color: Color = Color("69d2e7")
@export var marker_style: PieceEffectMarkerStyle.Value = PieceEffectMarkerStyle.Value.GENERIC
@export var trigger: PieceCardEffectTrigger.Value = PieceCardEffectTrigger.Value.ON_PLACEMENT
@export var effects: Array[GameplayEffect] = []
@export_range(0.0, 100.0) var roll_weight: float = 1.0
@export var priority: int = 0
@export_range(0.0, 5.0, 0.05) var enemy_health_scaling_weight: float = 1.0
@export var tags: Array[StringName] = []
@export var required_piece_tags: Array[StringName] = []
@export var excluded_piece_tags: Array[StringName] = []

func can_roll_for(piece: PieceDefinition) -> bool:
	if piece == null or roll_weight <= 0.0 or not is_valid():
		return false
	for required_tag: StringName in required_piece_tags:
		if not piece.tags.has(required_tag):
			return false
	for excluded_tag: StringName in excluded_piece_tags:
		if piece.tags.has(excluded_tag):
			return false
	return true

func is_valid() -> bool:
	if display_name.is_empty() or description.is_empty() or icon == null or roll_weight < 0.0:
		return false
	if required_piece_tags.any(func(tag: StringName) -> bool: return excluded_piece_tags.has(tag)):
		return false
	return not effects.is_empty() and effects.all(func(effect: GameplayEffect) -> bool: return effect != null)
