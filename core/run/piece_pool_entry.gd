class_name PiecePoolEntry
extends RefCounted

var card_id: int = 0
var piece: PieceDefinition
var intrinsic_effect: PieceCardEffectDefinition
var display_name: String
var cells: Array[Vector2i] = []
var color: Color
var is_enabled: bool = true
var is_new: bool = false
var modifier_descriptions: PackedStringArray = []
var unique_rotation_count: int = 1
var can_appear_as_bonus_item: bool = false
var modifiers: Array[PieceModifierDefinition] = []
var modifier_colors: Array[Color] = []
var source_relics: Array[RelicDefinition] = []
var added_act: int = 0
var is_starting_piece: bool = false
var is_temporary: bool = false
