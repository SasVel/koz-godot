shader_type canvas_item;

// Size of polygon relative to the polygon that fits the viewport.
uniform float size : hint_range(0.0, 1.0) = 0.5;

// Number of sides of polygon
uniform int sides : hint_range(0, 50) = 6;

// Rotation of the polygon
uniform float rotation : hint_range(-360.0, 360.0) = 0.0;

// Center point of the polygon
uniform float position_x : hint_range(-1.0, 1.5) = 0.5;
uniform float position_y : hint_range(-1.0, 1.5) = 0.5;

// The width of the border around the polygon. If 0.0, there is no border.
uniform float border_width : hint_range(0.0, 1.0) = 0.1;

// The color to modulate the border area.
uniform vec4 border_color : source_color = vec4(0.35, 0.35, 1.0, 1.0);

// Optional color modulation parameter (multiplicative).
// Default is white (no change). Use this to modulate the whole image.
uniform vec4 modulate_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Whether to ensure that the polygon is regular with respect
// to the actual viewport aspect ratio.
uniform bool maintain_aspect_ratio = true;

void fragment() {
	// Pull in the texture.
	vec4 tex = texture(TEXTURE, UV);

	// Most of the logic presumes that there is some kind of non 1:1 aspect
	// ratio and adjusts the texture to suit logic that must assume there is a
	// 1:1 aspect ratio. If the maintain_aspect_ratio option is turned off,
	// however, the logic will assume a 1:1 ratio without it being true. This
	// will distort the triangles such that the area of the erasure is
	// proportional to the area of the image.
	vec2 aspect_ratio = vec2(1.0, 1.0);
	if (maintain_aspect_ratio) {
		aspect_ratio = vec2(
			min(1.0, TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x),
			min(1.0, TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y)
		);
	}
	
	vec2 adjusted_uv = vec2(
		((UV.x - position_x) * aspect_ratio.x) + 0.5,
		((UV.y - position_y) * aspect_ratio.y) + 0.5
	);
	
	adjusted_uv.x = mix(-1.0, 1.0, adjusted_uv.x);
	adjusted_uv.y = mix(-1.0, 1.0, adjusted_uv.y);
	
	float theta = atan(adjusted_uv.y, adjusted_uv.x) + (rotation * PI / 180.0);
	float angle = TAU / float(sides); // avoid divide by zero
	float half_angle = angle / 2.0;
	theta = mod(theta, angle) + half_angle;
	
	float corner_theta = atan(-aspect_ratio.y, -aspect_ratio.x);
	corner_theta = mod(corner_theta, angle) + half_angle;
	
	float corner_d = distance(vec2(0.0, 0.0), -aspect_ratio);
	float max_radius = corner_d * cos(half_angle - abs(half_angle - corner_theta));
	
	float scale = size * max_radius;
	float polygon_radius = scale / cos(half_angle - abs(half_angle - theta));
	
	float border_scale = (size - border_width) * max_radius;
	float border_radius = border_scale / cos(half_angle - abs(half_angle - theta));
	
	float d = distance(vec2(0.0, 0.0), adjusted_uv);
	
	// Start with the texture color
	vec4 out_col = tex;
	
	if (d > polygon_radius) {
		// outside polygon: make transparent
		out_col.a = 0.0;
	} else if (d > border_radius) {
		// border: mix with border_color (respecting border_color alpha)
		vec4 modulated_border = vec4(border_color.rgb * border_color.a, 1.0);
		out_col = mix(out_col, modulated_border, border_color.a);
	}
	
	// Apply global modulation parameter (multiplicative).
	// This lets users modulate the whole sprite via this uniform.
	out_col.rgb *= modulate_color.rgb;
	out_col.a *= modulate_color.a;
	
	// Output final color
	COLOR = out_col;
}

