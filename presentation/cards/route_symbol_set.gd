class_name RouteSymbolSet
extends Resource

## Symbol used for normal combat rooms.
@export var normal_combat: Texture2D
## Symbol used for elite combat rooms.
@export var elite_combat: Texture2D
## Symbol used for shops.
@export var shop: Texture2D
## Symbol used for random events.
@export var event: Texture2D
## Symbol used for recovery rooms.
@export var recovery: Texture2D
## Symbol used for optional challenge rooms.
@export var challenge: Texture2D
## Symbol used for act bosses.
@export var boss: Texture2D

## Player-facing name for normal combat rooms.
@export var normal_combat_title: String = "COMBAT"
## Generic explanation for normal combat rooms.
@export_multiline var normal_combat_description: String = "A standard enemy encounter."
## Player-facing name for elite combat rooms.
@export var elite_combat_title: String = "ELITE"
## Generic explanation for elite combat rooms.
@export_multiline var elite_combat_description: String = "A more dangerous enemy encounter."
## Player-facing name for shop rooms.
@export var shop_title: String = "SHOP"
## Generic explanation for shop rooms.
@export_multiline var shop_description: String = "Spend Shards on supplies and services."
## Player-facing name for event rooms.
@export var event_title: String = "EVENT"
## Generic explanation for event rooms.
@export_multiline var event_description: String = "Make a choice in an unknown encounter."
## Player-facing name for recovery rooms.
@export var recovery_title: String = "RECOVERY"
## Generic explanation for recovery rooms.
@export_multiline var recovery_description: String = "Restores Core health before continuing."
## Player-facing name for optional challenge rooms.
@export var challenge_title: String = "CHALLENGE"
## Generic explanation for optional challenge rooms.
@export_multiline var challenge_description: String = "An optional high-danger combat encounter."
## Player-facing name for act bosses.
@export var boss_title: String = "BOSS"
## Generic explanation for act boss rooms.
@export_multiline var boss_description: String = "The final combat encounter of this act."

func texture_for(node_type: RouteNodeState.NodeType) -> Texture2D:
	match node_type:
		RouteNodeState.NodeType.NORMAL_COMBAT:
			return normal_combat
		RouteNodeState.NodeType.ELITE_COMBAT:
			return elite_combat
		RouteNodeState.NodeType.SHOP:
			return shop
		RouteNodeState.NodeType.EVENT:
			return event
		RouteNodeState.NodeType.RECOVERY:
			return recovery
		RouteNodeState.NodeType.CHALLENGE:
			return challenge
		RouteNodeState.NodeType.BOSS:
			return boss
	return normal_combat

func title_for(node_type: RouteNodeState.NodeType) -> String:
	match node_type:
		RouteNodeState.NodeType.NORMAL_COMBAT:
			return normal_combat_title
		RouteNodeState.NodeType.ELITE_COMBAT:
			return elite_combat_title
		RouteNodeState.NodeType.SHOP:
			return shop_title
		RouteNodeState.NodeType.EVENT:
			return event_title
		RouteNodeState.NodeType.RECOVERY:
			return recovery_title
		RouteNodeState.NodeType.CHALLENGE:
			return challenge_title
		RouteNodeState.NodeType.BOSS:
			return boss_title
	return normal_combat_title

func description_for(node_type: RouteNodeState.NodeType) -> String:
	match node_type:
		RouteNodeState.NodeType.NORMAL_COMBAT:
			return normal_combat_description
		RouteNodeState.NodeType.ELITE_COMBAT:
			return elite_combat_description
		RouteNodeState.NodeType.SHOP:
			return shop_description
		RouteNodeState.NodeType.EVENT:
			return event_description
		RouteNodeState.NodeType.RECOVERY:
			return recovery_description
		RouteNodeState.NodeType.CHALLENGE:
			return challenge_description
		RouteNodeState.NodeType.BOSS:
			return boss_description
	return normal_combat_description

func tooltip_for(node_type: RouteNodeState.NodeType) -> String:
	return "%s\n%s" % [title_for(node_type), description_for(node_type)]
