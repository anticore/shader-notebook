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

/*
	hg_sdf by mercury
	mercury.sexy

	webgl port inspired by
	https://www.shadertoy.com/view/Xs3GRB
*/

const float PI = 3.14159265;
const float TAU = 2.0 * PI;
const float PHI = sqrt(5.0) * 0.5 + 0.5;

float saturate(float x) {
  return clamp(x, 0.0, 1.0);
}

float sgn(float x) {
  return x < 0.0
    ? -1.0
    : 1.0;
}
vec2 sgn(vec2 v) {
  return vec2(v.x < 0.0 ? -1.0 : 1.0, v.y < 0.0 ? -1.0 : 1.0);
}

float square(float x) {
  return x * x;
}
vec2 square(vec2 x) {
  return x * x;
}
vec3 square(vec3 x) {
  return x * x;
}

float lengthSqr(vec3 x) {
  return dot(x, x);
}

float vmax(vec2 v) {
  return max(v.x, v.y);
}
float vmax(vec3 v) {
  return max(max(v.x, v.y), v.z);
}
float vmax(vec4 v) {
  return max(max(v.x, v.y), max(v.z, v.w));
}

float vmin(vec2 v) {
  return min(v.x, v.y);
}
float vmin(vec3 v) {
  return min(min(v.x, v.y), v.z);
}
float vmin(vec4 v) {
  return min(min(v.x, v.y), min(v.z, v.w));
}

//             PRIMITIVE DISTANCE FUNCTIONS

float fSphere(vec3 p, float r) {
  return length(p) - r;
}

float fPlane(vec3 p, vec3 n, float distanceFromOrigin) {
  return dot(p, n) + distanceFromOrigin;
}

float fBoxCheap(vec3 p, vec3 b) {
  //cheap box
  return vmax(abs(p) - b);
}

float fBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

float fBox2Cheap(vec2 p, vec2 b) {
  return vmax(abs(p) - b);
}

float fBox2(vec2 p, vec2 b) {
  vec2 d = abs(p) - b;
  return length(max(d, vec2(0))) + vmax(min(d, vec2(0)));
}

float fCorner(vec2 p) {
  return length(max(p, vec2(0))) + vmax(min(p, vec2(0)));
}

float fCylinder(vec3 p, float r, float height) {
  float d = length(p.xz) - r;
  d = max(d, abs(p.y) - height);
  return d;
}

float fCapsule(vec3 p, float r, float c) {
  return mix(
    length(p.xz) - r,
    length(vec3(p.x, abs(p.y) - c, p.z)) - r,
    step(c, abs(p.y))
  );
}

float fLineSegment(vec3 p, vec3 a, vec3 b) {
  vec3 ab = b - a;
  float t = saturate(dot(p - a, ab) / dot(ab, ab));
  return length(ab * t + a - p);
}

float fCapsule(vec3 p, vec3 a, vec3 b, float r) {
  return fLineSegment(p, a, b) - r;
}

