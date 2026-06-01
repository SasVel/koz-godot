shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float grayscale = (original.r + original.g + original.g) / 3.0f;
	vec4 grayscale_color = vec4(vec3(grayscale), original.a);
	COLOR = grayscale_color * color;
}
