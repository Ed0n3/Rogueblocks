class_name PieceChoiceCard
extends Button

var piece: PieceDefinition
var selected: bool = false
var placeable: bool = true
var forced: bool = false
var modifiers: Array[PieceModifierDefinition] = []

func set_piece(definition: PieceDefinition, is_selected: bool, can_place: bool, is_forced: bool) -> void:
	piece = definition
	selected = is_selected
	placeable = can_place
	forced = is_forced
	text = ""
	tooltip_text = "No valid placement" if not placeable else definition.display_name
	queue_redraw()

func set_modifiers(states: Array[PieceModifierState]) -> void:
	modifiers.clear()
	for state: PieceModifierState in states:
		var definition: PieceModifierDefinition = state.definition
		if definition != null:
			modifiers.append(definition)
	if piece != null and not modifiers.is_empty():
		var details: PackedStringArray = []
		for definition: PieceModifierDefinition in modifiers:
			details.append("%s: %s" % [definition.display_name, definition.description])
		tooltip_text = "%s\n\n%s" % [piece.display_name, "\n".join(details)]
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED or what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()

func _draw() -> void:
	if piece == null:
		return
	var shape_area: Rect2 = Rect2(12.0, 8.0, size.x - 24.0, maxf(24.0, size.y - 40.0))
	var shape_color: Color = Color(piece.preview_color, 0.92 if placeable else 0.25)
	var outline: Color = Color("7ee7d8") if selected else (Color("f1c75b") if forced else Color("a3acc5"))
	PieceDrawing.draw_cells(self, PieceRotationService.normalize_cells(piece.base_cells), shape_area, shape_color, outline)
	var label: String = piece.display_name if placeable else "NO SPACE"
	var label_color: Color = Color("e9edfa") if placeable else Color("ff786f")
	draw_string(ThemeDB.fallback_font, Vector2(8.0, size.y - 9.0), label, HORIZONTAL_ALIGNMENT_CENTER, size.x - 16.0, 14, label_color)
	if selected:
		draw_line(Vector2(12.0, 5.0), Vector2(size.x - 12.0, 5.0), Color("7ee7d8"), 3.0)
	if not placeable:
		draw_line(Vector2(15.0, 15.0), Vector2(size.x - 15.0, size.y - 15.0), Color("ff786f"), 2.0)
	for index: int in mini(3, modifiers.size()):
		var definition: PieceModifierDefinition = modifiers[index]
		var color: Color = definition.visual_definition.accent_color if definition.visual_definition != null else Color.WHITE
		var center: Vector2 = Vector2(size.x - 13.0 - float(index) * 14.0, 14.0)
		draw_circle(center, 5.0, Color(color, 0.24))
		draw_arc(center, 5.0, 0.0, TAU, 12, color, 1.5, true)
	if modifiers.size() > 3:
		draw_string(ThemeDB.fallback_font, Vector2(size.x - 58.0, 18.0), "+%d" % (modifiers.size() - 3), HORIZONTAL_ALIGNMENT_LEFT, 20.0, 9, Color.WHITE)
	if not modifiers.is_empty():
		var accent: Color = modifiers[0].visual_definition.accent_color if modifiers[0].visual_definition != null else Color.WHITE
		draw_rect(Rect2(2.0, 2.0, size.x - 4.0, size.y - 4.0), Color(accent, 0.85), false, 2.0)
