shader_type canvas_item;

uniform vec4 combo_color : source_color = vec4(0.49, 0.91, 0.85, 1.0);
uniform float combo_strength : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed : hint_range(0.0, 6.0) = 0.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	float pulse = 0.78;
	if (pulse_speed > 0.0) {
		pulse = 0.72 + sin(TIME * pulse_speed) * 0.2;
	}
	float effect_strength = clamp(combo_strength * pulse, 0.0, 1.0);
	vec3 tinted = mix(source.rgb, combo_color.rgb, effect_strength * 0.72);
	vec3 highlight = combo_color.rgb * effect_strength * source.a * 0.22;
	COLOR = vec4(tinted + highlight, source.a);
}
