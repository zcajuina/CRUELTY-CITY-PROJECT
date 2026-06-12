/*
DOOM Melting Screen-like shader!
With color controls and modulation
*/
shader_type canvas_item;

uniform uint subdivisions = 2; // How many subdivisions
uniform float movement: hint_range(0.0, 1.0, 0.01); // Control for animation

// Color controls
uniform vec4 tint_color: source_color = vec4(1.0); // RGB + Alpha tint
uniform float saturation: hint_range(0.0, 2.0, 0.01) = 1.0; // Color saturation
uniform float brightness: hint_range(0.0, 2.0, 0.01) = 1.0; // Brightness
uniform float contrast: hint_range(0.0, 2.0, 0.01) = 1.0; // Contrast
uniform float alpha_multiplier: hint_range(0.0, 1.0, 0.01) = 1.0; // Overall alpha

// Color wheel/tint options
uniform bool use_color_tint = true;
uniform float color_shift: hint_range(0.0, 1.0, 0.01) = 0.0; // Hue shift

// Random and noise code from godotshaders.com
vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), uv_fract.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), uv_fract.x), uv_fract.y) + 0.5;
}

// Convert RGB to HSV
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Convert HSV to RGB
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Apply color adjustments
vec4 apply_color_effects(vec4 color) {
    // Apply brightness and contrast
    color.rgb = (color.rgb - 0.5) * contrast + 0.5;
    color.rgb *= brightness;
    
    // Apply saturation
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(luminance), color.rgb, saturation);
    
    // Apply hue shift if needed
    if (color_shift > 0.0) {
        vec3 hsv = rgb2hsv(color.rgb);
        hsv.x = mod(hsv.x + color_shift, 1.0);
        color.rgb = hsv2rgb(hsv);
    }
    
    // Apply color tint
    if (use_color_tint) {
        color.rgb *= tint_color.rgb;
    }
    
    // Apply alpha controls
    color.a *= tint_color.a; // Multiply by tint alpha
    color.a *= alpha_multiplier; // Multiply by global alpha multiplier
    
    return color;
}

void fragment() {
	// Get how much to offset based on noise
	float offset = max(noise(vec2(UV.x / (TEXTURE_PIXEL_SIZE.x * float(uint(textureSize(TEXTURE, 0).x) / subdivisions)), 1.0)), 0.0);
	
	// Offset column
	float col = UV.y - (movement + offset) * movement;
	
	// Get original texture color
	vec4 tex_color = texture(TEXTURE, vec2(UV.x, col));
	
	// Apply step for alpha (original melt effect)
	tex_color.a *= step(0.0, col);
	
	// Apply color effects
	COLOR = apply_color_effects(tex_color);
}