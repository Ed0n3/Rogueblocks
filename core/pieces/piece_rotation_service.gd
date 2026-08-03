class_name PieceRotationService
extends RefCounted

static func get_unique_rotations(definition: PieceDefinition) -> Array[Array]:
	var rotations: Array[Array] = []
	var current: Array[Vector2i] = normalize_cells(definition.base_cells)
	var rotation_count: int = 4 if definition.allow_rotation else 1
	for index: int in rotation_count:
		var key: String = cells_key(current)
		var duplicate: bool = false
		for existing: Array in rotations:
			if cells_key(_typed_cells(existing)) == key:
				duplicate = true
				break
		if not duplicate:
			rotations.append(current.duplicate())
		current = rotate_clockwise(current)
	return rotations

static func rotate_clockwise(cells: Array[Vector2i]) -> Array[Vector2i]:
	var rotated: Array[Vector2i] = []
	for cell: Vector2i in cells:
		rotated.append(Vector2i(-cell.y, cell.x))
	return normalize_cells(rotated)

static func normalize_cells(cells: Array[Vector2i]) -> Array[Vector2i]:
	if cells.is_empty():
		return []
	var minimum: Vector2i = cells[0]
	for cell: Vector2i in cells:
		minimum.x = mini(minimum.x, cell.x)
		minimum.y = mini(minimum.y, cell.y)
	var normalized: Array[Vector2i] = []
	for cell: Vector2i in cells:
		normalized.append(cell - minimum)
	return normalized

static func cells_key(cells: Array[Vector2i]) -> String:
	var parts: PackedStringArray = []
	var normalized: Array[Vector2i] = normalize_cells(cells)
	normalized.sort_custom(func(left: Vector2i, right: Vector2i) -> bool: return left.y < right.y or (left.y == right.y and left.x < right.x))
	for cell: Vector2i in normalized:
		parts.append("%d:%d" % [cell.x, cell.y])
	return ";".join(parts)

static func _typed_cells(cells: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell: Variant in cells:
		result.append(cell as Vector2i)
	return result
