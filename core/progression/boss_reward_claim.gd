class_name BossRewardClaim
extends RefCounted

var run_sequence: int
var act: int
var column: int
var row: int

func matches(run: int, route_node: RouteNodeState) -> bool:
	return route_node != null and run_sequence == run and act == route_node.act and column == route_node.column and row == route_node.row

func to_save_data() -> Dictionary:
	return {"run_sequence": run_sequence, "act": act, "column": column, "row": row}

static func from_save_data(data: Dictionary) -> BossRewardClaim:
	var claim: BossRewardClaim = BossRewardClaim.new()
	claim.run_sequence = int(data.get("run_sequence", 0))
	claim.act = int(data.get("act", 0))
	claim.column = int(data.get("column", 0))
	claim.row = int(data.get("row", 0))
	return claim

static func from_legacy(value: String) -> BossRewardClaim:
	var parts: PackedStringArray = value.split(":")
	if parts.size() < 4:
		return null
	var claim: BossRewardClaim = BossRewardClaim.new()
	claim.run_sequence = ":".join(parts.slice(0, parts.size() - 3)).hash()
	claim.act = int(parts[parts.size() - 3])
	claim.column = int(parts[parts.size() - 2])
	claim.row = int(parts[parts.size() - 1])
	return claim
