#version 300 es

precision highp float;
uniform float t;
uniform vec2 r;

out vec4 outColor;

#include "$lib/fragCoordToUV.glsl";
#include "$lib/rotM.glsl";
#include "$lib/2d_sdf.glsl";
#include "$lib/perlin2d.glsl";

vec3 background(vec2 p) {
    float perlin = perlin2d(p + t * 0.2, 2, 3.);
    float perlin2 = perlin2d(p + t * 0.17, 2, 3.);

    float d = 999.;
    float m = 0.;

    float c1 = circle((p * 0.3 + vec2(0.3, 0.1) )  * vec2(.2, .2), 0.1)  + perlin * .5;
    
    float c2 = circle((p * 0.3  + vec2(-0.3, 0.1) ) * vec2(0.3, .15), 0.1) + perlin2 * .5;

    if (c1 < 0. && c1 < c2) {
        return fract(c1 * 200.) > 0.95 ? vec3(1.) : vec3(0.);
    } else if (c2 < 0. && c2 < c1) {
        return fract(c2 * 250.) > 0.95 ? vec3(1.) : vec3(0.);
    }

    return vec3(0.);
}

void main() {
    vec2 uv = fragCoordToUV(r, true);

    vec3 bg = background(uv);

    outColor = vec4(bg, 1.);
}