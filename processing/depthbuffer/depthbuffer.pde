 import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  

import javax.media.opengl.glu.*; 

GL gl; 

PImage tx;
 
void setup() {
    
  size(400, 300, OPENGL); 
  
   gl=((PGraphicsOpenGL)g).gl; 
  
   tx = createImage(width, height, RGB);
  
}

float f = 0.0;
String base = "/home/lucasw/gprocessing/depthbuffer/";
int index = 0;

void draw() {
  
  background(0);
  
  gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT); 
  
  f+= 0.1;  
  
  fill(255, 255, 255);
  
  pushMatrix();
   translate(width/2,height/2,-1*f);
  rotateX(0.4*f);
//  translate(0.1*f,-0.1*f);
  
  //sphere(100);
  
  
  pushMatrix();
  scale(50);
   beginShape(QUADS);

  fill(0, 255, 255); vertex(-1,  1,  1);
  fill(1, 255, 255); vertex( 1,  1,  1);
  fill(1, 0, 255);   vertex( 1, -1,  1);
  fill(1, 0, 255);   vertex(-1, -1,  1);
   
  endShape();
  popMatrix();
  
  
  
  popMatrix();
  
  FloatBuffer fb = BufferUtil.newFloatBuffer(width*height);
  //set up a floatbuffer to get the depth buffer value of the mouse position
 
  gl.glReadPixels(0, 0, width, height, GL.GL_DEPTH_COMPONENT, GL.GL_FLOAT, fb); 
  fb.rewind();
  
  float mind = 0.85;
  float maxd = 0.99;
  
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
      
        int ind = i*height+j;
         float d = fb.get(ind);
        
        
        if (d > maxd) d = maxd;
        if (d < mind) d = mind;
        
        tx.pixels[ind] = makecolor( 1.0 - ((d-mind)/(maxd-mind)) ); 
    
        //if (d < mind) mind = d;
        //if (d > maxd) maxd = d;   
    }
  }
  
  tx.updatePixels();
  
  tx.save(base + "frames/depth" + (index+10000) + ".png");
  index++;

  
 // println(mind + " " + maxd);
}
