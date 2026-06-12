shader_type canvas_item;

uniform float bar_count = 50.0;
uniform float seed = 12.345;

// Simple random function
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

void fragment() {
    // Divide the UV.x into sections based on bar_count
    float bar_id = floor(UV.x * bar_count);
    
    // Generate a random value for this bar
    float rand = hash(bar_id + seed);
    
    // Make bars black (0) or white (1) based on the random value
    float color = step(0.5, rand);
    
    COLOR = vec4(vec3(color), 1.0);
}
