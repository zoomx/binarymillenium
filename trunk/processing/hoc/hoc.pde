/**
*
(c) binarymillenium 2008
Licensed under the GNU GPL latest version
*/

import processing.opengl.*;


int counter =1;

final int SZX = 68;
final int SZY = 68;

///


float[][][] f = new float[SZX][SZY][4];
/// the spring points, also stores the target points (which aren't updated)
float[][][] sp = new float[SZX*2][SZY][6];

boolean doublePoints = false;


float[] minus(float a[], float b[]) {
  float r[] = new float[3];
  
  r[0] = a[0] - b[0];
  r[1] = a[1] - b[1];
  r[2] = a[2] - b[2];
  
  return r;
}

float[] crossProduct(int i, int j, int i1, int j1, int i2, int j2) {
 
 float a[] = minus(sp[i1][j1], sp[i][j]);
 float b[] = minus(sp[i2][j2], sp[i][j]);
 
 return crossProduct(a,b);
  
}

float[] crossProduct(float[] a, float b[]) {
    float r[] = new float[3];
    r[0] = 1;
    
  if (a.length != 3) return r;
  if (b.length != 3) return r;
  
  a = normalize(a);
  b = normalize(b);
  
  
  r[0] = a[1]*b[2] - a[2]*b[1];
  r[1] = a[2]*b[0] - a[0]*b[2];
  r[2] = a[0]*b[1] - a[1]*b[0];
  
  r = normalize(r);
  
  return r;
  
}

class Spring {
  
  /// this is the length the spring tries to be
  float len;
  
  int i1;
  int j1;
  int i2;
  int j2;
  
  float kd;
  float kv;
  
  Spring(int i1, int j1, int i2, int j2, float len, float kd, float kv ){
    this.i1 = i1;
    this.j1 = j1;
    this.i2 = i2;
    this.j2 = j2;
    
    this.len = len;
    
    this.kd = kd;
    this.kv = kv;
    
  }
  
  void updateVel() {

      float dx = sp[i1][j1][0] - sp[i2][j2][0];
      float dy = sp[i1][j1][1] - sp[i2][j2][1];
      float dz = sp[i1][j1][2] - sp[i2][j2][2];
      
      float curlen = dist(0,0,0,dx,dy,dz);

      float lx = (curlen != 0) ? dx/curlen*len : 0;
      float ly = (curlen != 0) ? dy/curlen*len : 0;
      float lz = (curlen != 0) ? dz/curlen*len : 0;

      // update velocity with p and d
      float ax = (dx - lx)*kd; 
      float ay = (dy - ly)*kd; 
      float az = (dz - lz)*kd; 
      
      //print(ax + " " + ay + ", " + dz + " " + lz +"\n");
      
      sp[i1][j1][3] -= (ax - sp[i1][j1][3]*kv);
      sp[i1][j1][4] -= (ay - sp[i1][j1][4]*kv);
      sp[i1][j1][5] -= (az - sp[i1][j1][5]*kv);
      
      sp[i2][j2][3] += (ax - sp[i2][j2][3]*kv);
      sp[i2][j2][4] += (ay - sp[i2][j2][4]*kv);
      sp[i2][j2][5] += (az - sp[i2][j2][5]*kv);
         
  }
  
  void updatePos() {
    
  }
  
  
}

Spring allSprings[] = new Spring[0];

