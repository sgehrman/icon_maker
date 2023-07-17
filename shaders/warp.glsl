#include<flutter/runtime_effect.glsl>

precision highp float;
uniform float iTime;
uniform vec2 iResolution;
uniform vec2 iMouse;
uniform sampler2D uTexture;
out vec4 fragColor;

#define S(x,y,z)smoothstep(x,y,z)
#define M(t,d)mat2(cos(t*d),sin(t*d),-sin(t*d),cos(t*d))
#define SEED .2831
#define PI acos(-1.)

// fbm code by @iq // https://www.shadertoy.com/view/lsfGRr

float hash(float n)
{
    return fract(sin(n)*91438.55123);
}

float hash2(vec2 p)
{
    // hash2 taken from Dave Hoskins
    // https://www.shadertoy.com/view/4djSRW
    vec3 p3=fract(vec3(p.xyx)*SEED);
    p3+=dot(p3,p3.yzx+19.19);
    return fract((p3.x+p3.y)*p3.z);
}

float noise(in vec2 x){
    vec2 p=floor(x);
    vec2 f=fract(x);
    f=f*f*(3.-2.*f);
    float n=p.x+p.y*57.;
    return mix(mix(hash(n+0.),hash(n+1.),f.x),mix(hash(n+57.),hash(n+58.),f.x),f.y);
}

mat2 m=mat2(.6,.6,-.6,.8);
float fbm(vec2 p){
    
    float f=0.;
    f+=.5000*noise(p);p*=m*2.02;
    f+=.2500*noise(p);p*=m*2.03;
    f+=.1250*noise(p);p*=m*2.01;
    f+=.0625*noise(p);p*=m*2.04;
    f/=.9375;
    return f;
}

float star(vec2 uv,vec2 scale,float density){
    
    vec2 grid=uv*scale;
    vec2 id=floor(grid);
    grid=fract(grid)-.5;
    
    float d=length(grid);
    float r=pow(hash2(id),density);
    float star=S(-.01,clamp(r,.0,.5),d);
    
    return 1.-star;
}

float halo(vec2 uv,vec2 scale,float density){
    
    vec2 grid=uv*scale;
    vec2 id=floor(grid);
    grid=fract(grid)-.5;
    
    float d=length(grid);
    float r=pow(hash2(id),density);
    float a=S(-.4,clamp(r,.0,.5),d);
    
    return 1.-a;
}

float bigstar(vec2 uv,vec2 scale,float density,float angle,float speed){
    
    //angle *= PI*.5;
    vec2 grid=uv*scale;
    vec2 id=floor(grid);
    grid=fract(grid)-.5;
    
    float d=length(grid);
    float dx=length(M(-angle,speed)*grid*vec2(5.,.1));
    float dy=length(M(-angle,speed)*grid*vec2(.1,5.));
    float r=pow(hash2(id),density);
    float star=S(-.01,clamp(r,.0,.3),d);
    
    float l=S(.0,1.,length(grid-1.));
    
    return 1.-S(-.1,r*l*l,2.*sqrt(dot(dx,dy)));
}

vec2 dist(vec2 uv){
    
    vec2 d=vec2(.0);
    d+=.2*dot(uv,uv)-.5;
    
    return d;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fragCoord.xy/iResolution.xy;
    uv.x*=iResolution.x/iResolution.y;
    
    vec2 st=uv*1.35;
    
    st+=dist(st);
    float t=iTime*.01;
    
    uv-=vec2(.8,.5);
    st+=sign(dot(uv,uv));
    uv+=sign(dot(uv,uv));
    
    float mw=S(-.5,1.5,length(uv));
    
    float a0=halo(M(t,2.5)*uv,vec2(15.),mw*50.);
    float l0=a0+bigstar(M(t,2.5)*uv,vec2(15.),mw*50.,t,2.5);
    
    float l1=star(M(10.+t,2.)*uv*.8,vec2(120.),mw*80.);
    float l2=star(M(20.+t,1.5)*uv*.6,vec2(150.),mw*100.);
    float l3=star(M(t*1.4,1.)*uv,vec2(200.),mw*120.);
    
    float a4=halo(M(PI+t*1.4,3.)*uv,vec2(15.),mw*90.);
    float l4=a4+bigstar(M(PI+t*1.4,3.)*uv,vec2(15.),mw*90.,t*1.4,3.);
    
    uv-=sign(dot(uv,uv));
    
    vec2 n1=vec2(.2*t,.2*t);
    vec2 n2=vec2(.3*t,.3*t);
    vec2 n3=vec2(.4*t,.4*t);
    
    float r=.23*fbm(M(t,2.5)*(1.5*st+n1));
    float g=.24*fbm(M(t,2.)*(2.*st+n2));
    float b=.26*fbm(M(t,1.5)*(1.*st+n3));
    
    vec4 cl=pow(vec4(r,g,b,1.),vec4(1.3));
    cl=cl+cl;
    
    vec4 s=vec4(vec3(l0+l1+l2+l3+l4),1.);
    cl=pow(cl+cl,vec4(1.5));
    cl=pow(cl+cl+cl,vec4(1.5))*.7;
    
    cl=mix(cl+cl,cl*s,.85);
    
    cl+=cl*2.;
    cl.xyz+=.5*pow(1.-length(uv/2.),2.5);
    
    cl=.9*clamp(cl,vec4(.0),vec4(1.));
    
    cl+=S(.0,1.,S(.7,1.,s));
    float cl1=fbm((fbm(st*.4)-vec2(t,t))*15.)*dist(uv).x;
    
    cl=mix(cl,cl+cl1+cl1+cl1,.8);
    cl+=.33*fbm(vec2(-iTime*.3,iTime*.3)+(uv*20.));
    cl-=min(cl,vec4(-.3,.0,-.5,1.));
    cl-=.8*dot(uv,uv);
    
    fragColor=cl;
    
}

void main(void){mainImage(fragColor,FlutterFragCoord());}
