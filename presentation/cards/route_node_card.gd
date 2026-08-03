class_name RouteNodeCard
extends Button

const SYMBOL_SIZE_RATIO: float = 0.72
const FALLBACK_SYMBOL_RADIUS: float = 12.0

var node_type: RouteNodeState.NodeType = RouteNodeState.NodeType.NORMAL_COMBAT
var accent_color: Color = Color("75d7e8")
var symbol_texture: Texture2D

func configure_type(
	type: RouteNodeState.NodeType,
	color: Color,
	symbol: Texture2D
) -> void:
	node_type = type
	accent_color = color
	symbol_texture = symbol
	text = ""
	queue_redraw()

func _draw() -> void:
	var icon_rect: Rect2 = get_icon_rect()
	if symbol_texture != null:
		draw_texture_rect(symbol_texture, icon_rect, false)
	else:
		_draw_fallback_symbol(icon_rect.get_center())

func get_icon_rect() -> Rect2:
	var icon_size: float = minf(size.x, size.y) * SYMBOL_SIZE_RATIO
	return Rect2((size - Vector2.ONE * icon_size) * 0.5, Vector2.ONE * icon_size)

func _draw_fallback_symbol(center: Vector2) -> void:
	match node_type:
		RouteNodeState.NodeType.NORMAL_COMBAT:
			draw_line(center - Vector2(8.0, 8.0), center + Vector2(8.0, 8.0), accent_color, 3.0)
			draw_line(center + Vector2(8.0, -8.0), center - Vector2(8.0, 8.0), accent_color, 3.0)
		RouteNodeState.NodeType.RECOVERY:
			draw_arc(center + Vector2(3.0, 0.0), FALLBACK_SYMBOL_RADIUS, PI * 0.5, PI * 1.5, 14, accent_color, 3.0)
		RouteNodeState.NodeType.SHOP:
			draw_circle(center, FALLBACK_SYMBOL_RADIUS, Color(accent_color, 0.28))
			draw_arc(center, FALLBACK_SYMBOL_RADIUS, 0.0, TAU, 16, accent_color, 2.0)
		_:
			draw_colored_polygon(_polygon(center, FALLBACK_SYMBOL_RADIUS, 6), Color(accent_color, 0.35))
			draw_polyline(_closed_polygon(center, FALLBACK_SYMBOL_RADIUS, 6), accent_color, 2.0)

func _polygon(center: Vector2, radius: float, sides: int) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in sides:
		points.append(center + Vector2.from_angle(TAU * float(index) / float(sides)) * radius)
	return points

func _closed_polygon(center: Vector2, radius: float, sides: int) -> PackedVector2Array:
	var points: PackedVector2Array = _polygon(center, radius, sides)
	points.append(points[0])
	return points
