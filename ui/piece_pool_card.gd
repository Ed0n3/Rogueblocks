class_name PiecePoolCard
extends Button

var entry: PiecePoolEntry

func setup(pool_entry: PiecePoolEntry) -> void:
	entry = pool_entry
	disabled = false
	self_modulate = Color(1.0, 1.0, 1.0, 1.0 if entry.is_enabled else 0.62)
	tooltip_text = _tooltip()
	queue_redraw()

func _draw() -> void:
	if entry == null:
		return
	PieceDrawing.draw_cells(self, entry.cells, Rect2(12.0, 8.0, size.x - 24.0, 44.0), Color(entry.color, 0.35 if not entry.is_enabled else 0.95), Color(entry.color.lightened(0.35), 0.55 if not entry.is_enabled else 1.0))
	var font: Font = get_theme_font("font")
	var color: Color = get_theme_color("font_disabled_color" if not entry.is_enabled else "font_color")
	draw_string(font, Vector2(8.0, 75.0), entry.display_name, HORIZONTAL_ALIGNMENT_CENTER, size.x - 16.0, 14, color)
	var effect_name: String = entry.intrinsic_effect.display_name if entry.intrinsic_effect != null else "FILLER PIECE"
	var effect_color: Color = entry.intrinsic_effect.accent_color if entry.intrinsic_effect != null else Color("8293aa")
	draw_string(font, Vector2(8.0, 96.0), effect_name, HORIZONTAL_ALIGNMENT_CENTER, size.x - 16.0, 12, effect_color)
	if not entry.is_enabled:
		draw_line(Vector2(8.0, size.y - 8.0), Vector2(size.x - 8.0, 8.0), Color("e8a06e"), 2.0)
		draw_string(font, Vector2(8.0, 18.0), "REMOVED", HORIZONTAL_ALIGNMENT_CENTER, size.x - 16.0, 10, Color("f0b06e"))
	if entry.is_new:
		draw_rect(Rect2(1.0, 1.0, size.x - 2.0, size.y - 2.0), Color("6fe5ee"), false, 2.0)
		draw_string(font, Vector2(size.x - 42.0, 16.0), "NEW", HORIZONTAL_ALIGNMENT_CENTER, 34.0, 10, Color("6fe5ee"))
	for index: int in mini(3, entry.modifier_colors.size()):
		var marker_color: Color = entry.modifier_colors[index]
		var marker: Vector2 = Vector2(11.0 + float(index) * 14.0, 11.0)
		draw_circle(marker, 4.5, Color(marker_color, 0.28))
		draw_arc(marker, 4.5, 0.0, TAU, 12, marker_color, 1.5, true)

func _tooltip() -> String:
	var modifiers: String = "None" if entry.modifier_descriptions.is_empty() else "\n".join(entry.modifier_descriptions)
	var piece_effect: String = "Filler piece: No intrinsic effect." if entry.intrinsic_effect == null else "%s: %s" % [entry.intrinsic_effect.display_name, entry.intrinsic_effect.description]
	return "%s\n\n%d cells | %d unique rotations\nPiece effect: %s\n\nModifiers:\n%s" % [entry.display_name, entry.cells.size(), entry.unique_rotation_count, piece_effect, modifiers]
