// binarymillenium 2008
// licensed under the GNU GPL latest version

import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  
import javax.media.opengl.glu.*; 
import saito.objloader.*;

GL gl; 
 GLU glu; 
OBJModel model;

boolean useopengl = true;
boolean orthomode = false;
boolean orthotopview = false;
boolean savedata = true;
boolean usenoise = false;

PrintWriter output;

/// xyz rot
float state[] = new float[4];
/// v xyz vrot
float dstate[] = new float[4];
int wpind=0;

final float movemax = 2.0;
final float fov = 90.0;  //degrees
 
float cameraZ = 0.0;
float near= 0.0;
float far = 0.0;


float scaleval = 100;

PImage tx;
 
 /// waypoints
float wp[][] = new float[9][4];


float wprad = 0.55;

FloatBuffer fb;
 
void setup() {
  
  cameraZ = (height/2.0) / tan(PI * fov / 360.0);

  if (useopengl)   size(800, 800, OPENGL); 
  else             size(800, 800, P3D); 
  scaleval = height/2;
  
  near = scaleval/2; 
  far = scaleval*40;
  println(cameraZ + ", " + near + " " + far);
   
  fb = BufferUtil.newFloatBuffer(width*height);

  if (useopengl){
    gl=((PGraphicsOpenGL)g).gl; 
    glu=((PGraphicsOpenGL)g).glu; 
  }
  
  tx = createImage(width, height, RGB);
   
  //frameRate(10);
  model = new OBJModel(this);
  model.debugMode();
  model.load("scenesimple2.obj");
  //model.load("scene4.obj");
  
  noStroke();
  model.drawMode(POLYGON);
  
  if (orthomode) {
    
  } else if (orthotopview) {
      setuporthotopview();

  } else {
    
    
    perspective(fov/180.0*PI, float(width)/float(height),near,far);
    //perspective(fov/180.0*PI, float(width)/float(height),near,far);
    
    
      if (savedata) output = createWriter("angles.csv");
  
  final float r = 0;//PI/9;
  //for (int i = 0; i< waypoints.length; i++ ) {
  final float d = wprad*5;
  state[0] = 0;
  state[1] = 0;
  state[2] = 0;
  state[3] = r;
  
  int i; 
 /* i=0; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] = -d; wp[i][3] = PI/2;

  i=1; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] = -d; wp[i][3] = PI/12;
  i=2; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = 0;
  i=3; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] =-PI/2;
  i=4; wp[i][0] = d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = -PI/2;
  i=5; wp[i][0] = d;   wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = -PI;
  i=6; wp[i][0] = -d;  wp[i][1] = 0; wp[i][2] =  d; wp[i][3] = -PI;
  i=7; wp[i][0] = -d;  wp[i][1] = 0; wp[i][2] = -d; wp[i][3] = -PI;
  i=8; wp[i][0] =-d;   wp[i][1] = 0; wp[i][2] = -d; wp[i][3] = PI/2;*/

 /*
  i=4; wp[i][0] = 300;   wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = -PI/2;
  i=5; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = -PI/2;
  i=6; wp[i][0] = 0;     wp[i][1] = 0; wp[i][2] = 0;   wp[i][3] = 0;
 */ 
  //wp[4][0] = 200; wp[3][1] = 0; wp[3][2] = 190; wp[3][3] = 0;
  //wp[4][0] = 0; wp[4][1] = 0; wp[4][2] = 190; wp[4][3] = 0;
    
  //}
  }
  
}

float f = 0.0;
//String base = "/home/lucasw/gprocessing/depthbuffer/";
//String base = "C:/cygwin/home/lucasw/google/processing2/depthbuffer/";
//String base = "C:/Documents and Settings/lucasw/My Documents/own/ee587/final/depthbuffer/";
String base = "C:/Users/lucasw/own/prog/googlecode/trunk/processing/depthbuffer/";
//String base = "H:/final_project/depthbuffer/";

int index = 0;

int wpcounter = 0;

float f2 = 0.0;

