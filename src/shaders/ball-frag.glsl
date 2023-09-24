#version 300 es
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
uniform float Trasnparancy;
uniform float New_radius;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec2 fs_uvs;
in float height;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const vec4 Fire_5= vec4(238.0f/555.0f,36.0f/555.0f,0.0f/555.0f,1.0f);
const vec4 Fire_4= vec4(238.0f/355.0f,36.0f/355.0f,0.0f/355.0f,1.0f);
const vec4 Fire_3= vec4(255.0f/355.0f,154.0f/355.0f,0.0f/355.0f,1.0f);
const vec4 Fire_2= vec4(244.0f/255.0f,172.0f/255.0f,0.0f/255.0f,1.0f);
const vec4 Fire_1= vec4(255.0f/255.0f,219.0f/255.0f,0.0f/255.0f,1.0f);
const vec4 Fire_0= vec4(255.0f/255.0f,255.0f/255.0f,254.0f/255.0f,1.0f);

vec4 easeOut(float t, float a, vec4 color0,vec4 color1){
    t=1.0f-t;
    return (1.0f-pow(t,a))*color1+pow(t,a)*color0;
}

vec4 easeIn(float t, float a, vec4 color0,vec4 color1){
    return pow(t,a)*color1+(1.0f-pow(t,a))*color0;
}

vec4 interpolate(float t){
    if (t<1.1f){
        t=(t-1.0f)/0.1f;
        return easeIn(t,3.0f,Fire_0,Fire_1);
    }else if(t<1.2f){
        t=(t-1.1f)/0.1f;
        return easeOut(t,2.0f,Fire_4,Fire_2);
    }
    t=(t-1.2f)/0.05f;
    return easeOut(t,2.0f,Fire_2,Fire_4);
}
void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;
        float elongated_height=(height-0.7f)*0.7f+0.7f;
        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0.0f, 1.0f);

        float ambientTerm = 0.2f;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        if(Trasnparancy==1.0f)
            out_Col = vec4(vec3(interpolate(height)),Trasnparancy*height);
        else
            out_Col = vec4(vec3(Fire_2),clamp(pow(Trasnparancy*(height-1.0f),0.5f),0.0f,1.0f));
        //out_Col = vec4(0.0f,0.0f,0.0f, 1.0f);
}