class_name TutorialTargetRegistryService
extends Node

const TutorialTargetRegistration = preload("res://core/tutorial/tutorial_target_registration.gd")

signal targets_changed()

var targets: Array[TutorialTargetRegistration] = []

func register_target(key: TutorialTargetKey.Value, node: Node, owner: Node = null) -> void:
	if key == TutorialTargetKey.Value.NONE or node == null:
		return
	var registration: TutorialTargetRegistration = TutorialTargetRegistration.new(key, node, owner if owner != null else node)
	var index: int = _find_registration_index(key)
	if index >= 0:
		targets[index] = registration
	else:
		targets.append(registration)
	targets_changed.emit()

func unregister_target(key: TutorialTargetKey.Value, node: Node = null) -> void:
	var index: int = _find_registration_index(key)
	if index >= 0 and (node == null or targets[index].get_node() == node):
		targets.remove_at(index)
		targets_changed.emit()

func unregister_owner(owner: Node) -> void:
	if owner == null:
		return
	var changed: bool = false
	for index: int in range(targets.size() - 1, -1, -1):
		if targets[index].get_owner() == owner:
			targets.remove_at(index)
			changed = true
	if changed:
		targets_changed.emit()

func resolve_node(key: TutorialTargetKey.Value) -> Node:
	var index: int = _find_registration_index(key)
	if index < 0:
		return null
	var registration: TutorialTargetRegistration = targets[index]
	var node: Node = registration.get_node()
	if node == null or not is_instance_valid(node):
		targets.remove_at(index)
		return null
	return node

func resolve_rect(target: TutorialTarget) -> Rect2:
	if target == null:
		return Rect2()
	var node: Node = resolve_node(target.target_key)
	if node == null:
		return Rect2()
	if node is BoardView:
		return _resolve_board_rect(node as BoardView, target)
	if node is Control:
		return (node as Control).get_global_rect().grow(target.padding)
	if node is Node2D:
		return Rect2((node as Node2D).global_position - Vector2.ONE * 12.0, Vector2.ONE * 24.0).grow(target.padding)
	return Rect2()

func registered_targets() -> Array[TutorialTargetKey.Value]:
	var result: Array[TutorialTargetKey.Value] = []
	for registration: TutorialTargetRegistration in targets.duplicate():
		if resolve_node(registration.key) != null:
			result.append(registration.key)
	result.sort()
	return result

func _find_registration_index(key: TutorialTargetKey.Value) -> int:
	for index: int in targets.size():
		if targets[index].key == key:
			return index
	return -1

func _resolve_board_rect(board_view: BoardView, target: TutorialTarget) -> Rect2:
	var board_rectangle: Rect2 = board_view.get_board_rect()
	if board_view.board == null or target.target_type == TutorialTargetType.Value.UI_CONTROL or target.target_type == TutorialTargetType.Value.BOARD_AREA:
		return _transform_rectangle(board_view.get_global_transform_with_canvas(), board_rectangle).grow(target.padding)
	var cell_size: float = board_rectangle.size.x / float(board_view.board.width)
	var cells: Array[Vector2i] = target.board_cells.duplicate()
	if target.target_type == TutorialTargetType.Value.BOARD_ROW and target.board_row >= 0:
		for x: int in board_view.board.width:
			cells.append(Vector2i(x, target.board_row))
	elif target.target_type == TutorialTargetType.Value.BOARD_COLUMN and target.board_column >= 0:
		for y: int in board_view.board.height:
			cells.append(Vector2i(target.board_column, y))
	if cells.is_empty():
		return _transform_rectangle(board_view.get_global_transform_with_canvas(), board_rectangle).grow(target.padding)
	var result: Rect2
	for index: int in cells.size():
		var cell: Vector2i = cells[index]
		var local_rectangle: Rect2 = Rect2(board_view.grid_position_to_local(cell), Vector2.ONE * cell_size)
		var rectangle: Rect2 = _transform_rectangle(board_view.get_global_transform_with_canvas(), local_rectangle)
		result = rectangle if index == 0 else result.merge(rectangle)
	return result.grow(target.padding)

func _transform_rectangle(transform: Transform2D, rectangle: Rect2) -> Rect2:
	var corners: Array[Vector2] = [rectangle.position, Vector2(rectangle.end.x, rectangle.position.y), rectangle.end, Vector2(rectangle.position.x, rectangle.end.y)]
	var transformed: Rect2 = Rect2(transform * corners[0], Vector2.ZERO)
	for index: int in range(1, corners.size()):
		transformed = transformed.expand(transform * corners[index])
	return transformed
