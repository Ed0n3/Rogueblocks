class_name BoardStatusEffectLayer
extends Node2D

@export var effect_shader: Shader
@export var visual_definition: StatusVisualDefinition
@export var cell_texture: Texture2D
@export_range(0.0, 1.0) var overlay_opacity: float = 0.78

var effect_material: ShaderMaterial
var effect_cells: Array[Vector2i] = []
var tile_size: float = 128.0
var motion: MotionSettings

func _ready() -> void:
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	effect_material = ShaderMaterial.new()
	effect_material.shader = effect_shader
	material = effect_material
	_apply_visual_definition()

func set_cells(cells: Array[Vector2i]) -> void:
	if effect_cells == cells:
		return
	effect_cells = cells.duplicate()
	queue_redraw()

func set_tile_size(value: float) -> void:
	if is_equal_approx(tile_size, value):
		return
	tile_size = value
	queue_redraw()

func get_cell_count() -> int:
	return effect_cells.size()

func get_effect_strength() -> float:
	return float(effect_material.get_shader_parameter("effect_strength")) if effect_material != null else 0.0

func _draw() -> void:
	if cell_texture == null:
		return
	for cell: Vector2i in effect_cells:
		var rectangle: Rect2 = Rect2(Vector2(cell) * tile_size, Vector2.ONE * tile_size)
		draw_texture_rect(cell_texture, rectangle, false, Color(1.0, 1.0, 1.0, overlay_opacity))

func _apply_visual_definition() -> void:
	if effect_material == null or visual_definition == null:
		return
	effect_material.set_shader_parameter("primary_color", visual_definition.primary_color)
	effect_material.set_shader_parameter("secondary_color", visual_definition.secondary_color)
	effect_material.set_shader_parameter("effect_strength", visual_definition.maximum_strength)
	effect_material.set_shader_parameter("effect_speed", 0.0 if motion.reduced_motion else visual_definition.pulse_speed)
