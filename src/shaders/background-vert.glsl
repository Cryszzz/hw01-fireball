#version 300 es

precision highp float;

in vec4 vs_Pos;
uniform float u_Time;
out vec2 vertPos;

void main()
{
    vertPos     = vec2(vs_Pos);
    gl_Position=vec4(vec2(vs_Pos),0.0f,1.0f);
}