float fTorus(vec3 p, float smallRadius, float largeRadius) {
  return length(vec2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}

float fCircle(vec3 p, float r) {
  float l = length(p.xz) - r;
  return length(vec2(p.y, l));
}

float fDisc(vec3 p, float r) {
  float l = length(p.xz) - r;
  return l < 0.0
    ? abs(p.y)
    : length(vec2(p.y, l));
}

float fHexagonCircumcircle(vec3 p, vec2 h) {
  vec3 q = abs(p);
  return max(q.y - h.y, max(q.x * sqrt(3.0) * 0.5 + q.z * 0.5, q.z) - h.x);
}

float fHexagonIncircle(vec3 p, vec2 h) {
  return fHexagonCircumcircle(p, vec2(h.x * sqrt(3.0) * 0.5, h.y));
}

float fCone(vec3 p, float radius, float height) {
  vec2 q = vec2(length(p.xz), p.y);
  vec2 tip = q - vec2(0, height);
  vec2 mantleDir = normalize(vec2(height, radius));
  float mantle = dot(tip, mantleDir);
  float d = max(mantle, -q.y);
  float projected = dot(tip, vec2(mantleDir.y, -mantleDir.x));

  // distance to tip
  if (q.y > height && projected < 0.0) {
    d = max(d, length(tip));
  }

  // distance to base ring
  if (q.x > radius && projected > length(vec2(height, radius))) {
    d = max(d, length(q - vec2(radius, 0)));
  }
  return d;
}

//                DOMAIN MANIPULATION OPERATORS

void pR(inout vec2 p, float a) {
  p = cos(a) * p + sin(a) * vec2(p.y, -p.x);
}

void pR45(inout vec2 p) {
  p = (p + vec2(p.y, -p.x)) * sqrt(0.5);
}

float pMod1(inout float p, float size) {
  float halfsize = size * 0.5;
  float c = floor((p + halfsize) / size);
  p = mod(p + halfsize, size) - halfsize;
  return c;
}

float pModMirror1(inout float p, float size) {
  float halfsize = size * 0.5;
  float c = floor((p + halfsize) / size);
  p = mod(p + halfsize, size) - halfsize;
  p *= mod(c, 2.0) * 2.0 - 1.0;
  return c;
}

float pModSingle1(inout float p, float size) {
  float halfsize = size * 0.5;
  float c = floor((p + halfsize) / size);
  if (p >= 0.0) p = mod(p + halfsize, size) - halfsize;
  return c;
}

float pModInterval1(inout float p, float size, float start, float stop) {
  float halfsize = size * 0.5;
  float c = floor((p + halfsize) / size);
  p = mod(p + halfsize, size) - halfsize;
  if (c > stop) {
    //yes, this might not be the best thing numerically.
    p += size * (c - stop);
    c = stop;
  }
  if (c < start) {
    p += size * (c - start);
    c = start;
  }
  return c;
}

float pModPolar(inout vec2 p, float repetitions) {
  float angle = 2.0 * PI / repetitions;
  float a = atan(p.y, p.x) + angle / 2.0;
  float r = length(p);
  float c = floor(a / angle);
  a = mod(a, angle) - angle / 2.0;
  p = vec2(cos(a), sin(a)) * r;
  if (abs(c) >= repetitions / 2.0) c = abs(c);
  return c;
}

vec2 pMod2(inout vec2 p, vec2 size) {
  vec2 c = floor((p + size * 0.5) / size);
  p = mod(p + size * 0.5, size) - size * 0.5;
  return c;
}

vec2 pModMirror2(inout vec2 p, vec2 size) {
  vec2 halfsize = size * 0.5;
  vec2 c = floor((p + halfsize) / size);
  p = mod(p + halfsize, size) - halfsize;
  p *= mod(c, vec2(2)) * 2.0 - vec2(1);
  return c;
}

vec2 pModGrid2(inout vec2 p, vec2 size) {
  vec2 c = floor((p + size * 0.5) / size);
  p = mod(p + size * 0.5, size) - size * 0.5;
  p *= mod(c, vec2(2)) * 2.0 - vec2(1);
  p -= size / 2.0;
  if (p.x > p.y) p.xy = p.yx;
  return floor(c / 2.0);
}

vec3 pMod3(inout vec3 p, vec3 size) {
  vec3 c = floor((p + size * 0.5) / size);
  p = mod(p + size * 0.5, size) - size * 0.5;
  return c;
}

float pMirror(inout float p, float dist) {
  float s = sgn(p);
  p = abs(p) - dist;
  return s;
}

vec2 pMirrorOctant(inout vec2 p, vec2 dist) {
  vec2 s = sgn(p);
  pMirror(p.x, dist.x);
  pMirror(p.y, dist.y);
  if (p.y > p.x) p.xy = p.yx;
  return s;
}

float pReflect(inout vec3 p, vec3 planeNormal, float offset) {
  float t = dot(p, planeNormal) + offset;
  if (t < 0.0) {
    p = p - 2.0 * t * planeNormal;
  }
  return sgn(t);
}

//             OBJECT COMBINATION OPERATORS

float fOpUnionChamfer(float a, float b, float r) {
  return min(min(a, b), (a - r + b) * sqrt(0.5));
}

float fOpIntersectionChamfer(float a, float b, float r) {
  return max(max(a, b), (a + r + b) * sqrt(0.5));
}

float fOpDifferenceChamfer(float a, float b, float r) {
  return fOpIntersectionChamfer(a, -b, r);
}

float fOpUnionRound(float a, float b, float r) {
  vec2 u = max(vec2(r - a, r - b), vec2(0));
  return max(r, min(a, b)) - length(u);
}

float fOpIntersectionRound(float a, float b, float r) {
  vec2 u = max(vec2(r + a, r + b), vec2(0));
  return min(-r, max(a, b)) + length(u);
}

float fOpDifferenceRound(float a, float b, float r) {
  return fOpIntersectionRound(a, -b, r);
}

float fOpUnionColumns(float a, float b, float r, float n) {
  if (a < r && b < r) {
    vec2 p = vec2(a, b);
    float columnradius = r * sqrt(2.0) / ((n - 1.0) * 2.0 + sqrt(2.0));
    pR45(p);
    p.x -= sqrt(2.0) / 2.0 * r;
    p.x += columnradius * sqrt(2.0);
    if (mod(n, 2.0) == 1.0) {
      p.y += columnradius;
    }

    pMod1(p.y, columnradius * 2.0);
    float result = length(p) - columnradius;
    result = min(result, p.x);
    result = min(result, a);
    return min(result, b);
  } else {
    return min(a, b);
  }
}

float fOpDifferenceColumns(float a, float b, float r, float n) {
  a = -a;
  float m = min(a, b);

  if (a < r && b < r) {
    vec2 p = vec2(a, b);
    float columnradius = r * sqrt(2.0) / n / 2.0;
    columnradius = r * sqrt(2.0) / ((n - 1.0) * 2.0 + sqrt(2.0));

    pR45(p);
    p.y += columnradius;
    p.x -= sqrt(2.0) / 2.0 * r;
    p.x += -columnradius * sqrt(2.0) / 2.0;

    if (mod(n, 2.0) == 1.0) {
      p.y += columnradius;
    }
    pMod1(p.y, columnradius * 2.0);

    float result = -length(p) + columnradius;
    result = max(result, p.x);
    result = min(result, a);
    return -min(result, b);
  } else {
    return -m;
  }
}

float fOpIntersectionColumns(float a, float b, float r, float n) {
  return fOpDifferenceColumns(a, -b, r, n);
}

float fOpUnionStairs(float a, float b, float r, float n) {
  float s = r / n;
  float u = b - r;
  return min(min(a, b), 0.5 * (u + a + abs(mod(u - a + s, 2.0 * s) - s)));
}

float fOpIntersectionStairs(float a, float b, float r, float n) {
  return -fOpUnionStairs(-a, -b, r, n);
}

float fOpDifferenceStairs(float a, float b, float r, float n) {
  return -fOpUnionStairs(-a, b, r, n);
}

float fOpUnionSoft(float a, float b, float r) {
  float e = max(r - abs(a - b), 0.0);
  return min(a, b) - e * e * 0.25 / r;
}

float fOpPipe(float a, float b, float r) {
  return length(vec2(a, b)) - r;
}

float fOpEngrave(float a, float b, float r) {
  return max(a, (a + r - abs(b)) * sqrt(0.5));
}

float fOpGroove(float a, float b, float ra, float rb) {
  return max(a, min(a + ra, rb - abs(b)));
}

float fOpTongue(float a, float b, float ra, float rb) {
  return min(a, max(a - ra, abs(b) - rb));
}

mat2 rotM(float t) {
  return mat2(cos(t), sin(t), -sin(t), cos(t));
}

float fCircle(vec2 p, float r) {
  return length(p) - r;
}

float fSkewBox(vec2 p, float wi, float he, float sk) {
  vec2 e = vec2(sk, he);
  p = p.y < 0.0 ? -p : p;
  vec2 w = p - e;
  w.x -= clamp(w.x, -wi, wi);
  vec2 d = vec2(dot(w, w), -w.y);
  float s = p.x * e.y - p.y * e.x;
  p = s < 0.0 ? -p : p;
  vec2 v = p - vec2(wi, 0);
  v -= e * clamp(dot(v, e) / dot(e, e), -1.0, 1.0);
  d = min(d, vec2(dot(v, v), wi * he - abs(s)));
  return sqrt(d.x) * sign(-d.y);
}

float opOnion(float dist, float thickness) {
  return abs(dist) - thickness;
}

float opSmooth(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0., 1.);
  return mix(d2, d1, h) - k * h * (1.-h);
}

float opMin(float d1, float d2) {
    return max(-d1, d2);
}

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