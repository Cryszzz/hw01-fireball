#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself
uniform float u_Time;
uniform float New_radius;
uniform float Trasnparancy;


in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

in vec2 vs_UV;

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

out vec2 fs_uvs;
out float height;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.
const int N_OCTAVES=8;

const float PI=3.1415926f;

float noisegen3(vec3 pos){
    return fract(sin(dot(pos, vec3(12.9898,78.233,43.21)))*43758.5453);
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float square_wave(float x, float freq, float amplitude){
    return abs(floor(mod(x*freq,2.0f)*amplitude));
}

float sawtooth_wave(float x, float freq, float amplitude){
    return (x*freq-floor(x*freq))*amplitude;
}

float bias(float t, float b) {
    return (t / ((((1.0/b) - 2.0)*(1.0 - t))+1.0));
}

float triangle_wave(float x, float freq, float amplitude){
    return abs(mod((x*freq),amplitude)-0.5*amplitude);
}

mat4 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(
        vec4(1, 0, 0,0),
        vec4(0, c, -s,0),
        vec4(0, s, c,0),
        vec4(0, 0, 0,1)
    );
}
mat4 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(
        vec4(c, 0, s,0),
        vec4(0, 1, 0,0),
        vec4(-s, 0, c,0),
        vec4(0, 0, 0,1)
    );
}
mat4 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat4(
        vec4(c, -s, 0,0),
        vec4(s, c, 0,0),
        vec4(0, 0, 1,0),
        vec4(0, 0, 0,1)
    );
}

float combineSine(vec3 pos){
    float displacementx=bias(sin(pos.x*PI),0.52f)*bias(sin(pos.x*PI+0.1f),0.48f)/10.0f+1.0f;
    float displacementy=bias(sin(pos.y*PI),0.4f)*cos(pos.y*PI+0.4f)/12.0f+1.0f;
    float displacementz=bias(cos(pos.z*PI+0.2f),0.45f)*cos(pos.z*PI)/15.0f+1.0f;
    return displacementx*displacementy*displacementz;
}

float combineSine2(vec3 pos){
    float displacementx=bias(sin(pos.x*PI*280.0f),0.52f)*bias(sin(pos.x*PI*143.0f+0.1f),0.48f)/50.0f+1.0f;
    float displacementy=bias(sin(pos.y*PI*400.0f),0.4f)*cos(pos.y*PI*177.0f+0.4f)/34.0f+1.0f;
    float displacementz=bias(cos(pos.z*PI*606.0f+0.2f),0.45f)*cos(pos.z*PI*188.0f)/52.0f+1.0f;
    return displacementx*displacementy*displacementz;
}


vec3 SphereToCard(vec3 coord){
    return vec3(coord.x*cos(coord.y)*sin(coord.z),coord.x*sin(coord.y)*sin(coord.z),coord.x*cos(coord.z));
}

float slerp(float a, float b, float t){
    return (sin(1.0f-t))/sin(1.0f)*a+(sin(t))/sin(1.0f)*b;
}

float noise(vec3 st,float frequency,float scalar) {
    float radius=sqrt(st.x*st.x+st.y*st.y+st.z*st.z);
    float theta=atan(st.y,st.x)+PI+scalar*u_Time;
    float phi=acos(st.z/radius)+scalar*u_Time;
    vec2 i = floor(vec2(theta,phi)*frequency);
    vec2 f = fract(vec2(theta,phi)*frequency);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return slerp(slerp(a,b,u.x),slerp(c,d,u.x),u.y);
}

float fbm (vec3 st, float scalar) {
    // Initial values
    float value = 0.0f;
    float amplitude = 0.125f;
    float frequency = 6.0f;
    //
    // Loop of octaves
    for (int i = 0; i < N_OCTAVES; i++) {
        value += amplitude * noise(st,frequency,scalar);
        amplitude *= 0.5f;
        frequency*=2.0f;
    }
    return value;
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    mat4 randomMat=rotateX(cos(u_Time))*rotateY(sin(u_Time))*rotateZ(sin(u_Time)*cos(u_Time));
    mat4 ivrMat=transpose(inverse(randomMat));
    mat3 invTranspose = mat3(ivrMat*u_ModelInvTr);
    

    float another=fbm(vec3(vs_Pos)+0.5f*fbm(vec3(vs_Pos),0.17f)+0.5f*fbm(vec3(vs_Pos),0.24f),0.0f);
    height=combineSine(vec3(vs_Pos))+another;
    
    
    //if(Trasnparancy!=1.0f)
        //height=(height-1.0f)*(1.0f+(1.0f-Trasnparancy))+1.0f;
    vec4 mag=height*vs_Pos*New_radius;
    vec4 newPos=vec4(mag.x,mag.y,mag.z,1.0f);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    vec4 Pos=randomMat*newPos;
    vec4 modelposition = u_Model *  Pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                                // used to render the final positions of the geometry's vertices
}