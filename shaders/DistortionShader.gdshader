shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D distortionTexture;
uniform float strength : hint_range(0.0, 0.1, 0.01) = 0.05;
uniform float time_scale : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float distortStr : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float rotate_speed : hint_range(0.0, 5.0, 0.1) = 2.0;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));

	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment(){
	float distortVal = max(sin(TIME * time_scale) * cos(TIME * time_scale), 0.3) * distortStr;
	vec2 textureUV = rotate(UV, vec2(0.5), rotate_speed * TIME * time_scale);
	vec4 distortedTexture = texture(distortionTexture, textureUV) * distortVal;
	vec2 distortedUV = SCREEN_UV + distortedTexture.x * strength;
	COLOR = texture(SCREEN_TEXTURE, distortedUV);
}