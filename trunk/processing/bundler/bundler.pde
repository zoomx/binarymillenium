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
 
int len = 20000;
 
VBPointCloud cloud;

boolean saveImages = false;

class PC {
  
  int index;
  float[] points;
  float[] colors;
  
  PC(int len) {
    index = 0;
     points = new float[len * 3];
     colors = new float[len * 4]; 
  }
}

PC rv;
BufferedReader reader;

void setup(){
  //frameRate(SZ);
  size(640,480, OPENGL);
  //size(1280,720, OPENGL);
  cloud = new VBPointCloud(this);
 
  //frustum(-width/2, width/2, -height/2, height/2, 0.1, 200.0);


// println("Loaded: " + raw.length + " points");
 update();
 
 frameRate(15);
 
}

void update() {
   
  //reader = createReader("mesaverde.csv");
  // reader = createReader("sphinx.csv");
  // reader = createReader("flower.csv");
   
   
   rv = new PC(len);
   
   int start;
   
  /*
   reader = createReader("points001.ply");
   start = loadPoints(len,0);
   reader = createReader("points004.ply");
   start = loadPoints(len,start);
   reader = createReader("points006.ply");
   start = loadPoints(len,start);
   reader = createReader("points008.ply");
   start = loadPoints(len,start);
   reader = createReader("points009.ply");
   start = loadPoints(len,start);
   */
   
   reader = createReader("ply/flower/points001.ply");
   start = loadPoints(len,0);
   reader = createReader("ply/flower/points003.ply");
   start = loadPoints(len,start);
   reader = createReader("ply/flower/points004.ply");
   start = loadPoints(len,start);  

   
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
    saveFrame("frames/unit_46_velodyne_full_monterey_pc_######.jpg");  
  }
}


int counter = 0;

int numpoints = 0;

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
    
    rv.points[i * 3]     = new Float(thisLine[0]).floatValue()*100;
    rv.points[i * 3 + 1] = new Float(thisLine[1]).floatValue()*100;
    rv.points[i * 3 + 2] = new Float(thisLine[2]).floatValue()*100;

// 3 5 4 looks almost right
    rv.colors[i*4]   = new Float(thisLine[3]).floatValue() / 255.0;
    rv.colors[i*4+1] = new Float(thisLine[4]).floatValue() / 255.0;//abs( new Float(thisLine[0]).floatValue() )/32.0;
    rv.colors[i*4+2] = new Float(thisLine[5]).floatValue() / 255.0;//abs( new Float(thisLine[0]).floatValue() )/32.0;
    rv.colors[i*4+3] = 0.7;
     
     numpoints = i;
    } else {
      
       println(newline); 
       
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


