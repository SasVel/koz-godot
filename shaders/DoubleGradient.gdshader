shader_type canvas_item;
render_mode unshaded;

uniform vec2 direction = vec2(0.0, -1.0);
uniform vec4 start_color : source_color;
uniform vec4 end_color : source_color;

uniform float rotate_speed : hint_range(0.0, 5.0, 0.1) = 2.0;

uniform float time_scale : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float opacity : hint_range(0.0, 1.0, 0.1) = 0.5;


float vmax(vec4 vec)
{
	return max(vec.x, max(vec.y, max(vec.z, vec.w)));
}

float random(vec2 seed, float pmin, float pmax)
{
	return pmin + fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123) * (pmax - pmin);
}

float get_color_count(float range)
{
	return ceil(clamp(range, 0.0, 1.0) * 255.0);
}

float get_delta(vec2 uv)
{
	vec2 dir = normalize(direction);
	return (dir.x < 0.0 ? (1.0 - uv.x) : uv.x) * dir.x * dir.x + (dir.y < 0.0 ? (1.0 - uv.y) : uv.y) * dir.y * dir.y;
}

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));

	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment()
{
	vec2 uv = UV + ((sin(TIME) * cos(TIME)) * time_scale);
	uv = rotate(uv, vec2(0.5), rotate_speed * TIME * time_scale);
	float color_count = get_color_count(vmax(abs(end_color - start_color)));
	float inv_color_count = 1.0 / color_count;

	float color_index = floor(get_delta(uv) * color_count);
	vec4 color1 = mix(start_color, end_color, color_index / color_count);
	vec4 color2 = mix(start_color, end_color, (color_index + 1.0) / color_count);

	float ratio = clamp(mod(get_delta(uv), inv_color_count) * color_count + random(uv, -0.5, 0.5), 0.0, 1.0);
	vec4 screen = texture(TEXTURE, UV);

	COLOR = color1 * (1.0 - ratio) + color2 * ratio;
	COLOR.a = min(screen.a, opacity);
}