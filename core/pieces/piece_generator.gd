class_name PieceGenerator
extends RefCounted

var rng: RandomNumberGenerator
var call_count: int = 0

func _init(seed_value: int = 1) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value

func to_save_data() -> Dictionary:
	return {"state": str(rng.state), "call_count": call_count}

func restore(data: Dictionary) -> void:
	rng.state = String(data.get("state", str(rng.state))).to_int()
	call_count = maxi(0, int(data.get("call_count", 0)))
