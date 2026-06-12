shader_type spatial;

uniform sampler2D albedo: source_color;
uniform sampler2D tile_noise: source_color;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform float tile_offset = 1.0;

vec3 textureNoTile(sampler2D tex, vec2 uv, float v){
	float k = texture(tile_noise, 0.005 * uv).x; // cheap (cache friendly) lookup

	vec2 duvdx = dFdx(uv);
	vec2 duvdy = dFdy(uv);

	float l = k * 8.0;
	float f = fract(l);

	float ia = floor(l);
	float ib = ia + 1.0;

	vec2 offa = sin(vec2(3.0, 7.0) * ia); // can replace with any other hash
	vec2 offb = sin(vec2(3.0, 7.0) * ib); // can replace with any other hash

	vec3 cola = textureGrad(tex, uv + v * offa, duvdx, duvdy).xyz;
	vec3 colb = textureGrad(tex, uv + v * offb, duvdx, duvdy).xyz;
	vec3 ab = cola - colb;
	float sum_ab = ab.x + ab.y + ab.z;

	return mix(cola, colb, smoothstep(0.2, 0.8, f - 0.1 * sum_ab));
}


void fragment() {
	ALBEDO.rgb = textureNoTile(albedo, UV * uv_scale, tile_offset);
}
