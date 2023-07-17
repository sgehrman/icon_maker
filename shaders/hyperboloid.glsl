////////////////////////////////////////////////////////////////////////////////
// Glowing Hyperboloid, Matthew Arcus, mla, 2022
// Inspired by, and uses code from https://www.shadertoy.com/view/fdjczd
// by @oneshade
////////////////////////////////////////////////////////////////////////////////

#include<flutter/runtime_effect.glsl>

precision highp float;
uniform float iTime;
uniform vec2 iResolution;
uniform vec2 iMouse;
uniform sampler2D uTexture;
out vec4 fragColor;


const int N=50;// Number of lines
const float scale=1.;
const float CAMERA=6.;
const float A=.1;// Light amplitude
const float K=6.;// Exponental falloff
const float PI=3.14159265;
const float TWOPI=2.*PI;
#define sin(x)sin(mod((x),TWOPI))
#define cos(x)cos(mod((x),TWOPI))

float det(vec2 c0,vec2 c1){
    return determinant(mat2(c0,c1));
}

// Given lines p+kq and r+js, points
// u = p+kq, v = r+js are closest if
// q.(u-v) = 0 = s.(u-v) (ie. the line
// between them is orthogonal to both lines).
// Expanding out gives a linear system to
// solve for k and j.
vec2 closest0(vec3 p,vec3 q,vec3 r,vec3 s){
    // Use Cramer's rule to solve linear system
    // Matrices are column major!
    // Assume q and s are unit vectors
    // No cross products, 4 dot products, 3 2x2 determinants
    vec2 c0=vec2(1.,dot(q,s));
    vec2 c1=vec2(-dot(q,s),-1.);
    vec2 a=vec2(dot(r-p,q),dot(r-p,s));
    return vec2(det(a,c1),det(c0,a))/det(c0,c1);
}

// return vec2(k,j) such that p + kq and
// r + js are closest points on lines
// Assumes q and s are normalized
vec2 closest1(vec3 p,vec3 q,vec3 r,vec3 s){
    // Matrices are column major!
    // Assume q and s are unit vectors
    mat2 m=mat2(1.,dot(q,s),-dot(q,s),-1.);
    return inverse(m)*vec2(dot(r-p,q),dot(r-p,s));
}

// Nice "geometric" solution from Wikipedia.
// Probably not as fast as Cramer's rule,
// 3 cross products, 4 dot products & a normalize
vec2 closest2(vec3 p,vec3 q,vec3 r,vec3 s){
    vec3 n=normalize(cross(q,s));
    vec3 n1=cross(q,n);
    vec3 n2=cross(s,n);
    return vec2(dot(r-p,n2)/dot(q,n2),
    dot(p-r,n1)/dot(s,n1));
}

vec2 closest3(vec3 p,vec3 q,vec3 r,vec3 s){
    // Matrices are column major!
    // Assume q and s are unit vectors
    float k=dot(q,s);
    mat2 m=mat2(-1.,-k,k,1.);
    return m*vec2(dot(r-p,q),dot(r-p,s))/(k*k-1.);
}

vec2 closest(vec3 p,vec3 q,vec3 r,vec3 s){
    return closest3(p,q,r,s);
}

// Smooth HSV to RGB conversion
// Function by iq, from https://www.shadertoy.com/view/MsS3Wc
vec3 h2rgb(float h){
    vec3 rgb=clamp(abs(mod(h*6.+vec3(0.,4.,2.),6.)-3.)-1.,0.,1.);
    rgb=rgb*rgb*(3.-2.*rgb);// cubic smoothing
    return rgb;
}

// Quaternion to rotation matrix, assumes normalized
mat3 qrot(vec4 q){
    float x=q.x,y=q.y,z=q.z,w=q.w;
    float x2=x*x,y2=y*y,z2=z*z;
    float xy=x*y,xz=x*z,xw=x*w;
    float yz=y*z,yw=y*w,zw=z*w;
    return 2.*mat3(.5-y2-z2,xy+zw,xz-yw,
        xy-zw,.5-x2-z2,yz+xw,
    xz+yw,yz-xw,.5-x2-y2);
}

vec2 rotate(vec2 p,float t){
    return p*cos(t)+vec2(p.y,-p.x)*sin(t);
}

vec3 transform(in vec3 p){
    if(iMouse.x>0.){
        float theta=(2.*iMouse.y-iResolution.y)/iResolution.y*PI;
        float phi=(2.*iMouse.x-iResolution.x)/iResolution.x*PI;
        p.yz=rotate(p.yz,theta);
        p.zx=rotate(p.zx,-phi);
    }
    return p;
}

void mainImage(out vec4 outColor,vec2 fragCoord){
    vec2 xy=scale*(2.*fragCoord-iResolution.xy)/iResolution.y;
    // p+kq is viewing ray
    vec3 p=vec3(0,0,-CAMERA);
    vec3 q=vec3(xy,2);
    p=transform(p);
    q=transform(q);
    q=normalize(q);
    
    // r+js is polygon line, to be rotated in loop
    vec3 r=vec3(0,1,0);
    vec3 s=vec3(1,0,0);
    // Rotation axis
    vec3 axis=normalize(vec3(1,1,cos(.1*iTime)));
    float phi=iTime*.15;
    mat3 n=qrot(vec4(sin(phi)*axis,cos(phi)));
    p=n*p;q=n*q;
    float mindist=1e10;
    vec3 color=vec3(0);// Accumulate color here
    float len=2.;
    float twist=sin(.25*iTime)*PI/2.;
    
    // Convert twist angle to a rotation matrix
    float co=cos(twist),si=sin(twist);
    mat2 rot=mat2(co,-si,si,co);
    
    // Calculate height to keep line length constant
    float chord=2.*sin(twist);
    float halfHeight=sqrt(len*len-chord*chord)/2.;
    for(int i=0;i<N;i++){
        float a=TWOPI*float(i)/float(N);
        vec3 p1=vec3(cos(a),-halfHeight,sin(a));
        vec3 p2=vec3(p1.x,halfHeight,p1.z);
        
        p1.xz*=transpose(rot);// Rotate in opposite direction
        p2.xz*=rot;
        vec3 r=.5*(p1+p2),s=normalize(p1-p2);
        vec2 k=closest(p,q,r,s);
        if(k.x>0.){
            vec3 p0=p+k.x*q;
            vec3 r0=r+k.y*s;
            float d=distance(p0,r0);
            float h=mod(.3*(-iTime+log(1.+abs(k.y))),1.);
            vec3 basecolor=h2rgb(h);
            color+=A*exp(-K*d)*basecolor;
        }
    }
    color=pow(color,vec3(.4545));
    outColor=vec4(color,1.);
}


 
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
 