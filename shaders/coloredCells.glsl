#include<flutter/runtime_effect.glsl>

precision highp float;
uniform float iTime;
uniform vec2 iResolution;
uniform vec2 iMouse;
uniform sampler2D uTexture;
out vec4 fragColor;


float scale=5.;
float speed=.5;

// hash function
vec2 hash(vec2 p)
{
    p=vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3)));
    return-1.+2.*fract(sin(p)*43758.5453123);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv=fragCoord/iResolution.xy;
    uv.x*=iResolution.x/iResolution.y;
    uv*=scale;
    
    vec2 i_uv=floor(uv);
    vec2 f_uv=fract(uv);
    
    float m_dist=1.;
    
    for(int i=-1;i<=1;i++)
    {
        for(int j=-1;j<=1;j++)
        {
            // neighbor grid's place
            vec2 neighbor=vec2(float(i),float(j));
            
            // random point position (in one of the current pixel's 9 grids)
            vec2 point=hash(i_uv+neighbor);
            
            // animate point
            point=.5+.5*sin(speed*(iTime+6.2831*point));
            
            // distance (current pixel is in the center grid)
            float dist=length(neighbor+point-f_uv);
            
            m_dist=min(m_dist,dist);
        }
    }
    
    // Time varying pixel color
    vec3 col=.5+.5*cos(iTime+uv.xyx+vec3(0,2,4));
    
    col*=m_dist;
    
    // draw grids
    //if(f_uv.x < 0.002*scale || f_uv.y < 0.002*scale)
    //col = vec3(0.);
    
    // Output to screen
    fragColor=vec4(col,1.);
}



void main(void) { mainImage(fragColor, FlutterFragCoord()); }
 