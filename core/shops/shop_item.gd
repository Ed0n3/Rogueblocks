class_name ShopItem
extends RefCounted

enum ItemType { RELIC = 0, HEAL = 1, RETIRED = 2, REMOVE_PIECE = 3, CONSUMABLE = 4, BOARD_PIECE = 5 }

var display_name: String
var type: ItemType
var relic: RelicDefinition
var item: ItemDefinition
var piece: PieceDefinition
var base_price: int = 1
var final_price: int = 1
var purchased: bool = false

func to_save_data() -> Dictionary:
	return {"display_name": display_name, "type": int(type), "relic": ContentReferenceCodec.encode(relic), "item": ContentReferenceCodec.encode(item), "piece": ContentReferenceCodec.encode(piece), "base_price": base_price, "final_price": final_price, "purchased": purchased}

static func from_save_data(data: Dictionary) -> ShopItem:
	var item: ShopItem = ShopItem.new()
	item.display_name = String(data.get("display_name", ""))
	item.type = int(data.get("type", 0)) as ItemType
	var legacy_content: String = String(data.get("content_id", ""))
	item.relic = ContentReferenceCodec.decode_legacy(String(data.get("relic", legacy_content)), RelicDefinition, ContentRegistry.catalog) as RelicDefinition
	item.item = ContentReferenceCodec.decode_legacy(String(data.get("item", legacy_content)), ItemDefinition, ContentRegistry.catalog) as ItemDefinition
	item.piece = ContentReferenceCodec.decode_legacy(String(data.get("piece", data.get("piece_id", legacy_content))), PieceDefinition, ContentRegistry.catalog) as PieceDefinition
	item.base_price = int(data.get("base_price", 1))
	item.final_price = int(data.get("final_price", 1))
	item.purchased = bool(data.get("purchased", false))
	return item
