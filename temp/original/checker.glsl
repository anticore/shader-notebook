#version 300 es

precision highp float;
uniform float t;
uniform vec2 r;

out vec4 outColor;

vec2 fragCoordToUV(vec2 r) {
  vec2 uv = vec2(gl_FragCoord.x / r.x, gl_FragCoord.y / r.y);
  return uv;
}
vec2 fragCoordToUV(vec2 r, bool center) {
  vec2 uv = fragCoordToUV(r);
  if (center == true) {
    uv -= 0.5; 
  }  
  uv /= vec2(r.y / r.x, 1.0);
  return uv;
}

float checker(vec2 p, float repeats) {
  float cx = floor(repeats * p.x);
  float cy = floor(repeats * p.y); 
  float result = mod(cx + cy, 2.0);
  return sign(result);
}


void main() {
    vec2 uv = fragCoordToUV(r, true);
    float c = checker(uv + sin(t) / 10., 4. + abs(sin(t)) * 4.);
    outColor = vec4(vec3(c), 1.);
}