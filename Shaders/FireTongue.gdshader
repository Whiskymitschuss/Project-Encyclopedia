shader_type spatial;
render_mode unshaded, cull_disabled;
uniform float flame_clock = 0.0;
uniform float seed = 0.0;
varying float height;
void vertex() {
 height = clamp(VERTEX.y / 4.8, 0.0, 1.0);
 VERTEX.x += sin(flame_clock * 5.2 + height * 5.0 + seed) * height * 0.4;
 VERTEX.z += cos(flame_clock * 3.8 + height * 7.0 + seed) * height * 0.25;
 VERTEX.y *= 0.94 + 0.10 * sin(flame_clock * 6.3 + seed);
}
void fragment() {
 vec3 core = vec3(1.0, 0.91, 0.38);
 vec3 rim = vec3(1.0, 0.24, 0.035);
 ALBEDO = mix(core, rim, smoothstep(0.12, 0.95, height));
 EMISSION = ALBEDO * 0.25;
}
