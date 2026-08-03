class_name ArtifactRewardCard
extends Button

var definition: BossArtifactDefinition

func setup(artifact: BossArtifactDefinition) -> void:
	definition = artifact
	%ArtifactIcon.setup(definition)
	%Name.text = definition.display_name.to_upper()
	%Benefit.text = definition.benefit
	%Drawback.text = definition.drawback
	%DrawbackHeading.visible = not definition.drawback.is_empty()
	%Drawback.visible = not definition.drawback.is_empty()
	tooltip_text = "%s\n\n%s\n\nRisk: %s" % [definition.display_name, definition.benefit, definition.drawback]
	queue_redraw()

func _draw() -> void:
	if definition == null:
		return
	draw_line(Vector2(12.0, 6.0), Vector2(size.x - 12.0, 6.0), definition.accent_color, 3.0, true)
	if is_hovered() or has_focus():
		draw_rect(Rect2(1.0, 1.0, size.x - 2.0, size.y - 2.0), Color(definition.accent_color, 0.75), false, 2.0)
