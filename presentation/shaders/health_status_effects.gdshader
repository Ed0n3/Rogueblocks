shader_type canvas_item;

uniform float burn_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 burn_color : source_color = vec4(1.0, 0.35, 0.08, 1.0);
uniform vec4 burn_secondary_color : source_color = vec4(1.0, 0.78, 0.22, 1.0);
uniform float burn_speed : hint_range(0.0, 6.0) = 1.6;
uniform float poison_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 poison_color : source_color = vec4(0.55, 0.85, 0.25, 1.0);
uniform vec4 poison_secondary_color : source_color = vec4(0.68, 0.34, 0.9, 1.0);
uniform float poison_speed : hint_range(0.0, 6.0) = 0.8;
uniform float fracture_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 fracture_color : source_color = vec4(0.58, 0.82, 1.0, 1.0);
uniform vec4 fracture_secondary_color : source_color = vec4(0.83, 0.93, 1.0, 1.0);
uniform float fracture_speed : hint_range(0.0, 6.0) = 0.0;
uniform float shield_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 shield_color : source_color = vec4(0.45, 0.95, 1.0, 1.0);
uniform vec4 shield_secondary_color : source_color = vec4(0.36, 0.7, 1.0, 1.0);
uniform float shield_speed : hint_range(0.0, 6.0) = 0.5;
uniform float empowered_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 empowered_color : source_color = vec4(1.0, 0.55, 0.2, 1.0);
uniform vec4 empowered_secondary_color : source_color = vec4(1.0, 0.82, 0.35, 1.0);
uniform float empowered_speed : hint_range(0.0, 6.0) = 1.2;
uniform float recovery_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 recovery_color : source_color = vec4(0.3, 0.95, 0.7, 1.0);
uniform vec4 recovery_secondary_color : source_color = vec4(0.55, 1.0, 0.82, 1.0);
uniform float recovery_speed : hint_range(0.0, 6.0) = 0.8;
uniform float electrified_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 electrified_color : source_color = vec4(0.2, 0.88, 1.0, 1.0);
uniform vec4 electrified_secondary_color : source_color = vec4(0.92, 0.98, 1.0, 1.0);
uniform float electrified_speed : hint_range(0.0, 6.0) = 4.2;
uniform float weakened_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 weakened_color : source_color = vec4(0.72, 0.76, 0.9, 1.0);
uniform vec4 weakened_secondary_color : source_color = vec4(0.28, 0.32, 0.48, 1.0);
uniform float weakened_speed : hint_range(0.0, 6.0) = 0.65;
uniform float slowed_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 slowed_color : source_color = vec4(0.4, 0.78, 0.95, 1.0);
uniform vec4 slowed_secondary_color : source_color = vec4(0.18, 0.32, 0.62, 1.0);
uniform float slowed_speed : hint_range(0.0, 6.0) = 0.55;
uniform float thorns_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 thorns_color : source_color = vec4(0.93, 0.35, 0.7, 1.0);
uniform vec4 thorns_secondary_color : source_color = vec4(0.45, 0.14, 0.46, 1.0);
uniform float thorns_speed : hint_range(0.0, 6.0) = 0.9;

float wave(float speed, float frequency, float phase) {
	return 0.5 + 0.5 * sin(TIME * speed + phase * frequency);
}

float hash(vec2 value) {
	return fract(sin(dot(value, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	vec3 result = source.rgb;
	float burn_wave = wave(burn_speed, 32.0, UV.x + UV.y * 0.4);
	float flame_mask = smoothstep(0.2, 0.95, 1.0 - UV.y + burn_wave * 0.26);
	result = mix(result, mix(burn_color.rgb, burn_secondary_color.rgb, burn_wave), burn_strength * (0.3 + flame_mask * 0.55) * source.a);
	float poison_bubbles = 1.0 - smoothstep(0.0, 0.12, abs(length(fract(UV * vec2(16.0, 3.0) + vec2(0.0, TIME * poison_speed * 0.12)) - 0.5) - 0.24));
	result = mix(result, mix(poison_color.rgb, poison_secondary_color.rgb, poison_bubbles), poison_strength * (0.35 + poison_bubbles * 0.5) * source.a);
	float fracture_line = 1.0 - smoothstep(0.0, 0.045, abs(fract(UV.x * 11.0 + floor(UV.y * 4.0) * 0.37) - 0.5));
	result = mix(result, mix(fracture_color.rgb, fracture_secondary_color.rgb, fracture_line), fracture_strength * fracture_line * source.a);
	float shield_wave = wave(shield_speed, 12.0, UV.x);
	float shield_edge = 1.0 - smoothstep(0.0, 0.22, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
	result = mix(result, mix(shield_color.rgb, shield_secondary_color.rgb, shield_wave), shield_strength * shield_edge * 0.7 * source.a);
	float empowered_wave = wave(empowered_speed, 18.0, UV.x);
	result += mix(empowered_color.rgb, empowered_secondary_color.rgb, empowered_wave) * empowered_strength * empowered_wave * 0.2 * source.a;
	float recovery_wave = wave(recovery_speed, 14.0, UV.x - UV.y);
	result = mix(result, mix(recovery_color.rgb, recovery_secondary_color.rgb, recovery_wave), recovery_strength * recovery_wave * 0.28 * source.a);
	float electric_time = floor(TIME * electrified_speed * 6.0);
	float electric_jitter = (hash(vec2(floor(UV.x * 22.0), electric_time)) - 0.5) * 0.5;
	float electric_bolt = 1.0 - smoothstep(0.0, 0.08, abs(UV.y - 0.5 - electric_jitter));
	float electric_flash = 0.5 + hash(vec2(electric_time, 4.0)) * 0.5;
	result += mix(electrified_color.rgb, electrified_secondary_color.rgb, electric_bolt) * electrified_strength * electric_bolt * electric_flash * source.a;
	result = mix(result, electrified_color.rgb, electrified_strength * 0.14 * electric_flash * source.a);
	float weakened_wave = wave(weakened_speed, 8.0, UV.x);
	result = mix(result, mix(weakened_secondary_color.rgb, weakened_color.rgb, weakened_wave), weakened_strength * 0.3 * source.a);
	float slowed_scan = smoothstep(0.74, 1.0, wave(slowed_speed, 30.0, UV.x));
	result = mix(result, mix(slowed_secondary_color.rgb, slowed_color.rgb, slowed_scan), slowed_strength * (0.16 + slowed_scan * 0.24) * source.a);
	float thorn_pattern = smoothstep(0.72, 1.0, abs(sin(UV.x * 42.0 + TIME * thorns_speed)) * (1.0 - abs(UV.y - 0.5)));
	result = mix(result, mix(thorns_secondary_color.rgb, thorns_color.rgb, thorn_pattern), thorns_strength * thorn_pattern * 0.55 * source.a);
	COLOR = vec4(result, source.a);
}
