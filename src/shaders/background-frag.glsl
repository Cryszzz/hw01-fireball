#version 300 es

precision highp float;

uniform float u_Time;
uniform vec2 iResolution;
out vec4 out_Col; 
in vec2 vertPos;
const vec4 Color= vec4(238.0f/555.0f,36.0f/555.0f,0.0f/555.0f,1.0f);
const vec4 Color2= vec4(0.0f/555.0f,0.0f/555.0f,0.0f/555.0f,1.0f);
const vec4 Fire_5= vec4(238.0f/555.0f,36.0f/555.0f,0.0f/555.0f,1.0f);
const vec4 Fire_4= vec4(238.0f/355.0f,36.0f/355.0f,0.0f/355.0f,1.0f);
const vec4 Fire_3= vec4(255.0f/355.0f,154.0f/355.0f,0.0f/355.0f,1.0f);
const vec4 Fire_2= vec4(244.0f/255.0f,172.0f/255.0f,0.0f/255.0f,1.0f);
const vec4 Fire_1= vec4(255.0f/255.0f,219.0f/255.0f,0.0f/255.0f,1.0f);
const vec4 Fire_0= vec4(255.0f/255.0f,255.0f/255.0f,254.0f/255.0f,1.0f);

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float rand2(vec2 co){
    return fract(sin(dot(co, vec2(43.21, 70.98853))) * 42741.5449);
}

vec4 colorstar(vec2 point){
    point=point*200.0f;
    vec2 i=floor(point);
    vec2 f=fract(point);
    vec2 rad=vec2(rand(i),rand2(i));
    float length=length(f-rad);
    float show=clamp(sin(u_Time*0.02f+rand(i)*10.0f),0.0f,1.0f);
    if(length<0.01f && show!=0.0f){
        return vec4(1.0f,1.0f,1.0f,show);
    }
    return vec4(0.0f);
}

// The function here is referenced from https://www.shadertoy.com/view/lsf3RH
float snoise(vec3 uv, float res)
{
	const vec3 s = vec3(1e0, 1e2, 1e3);
	
	uv *= res;
	
	vec3 uv0 = floor(mod(uv, res))*s;
	vec3 uv1 = floor(mod(uv+vec3(1.), res))*s;
	
	vec3 f = fract(uv); f = f*f*(3.0-2.0*f);

	vec4 v = vec4(uv0.x+uv0.y+uv0.z, uv1.x+uv0.y+uv0.z,
		      	  uv0.x+uv1.y+uv0.z, uv1.x+uv1.y+uv0.z);

	vec4 r = fract(sin(v*1e-1)*1e3);
	float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	r = fract(sin((v + uv1.z - uv0.z)*1e-1)*1e3);
	float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
	
	return mix(r0, r1, f.z)*2.-1.;
}

// The part of code in this function is referenced from https://www.shadertoy.com/view/lsf3RH
void main()
{
    float width=(gl_FragCoord.x-iResolution.x/2.0f);
    float height=(gl_FragCoord.y-iResolution.y/2.0f);

    vec2 p=vec2(width,height)/(iResolution.y/2.0f);
    float color = 3.0 - (3.*length(2.*p));
	
	vec3 coord = vec3(atan(p.x,p.y)/6.2832+.5, length(p)*.4, .5);
	
	for(int i = 1; i <= 7; i++)
	{
		float power = pow(2.0, float(i));
		color += (1.5 / power) * snoise(coord + vec3(0.,-u_Time*.0005, u_Time*.0001), power*16.);
	}
    //+
    vec4 tempcolor=color*(Fire_2-Fire_4)+Fire_2;
    tempcolor=vec4(clamp(tempcolor.x,0.0f,1.0f),clamp(tempcolor.y,0.0f,1.0f),clamp(tempcolor.z,0.0f,1.0f),clamp(tempcolor.w,0.0f,1.0f));
    tempcolor+=colorstar(vec2(width/iResolution.x,height/iResolution.y));
    out_Col =vec4(clamp(tempcolor.x,0.0f,1.0f),clamp(tempcolor.y,0.0f,1.0f),clamp(tempcolor.z,0.0f,1.0f),clamp(tempcolor.w,0.0f,1.0f));
	
}