shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.49, 0.91, 0.85, 1.0);
uniform float outline_width : hint_range(0.0, 6.0) = 1.5;
uniform float outline_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV) * COLOR;
	vec2 offset = TEXTURE_PIXEL_SIZE * outline_width;
	float surrounding_alpha = texture(TEXTURE, UV + vec2(offset.x, 0.0)).a;
	surrounding_alpha += texture(TEXTURE, UV - vec2(offset.x, 0.0)).a;
	surrounding_alpha += texture(TEXTURE, UV + vec2(0.0, offset.y)).a;
	surrounding_alpha += texture(TEXTURE, UV - vec2(0.0, offset.y)).a;
	float outline = clamp(surrounding_alpha, 0.0, 1.0) * (1.0 - source.a) * outline_strength;
	COLOR = mix(source, outline_color, outline);
}

