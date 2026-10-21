shader_type spatial;
render_mode cull_back;
uniform vec4 canopy_tone : source_color = vec4(0.3, 0.6, 0.3, 1.0);
uniform float wind_clock = 0.0;
uniform float wind_strength = 0.0;
varying float canopy_shade;
void vertex() {
 vec3 at = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
 float tip = clamp((VERTEX.y + 2.25) / 4.5, 0.0, 1.0);
 float breeze = sin(wind_clock * 1.25 + at.x * 0.13 + at.z * 0.09);
 VERTEX.x += breeze * tip * wind_strength * 0.23;
 VERTEX.z += cos(wind_clock * 0.85 + at.x * 0.1) * tip * wind_strength * 0.13;
 canopy_shade = mix(0.76, 1.04, tip);
}
void fragment() {
 ALBEDO = canopy_tone.rgb * COLOR.rgb * canopy_shade;
 ROUGHNESS = 0.92;
}
