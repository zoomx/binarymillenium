// blocky.frag - an OGLSL fragment shader with animation
// Mike Weiblen 2003-09-16 : derived from brick.frag
// Copyright 2003 3Dlabs Inc.
// see http://www.3dlabs.com/opengl2/ for more OpenGL Shading Language info.


// the App updates uniforms "slowly" (eg once per frame) for animation.
uniform float Sine;
uniform vec3 Color1;
uniform vec3 Color2;

// varyings are written by vert shader, interpolated, and read by frag shader.
varying vec2  BlockPosition;
varying float LightIntensity;
varying float dist;
varying float dist2;

void main(void)
{
    vec3 color;
    float ss, tt, w, h;
    
    ss = BlockPosition.x;
    tt = BlockPosition.y;

    if (fract(tt * 0.5) > 0.5)
        ss += 0.5;

    ss = fract(ss);
    tt = fract(tt);

    // animate the proportion of block to mortar
    float blockFract = (Sine + 1.1) * 0.4;

    w = step(ss, blockFract);
    h = step(tt, blockFract);

    vec3 fogColor = vec3(1.0,0.0,0.21);
    vec3 fogColor2 = vec3(0.0,0.2,0.9);

    //color = mix(Color2, Color1, w * h) * LightIntensity;
    color = vec3(0.5+w/2,1.0-h/2, 1.0)*LightIntensity;
    
    dist = clamp(dist/1700,0.0,1.0);
    dist2 = clamp(dist2/200,0.0,1.0);
    color = fogColor*(dist) + color*(1-dist);
    color = fogColor2*(dist2) + color*(1-dist2);
    
    gl_FragColor = vec4(color, 1.0);
}

