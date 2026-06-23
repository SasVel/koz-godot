shader_type canvas_item;

uniform bool is_lines_inverted = false;

vec4 screen(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

bool is_black_pc(vec4 c, float eps) {
    vec4 d = abs(c);
    return d.r <= eps && d.g <= eps && d.b <= eps;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (is_black_pc(tex.rgba, 0.74) && is_lines_inverted) {
    	tex.rgb = 1.0 - tex.rgb;
    	COLOR = screen(tex, COLOR);
    }
    else {
    	tex.rgba = COLOR;
    	COLOR = tex;
    }
}