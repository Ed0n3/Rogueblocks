shader_type canvas_item;

uniform vec4 primary_color : source_color = vec4(0.2, 0.88, 1.0, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.92, 0.98, 1.0, 1.0);
uniform float effect_strength : hint_range(0.0, 1.0) = 0.58;
uniform float effect_speed : hint_range(0.0, 6.0) = 4.2;

float hash(vec2 value) {
	return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	float frame = floor(TIME * effect_speed * 6.0);
	float jitter = (hash(vec2(floor(UV.y * 12.0), frame)) - 0.5) * 0.34;
	float main_bolt = 1.0 - smoothstep(0.0, 0.065, abs(UV.x - 0.5 - jitter));
	float branch = 1.0 - smoothstep(0.0, 0.04, abs(UV.x - 0.72 + jitter * 0.7 + (UV.y - 0.5) * 0.32));
	float spark_seed = hash(floor(UV * 10.0) + vec2(frame, -frame));
	float sparks = step(0.94, spark_seed);
	float flicker = 0.55 + hash(vec2(frame, 2.0)) * 0.45;
	float edge = smoothstep(0.32, 0.5, max(abs(UV.x - 0.5), abs(UV.y - 0.5)));
	float mask = clamp(main_bolt + branch * 0.65 + sparks * 0.7 + edge * 0.18, 0.0, 1.0);
	vec3 effect_color = mix(primary_color.rgb, secondary_color.rgb, clamp(main_bolt + sparks, 0.0, 1.0));
	COLOR = vec4(effect_color, effect_strength * mask * flicker * source.a);
}
