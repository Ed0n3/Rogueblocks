shader_type canvas_item;

uniform float dissolve_progress : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.2) = 0.05;
uniform vec4 edge_color : source_color = vec4(0.49, 0.91, 0.85, 1.0);
uniform float seed = 1.0;

float hash(vec2 value) {
	return fract(sin(dot(value, vec2(127.1, 311.7)) + seed) * 43758.5453);
}

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	float noise = hash(floor(UV * 180.0));
	float edge = smoothstep(dissolve_progress, dissolve_progress + edge_width, noise);
	float glow = step(dissolve_progress, noise) - step(dissolve_progress + edge_width, noise);
	COLOR = vec4(mix(source.rgb, edge_color.rgb, glow), source.a * edge);
}
