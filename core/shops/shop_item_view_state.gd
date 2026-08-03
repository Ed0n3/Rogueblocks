class_name ShopItemViewState
extends RefCounted

const EMPTY_ICON: Texture2D = preload("res://assets/icons/empty_texture.tres")

enum Category { RELIC, POTION, BLOCK_CAPSULE, SERVICE, BOARD_PIECE }
enum Availability { AFFORDABLE, UNAFFORDABLE, UNAVAILABLE, PURCHASED }

var item: ShopItem
var category: Category = Category.SERVICE
var availability: Availability = Availability.AFFORDABLE
var category_name: String
var subtype_name: String
var rarity_name: String
var description: String
var practical_effect: String
var limitations: String
var restriction: String
var comparison: String
var status_text: String
var short_summary: String
var accent_color: Color = Color("7890aa")
var icon: Texture2D = EMPTY_ICON
var piece: PieceDefinition
var charge_count: int = 0

func can_purchase() -> bool:
	return availability == Availability.AFFORDABLE
