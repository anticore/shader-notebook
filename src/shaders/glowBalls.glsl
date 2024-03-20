#version 300 es

precision highp float;
uniform float t;
uniform vec2 r;

out vec4 outColor;

#include "$lib/fragCoordToUV.glsl";
#include "$lib/hg_sdf.glsl";
#include "$lib/rotM.glsl";
#include "$lib/iq_sdf.glsl";

float fBoxes(vec3 p, vec3 pos, vec3 b) {
    p.xy *= rotM(sin(t * 3.));
    p.y += sin(t * 2. + p.x * (1.2 + sin(t) / 2.));
    p = vec3(p.x, mod(p.y, 0.4), p.z);
    vec3 q = abs(p + pos) - b;
    return min(max(q.x, max(q.y, q.z)), 0.);
}

float sdSpheres(vec3 p) {
    p = p - mod(p, 0.16 * 0.1 - abs(cos(t)) / 5. );

    float spheres = 999.;
    for (int i = 0; i < 18; i++) {
        float p1 = t / 6. * float(i);
        float p2 = t / 7. * (5. - float(i));
        float p3 = t + float(i) * 2.;
      
        spheres = opSmooth(spheres, 
            fSphere(p + vec3(sin(p1)*3., cos(p2)*3., sin(p3)+12.), float(i) * 0.05), 1.);
    }
    
    return spheres;
}

vec2 map(vec3 p) {
    float s = fSphere(p + vec3(0.,0.,10.), 2.);
    float b = fBoxes(p, vec3(5.,0.,10.), vec3(10.,.2,5.));
    float bms = opMin(b,s);
    float ss = sdSpheres(p);
    
    return vec2(opSmooth(bms, ss, 0.5), ss < bms ? 1. : 0.);
}

vec3 tr(vec3 ro, vec3 rd){
    float td = 1.;
    vec2 h;
  
    vec3 c0 = vec3(0.);
    vec3 glo0 = vec3(abs(sin(t)) * 0.035,abs(cos(t)) * 0.035, 0.03);
    vec3 c1 = vec3(0.);
    
    vec3 glo1 = 0.015 
    * (0.5 + 0.5 * cos(t * 2. + rd.y*2. + vec3(4.,1.,0.))) 
    + 0.015 * (0.5 + 0.5 * cos(t * 3. + rd.y*5. + vec3(1.,4.,0.)));
  
    for (int i = 0; i < 100; i++) {
        h = map(ro + rd * td);
        td += h.x;
      
        if (h.y == 0.) c0 += glo0; 
        else c1 += glo1;
      
        if (h.x < 0.001 || h.x > 20.) break;
    }
    
    return c0 + c1;
}


void main() {
    vec2 uv = fragCoordToUV(r, true);

    vec3 ro= vec3(cos(t * 2.) / 4., sin(t * 2.93) * 0.2, 1.7);
    vec3 rd = normalize(vec3(uv, 0.) - ro);

    outColor = vec4(tr(ro, rd), 1);
}