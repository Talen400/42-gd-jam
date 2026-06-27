shader_type canvas_item;

// Adicionado 'hint_default_white' para o jogo não quebrar caso o slot fique vazio
uniform sampler2D glitch_noise_tex : hint_default_white, filter_nearest, repeat_enable;

uniform float shake_power : hint_range(0.0, 0.1) = 0.03;
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
uniform float shake_speed : hint_range(0.0, 10.0) = 5.0;
uniform float chromatic_aberration : hint_range(0.0, 0.1) = 0.01;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    float enable_shift = float(random(vec2(trunc(TIME * shake_speed), 2.0)) < shake_rate);
    
    // Mudamos de SCREEN_UV para UV (coordenada local do Sprite)
    vec2 fixed_uv = UV;
    
    if (enable_shift > 0.5) {
        float noise_lookup = texture(glitch_noise_tex, vec2(UV.y, TIME)).r;
        fixed_uv.x += (noise_lookup - 0.5) * shake_power;
    }
    
    // Mudamos de SCREEN_TEXTURE para TEXTURE (textura original do seu Sprite)
    vec4 color_r = texture(TEXTURE, vec2(fixed_uv.x - chromatic_aberration * enable_shift, fixed_uv.y));
    vec4 color_g = texture(TEXTURE, fixed_uv);
    vec4 color_b = texture(TEXTURE, vec2(fixed_uv.x + chromatic_aberration * enable_shift, fixed_uv.y));
    
    COLOR = vec4(color_r.r, color_g.g, color_b.b, color_g.a);
}