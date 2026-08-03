class_name ItemDefinition
extends Resource

@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D = preload("res://assets/icons/empty_texture.tres") as Texture2D
@export var category: ItemCategory.Value = ItemCategory.Value.UTILITY_ITEM
@export var rarity: ItemRarity.Value = ItemRarity.Value.COMMON
@export var variant_of: ItemDefinition
@export var tags: Array[StringName] = []
@export var base_shop_price: int = 1
@export var maximum_stack_size: int = 1
@export var charges_per_purchase: int = 1
@export var target_mode: ItemTargetMode.Value = ItemTargetMode.Value.NO_TARGET
@export var effects: Array[GameplayEffect] = []
@export var consume_on_failed_use: bool = false
@export var can_use_outside_combat: bool = false
@export var accent_color: Color = Color.WHITE
