 import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  

import javax.media.opengl.glu.*; 

import saito.objloader.*;

GL gl; 
OBJModel model;

PImage tx;
 
void setup() {
    
  size(400, 300, OPENGL); 
  
   gl=((PGraphicsOpenGL)g).gl; 
  
   tx = createImage(width, height, RGB);
   
  frameRate(30);
  model = new OBJModel(this);
  model.debugMode();
  model.load("scene4.obj");
  
  noStroke();
  model.drawMode(POLYGON);
  //perspective(PI*0.44, float(width)/float(height),1,1000);
  
 
}

float f = 0.0;
//String base = "/home/lucasw/gprocessing/depthbuffer/";
String base = "C:/cygwin/home/lucasw/google/processing2/depthbuffer/";
int index = 0;

void draw() {


  background(5,10,100);
  
  gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT); 
  
  f+= 0.1;  
  
  fill(255, 255, 255);
  
  pushMatrix();
   translate(width/2,height*0.1,-1*f);
  rotateY(0.4*f);
//  translate(0.1*f,-0.1*f);
  
     
  //sphere(100);
  scale(50);
  
  pointLight(251, 102, 126, 35, 40, 36);
  
  pointLight(-251, -102, 126, 135, 140, 136);
  
  model.draw();
  
  /*
  pushMatrix();
  scale(50);
   beginShape(QUADS);

  fill(0, 255, 255); vertex(-1,  1,  1);
  fill(1, 255, 255); vertex( 1,  1,  1);
  fill(1, 0, 255);   vertex( 1, -1,  1);
  fill(1, 0, 255);   vertex(-1, -1,  1);
   
  endShape();
  popMatrix();
  */
  popMatrix();
  
  FloatBuffer fb = BufferUtil.newFloatBuffer(width*height);
  //set up a floatbuffer to get the depth buffer value of the mouse position
 
  gl.glReadPixels(0, 0, width, height, GL.GL_DEPTH_COMPONENT, GL.GL_FLOAT, fb); 
  fb.rewind();
  
  float mind = 0.85;
  float maxd = 0.99;
  
  for (int j = 0; j < height; j++) {
  for (int i = 0; i < width; i++) {
    
      // framebuffer has opposite vertical coord
        int ind1 = (height-j-1)*width+i;
         float d = fb.get(ind1);
         int ind = j*width+i;
        
        if (d > maxd) d = maxd;
        if (d < mind) d = mind;
        
        tx.pixels[ind] = makecolor( 1.0 - ((d-mind)/(maxd-mind)) ); 
    
        //if (d < mind) mind = d;
        //if (d > maxd) maxd = d;   
    }
  }
  
  tx.updatePixels();
  
  //saveFrame("frames/vis" +        (index+10000) + ".png");
  //tx.save(base + "frames/depth" + (index+10000) + ".png");
  index++;

  
 // println(mind + " " + maxd);
}
