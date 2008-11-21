import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  
import javax.media.opengl.glu.*; 
import saito.objloader.*;

GL gl; 
OBJModel model;

/// xyz rot
float state[] = new float[4];
/// v xyz vrot
float dstate[] = new float[4];
int wpind=0;

float near = 1.0;
float far = 4000.0;

PImage tx;
 
 /// waypoints
float wp[][] = new float[8][4];


float wprad = 0.55;

void setup() {
  
  float r = PI/9;
  //for (int i = 0; i< waypoints.length; i++ ) {
    float d = wprad*5;
  state[0] = d;
  state[1] = 0;
  state[2] = -d;
  state[3] = r;
  
  int i; 
  i=0; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] = -d; wp[i][3] = PI/2;
  i=1; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] = -d; wp[i][3] = PI/12;
  i=2; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = 0;
  i=3; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] =-PI/2;
  i=4; wp[i][0] = d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = -PI/2;
  i=5; wp[i][0] = d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = -PI;
  i=6; wp[i][0] = -d;  wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = -PI;
  i=7; wp[i][0] = -d;  wp[i][1] = 0; wp[i][2] = -d; wp[i][3] = -PI;
  /*
 
  i=4; wp[i][0] = 300;   wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = -PI/2;
  i=5; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = -PI/2;
  i=6; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = 0;
  */
  //wp[4][0] = 200; wp[3][1] = 0; wp[3][2] = 190; wp[3][3] = 0;
  //wp[4][0] = 0; wp[4][1] = 0; wp[4][2] = 190; wp[4][3] = 0;
    
  //}
     
  size(640, 640, OPENGL); 
  
   gl=((PGraphicsOpenGL)g).gl; 
  
   tx = createImage(width, height, RGB);
   
  frameRate(10);
  model = new OBJModel(this);
  model.debugMode();
  model.load("scenesimple2.obj");
  
  noStroke();
  model.drawMode(POLYGON);
  
  perspective(PI*0.5, float(width)/float(height),near,far);
  
 
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
//String base = "C:/cygwin/home/lucasw/google/processing2/depthbuffer/";
//String base = "C:/Documents and Settings/lucasw/My Documents/own/ee587/final/depthbuffer/";
String base = "C:/Users/lucasw/own/prog/googlecode/trunk/processing/depthbuffer/";
int index = 0;

int wpcounter = 0;

float f2 = 0.0;

void draw() {
  f2 += 0.3;

  float kd = 0.009;

  float diff[] = new float[4];
  for (int i = 0; i < 4; i++) {
    
     diff[i] = wp[wpind][i] - state[i];   
    
     if (i == 4) {
        if (diff[i] > 2*PI) diff[i] = diff[i] - 2*PI;
        if (diff[i] <-2*PI) diff[i] = diff[i] + 2*PI;
        
        if (diff[i] > PI) diff[i] = 2*PI-diff[i];
        if (diff[i] <-PI) diff[i] = 2*PI+diff[i];
        
     }
     
     dstate[i]+= diff[i]*kd +  0.0001*noise(f2 + 100*i);
     dstate[i] *= 0.8;  
     state[i] += dstate[i] + 0.01*noise(f2 + 10*i);// - dstate[i]*kv;
  
  }

    if ((abs(diff[0]) < wprad*2) && (abs(diff[1]) < wprad*2) && (abs(diff[2]) < wprad*2) &&
    (abs(dstate[0]) < wprad/2.0) && (abs(dstate[1]) <wprad/2.0) && (abs(dstate[2]) < wprad/2.0) &&
    (abs(diff[3]) < PI/15)
    ) {
        wpind++;
        if (wpind >= wp.length) { 
          wpcounter++; 
          wpind = 0;
          if (wpcounter >=2) noLoop();
        }
        println("new waypoint " + wpind);
     }
 

  background(100,100,240);
  
  gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT); 
  
  f+= 0.1;  
  
  fill(255, 255, 255);
  
  pushMatrix();
  
  float r = state[3];
   rotateY(r);
   
   /*
   float rm[][]     = {
                       {cos(r),  0,  -sin(r)}, 
                       {0,       1,  0},  
                       {sin(r),  0,  cos(r)} 
                      };
                      */
                      
   float rm[][]     = {
                       {1,  0,  0}, 
                       {0,  1,  0},  
                       {0,  0,  1} 
                      };
   
   
   float x = state[0];
   float y = state[1];
   float z = state[2];
   
   float rx,ry,rz;
   
   /*
   rx = rm[0][0]*x + rm[0][1]*y + rm[0][2]*z;
   ry = rm[1][0]*x + rm[1][1]*y + rm[1][2]*z;
   rz = rm[2][0]*x + rm[2][1]*y + rm[2][2]*z;
   */
   
   rx = rm[0][0]*x + rm[1][0]*y + rm[2][0]*z;
   ry = rm[0][1]*x + rm[1][1]*y + rm[2][1]*z;
   rz = rm[0][2]*x + rm[1][2]*y + rm[2][2]*z;
   

  
  
       translate(0,-400,0);
     
  //sphere(100);
  scale(200);
  
   translate(rx,ry,rz);
  
  pointLight(121, 121, 131, 435, -340, 436);  
 // pointLight(-51, 51,   51, 435, 540, 336);
   pointLight(71, 71,  11, -335, -20, 236);
   
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
  
  float neard = 0.0;// 500.0; //.998;//1000;
  float fard = far;//*0.6; //1;
  
  /*
  int viewport[] = new int[4];
  double[] proj=new double[16];
  double[] model=new double[16];
  gl.glGetIntegerv(GL.GL_VIEWPORT, viewport, 0);
  gl.glGetDoublev(GL.GL_PROJECTION_MATRIX,proj,0);
  gl.glGetDoublev(GL.GL_MODELVIEW_MATRIX,model,0); 
  double[] mousePosArr=new double[4]; 
*/

  for (int j = 0; j < height; j++) {
  for (int i = 0; i < width; i++) {
    
      // framebuffer has opposite vertical coord
        int ind1 = (height-j-1)*width+i;
         float d = fb.get(ind1);
         
         
         d = -2*far*near/(d*(far-near) - (far+near));
         
         //glu.gluUnProject(x,height-j,d, model,0,proj,0,viewport,0,mousePosArr,0); 
  
          //println(mousePosArr[0] + " " + mousePosArr[1] + " " + mousePosArr[2] );
  
         int ind = j*width+i;
         
        //if (d < mind) mind = d;
        //if (d > maxd) maxd = d; 
        
        //d+= (maxd-mind)/15.0 * noise((float)j/2.0,(float)i/2.0,f*10);
        
        
       
        if (d > fard) d = fard;
        if (d < neard) d = neard;
        
        tx.pixels[ind] = makecolor( 1.0 - ((d-neard)/(fard-neard)) ); 
    
      
    }
  }
  
  //noLoop();
  
  tx.updatePixels();
  
  
  saveFrame("frames/vis/vis"   +        (index+10000) + ".png");
  tx.save(base + "frames/depth/depth" + (index+10000) + ".png");
  
  
  index++;

  
// println(mind + " " + maxd);
}
