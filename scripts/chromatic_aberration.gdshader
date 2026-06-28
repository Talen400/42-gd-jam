shader_type canvas_item;

uniform float time;
uniform bool active;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (active) {
		float offset = sin(UV.y * 20.0 + time * 5.0) * 0.03;
		vec4 r = texture(TEXTURE, UV + vec2(offset, 0.0));
		vec4 g = texture(TEXTURE, UV);
		vec4 b = texture(TEXTURE, UV - vec2(offset, 0.0));
		COLOR = vec4(r.r, g.g, b.b, col.a);
	} else {
		COLOR = col;
	}
}
