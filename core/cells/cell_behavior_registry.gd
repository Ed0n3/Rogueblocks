class_name CellBehaviorRegistry
extends RefCounted

var behaviors: Dictionary[int, CellClearBehavior] = {}

func _init() -> void:
	behaviors[CellType.Value.EMPTY] = CellClearBehavior.new()
	behaviors[CellType.Value.OCCUPIED] = CellClearBehavior.new()
	behaviors[CellType.Value.BLOCKER] = BlockedCellBehavior.new(false)
	behaviors[CellType.Value.CORRUPTED] = MarkerCellBehavior.new(CellType.Value.CORRUPTED)
	behaviors[CellType.Value.BONUS] = MarkerCellBehavior.new(CellType.Value.BONUS)
	behaviors[CellType.Value.LOCKED] = LockedCellBehavior.new()
	behaviors[CellType.Value.TARGET] = MarkerCellBehavior.new(CellType.Value.TARGET)
	behaviors[CellType.Value.ARMORED] = BlockedCellBehavior.new(true)

func get_behavior(type: int) -> CellClearBehavior:
	return behaviors.get(type, behaviors[CellType.Value.EMPTY])
