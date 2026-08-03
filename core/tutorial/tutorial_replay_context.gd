class_name TutorialReplayContext
extends RefCounted

enum Value { COMBAT, ROUTE, SHOP, REWARD, ARTIFACT, HUB, UPGRADES, DRAFT }

static func supports_target(context: Value, target: TutorialTargetKey.Value) -> bool:
	match target:
		TutorialTargetKey.Value.NONE:
			return true
		TutorialTargetKey.Value.ARTIFACT_FIRST_CARD:
			return context == Value.ARTIFACT
		TutorialTargetKey.Value.COMBAT_BOARD, TutorialTargetKey.Value.COMBAT_DISCARD_QUEUE, TutorialTargetKey.Value.COMBAT_ENEMY, TutorialTargetKey.Value.COMBAT_ENEMY_HEALTH, TutorialTargetKey.Value.COMBAT_ENEMY_INTENT, TutorialTargetKey.Value.COMBAT_ITEM_BELT, TutorialTargetKey.Value.COMBAT_PIECE_CHOICE_FIRST, TutorialTargetKey.Value.COMBAT_PIECE_CHOICE_SECOND, TutorialTargetKey.Value.COMBAT_PLACE, TutorialTargetKey.Value.COMBAT_PLAYER_HEALTH, TutorialTargetKey.Value.COMBAT_REROLL, TutorialTargetKey.Value.COMBAT_ROTATE_LEFT, TutorialTargetKey.Value.COMBAT_ROTATE_RIGHT, TutorialTargetKey.Value.COMBAT_ROTATE_TUTORIAL, TutorialTargetKey.Value.COMBAT_STATUS_ENEMY, TutorialTargetKey.Value.COMBAT_STATUS_PLAYER:
			return context == Value.COMBAT
		TutorialTargetKey.Value.DRAFT_BEGIN, TutorialTargetKey.Value.DRAFT_CANDIDATES:
			return context == Value.DRAFT
		TutorialTargetKey.Value.HUB_DAILY_CHALLENGE, TutorialTargetKey.Value.HUB_PERMANENT_UPGRADES, TutorialTargetKey.Value.HUB_RUN_CONTROLS, TutorialTargetKey.Value.HUB_ARCHIVE, TutorialTargetKey.Value.HUB_HEADER_CONTROLS, TutorialTargetKey.Value.HUB_MAIN_MENU:
			return context == Value.HUB
		TutorialTargetKey.Value.PROGRESSION_UPGRADE_GRID, TutorialTargetKey.Value.PROGRESSION_UPGRADE_ACTIONS, TutorialTargetKey.Value.PROGRESSION_UPGRADE_DETAILS, TutorialTargetKey.Value.PROGRESSION_UPGRADE_CONFIRM:
			return context == Value.UPGRADES
		TutorialTargetKey.Value.REWARD_FIRST_CARD:
			return context == Value.REWARD
		TutorialTargetKey.Value.ROUTE_AVAILABLE_NODE, TutorialTargetKey.Value.ROUTE_PIECE_POOL_BUTTON, TutorialTargetKey.Value.ROUTE_RELIC_BUTTON, TutorialTargetKey.Value.ROUTE_SHARDS:
			return context == Value.ROUTE
		TutorialTargetKey.Value.SHOP_BUY_BUTTON, TutorialTargetKey.Value.SHOP_DETAIL_PANEL, TutorialTargetKey.Value.SHOP_OFFER_GRID, TutorialTargetKey.Value.SHOP_SHARDS:
			return context == Value.SHOP
	return false