void updatestate()
{
  f2 += 0.3;

  float kd = 0.009;

  if (savedata) output.print(index + ",\t");
  //print(index + ",\t");
  
  float diff[] = new float[4];
  for (int i = 0; i < 4; i++) {
    
     diff[i] = wp[wpind][i] - state[i];   
    
    /*
     if (i == 3) {
        if (diff[i] > 2*PI) diff[i] = diff[i] - 2*PI;
        if (diff[i] <-2*PI) diff[i] = diff[i] + 2*PI;
        
        if (diff[i] > PI) diff[i] = 2*PI-diff[i];
        if (diff[i] <-PI) diff[i] = 2*PI+diff[i];
        
     }*/
     
     dstate[i]+= diff[i]*kd;
      if (usenoise) dstate[i] += 0.001*noise(f2 + 100*i);
     dstate[i] *= 0.8;  
     
  
     
     if (i < 3) {
         if (dstate[i] > movemax) dstate[i] = movemax; 
         if (dstate[i] <-movemax) dstate[i] =-movemax;
         //print(dstate[i] + "\t");
     } else {
        if (dstate[i]*180.0/PI > 2.0) dstate[i] = 2.0/180.0*PI; 
        if (dstate[i]*180.0/PI <-2.0) dstate[i] =-2.0/180.0*PI; 
         //print(",\tdegrate " + dstate[i]*180.0/PI + ",\t");
     }
      if (usenoise) dstate[i] += 0.0003*noise(f2 + 10*i);// - dstate[i]*kv;
     
    
     if (savedata) {
       if(i < 3) output.print(dstate[i]*scaleval + ",\t");
       else   output.print(dstate[i]*180.0/PI + ",\t");
     }
     
     state[i] += dstate[i];   
  }
  
  if (savedata) {
     output.print(state[0] + ",\t" + state[1] + ",\t" + state[2] + ",\t" + state[3]*180.0/PI + ",\t");
    output.print("\n");
    output.flush();
  }
  
  //print("\n");
  

    if ((abs(diff[0]) < wprad*4) && (abs(diff[1]) < wprad*4) && (abs(diff[2]) < wprad*4) &&
    (abs(dstate[0]) < wprad*3) && (abs(dstate[1]) <wprad*3) && (abs(dstate[2]) < wprad*3) &&
    (abs(diff[3]) < 16.0/180.0*PI)
    ) {
        wpind++;
        if (wpind >= wp.length) { 
          wpcounter++; 
          wpind = 0;
          if (wpcounter >=1) noLoop();
        }
        println("new waypoint " + wpind);
     }
///////////////////////////////////////////////////////// 
 
}


void drawandgetdepth() {
  
 
  f+= 0.1;  
  
  fill(255, 255, 255);
  
  //noFill();
  //stroke(255);
  
  pushMatrix();
  
  float r = state[3];
   rotateY(r);
   
   
  

    scale(scaleval);
    translate(0,1,0);
    float x = state[0];
   float y = state[1];
   float z = state[2];
   
   if (false) {
//      r = -r;
   float rm[][]     = {
                       {cos(r),  0,  -sin(r)}, 
                       {0,       1,  0},  
                       {sin(r),  0,  cos(r)} 
                      };                   
   
 
   
   float rx,ry,rz;
   
   
   if (true) {
   rx = rm[0][0]*x + rm[0][1]*y + rm[0][2]*z;
   ry = rm[1][0]*x + rm[1][1]*y + rm[1][2]*z;
   rz = rm[2][0]*x + rm[2][1]*y + rm[2][2]*z;
   } else {
   rx = rm[0][0]*x + rm[1][0]*y + rm[2][0]*z;
   ry = rm[0][1]*x + rm[1][1]*y + rm[2][1]*z;
   rz = rm[0][2]*x + rm[1][2]*y + rm[2][2]*z;
   }
  
      translate(-rx,-ry,-rz);
   } else { 
  
       translate(x,y,z);
   }
   
  pointLight(121, 121, 131, 435, -340, 436);  
 // pointLight(-51, 51,   51, 435, 540, 336);
   pointLight(71, 71,  11, -335, -20, 236);
   
  model.draw();
  
  popMatrix();
  
  
  //set up a floatbuffer to get the depth buffer value of the mouse position
 
   if (useopengl) {
    gl.glReadPixels(0, 0, width, height, GL.GL_DEPTH_COMPONENT, GL.GL_FLOAT, fb); 
      fb.rewind();
   }
  
  float neard =  near; //.998;//1000;
  float fard = far*0.7; //1;

int viewport[] = new int[4]; 
  double[] proj=new double[16];
  double[] model=new double[16];
  gl.glGetIntegerv(GL.GL_VIEWPORT, viewport, 0);
  gl.glGetDoublev(GL.GL_PROJECTION_MATRIX,proj,0);
  gl.glGetDoublev(GL.GL_MODELVIEW_MATRIX,model,0);
  
   double[] pos=new double[4];

  for (int j = 0; j < height; j++) {
    
  for (int i = 0; i < width; i++) {
    
      // framebuffer has opposite vertical coord
        
        int ind = j*width+i;
        
        float rawd = 0;
         if (useopengl) {
           int ind1 = (height-j-1)*width+i;
           rawd = fb.get(ind1);
         } else {
           rawd = g.zbuffer[ind];
         }

         //float d = (-2*far*near/(rawd*(far-near) - (far+near)));
         


         glu.gluUnProject(i,height-j,rawd, model,0,proj,0,viewport,0,pos,0); 
         float d = (float)-pos[2];
         
         if ((i == width/2) && (j > height/2)) {
            output.println(rawd + ",\t" + d/scaleval + ",\t" + (float)height/(2.0*(j-height/2)));
         }
         
        //if (d < mind) mind = d;
        //if (d > maxd) maxd = d; 
        
        //d+= (maxd-mind)/15.0 * noise((float)j/2.0,(float)i/2.0,f*10);
          
        if (d > fard) d = fard;
        if (d < neard) d = neard;
        
        float distf=  1.0 - ((d-neard)/(fard-neard));
        

        tx.pixels[ind] = makecolor(distf); //color(distf*255); //   
    }
  }
  
  //noLoop();
  
  tx.updatePixels();
  
  
  if (savedata) {
    saveFrame("frames/vis/vis"   +        (index+10000) + ".png");
    tx.save(base + "frames/depth/depth" + (index+10000) + ".png");
  }
  
  index++;

   
// println(mind + " " + maxd);
}

