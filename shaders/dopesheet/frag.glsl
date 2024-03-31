#version 300 es

precision highp float;
uniform float t;
uniform vec2 r;
#include "$lib/dopesheetUniforms.glsl";

out vec4 outColor;

#include "$lib/fragCoordToUV.glsl";
#include "$lib/hsl2rgb.glsl";
#include "$lib/hg_sdf.glsl";
#include "$lib/rotM.glsl";

const float far = 80.;

vec3 bg(vec2 uv) {
    return hsl2rgb(vec3(dA2 * uv.x + t * .1, dA3 + uv.x, abs(uv.y) * uv.y));
}

vec2 map(vec3 p) {
    p.z += 5.;
    p.xz *= rotM(t);
    p.yx *= rotM(t);
    vec2 sphere = vec2(fSphere(p, 1.), 0.);
    vec2 box = vec2(fBox(p, vec3(1.)), 1.);
    vec2 torus = vec2(fTorus(p, .3, 1.), 2.);
    
    vec2 scene = sphere;
    if (dA1 == 1.) scene = box;
    else if (dA1 == 2.) scene = torus;

    return scene;
}

#include "$lib/f_norm.glsl";

vec2 tr(vec3 ro, vec3 rd){
    vec2 h;
    vec2 res = vec2(0.);

    for (int i = 0; i < 128; i++) {
        h = map(ro + rd * res.x);
        if (h.x < 0.0001 || h.x > far) break;
        res.x += h.x; res.y = h.y;
    }
    
    return res;
}

void main() {
    vec2 uv = fragCoordToUV(r, true);

    vec3 ro = vec3(0., 0., 1.);
    vec3 rd = normalize(vec3(uv, 0.) - ro);

    vec3 c = bg(uv);

    vec2 h = tr(ro, rd);

    if(h.x<far){
        vec3 hp = ro + rd * h.x;
        vec3 hn = f_norm(hp);
        vec3 ld = normalize(vec3(-.1,.4,.3));

        if (h.y == 0.) {
            c = vec3(.1);
        } else if (h.y == 1.) {
            c = vec3(.3);
        } else if (h.y == 2.) {
            c = vec3(.5);
        }

        float diffuse = max(0.,dot(hn,ld));
        float fresnel=min(1.,pow(1.+dot(hn,rd),4.)); //Fresnel = background reflections on edges of geometry
        float specular=pow(max(dot(reflect(-ld,hn),-rd),0.),10.);//Specular = Bright highlights; 30 = specular power
        float ao=clamp(map(hp+hn*.1).x/.1,0.,1.);          //Ambient occlusion
        float sss=smoothstep(0.,1.,map(hp+ld*.1).x/.1);
        
        c = mix(specular+c*(ao+.1)*(diffuse+sss*.5),bg(uv),fresnel);
        c = mix(bg(uv),c,exp(-.001*h.x*h.x*h.x)); 
    }

    outColor = vec4(c, 1.);
}