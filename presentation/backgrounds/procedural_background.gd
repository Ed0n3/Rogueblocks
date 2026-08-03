class_name ProceduralBackground
extends Control

@export var tokens: VisualTokens
@export var focal_position: Vector2 = Vector2(0.62, 0.42)
@export var pattern_opacity: float = 0.12

var phase: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tokens == null:
		tokens = load("res://presentation/theme/visual_tokens.tres") as VisualTokens
	set_process(visible)

func _process(delta: float) -> void:
	phase = fmod(phase + delta * 4.0, 64.0)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(visible)

func _draw() -> void:
	if tokens == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), tokens.background_deep, true)
	var bands: int = 18
	for index: int in bands:
		var ratio: float = float(index) / float(bands)
		var band_color: Color = tokens.background_deep.lerp(tokens.background_raised, ratio * 0.7)
		draw_rect(Rect2(0.0, size.y * ratio, size.x, size.y / float(bands) + 1.0), band_color, true)
	var focal: Vector2 = size * focal_position
	for ring: int in 10:
		var radius: float = 360.0 - float(ring) * 30.0
		var alpha: float = 0.006 + float(ring) * 0.002
		draw_circle(focal, radius, Color(tokens.secondary_blue, alpha), true)
	var spacing: float = 64.0
	var offset: float = phase
	var line_color: Color = Color(tokens.border_subtle, pattern_opacity)
	var start_x: float = -size.y + offset
	while start_x < size.x:
		draw_line(Vector2(start_x, 0.0), Vector2(start_x + size.y, size.y), line_color, 1.0)
		start_x += spacing
	for x: float in range(0, int(size.x) + 1, 96):
		for y: float in range(0, int(size.y) + 1, 96):
			var pulse: float = 0.14 + 0.06 * sin((x + y + phase * 3.0) * 0.02)
			draw_circle(Vector2(x, y), 1.5, Color(tokens.primary_cyan, pulse))
