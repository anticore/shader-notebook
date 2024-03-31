#version 300 es

precision highp float;
uniform float t;
uniform vec2 r;
#include "$lib/dopesheetUniforms.glsl";

out vec4 outColor;

#include "$lib/fragCoordToUV.glsl";
#include "$lib/hsl2rgb.glsl";
#include "$lib/hg_sdf.glsl";
#include "$lib/mo.glsl";
#include "$lib/smin.glsl";
#include "$lib/rotM.glsl";

const float far = 30.;

vec3 bg(vec2 uv) {
    return vec3(0.05, 0.04, .1);
}

float bgBoxes(vec3 p) {

    p.z += 10.;

    p.xz *= rotM(p.y * 0.06);
    p.yx *= rotM(0.5);

    vec3 cp = p;

    mo(p.xz, vec2(1.9));
    
    float ipx = pModInterval1(p.y, 2.4,-3., 3.);
    float ipy = pModInterval1(p.x, 1.4,-1., 1.);

    mo(p.xy, vec2(.8));

    float metalBoxes = smin(
                fBox(p, vec3(0.3)),
                fBox(p + vec3(.2), vec3(.3, 1., .3)),  
                0.1
            ) - 0.05;

    cp += vec3(-.12);
    vec3 cpi = pMod3(cp, vec3(.18));
    float minusBoxes = fBox(cp, vec3(.03, 0.03, 0.07)); 

    return fOpDifferenceChamfer(metalBoxes, minusBoxes, .02);
}

float waterPlane(vec3 p) {
    return  fPlane(p, vec3(0., 1., 0.), 2.);
}

vec2 map(vec3 p) {
    vec2 metalBoxes = vec2(bgBoxes(p), 1.);
    vec2 water = vec2(waterPlane(p), 2.);

    vec2 scene = metalBoxes;
    if (water.x < scene.x) scene = water;

    return scene;
}

#include "$lib/f_norm.glsl";

vec3 tr(vec3 ro, vec3 rd, vec2 uv){
    vec2 h;
    vec3 hp, hn;
    float td = 0.;
    vec4 c = vec4(0.);
    int bnc = 0; float en = 1.;
    float ttd = td;

    for (int i = 0; i < 256; i++) {
        hp = ro + rd * td;
        h = map(hp);

        td += h.x; 
        ttd += h.x;

        if (h.x > far 
            || td > far) {
                c += vec4(bg(uv), 1.);
                break;
            };


        hn = f_norm(hp);
        

        if (h.x < 0.001) {
            if (h.y == 1.) {
                vec3 cc = vec3(.3);
                vec3 ld = normalize(vec3(-.1,.4,.3));
                
                float diffuse = max(0.,dot(hn,ld));
                float fresnel=min(1.,pow(1.+dot(hn,rd),4.)); //Fresnel = background reflections on edges of geometry
                float specular=pow(max(dot(reflect(-ld,hn),-rd),0.),10.);//Specular = Bright highlights; 30 = specular power
                float ao=clamp(map(hp+hn*.3).x/.3,0.,1.);          //Ambient occlusion
                    

                cc = mix(specular+cc *(ao+.1)*(diffuse),bg(uv),fresnel);
                 cc = mix(bg(uv),cc,exp(-.001*ttd*ttd*ttd)); 

                c += vec4(cc, 1.) * en;
                break;
            }
            else if (h.y == 2.) {
                float ao=clamp(map(hp+hn*.3).x/.3,0.,1.);   
                vec3 cc = vec3(bg(uv)) * ao;
                cc = mix(bg(uv),cc,exp(-.001*ttd*ttd*ttd)); 
                c += vec4(cc, .15) * ao * en;
                ro = hp;
                rd = reflect(rd, hn);
                td = .4;
                bnc += 1;
                en = max(en - .5, 0.);
            }
        }


 
        if (c.a >= 1.
            || bnc > 2
            || en < 0. 
        ) break;
        
    }

    if (td > far || h.x > far) 
                c += vec4(bg(uv), 1.);

    vec3 cc = c.rgb;
    return cc;
}

void main() {
    vec2 uv = fragCoordToUV(r, true);

    vec3 ro = vec3(0., 0., 1.);
    vec3 rd = normalize(vec3(uv, 0.) - ro);

    vec3 c = tr(ro, rd, uv);

    outColor = vec4(c, 1.);
}