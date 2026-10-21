shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, depth_draw_never;
uniform float clock = 0.0;
uniform float seed = 0.0;
uniform bool smoke = false;
uniform float opacity = 1.0;
uniform float cooling = 0.0;
float hash21(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash21(i),hash21(i+vec2(1,0)),f.x),mix(hash21(i+vec2(0,1)),hash21(i+vec2(1,1)),f.x),f.y);
}
void vertex() {
 // Camera-facing cards retain their actual world size and roof position.
 mat4 face=mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
 face[0].xyz*=length(MODEL_MATRIX[0].xyz);
 face[1].xyz*=length(MODEL_MATRIX[1].xyz);
 face[2].xyz*=length(MODEL_MATRIX[2].xyz);
 MODELVIEW_MATRIX=VIEW_MATRIX*face;
}
void fragment() {
 vec2 uv=UV;
 float n=noise(vec2(uv.x*6.0+seed,uv.y*7.0+clock*2.0));
 float detail=noise(vec2(uv.x*13.0+seed,uv.y*15.0+clock*3.4));
 if (smoke) {
  vec2 p=(uv-0.5)*2.0;
  float edge=length(p)+n*0.35+detail*0.13;
  ALPHA=(1.0-smoothstep(0.55,1.05,edge))*opacity*0.62;
  ALBEDO=mix(vec3(0.19,0.22,0.23),vec3(0.53,0.55,0.53),n*0.65+cooling*0.35);
 } else {
  float height=1.0-uv.y;
  float bend=sin(height*8.0-clock*3.3+seed)*height*0.13;
  float width=(1.0-height)*0.47;
  float edge=abs(uv.x-0.5+bend)+(n-0.5)*0.21+detail*0.05;
  float shape=1.0-smoothstep(max(0.0,width-0.1),width+0.025,edge);
  float core=clamp((width-edge)*5.0,0.0,1.0)*(1.0-height);
  ALPHA=shape*smoothstep(0.0,0.1,uv.y)*smoothstep(0.0,0.08,height)*opacity;
  ALBEDO=mix(vec3(1.0,0.18,0.025),vec3(1.0,0.91,0.43),core);
  EMISSION=ALBEDO*0.6;
 }
}
