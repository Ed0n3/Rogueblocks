class_name StatusHealthBar
extends ProgressBar

@export var effect_shader: Shader = preload("res://presentation/shaders/health_status_effects.gdshader") as Shader
@export_range(0.0, 2.0, 0.05) var minimum_effect_display_seconds: float = 0.45

class HeldStatusVisual extends RefCounted:
	var definition: StatusVisualDefinition
	var stacks: int = 1
	var active: bool = false
	var release_time_msec: int = 0

var effect_material: ShaderMaterial
var fill_style: StyleBoxFlat
var motion: MotionSettings
var held_visuals: Array[HeldStatusVisual] = []

func _ready() -> void:
	motion = MotionSettings.from_saved_settings(SaveService.settings)
	effect_material = material.duplicate() as ShaderMaterial if material is ShaderMaterial else ShaderMaterial.new()
	effect_material.shader = effect_shader
	material = effect_material
	var authored_fill: StyleBox = get_theme_stylebox("fill")
	fill_style = authored_fill.duplicate() as StyleBoxFlat if authored_fill is StyleBoxFlat else StyleBoxFlat.new()
	add_theme_stylebox_override("fill", fill_style)
	StatusVisualMaterialDriver.reset(effect_material)
	set_process(false)

func set_effects(statuses: StatusCollection) -> void:
	if effect_material == null:
		return
	var current_time_msec: int = Time.get_ticks_msec()
	for held_visual: HeldStatusVisual in held_visuals:
		held_visual.active = false
	if statuses != null:
		for instance: StatusInstance in statuses.instances:
			var definition: StatusDefinition = instance.definition
			if definition != null and definition.visual_definition != null and definition.visual_definition.applies_to_health:
				_activate_visual(definition.visual_definition, instance.stacks, current_time_msec)
	_remove_expired_visuals(current_time_msec)
	_apply_held_visuals()
	set_process(_has_releasing_visuals())

func set_base_color(color: Color) -> void:
	if fill_style != null:
		fill_style.bg_color = color

func get_effect_strength(channel: StatusVisualChannel.Value) -> float:
	return StatusVisualMaterialDriver.effect_strength(effect_material, channel)

func _process(_delta: float) -> void:
	if _remove_expired_visuals(Time.get_ticks_msec()):
		_apply_held_visuals()
	set_process(_has_releasing_visuals())

func _activate_visual(definition: StatusVisualDefinition, stacks: int, current_time_msec: int) -> void:
	var held_visual: HeldStatusVisual = _find_held_visual(definition)
	if held_visual == null:
		held_visual = HeldStatusVisual.new()
		held_visual.definition = definition
		held_visuals.append(held_visual)
	held_visual.stacks = maxi(held_visual.stacks, stacks) if held_visual.active else maxi(1, stacks)
	held_visual.active = true
	held_visual.release_time_msec = current_time_msec + roundi(minimum_effect_display_seconds * 1000.0)

func _find_held_visual(definition: StatusVisualDefinition) -> HeldStatusVisual:
	for held_visual: HeldStatusVisual in held_visuals:
		if held_visual.definition == definition:
			return held_visual
	return null

func _remove_expired_visuals(current_time_msec: int) -> bool:
	var changed: bool = false
	for index: int in range(held_visuals.size() - 1, -1, -1):
		var held_visual: HeldStatusVisual = held_visuals[index]
		if not held_visual.active and current_time_msec >= held_visual.release_time_msec:
			held_visuals.remove_at(index)
			changed = true
	return changed

func _apply_held_visuals() -> void:
	StatusVisualMaterialDriver.reset(effect_material)
	var ordered_visuals: Array[HeldStatusVisual] = held_visuals.duplicate()
	ordered_visuals.sort_custom(func(left: HeldStatusVisual, right: HeldStatusVisual) -> bool:
		if left.definition.priority != right.definition.priority:
			return left.definition.priority < right.definition.priority
		return left.definition.resource_path < right.definition.resource_path)
	for held_visual: HeldStatusVisual in ordered_visuals:
		StatusVisualMaterialDriver.apply(effect_material, held_visual.definition, held_visual.stacks, motion.reduced_motion)

func _has_releasing_visuals() -> bool:
	for held_visual: HeldStatusVisual in held_visuals:
		if not held_visual.active:
			return true
	return false
