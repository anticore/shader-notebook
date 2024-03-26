#version 300 es

precision highp float;
uniform float t;
uniform vec2 r;
uniform float squareSize;

out vec4 outColor;

#include "$lib/fragCoordToUV.glsl";
#include "$lib/checkerboard.glsl";


void main() {
    vec2 uv = fragCoordToUV(r, true);
    float c = checker(uv + sin(t) / 10., 4. - squareSize + abs(sin(t)) * 4.);
    outColor = vec4(vec3(c), 1.);
}