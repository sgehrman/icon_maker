#include<flutter/runtime_effect.glsl>

precision highp float;
uniform float iTime;
uniform vec2 iResolution;
uniform vec2 iMouse;
uniform sampler2D uTexture;
out vec4 fragColor;

#define res iResolution
#define ft float

ft hm(vec2 uv,vec2 m){
    ft a=dot(uv,uv);
    ft b=(sin(.0*iTime+uv.x/a/m.x))*sin(iTime+uv.y/a/m.y);
    return abs(b*1.4)*a;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=4.*(2.*fragCoord.xy-res.xy)/res.y;
    vec2 m=vec2(.03);
    vec2 mouse=iMouse.y<1.?vec2(.5,.05):iMouse.xy/res.xy;
    ft a=hm(uv,m);
    for(ft i=0;i<5.;i++){
        uv=abs(uv/hm(uv,m+i*.2)-.4*mouse);
    }
    fragColor=vec4(1.-uv.xyy,1.);
}

void main(void){mainImage(fragColor,FlutterFragCoord());}
