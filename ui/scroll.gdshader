shader_type canvas_item;
render_mode blend_mix;

uniform vec2 speed;

void fragment () {
	vec2 scale = mod(vec2(TIME * speed.x, TIME * speed.y), 1.0f);
	COLOR = texture(TEXTURE, vec2(UV.x + scale.x, UV.y + scale.y));
}