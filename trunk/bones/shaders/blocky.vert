// blocky.vert - an OGLSL vertex shader with animation
// Mike Weiblen 2003-09-16 : derived from brick.vert
// Copyright 2003 3Dlabs Inc.
// see http://www.3dlabs.com/opengl2/ for more OpenGL Shading Language info.


// the App updates uniforms "slowly" (eg once per frame) for animation.
uniform float Sine;

const vec3 LightPosition = vec3(10.0, 0.0, 0.0);
const float BlockScale = 0.30;

// varyings are written by vert shader, interpolated, and read by frag shader.
varying float LightIntensity;
varying vec2  BlockPosition;
varying float dist;
varying float dist2;

void main(void)
{
    // per-vertex diffuse lighting
    vec4 ecPosition	= gl_ModelViewMatrix * gl_Vertex;
    vec3 tnorm		= normalize(gl_NormalMatrix * gl_Normal);
    vec3 lightVec	= normalize(LightPosition - vec3 (ecPosition));
    LightIntensity	= max(dot(lightVec, tnorm), 0.0); 

    // blocks will be determined by fragment's position on the XZ plane.
    BlockPosition = gl_Vertex.xz / BlockScale;

    //vec3 out(0,0,-1.0);
    float viewInt = dot(tnorm,vec3(0,1.0,0.0));
    //LightIntensity /= (-ecPosition.z/200.0);
    dist = (-ecPosition.z);
    //dist2 = length(gl_Vertex);
    dist2 = length(ecPosition.y);
    
    if (viewInt < 0.2) { LightIntensity = 0.0; }
    if (viewInt > 0.9) { LightIntensity = 1.5; }

    gl_Position	= gl_ModelViewProjectionMatrix * gl_Vertex;

}

