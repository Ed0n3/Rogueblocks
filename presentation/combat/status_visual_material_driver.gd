class_name StatusVisualMaterialDriver
extends RefCounted

const STRENGTH_PARAMETERS: Array[StringName] = [
	&"burn_strength",
	&"poison_strength",
	&"fracture_strength",
	&"shield_strength",
	&"empowered_strength",
	&"recovery_strength",
	&"electrified_strength",
	&"weakened_strength",
	&"slowed_strength",
	&"thorns_strength",
]

static func reset(material: ShaderMaterial) -> void:
	if material == null:
		return
	for parameter: StringName in STRENGTH_PARAMETERS:
		material.set_shader_parameter(parameter, 0.0)

static func effect_strength(material: ShaderMaterial, channel: StatusVisualChannel.Value) -> float:
	var parameter: StringName = _strength_parameter(channel)
	return float(material.get_shader_parameter(parameter)) if material != null and not parameter.is_empty() else 0.0

static func apply(material: ShaderMaterial, visual: StatusVisualDefinition, stacks: int, reduced_motion: bool) -> void:
	if material == null or visual == null:
		return
	var strength_parameter: StringName = _strength_parameter(visual.channel)
	if strength_parameter.is_empty():
		return
	var strength: float = maxf(effect_strength(material, visual.channel), visual.strength_for_stacks(stacks))
	material.set_shader_parameter(strength_parameter, strength)
	var color_parameter: StringName = _color_parameter(visual.channel)
	if not color_parameter.is_empty():
		material.set_shader_parameter(color_parameter, visual.primary_color)
	var secondary_color_parameter: StringName = _secondary_color_parameter(visual.channel)
	if not secondary_color_parameter.is_empty():
		material.set_shader_parameter(secondary_color_parameter, visual.secondary_color)
	var speed_parameter: StringName = _speed_parameter(visual.channel)
	if not speed_parameter.is_empty():
		material.set_shader_parameter(speed_parameter, 0.0 if reduced_motion else visual.pulse_speed)

static func _strength_parameter(channel: StatusVisualChannel.Value) -> StringName:
	match channel:
		StatusVisualChannel.Value.BURN:
			return &"burn_strength"
		StatusVisualChannel.Value.POISON:
			return &"poison_strength"
		StatusVisualChannel.Value.FRACTURE:
			return &"fracture_strength"
		StatusVisualChannel.Value.SHIELD:
			return &"shield_strength"
		StatusVisualChannel.Value.EMPOWERED:
			return &"empowered_strength"
		StatusVisualChannel.Value.RECOVERY:
			return &"recovery_strength"
		StatusVisualChannel.Value.ELECTRIFIED:
			return &"electrified_strength"
		StatusVisualChannel.Value.WEAKENED:
			return &"weakened_strength"
		StatusVisualChannel.Value.SLOWED:
			return &"slowed_strength"
		StatusVisualChannel.Value.THORNS:
			return &"thorns_strength"
	return &""

static func _color_parameter(channel: StatusVisualChannel.Value) -> StringName:
	var strength_parameter: StringName = _strength_parameter(channel)
	return StringName(String(strength_parameter).trim_suffix("_strength") + "_color") if not strength_parameter.is_empty() else &""

static func _secondary_color_parameter(channel: StatusVisualChannel.Value) -> StringName:
	var strength_parameter: StringName = _strength_parameter(channel)
	return StringName(String(strength_parameter).trim_suffix("_strength") + "_secondary_color") if not strength_parameter.is_empty() else &""

static func _speed_parameter(channel: StatusVisualChannel.Value) -> StringName:
	var strength_parameter: StringName = _strength_parameter(channel)
	return StringName(String(strength_parameter).trim_suffix("_strength") + "_speed") if not strength_parameter.is_empty() else &""
