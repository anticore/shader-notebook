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
#include "$lib/b_hash.glsl";
#include "$lib/acesTonemap.glsl";
#include "$lib/skyGradient.glsl";
#include "$lib/gamma.glsl";
#include "$lib/waves.glsl";

const float far = 30.;

vec3 bg(vec3 rd) {
    return skyGradient(rd, vec3(0.5, -.1, 0.1), vec3(.5, 0.5, 0.6));
}

float bgBoxes(vec3 p) {
    p.z += 10.;
    p.yx *= rotM(0.5);
    p.xz *= rotM( .100);

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
    float waves = getwaves(p.xz * 2., 5, t * 3.);
    return  fPlane(p, vec3(0., 1., 0.), 1.5) - waves * 0.1;
}

float datastream(vec3 p) {
    p.z += 10.;

    p.yx *= rotM(0.5);
    return fBox(p, vec3(.1, 1000., .1));
}

vec2 map(vec3 p) {
    vec2 metalBoxes = vec2(bgBoxes(p), 1.);
    vec2 water = vec2(waterPlane(p), 2.);
    vec2 stream = vec2(datastream(p), 3.);

    vec2 scene = metalBoxes;
    if (water.x < scene.x) scene = water;
    if (stream.x < scene.x) scene = stream;

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

    for (int i = 0; i < 200; i++) {
        hp = ro + rd * td;
        h = map(hp);

        td += h.x; 
        ttd += h.x;

        if (h.x > far 
            || td > far) {
                c += vec4(bg(rd), 1.);
                break;
            };


        hn = f_norm(hp);
        

        if (h.x < 0.005) {
            if (h.y == 1.) {
                hn += b_hash(uv) * 0.05;
                vec3 cc = skyGradient(hn, vec3(.3), vec3(1.)) * vec3(0.3);
                //vec3 cc = vec3(.3);
                vec3 ld = normalize(vec3(-.1,.4,.3));
                
                float diffuse = max(0.,dot(hn,ld));
                float fresnel=min(1.,pow(1.+dot(hn,rd),5.)); //Fresnel = background reflections on edges of geometry
                float specular=pow(max(dot(reflect(-ld,hn),-rd),0.),10.);//Specular = Bright highlights; 30 = specular power
                float ao=clamp(map(hp+hn*.3).x/.3,0.,1.);          //Ambient occlusion
                    

                cc = mix(specular+cc *(ao+.1)*(diffuse),bg(rd),fresnel * .1);
                //cc = mix(bg(rd),cc,exp(-.00005*td*td*td)); 


                c += vec4(cc, .99) * en;
                ro = hp;
                rd = reflect(rd, hn);
                td = .1;
                bnc += 1;
                en = max(en - .0, 0.);
            }
            else if (h.y == 2.) { 
                vec3 cc = vec3(bg(reflect(rd, hn))) ;
                cc = mix(bg(reflect(rd, hn)),cc,exp(-.001*ttd*ttd*ttd)); 
                c += vec4(cc, .1) * en;
                ro = hp;
                rd = reflect(rd, hn);
                td = .01;
                bnc += 1;
                en = max(en - .1, 0.);
            }
            else if (h.y == 3.) {
                c = vec4(hsl2rgb(vec3(sin(-t * 2. + h.x * 10. + hp.y / 10.), 1., .5)), 1.);
                break;
            }
        }


 
        if (c.a >= 1.
            || bnc > 2
            || en < 0. 
        ) break;
        
    }

    if (td > far || h.x > far) 
                c += vec4(bg(rd), 1.);

    vec3 cc = c.rgb;
    return clamp(cc, 0., 1.);
}

void main() {
    vec2 uv = fragCoordToUV(r, true);

    vec3 ro = vec3(0, 0., 0.2 + t / 15.);
    vec3 rd = normalize(vec3(uv, 0.) - ro);

    vec3 c = tr(ro, rd, uv);

    outColor = vec4(/*gamma*/(aces_tonemap(c)), 1.);
}