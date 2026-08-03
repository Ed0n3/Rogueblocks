class_name PieceDefinition
extends Resource

@export var display_name: String
@export var base_cells: Array[Vector2i] = []
@export var preview_color: Color = Color("69d2e7")
@export var upgrade_board_icon: Texture2D
@export var permanent_card_effect: PieceCardEffectDefinition
@export_range(0.0, 100.0) var starting_draft_weight: float = 1.0
@export var can_appear_in_starting_draft: bool = true
@export var allow_rotation: bool = true
@export var tags: Array[StringName] = []
@export var initially_unlocked: bool = true
@export var can_appear_as_bonus_item: bool = true
@export var bonus_item_weight: float = 1.0
@export var bonus_item_price: int = 18
@export var bonus_item_charges: int = 1
@export var bonus_item_rarity: ItemRarity.Value = ItemRarity.Value.COMMON

func is_valid() -> bool:
	if display_name.is_empty() or base_cells.is_empty() or starting_draft_weight < 0.0:
		return false
	var unique_cells: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in base_cells:
		if unique_cells.has(cell):
			return false
		unique_cells[cell] = true
	return true