void updateSprings() {
  
   for (int i =0; i < allSprings.length; i++) {
      allSprings[i].updateVel();
   } 
   
}

  void updatePos() {
      
    for (int i = 0; i < SZX; i++) {
    for (int j = 0; j < SZY; j++) {
      sp[i][j][3] *= 0.99;
      sp[i][j][4] *= 0.99;
      sp[i][j][5] *= 0.99;
      
      sp[i][j][0] += sp[i][j][3];
      sp[i][j][1] += sp[i][j][4];
      sp[i][j][2] += sp[i][j][5];
      
    }}

    
  }
  
  
  /////////////////////////////

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
       
      sp[i][j][0] = 0;//f[i][j][0];
      sp[i][j][1] = 0; //f[i][j][1];
      sp[i][j][2] = f[i][j][2];
     
      sp[i+SZX][j][0] = f[i][j][0];
      sp[i+SZX][j][1] = f[i][j][1];
      sp[i+SZX][j][2] = f[i][j][2];
    }
  }
  
  
  print ("assign z-depth points " + counter + "\n");
  
  /// go through again to assign data to bins
  for (int i = 0; i < raw.length; i++) {
    /// get rid of the /2 *2 to get rid of the doubling up effect
    int x_ind = 0; 
    int y_ind = 0;
   
    if (doublePoints) {
      y_ind = int((p1[i][1]-miny)/(maxy-miny)*(SZY/2))*2;
      x_ind = int((p1[i][0]-minx)/(maxx-minx)*(SZX/2))*2;
    
    } else {
      y_ind = int((p1[i][1]-miny)/(maxy-miny)*(SZY));
      x_ind = int((p1[i][0]-minx)/(maxx-minx)*(SZX));
    }
    
    if ((x_ind >= 0) && (x_ind < SZX) && (y_ind >= 0) && (y_ind < SZY)) {
      if ((p1[i][2] +150 >0) && ((i == 0) || (abs(p1[i][2]-p1[i-1][2]) < 5) )) {
        f[x_ind][y_ind][2] = p1[i][2]+150;
        sp[x_ind+SZX][y_ind][2] =  p1[i][2]+150;
      }
        
      f[x_ind][y_ind][3] = p1[i][3];
      
      
    }
    
      
      
  }
  
  
  if (doublePoints) {
  
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
  
  print ("starting spring creation " + counter + "\n");

   for (int i = 0; i < SZX-1; i++) {
    for (int j = 0; j < SZY-1; j++) {
        
        ///distances to adjacent points
        float l1 = dist(f[i][j][0], f[i][j][1], f[i][j][2], f[i+1][j+1][0], f[i+1][j+1][1], f[i+1][j+1][2]);
        float l2 = dist(f[i][j][0], f[i][j][1], f[i][j][2], f[i+1][j][0],   f[i+1][j][1],   f[i+1][j][2]);
        float l3 = dist(f[i][j][0], f[i][j][1], f[i][j][2], f[i][j+1][0],   f[i][j+1][1],   f[i][j+1][2]);
        
        
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+1, j+1, l1, 5e-3, 5e-4 ));
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+1, j,   l2, 5e-3, 5e-4 ));
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i,   j+1, l3, 5e-3, 5e-4 ));
        
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+SZX,   j, 0 , 1e-4, 5e-5));
      }}

  print ("update finished " + counter + "\n");
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
    float n1[] = getNormal(i,j);
    float n2[] = getNormal(i,j+1);
    float n3[] = getNormal(i+1,j);
    float n4[] = getNormal(i+1,j+1);
   
    normal( n1[0], n1[1], n1[2]);
    vertex( sp[i][j][0],     sp[i][j][1],    sp[i][j][2]); 
    normal( n2[0], n2[1], n2[2]);
    vertex( sp[i][j+1][0],   sp[i][j+1][1],  sp[i][j+1][2]);
    normal( n3[0], n3[1], n3[2]);
    vertex( sp[i+1][j][0],   sp[i+1][j][1],  sp[i+1][j][2]);
    normal( n4[0], n4[1], n4[2]);
    vertex( sp[i+1][j+1][0], sp[i+1][j+1][1],sp[i+1][j+1][2]);
    //endShape();
    }
     endShape(); 
  }
  
  //update(counter++);
  
  updateSprings();
  
  updatePos();
    
    
  // This would be a way to save out frame *remember you're saving files to your harddrive*
  // saveFrame("renderedFrames/"+frameCounter+".tga");
  
  popMatrix();
}



float[] getNormal(int i, int j) {
  
  float r[] = new float[3];
  r[0] = 1.0;
  
  float cp[][] = new float[0][3];

  if ((j <= 0) || (i <= 0) || (j >= SZY-1) || (i >= SZX-1)) return r;
  

/*
    vertex( sp[i][j][0],     sp[i][j][1],    sp[i][j][2]); 
    vertex( sp[i][j+1][0],   sp[i][j+1][1],  sp[i][j+1][2]);
    vertex( sp[i+1][j][0],   sp[i+1][j][1],  sp[i+1][j][2]);
    vertex( sp[i+1][j+1][0], sp[i+1][j+1][1],sp[i+1][j+1][2]);
*/
  
   cp = (float[][])append(cp, crossProduct(i,j, i-1,j-1, i,j-1) );
   cp = (float[][])append(cp, crossProduct(i,j, i-1,j, i-1,j-1) );
   cp = (float[][])append(cp, crossProduct(i,j, i,j+1, i-1,j) );
   cp = (float[][])append(cp, crossProduct(i,j, i+1,j+1, i,j+1) );
   cp = (float[][])append(cp, crossProduct(i,j, i+1,j, i+1,j+1) );
   cp = (float[][])append(cp, crossProduct(i,j, i,j-1, i+1,j) );
    
    //print(i + " " + j + "\n");
    /// sum all normal vectors
  for (int ind = 0; ind < cp.length; ind++) {
    r[0] += cp[ind][0];    
    r[1] += cp[ind][1];
    r[2] += cp[ind][2];
  }
  
  /// normalize
  
  r = normalize(r);

  return r;
  
}

float [] normalize(float r[]) {

  float l = dist(0,0,0,r[0],r[1],r[2]);
  
  if (l == 0) return r;
  
  r[0] /= l;
  r[1] /= l;
  r[2] /= l;
  
  return r;
 }
