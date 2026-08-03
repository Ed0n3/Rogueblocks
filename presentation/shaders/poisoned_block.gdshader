shader_type canvas_item;

uniform vec4 primary_color : source_color = vec4(0.55, 0.85, 0.25, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.68, 0.34, 0.9, 1.0);
uniform float effect_strength : hint_range(0.0, 1.0) = 0.48;
uniform float effect_speed : hint_range(0.0, 6.0) = 0.8;

float circle(vec2 point, vec2 center, float radius) {
	return 1.0 - smoothstep(radius - 0.02, radius + 0.03, distance(point, center));
}

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	float time_offset = TIME * effect_speed * 0.14;
	vec2 first_center = vec2(0.25, fract(0.82 - time_offset));
	vec2 second_center = vec2(0.68, fract(0.46 - time_offset * 0.72));
	vec2 third_center = vec2(0.48, fract(0.12 - time_offset * 1.18));
	float bubbles = circle(UV, first_center, 0.1) + circle(UV, second_center, 0.075) + circle(UV, third_center, 0.055);
	float corrosion = 0.5 + 0.5 * sin(UV.x * 17.0 + UV.y * 13.0 + TIME * effect_speed);
	vec3 effect_color = mix(primary_color.rgb, secondary_color.rgb, clamp(bubbles * 0.8 + corrosion * 0.25, 0.0, 1.0));
	float edge = 1.0 - smoothstep(0.0, 0.52, distance(UV, vec2(0.5)));
	float alpha = effect_strength * (0.2 + bubbles * 0.55 + corrosion * edge * 0.16) * source.a;
	COLOR = vec4(effect_color, alpha);
}
