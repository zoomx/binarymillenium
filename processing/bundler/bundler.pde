/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 *
 *   Simple Radiohead Scene Viewer 
 *  
 *   by Aaron Koblin
 *
 *   To use-
 *      -download, extract, and open Processing Development Environment (www.processing.org)
 *      -make sure SceneViewer.pde, Control.pde, and PointCloud.pde are in a folder called "SceneViewer" 
 *      -open SceneViewer.pde in Processing 
 *      -make sure the "data" folder with your scene files exists within the "SceneViewer" folder (press ctrl+k to see)
 *      -go to file>preferences
 *      -check the box next to "set maximum available memory to" and make sure the value is at least 256
 *      -press ok
 *      -press play and enjoy.
 *      -change file names in the setup function to look at different scenes. Play around.
 *
 *   UP and DOWN Arrows control zoom.
 *
 *  Copyright 2008 Aaron Koblin 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at 
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
 *  See the License for the specific language governing permissions and
 *  limitations under the License. 
 *
 *//////////////////////////////////////////////////////////////

import processing.opengl.*;
//import java.util.*
 
int len = 400000;
 
VBPointCloud cloud;

boolean saveImages = false;

boolean blendtype = true;

class PC {
  
  int index;
  float[] points;
  float[] colors;
  
  PC(int len) {
    index = 0;
     points = new float[len * 3];
     colors = new float[len * 4]; 
  }
  
  int numpoints;
}

class hist {
  
   float[] bins;
   float mx;
   float mn;
  
   hist(int numbins, float mx, float mn, float[] points, int numpoints, int stride, int offset) {
      bins = new float[numbins];
      this.mx = mx;
      this.mn = mn; 
      
      float stepsize = (mx - mn)/(numbins-1);      
      
      for (int i = 0; i< numpoints; i++) {
         
         float x = points[i*stride+offset];
         
         int binnum = (int)((x-mn)/stepsize);
         
         if (binnum < 0) binnum = 0;
         
         
         if (binnum >= bins.length) binnum = bins.length - 1;
         
         bins[binnum] +=  1.0/(float)numpoints;
        
      }
   }
   
   void print()
   {
      for (int i = 0; i< bins.length; i++) {
        println("bin " + i + ": " + bins[i]);
       
      } 
   }
}

void gethists(PC thePC)
{
    hist xhist = new hist(20, 1900, -4200, thePC.points, thePC.numpoints, 3, 0);
    
    println("xhist");
    xhist.print();
  
}

PC rv;
BufferedReader reader;

void setup(){
  //frameRate(SZ);
  size(1280,720, OPENGL);
  //size(1280,720, OPENGL);
  cloud = new VBPointCloud(this);
 
  //frustum(-width/2, width/2, -height/2, height/2, 0.1, 200.0);


// println("Loaded: " + raw.length + " points");
 update();
 
 frameRate(15);
 
}

void update() {

   rv = new PC(len);
   
   int start = 0;
   
   String end = ".ply";

   String base = "ply/car/bundle/points";
   
   reader = createReader(base + "001" + end);   start = loadPoints(len,start);
   reader = createReader(base + "004" + end);   start = loadPoints(len,start);
   reader = createReader(base + "005" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "007" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "009" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "010" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "012" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "014" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "016" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "019" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "022" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "024" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "025" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "027" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "033" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "035" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "040" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "047" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "051" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "060" + end);   start = loadPoints(len,start); 
   reader = createReader(base + "063" + end);   start = loadPoints(len,start);
   reader = createReader(base + "070" + end);   start = loadPoints(len,start);
   reader = createReader(base + "074" + end);   start = loadPoints(len,start);
   reader = createReader(base + "076" + end);   start = loadPoints(len,start);
   reader = createReader(base + "080" + end);   start = loadPoints(len,start);
   reader = createReader(base + "084" + end);   start = loadPoints(len,start);
   reader = createReader(base + "085" + end);   start = loadPoints(len,start);
 
  println(xmin + "," + ymin + "," + zmin + ",\t" + xmax + "," +ymax + "," + zmax);
   
   gethists(rv);
   
   cloud.loadFloats(rv.points,rv.colors); 
}

void draw(){

  background(color(0,0,0,10));
 // fill(color(1,1,1,20));
 //rect(0,0,width,height);
  

   center();
  rotations();
 

  stroke(225,250,175,90);
  cloud.draw();
  
  if (saveImages) {
    saveFrame("frames/bundler_car_######.png");  
  }
}


int counter = 0;

int numpoints = 0;

float xmin = 1000;
float ymin = 1000;
float zmin = 1000;
float xmax = -1000;
float ymax = -1000;
float zmax = -1000;

int loadPoints(int len, int start) {
    
    String newline;
  try {
    newline = reader.readLine();
  } catch(Exception e) {
    return start;  
  }  
    
 boolean header_ended = false;
 for (int i = start;  (newline != null) ; i++) {
   
    if ( header_ended) {
    String[] thisLine = split(newline, " ");
    
    float x = new Float(thisLine[0]).floatValue()*10;
    float y = new Float(thisLine[1]).floatValue()*10;
    float z = new Float(thisLine[2]).floatValue()*10;
    
    rv.points[i * 3]     = x;
    rv.points[i * 3 + 1] = y;
    rv.points[i * 3 + 2] = z;
    
    if (x < xmin) xmin = x;
    if (y < ymin) ymin = y;
    if (z < zmin) zmin = z;
    
    if (x > xmax) xmax = x;
    if (y > ymax) ymax = y;
    if (z > zmax) zmax = z;
    
// 3 5 4 looks almost right
    rv.colors[i*4]   = new Float(thisLine[3]).floatValue() / 255.0;
    rv.colors[i*4+1] = new Float(thisLine[4]).floatValue() / 255.0;//abs( new Float(thisLine[0]).floatValue() )/32.0;
    rv.colors[i*4+2] = new Float(thisLine[5]).floatValue() / 255.0;//abs( new Float(thisLine[0]).floatValue() )/32.0;
    rv.colors[i*4+3] = 0.05;
     
     numpoints = i;
      rv.numpoints = numpoints;
    } else {
      
       //println(newline); 
       
       if (match(newline,"end_header") != null) {
          header_ended = true;
       } 
    }
  try {
    newline = reader.readLine();
  } catch(Exception e) {
    return numpoints;  
  }
  
    
  }

  println(numpoints);
  
 
  
  return numpoints;
}


