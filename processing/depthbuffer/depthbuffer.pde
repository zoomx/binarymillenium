 import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  

import javax.media.opengl.glu.*; 

import saito.objloader.*;

GL gl; 
OBJModel model;

/// waypoints
float wp[][] = new float[7][4];
/// xyz rot
float state[] = new float[4];
/// v xyz vrot
float dstate[] = new float[4];
int wpind=0;


PImage tx;
 
void setup() {
  
  //for (int i = 0; i< waypoints.length; i++ ) {
  state[0] = 0;
  state[1] = 0;
  state[2] = 50;
  state[3] = 0;
  
  int i;  
  i=0; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 100; wp[i][3] = 0;
  i=1; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 300; wp[i][3] = 0;
  i=2; wp[i][0] = 300;   wp[i][1] = 0; wp[i][2] = 300; wp[i][3] = 0;
  i=3; wp[i][0] = 300;   wp[i][1] = 0; wp[i][2] = 300; wp[i][3] = -PI/2;
  i=4; wp[i][0] = 300;   wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = -PI/2;
  i=5; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = -PI/2;
  i=6; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = 0;
  //wp[4][0] = 200; wp[3][1] = 0; wp[3][2] = 190; wp[3][3] = 0;
  //wp[4][0] = 0; wp[4][1] = 0; wp[4][2] = 190; wp[4][3] = 0;
    
  //}
  
 
    
  size(400, 300, OPENGL); 
  
   gl=((PGraphicsOpenGL)g).gl; 
  
   tx = createImage(width, height, RGB);
   
  frameRate(10);
  model = new OBJModel(this);
  model.debugMode();
  model.load("scene4.obj");
  
  noStroke();
  model.drawMode(POLYGON);
  //perspective(PI*0.44, float(width)/float(height),1,1000);
  
 
  float fogColor[] =
    { 1.0f, 1.0f, 1.0f, 1.0f };
    float f1 = 1.0f;
    float f2 = 5.0f;
    float f3 = 10.0f;

   /* gl.glEnable(GL.GL_FOG);
    gl.glFogi(GL.GL_FOG_MODE, GL.GL_EXP);
    gl.glFogfv(GL.GL_FOG_COLOR, fogColor, 0);
   //gl.glFogf(GL.GL_FOG_DENSITY, 0.000005f);
   gl.glHint(GL.GL_FOG_HINT, GL.GL_DONT_CARE);
   // gl.glFogi(GL.GL_FOG_COORDINATE_SOURCE_EXT, GL.GL_FOG_COORDINATE_EXT);
    gl.glClearColor(0.0f, 0.25f, 0.25f, 1.0f);  */
}

float f = 0.0;
//String base = "/home/lucasw/gprocessing/depthbuffer/";
String base = "C:/cygwin/home/lucasw/google/processing2/depthbuffer/";
int index = 0;

void draw() {

  float kd = 0.04;
  //float kv = 0.09;
  float diff[] = new float[4];
  for (int i = 0; i < 4; i++) {
    
     diff[i] = wp[wpind][i] - state[i];    
     dstate[i]+= diff[i]*kd;
     dstate[i] *= 0.8;  
     state[i] += dstate[i];// - dstate[i]*kv;
  
  }

    if ((abs(diff[0]) < 10) && (abs(diff[1]) < 10) && (abs(diff[2]) < 10) &&
    (abs(dstate[0]) < 2) && (abs(dstate[1]) <2) && (abs(dstate[2]) < 2)
    ) {
        wpind++;
        if (wpind >= wp.length) wpind = 0;
        println("new waypoint " + wpind);
     }
 

  background(100,100,240);
  
  gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT); 
  
  f+= 0.1;  
  
  fill(255, 255, 255);
  
  pushMatrix();
  
   rotateY(state[3]);
   translate(state[0],state[1],state[2]);
  
//  translate(0.1*f,-0.1*f);
  
     
  //sphere(100);
  scale(50);
  
  pointLight(151, 102, 126, 35, -540, 36);
  
  pointLight(-51, 32, 46, 435, 540, 136);
  
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
        
        d+= (maxd-mind)/15.0 * noise((float)j/2.0,(float)i/2.0,f*10);
        
        if (d > maxd) d = maxd;
        if (d < mind) d = mind;
        
        tx.pixels[ind] = makecolor( 1.0 - ((d-mind)/(maxd-mind)) ); 
    
        //if (d < mind) mind = d;
        //if (d > maxd) maxd = d;   
    }
  }
  
  tx.updatePixels();
  
  
  saveFrame("frames/vis" +        (index+10000) + ".png");
  tx.save(base + "frames/depth" + (index+10000) + ".png");
  index++;

  
 // println(mind + " " + maxd);
}
