shader_type canvas_item;

uniform bool isOn = true;
uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_opacity: hint_range(0.0, 1.0, 0.1) = 0;
uniform float opacity : hint_range(0.0, 1.0, 0.1) = 1.0;

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

void fragment() {
	if (isOn) {
		vec4 color = texture(TEXTURE, UV);
		color.rgb = mix(color.rgb, flash_color.rgb, flash_opacity);
		color.a = opacity * when_gt(color.a, 0);
		COLOR = color;
	}
}
