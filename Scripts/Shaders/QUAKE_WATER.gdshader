shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest;

uniform float warp_speed     : hint_range(0.0, 5.0)  = 1.0;
uniform float warp_intensity : hint_range(0.0, 1.5)  = 0.12;
uniform float warp_closeness : hint_range(0.01, 10.0) = 2.0;

uniform vec2  flow_dir = vec2(1.0, 0.0);
uniform float flow_speed : hint_range(0.0, 5.0) = 0.0;

uniform float uv_scale : hint_range(0.1, 2048.0) = 1.0;

void fragment() {
	float t  = TIME * warp_speed;

	vec2 uv = UV * uv_scale;
	uv += normalize(flow_dir) * TIME * flow_speed;

	float nx = uv.x / warp_closeness;
	float ny = uv.y / warp_closeness;

	float warped_x = nx + warp_intensity * sin(t + ny * 2.0);
	float warped_y = ny + warp_intensity * sin(t + nx * 2.0);

	vec2 finalUV = vec2(warped_x, warped_y) * warp_closeness;

	vec3 color = texture(albedo_texture, finalUV).rgb;

	ALBEDO   = color;
	SPECULAR = 0.0;
}