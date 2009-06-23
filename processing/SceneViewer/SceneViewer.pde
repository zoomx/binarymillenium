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
 
int len = 150000;
 
VBPointCloud cloud;

boolean dontprogress = false;
boolean saveImages = true;

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
  //size(640,480, OPENGL);
  size(1280,720, OPENGL);
  cloud = new VBPointCloud(this);
 
// println("Loaded: " + raw.length + " points");
 update();
 
}

void update() {
   
   reader = createReader("../googlecode/trunk/processing/velodyne/unit_46_sample_capture_velodyne_" + counter + ".csv");
   
   rv = new PC(len);

   loadPoints(len);
  
     cloud.loadFloats(rv.points,rv.colors);

     println(counter);
}

void draw(){

    if (!dontprogress) {
      counter++;
      update(); 
    }

  background(0);
  //fill(color(0,0,50,150));
  //rect(0,0,width,height);
  
  center();
  rotations();
  zooms();

  stroke(225,250,175,90);
  cloud.draw();
  
  if (saveImages) {
    saveFrame("frames/unit_46_velodyne_full_monterey_pc_######.jpg");  
  }
}


int counter = 0;

int numpoints = 0;

void loadPoints(int len) {
  
  //byte b[] = loadBytes("../../velodyne/output" + counter +".bin");

  //rv.points = new float[1][b.length/16 * 3];
  //rv.colors = new float[1][b.length/16 * 4]; 
  
  
  //for (int i = 0; i < b.length/16; i++) {
    
    String newline;
  try {
    newline = reader.readLine();
  } catch(Exception e) {
    return;  
  }  
    
   
 for (int i = 0; (i < len) && (newline != null) ; i++) {
    
    // String[] thisLine = split(raw[i+ counter*len], ",");
    String[] thisLine = split(newline, ",");
    
    rv.points[i * 3]     = new Float(thisLine[1]).floatValue() / 500;
    rv.points[i * 3 + 1] = new Float(thisLine[2]).floatValue() / 500;
    rv.points[i * 3 + 2] = new Float(thisLine[3]).floatValue() / 500;



    
    rv.colors[i*4]   = new Float(thisLine[0]).floatValue() / 255;
    rv.colors[i*4+1] = (new Float(thisLine[3]).floatValue()+1700 ) /1555.0;
    rv.colors[i*4+2] = (new Float(thisLine[3]).floatValue()+1300 ) /2555.0;
    rv.colors[i*4+3] = 150.0;
     
     numpoints = i;
  try {
    newline = reader.readLine();
  } catch(Exception e) {
    return;  
  }
  
    
  }

  
  
  return;
}


