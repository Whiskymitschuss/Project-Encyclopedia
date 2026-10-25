shader_type spatial;
render_mode cull_back;
uniform vec4 canopy_tone : source_color = vec4(0.3, 0.6, 0.3, 1.0);
varying float canopy_shade;
void vertex() {
 float tip = clamp((VERTEX.y + 2.25) / 4.5, 0.0, 1.0);
 canopy_shade = mix(0.76, 1.04, tip);
}
void fragment() {
 ALBEDO = canopy_tone.rgb * COLOR.rgb * canopy_shade;
 ROUGHNESS = 0.92;
}
