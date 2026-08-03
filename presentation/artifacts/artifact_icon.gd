class_name ArtifactIcon
extends Control

var definition: BossArtifactDefinition

func setup(artifact: BossArtifactDefinition) -> void:
	definition = artifact
	queue_redraw()

func _draw() -> void:
	if definition == null:
		return
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.32
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in 6:
		var angle: float = -PI * 0.5 + TAU * float(index) / 6.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, Color(definition.accent_color, 0.2))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[4], points[5], points[0]]), definition.accent_color, 2.0, true)
	var inner_radius: float = radius * 0.45
	draw_circle(center, inner_radius, Color(definition.accent_color, 0.38))
	draw_arc(center, inner_radius, 0.0, TAU, 16, definition.accent_color.lightened(0.25), 2.0, true)
