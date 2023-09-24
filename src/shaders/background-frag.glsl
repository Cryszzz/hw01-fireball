#version 300 es

uniform float u_Time;
out vec4 out_Col; 
const vec4 Color= vec4(238.0f/555.0f,36.0f/555.0f,0.0f/555.0f,1.0f);

void main()
{
    float distanceX = abs(gl_FragCoord.x - windowWidth / 2.0f);
    float distanceY = abs(gl_FragCoord.y - windowHeight / 2.0f);
    float distance = sqrt(distanceX * distanceX + distanceY * distanceY);
    if(abs(distance) > 0.2f) {
        out_Col = Color;
    }

}