void draw() {
   noLoop();
  if (orthomode) {
    
      updatestate();
  
      background(100,100,240);
  
      gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    
      
      drawandgetdepth();
    
  } else if (orthotopview) {
     drawtopview();
  } else {
    
    
    updatestate();
  
  background(100,100,240);
  
  if (useopengl) {
    gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
  }
  
 /// this is critical, 0,0 is in the upper left 
   float cameraZ = (height/2.0) / tan(PI * fov / 360.0);
    translate(width/2,height/2,cameraZ);
  
    drawandgetdepth();
 
  }
}



////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

void setuporthotopview() {
     near = 893;//270;
    far = 887;//280;
    /*
    float minx =0,maxx=0,miny=0,maxy=0,minz=0,maxz = 0;
    for (i = 0; i < model.getVertexsize(); i++) {
      Vertex v =  model.getVertex(i);
      if (i == 0) {
        minx = v.vx;
        maxx = v.vx;
        miny = v.vy;
        maxy = v.vy;
        minz = v.vz;
        maxz = v.vz;
      } else {
        if (v.vx > maxx) maxx = v.vx;
        if (v.vx < minx) minx = v.vx;
        if (v.vy > maxy) maxy = v.vy;
        if (v.vy < miny) miny = v.vy;        
        if (v.vz > maxz) maxz = v.vz;
        if (v.vz < minz) minz = v.vz;
       
      }
    }
    
    println(minx + " " + maxx + ", " + miny + " " + maxy + ", " + minz + " " + maxz);
    */
    float minx = -41;
    float maxx = 32;
    float miny = -10;
    float maxy = 10;
    float minz = -32;
    float maxz = 36;
    
    //noLoop();
    
    ortho(-15,15,-15,15, near,far);
//    ortho(0,width,0,height, -4000,4000);
    //ortho(-width*10,width*10,-height*10,height*10, -4000,4000);
   // perspective(fov/180.0*PI, float(width)/float(height),near,far);   
}
     
void drawtopview() {
     background(0);
    pushMatrix();
     
     //translate
   // float cameraZ = (height/2.0) / tan(PI * fov / 360.0);
    translate(width/2,height/2,0);
    rotateX(-90.0/180.0*PI);
  
    pointLight(121, 121, 131, 435, -340, 436);  
    pointLight(71, 71,  11, -335, -20, 236);
    model.draw();
    popMatrix();
    
     gl.glReadPixels(0, 0, width, height, GL.GL_DEPTH_COMPONENT, GL.GL_FLOAT, fb); 
  fb.rewind();
  
  float neard =  500.0; //.998;//1000;
  float fard = far*0.8; //1;

  float mind=100000.0,maxd=0.0;
  
  loadPixels();
  int count = 0;
  for (int j = 0; j < height; j++) {
  for (int i = 0; i < width; i++) {
    
      // framebuffer has opposite vertical coord
        int ind1 =(height-j-1)*width+i;
        
        //if (pixels[ind1] != color(0)) {
          count++;
         float d = fb.get(ind1);

         d *= (far-near);
         //d = -2*far*near/(d*(far-near) - (far+near));
         
         int ind = j*width+i;
         
        //if (d < mind) mind = d;
        //if (d > maxd) maxd = d; 
        
        //d+= (maxd-mind)/15.0 * noise((float)j/2.0,(float)i/2.0,f*10);
        
        //if (d > fard)  d = fard;
        //if (d < neard) d = neard;
        
       // float distf=  //((d-near)/(far-near));
        
        if (d < mind) mind = d;
        if (d > maxd) maxd = d; 
       // print(distf + " " + d + ", ");
        tx.pixels[ind] = makecolor(d/(far-near)); //color(distf*255); //   
        //}
    }
  }
  println("\n" + count + ", " + mind + " " + maxd);
  
  
  
  tx.updatePixels();
  
  
  if (savedata) {
    saveFrame("frames/topvis.png");
    tx.save(base + "frames/topheight.png");
  }
    
    noLoop();
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
     
