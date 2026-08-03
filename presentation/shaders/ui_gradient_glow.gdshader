shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.49, 0.91, 0.85, 1.0);
uniform vec4 color_b : source_color = vec4(0.47, 0.66, 1.0, 1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.7;

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	vec3 gradient = mix(color_a.rgb, color_b.rgb, UV.x);
	COLOR = vec4(mix(source.rgb, gradient, glow_strength * source.a), source.a);
}
