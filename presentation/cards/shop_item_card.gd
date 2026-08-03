class_name ShopItemCard
extends Button

signal preview_requested(item: ShopItem)

var view_state: ShopItemViewState
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()

func _ready() -> void:
	mouse_entered.connect(_preview)
	focus_entered.connect(_preview)

func setup(state: ShopItemViewState) -> void:
	view_state = state
	%ItemIcon.setup(view_state)
	%Name.text = view_state.item.display_name
	%Subtype.text = view_state.subtype_name.to_upper()
	%Summary.text = view_state.short_summary
	%Price.text = "%d SHARDS" % view_state.item.final_price
	%State.text = view_state.status_text.to_upper()
	%Price.add_theme_color_override("font_color", _price_color())
	%State.add_theme_color_override("font_color", _state_color())
	self_modulate = Color(1.0, 1.0, 1.0, 0.58 if view_state.availability != ShopItemViewState.Availability.AFFORDABLE else 1.0)
	tooltip_text = "%s\n%s\n%d Shards\n%s" % [view_state.category_name, view_state.short_summary, view_state.item.final_price, view_state.status_text]
	queue_redraw()

func _preview() -> void:
	if view_state != null:
		preview_requested.emit(view_state.item)

func _draw() -> void:
	if view_state == null:
		return
	var border_color: Color = view_state.accent_color
	draw_line(Vector2(8.0, 5.0), Vector2(size.x - 8.0, 5.0), Color(border_color, 1.0 if selected or is_hovered() or has_focus() else 0.55), 4.0 if selected else 2.0, true)
	if selected or is_hovered() or has_focus():
		draw_rect(Rect2(1.0, 1.0, size.x - 2.0, size.y - 2.0), Color(border_color, 0.72), false, 2.0)
	if view_state.availability == ShopItemViewState.Availability.UNAVAILABLE:
		var stripe_x: float = -size.y
		while stripe_x < size.x:
			draw_line(Vector2(stripe_x, size.y), Vector2(stripe_x + size.y, 0.0), Color(0.8, 0.52, 0.45, 0.13), 2.0)
			stripe_x += 16.0
	if view_state.availability == ShopItemViewState.Availability.PURCHASED:
		draw_string(get_theme_font("font"), Vector2(10.0, size.y * 0.56), "BOUGHT", HORIZONTAL_ALIGNMENT_CENTER, size.x - 20.0, 22, Color("7ee7d8"))

func _price_color() -> Color:
	return Color("e98a72") if view_state.availability == ShopItemViewState.Availability.UNAFFORDABLE else Color("7ee7d8")

func _state_color() -> Color:
	match view_state.availability:
		ShopItemViewState.Availability.AFFORDABLE:
			return Color("82e6c6")
		ShopItemViewState.Availability.UNAFFORDABLE:
			return Color("e98a72")
		ShopItemViewState.Availability.UNAVAILABLE:
			return Color("e8b965")
		_:
			return Color("8293aa")
