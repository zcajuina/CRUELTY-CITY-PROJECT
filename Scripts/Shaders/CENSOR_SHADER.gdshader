shader_type spatial;

render_mode unshaded;

uniform sampler2D Screen_Texture:hint_screen_texture,filter_linear;

uniform vec2 Pixel_Grid = vec2(64.0, 64.0);
vec2 pixelate(vec2 uv) {
    return floor(uv * Pixel_Grid) / Pixel_Grid;
}

vec3 Blur_3x3(sampler2D Tex, vec2 uv, float Blur_Power, vec2 Screen_Size) {
    float px = 1.0 / Screen_Size.x;
    float py = 1.0 / Screen_Size.y;
    vec3 Sum = vec3(0.0);
    int Count = 0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 Offset = vec2(float(x) * px * Blur_Power, float(y) * py * Blur_Power);
            Sum += textureLod(Tex, uv + Offset, 0.0).rgb;
            Count++;
        }
    }

    return Sum / float(Count);
}
uniform float Blur_Amount = 2.0;

void fragment() {
	vec2 Screen_UV_Coords = SCREEN_UV;
	float Aspect_Ratio = VIEWPORT_SIZE.y / VIEWPORT_SIZE.x;

	vec2 Scaled_UV = (Screen_UV_Coords - vec2(0.5)) * vec2(1.0, Aspect_Ratio) + vec2(0.5);
	
	vec2 uv = SCREEN_UV;
	uv = pixelate(uv);
	
	vec3 Final_Color = Blur_3x3(Screen_Texture,uv,Blur_Amount,vec2(1280,720));
	
	ALBEDO = Final_Color;
}
