class_name ContentCard
extends Button

enum CardKind { UPGRADE, RELIC, SHOP_ITEM, EVENT_CHOICE, REWARD }

@export var card_kind: CardKind = CardKind.REWARD
@export var accent_color: Color = Color("7ee7d8")
@export var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()
@export var new_content: bool = false:
	set(value):
		new_content = value
		queue_redraw()

func _ready() -> void:
	theme_type_variation = &"RewardCard"
	if icon == null:
		icon = load("res://assets/icons/empty_texture.tres") as Texture2D
	queue_redraw()

func set_content(title: String, description: String, cost_text: String = "") -> void:
	text = "%s\n%s%s" % [title, description, "\n%s" % cost_text if not cost_text.is_empty() else ""]

func _draw() -> void:
	var width: float = 4.0 if selected else 2.0
	draw_line(Vector2(10.0, 5.0), Vector2(size.x - 10.0, 5.0), Color(accent_color, 0.95 if selected else 0.55), width, true)
	if disabled:
		var stripe_x: float = -size.y
		while stripe_x < size.x:
			draw_line(Vector2(stripe_x, size.y), Vector2(stripe_x + size.y, 0.0), Color(0.65, 0.68, 0.78, 0.1), 1.0)
			stripe_x += 14.0
	if new_content:
		draw_circle(Vector2(size.x - 13.0, 13.0), 5.0, accent_color)

