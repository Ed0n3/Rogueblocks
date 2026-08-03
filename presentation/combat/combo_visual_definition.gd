class_name ComboVisualDefinition
extends Resource

@export_range(1, 20) var maximum_colored_combo: int = 6
@export var colors: Gradient

func color_for_combo(combo: int) -> Color:
	if colors == null:
		return Color.WHITE
	var color_position: float = clampf(float(combo) / float(maximum_colored_combo), 0.0, 1.0)
	return colors.sample(color_position)
