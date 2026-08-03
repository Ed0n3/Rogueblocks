class_name EnemyActor
extends Control

var texture: Texture2D
var enemy: EnemyDefinition
var accent_color: Color = Color("c58bff")

func configure(definition: EnemyDefinition, sprite_texture: Texture2D, accent: Color) -> void:
	enemy = definition
	texture = sprite_texture
	accent_color = accent
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if texture != null:
		var texture_size: Vector2 = texture.get_size()
		var scale_factor: float = minf(size.x / texture_size.x, size.y / texture_size.y)
		var draw_size: Vector2 = texture_size * scale_factor
		draw_texture_rect(texture, Rect2((size - draw_size) * 0.5, draw_size), false)
		return
	var center: Vector2 = Vector2(size.x * 0.5, size.y * 0.55)
	var seed_source: String = enemy.resource_path if enemy != null and not enemy.resource_path.is_empty() else enemy.display_name if enemy != null else "enemy"
	var seed_value: int = absi(seed_source.hash())
	var body_width: float = size.x * (0.2 + float(seed_value % 9) * 0.008)
	var body_height: float = size.y * 0.34
	var silhouette: Color = accent_color.darkened(0.45)
	var rim: Color = Color(accent_color, 0.9)
	draw_circle(center - Vector2(0.0, body_height * 0.62), body_width * 0.42, silhouette)
	draw_polygon(PackedVector2Array([center + Vector2(-body_width, body_height), center + Vector2(-body_width * 0.72, -body_height * 0.35), center + Vector2(0.0, -body_height * 0.7), center + Vector2(body_width * 0.72, -body_height * 0.35), center + Vector2(body_width, body_height)]), PackedColorArray([silhouette]))
	draw_arc(center, body_width * 1.06, PI * 0.12, PI * 0.88, 24, rim, 3.0)
	draw_circle(center - Vector2(body_width * 0.16, body_height * 0.68), 3.5, accent_color.lightened(0.35))
	draw_circle(center + Vector2(body_width * 0.16, -body_height * 0.68), 3.5, accent_color.lightened(0.35))
