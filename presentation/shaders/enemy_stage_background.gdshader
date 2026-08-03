shader_type canvas_item;

uniform vec4 accent_color : source_color = vec4(0.49, 0.32, 0.8, 1.0);
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.25;
uniform float animation_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 centered = UV - vec2(0.5);
	float time_offset = TIME * 0.025 * animation_strength;
	vec2 shifted_uv = UV + vec2(time_offset, -time_offset * 0.6);
	vec2 grid_coordinates = abs(fract(shifted_uv * vec2(18.0, 11.0)) - vec2(0.5));
	float grid = smoothstep(0.46, 0.5, max(grid_coordinates.x, grid_coordinates.y));
	float vignette = 1.0 - smoothstep(0.22, 0.78, length(centered));
	float pulse = 0.72 + sin(TIME * 1.3) * 0.12 * animation_strength;
	vec3 base_color = mix(vec3(0.025, 0.03, 0.07), vec3(0.075, 0.055, 0.13), UV.y);
	vec3 glow = accent_color.rgb * vignette * (0.08 + pulse_strength * 0.16 * pulse);
	vec3 grid_color = accent_color.rgb * grid * 0.07;
	COLOR = vec4(base_color + glow + grid_color, 1.0);
}
