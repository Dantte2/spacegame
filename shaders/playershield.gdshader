shader_type canvas_item;

// Shield parameters
uniform float shield_length = 0.3;  // horizontal distance between left/right circle centers
uniform float shield_radius = 0.25; // radius of each circle

// Hit parameters
uniform vec2 hit_uv = vec2(0.5, 0.5); // hit location [0-1]
uniform float hit_strength = 1.0;     // intensity
uniform float hit_glow_radius = 0.1;  // glow falloff
uniform vec4 hit_color = vec4(0.5, 0.8, 1.0, 1.0); // hit glow color

void fragment() {
    // Center UV
    vec2 uv = UV - vec2(0.5);

    // Aspect correction
    float aspect = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
    vec2 uv_corr = uv * vec2(aspect, 1.0);

    // Circle centers
    vec2 left_center = vec2(-shield_length * 0.5, 0.0);
    vec2 right_center = vec2(shield_length * 0.5, 0.0);
    vec2 center_center = vec2(0.0, 0.0); // middle circle

    // Distance to each circle edge
    float d_left = length(uv_corr - left_center) - shield_radius;
    float d_right = length(uv_corr - right_center) - shield_radius;
    float d_center = length(uv_corr - center_center) - shield_radius;

    // Minimum distance gives smooth capsule
    float dist = min(d_left, min(d_right, d_center));

    // Shield mask (1 inside capsule, 0 outside)
    float shield_mask = smoothstep(0.01, 0.0, dist);

    // Hit distance from impact point
    vec2 hit_local = hit_uv - vec2(0.5);
    hit_local.x *= aspect; // aspect correction
    float hit_dist = length(uv_corr - hit_local);

    // Hit glow with Gaussian falloff
    float hit_glow = exp(-pow(hit_dist / hit_glow_radius, 2.0)) * hit_strength;

    // Constrain glow to shield shape
    hit_glow *= shield_mask;

    // Output: only hit glow (shield invisible)
    COLOR = hit_color * hit_glow;
}
