

import processing.opengl.*;


int counter =1;

final int SZX = 130*2;
final int SZY = 130*2;

///

///
float[][][] f = new float[SZX][SZY][4];



void setup(){
  
  size(640,480, OPENGL);
 
  strokeWeight(1);
  
  update(counter);
  
}

void update(int counter) {
  
  
  String[] raw = loadStrings(counter+".csv");
  
  float p1[][] = new float[raw.length][4];
  
  
  float minx = -70;
  float maxx = 230;
  
float miny = -110;
float maxy = 300;

float minz = -1100;
float maxz = 360;

float mini = 100;
float maxi = 0;

  
  /// preprocess to find out the extent of the data
  for (int i = 0; i < raw.length; i++) {
    
    String[] ln = split(raw[i],',');
    
    float x = float(ln[0]);
    float y = float(ln[1]);
    float z = float(ln[2]);
    int intensity = int(ln[3]);
    
      p1[i][0] = x;
      p1[i][1] = y;
      p1[i][2] = z;
      p1[i][3] = intensity;    
    
    if (intensity < mini) mini = intensity;
    if (intensity > maxi) maxi = intensity;  

/*
if (counter == 1) {
    
    if (x < minx) minx = x;
    if (y < miny) miny = y;
    if (z < minz) minz = z;
    if (x > maxx) maxx = x;
    if (y > maxy) maxy = y;
    if (z > maxz) maxz = z;
}
*/
    
  }
  
  /*
  if (counter == 1) {
  print(minx + ", " + maxx + ", " + miny + " " + maxy + ", " + minz + " " + maxz + "\n");
  }
  */
  /// maxi is 255
  //print(mini + " " + maxi + "\n");
  
  for (int i = 0; i < SZX; i++) {
    for (int j = 0; j < SZY; j++) {
      f[i][j][0] = (float)i/(float)SZX * (maxx-minx) + minx - (maxx-minx)/2;
      f[i][j][1] = (float)j/(float)SZY * (maxy-miny) + miny - (maxy-miny)/2;
      f[i][j][2] = 0;
    }
  }
  
  
  /// go through again to assign data to bins
  for (int i = 0; i < raw.length; i++) {
    /// get rid of the /2 *2 to get rid of the doubling up effect
    int x_ind = int((p1[i][0]-minx)/(maxx-minx)*(SZX/2))*2;
    int y_ind = int((p1[i][1]-miny)/(maxy-miny)*(SZY/2))*2;
    
    if ((x_ind >= 0) && (x_ind < SZX) && (y_ind >= 0) && (y_ind < SZY)) {
      if ((p1[i][2] +150 >0) && ((i == 0) || (abs(p1[i][2]-p1[i-1][2]) < 5) ))
        f[x_ind][y_ind][2] = p1[i][2]+150;
        
      f[x_ind][y_ind][3] = p1[i][3];
    }
    
    //print(x_ind + " " + y_ind + "\n");
  }
  
  
   for (int i = 1; i < SZX-1; i+=2) {
    for (int j = 1; j < SZY-1; j+=2) {  
      f[i][j][2] = (f[i-1][j-1][2] + f[i+1][j-1][2] + f[i+1][j-1][2] + f[i+1][j+1][2])/4.0;
      f[i][j][3] = (f[i-1][j-1][3] + f[i+1][j-1][3] + f[i+1][j-1][3] + f[i+1][j+1][3])/4.0;
    }
  }
  
  /// this doubling up isn't quite working right, should try something else
    for (int i = 2; i < SZX-1; i+=2) {
    for (int j = 1; j < SZY-1; j+=2) {  
      f[i][j][2] = (f[i][j-1][2] + f[i][j+1][2])/2.0;
      f[i][j][3] =  (f[i][j-1][3] + f[i][j+1][3])/2.0;
    }
  }
  
   for (int i = 1; i < SZX-1; i+=2) {
    for (int j = 2; j < SZY-1; j+=2) {  
      f[i][j][2] = (f[i-1][j][2] + f[i+1][j][2])/2.0;
      f[i][j][3] = (f[i-1][j][3] + f[i+1][j][3])/2.0;
    }
  }
  
  
}

void draw() {

  background(0);
  
  pushMatrix();
  
 //lights();
 
  translate(width/2, height/2); 

  translate(0,50,450-mouseY/1.0);



  float div = 100;
  rotateY(-(width/div)/2 + mouseX/div);
 
 //pointLight(255, 255, 255, 0, 50, 350);
 lights();
 
     noStroke();
    //stroke(255);
    
    for (int i = 0; i < SZX-1; i++) {
      beginShape(TRIANGLE_STRIP);
    for (int j = 0; j < SZY-1; j++) {
      
      fill(f[i][j][3]);
    //front face
   // beginShape(TRIANGLES);
    vertex( f[i][j][0],     f[i][j][1],    f[i][j][2]); 
    vertex( f[i][j+1][0],   f[i][j+1][1],  f[i][j+1][2]);
    vertex( f[i+1][j][0],   f[i+1][j][1],  f[i+1][j][2]);
    vertex( f[i+1][j+1][0], f[i+1][j+1][1],f[i+1][j+1][2]);
    //endShape();
    }
     endShape(); 
  }
  
  update(counter++);
    
    
  // This would be a way to save out frame *remember you're saving files to your harddrive*
  // saveFrame("renderedFrames/"+frameCounter+".tga");
  
  popMatrix();
}
