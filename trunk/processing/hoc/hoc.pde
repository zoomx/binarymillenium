/**
*
(c) binarymillenium 2008
Licensed under the GNU GPL latest version
*/

import processing.opengl.*;

boolean useSprings = false;
boolean drawScreen = false;
boolean clearOld = true;

PImage tx, tx2,tx3,tx4;

int counter =1;

final int SZX = 120;
final int SZY = 120;

///

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

//////////////////////////////////////////////////////

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
      
      
      sp[i1][j1][3] -= (ax - sp[i1][j1][3]*kv);
      sp[i1][j1][4] -= (ay - sp[i1][j1][4]*kv);
      sp[i1][j1][5] -= (az - sp[i1][j1][5]*kv);
      
      sp[i2][j2][3] += (ax - sp[i2][j2][3]*kv);
      sp[i2][j2][4] += (ay - sp[i2][j2][4]*kv);
      sp[i2][j2][5] += (az - sp[i2][j2][5]*kv);
         
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
      
      float r = 0.5;
      
      sp[i][j][3] *= r;
      sp[i][j][4] *= r;
      sp[i][j][5] *= r;
      
      float magn = dist(0,0,0, sp[i][j][3], sp[i][j][4], sp[i][j][5]);
      
      if (magn > 0.8) {
        sp[i][j][3] *= 0.8;
        sp[i][j][4] *= 0.8;
        sp[i][j][5] *= 0.8;
      }
      
      sp[i][j][0] += sp[i][j][3];
      sp[i][j][1] += sp[i][j][4];
      sp[i][j][2] += sp[i][j][5];
      
    }}
    
  }
  
///////////////////////////////////////////////////////

void setup(){
  
  size(640,480, OPENGL);
 
  strokeWeight(1);
  
  tx = new PImage();
  tx.width = SZX;
  tx.height = SZY;
  tx.pixels = new color[tx.width*tx.height];
  
  /// this texture will be written out with the height and intensity data
  tx2 = new PImage();
  tx2.width = SZX;
  tx2.height = SZY;
  tx2.pixels = new color[tx.width*tx.height];
  
    /// this texture will be written out with the height and intensity data
  tx3 = new PImage();
  tx3.width = SZX;
  tx3.height = SZY;
  tx3.pixels = new color[tx.width*tx.height];
  
    /// this texture will be written out with the height and intensity data
  tx4 = new PImage();
  tx4.width = SZX;
  tx4.height = SZY;
  tx4.pixels = new color[tx.width*tx.height];
  
  update(counter);
  
}

void update(int counter) {
  
  print(counter + " " + mx + " " + my+ " \n");
  
  
  String[] raw = loadStrings(counter+".csv");
  
  float p1[][] = new float[raw.length][4];
  
  
  float minx = -30; //-70;
  float maxx = 205; //230;
  
  float miny = -50;//-110;
  float maxy = 300; //300;

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
}*/

    
  }
  
  
  if (counter == 1) {
  print(minx + ", " + maxx + ", " + miny + " " + maxy + ", " + minz + " " + maxz + "\n");
  }
  
  /// maxi is 255
  //print(mini + " " + maxi + "\n");
  
  if (clearOld) {
     tx.pixels  = new color[tx.width*tx.height];
     tx2.pixels = new color[tx.width*tx.height];
     tx3.pixels = new color[tx.width*tx.height];
     tx4.pixels = new color[tx.width*tx.height];
  }
 
  
  if (counter == 1) {
  for (int i = 0; i < SZX; i++) {
    for (int j = 0; j < SZY; j++) {
     
      sp[i+SZX][j][0] = (float)i/(float)SZX * (maxx-minx) + minx - (maxx-minx)/2;
      sp[i+SZX][j][1] = (float)j/(float)SZY * (maxy-miny) + miny - (maxy-miny)/2;
      sp[i+SZX][j][2] = 0;
      
      sp[i][j][0] = sp[i+SZX][j][0];
      sp[i][j][1] = random(1.0);//sp[i+SZX][j][1];
      sp[i][j][2] = 0;
      
     
      
     
    }
  }
  }
  
  //print ("assign z-depth points " + counter + "\n");
  
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
      
      float  z = p1[i][2]+150;
      if (z < 0) z = 0;
      if (z > 140) z = 140;
      
      if ((i>0) && (abs(p1[i][2]- p1[i-1][2]) < 4)) {
        sp[x_ind+SZX][y_ind][2] = z;
  
      //sp[x_ind][y_ind][2] = p1[i][2]+150;
      } 

      float intensity = p1[i][3]/2;
      
      int pix_ind = y_ind*SZX + x_ind;
      tx.pixels[pix_ind] =  color(  brightness(tx.pixels[pix_ind])/2 + intensity/2 );      
       
      int c = int(z/140.0*255.0*255.0);
      
      /// saves all the data with 16-bit precision, but doesn't look like much
      tx2.pixels[pix_ind] = color(c/255,c%255,intensity);
      tx3.pixels[pix_ind] = color(intensity,intensity, intensity,(c>0) ? 255 : 0);
      tx4.pixels[pix_ind] = color(c/255,c/255,c/255, (c>0) ? 255 : 0);
      
    }     
  }
  
  tx.updatePixels();
  tx2.updatePixels();
  tx3.updatePixels();
  tx4.updatePixels();
  
   tx2.save("/home/lucasw/own/prog/google/trunk/processing/hoc/all/prepross_all_" + (counter+10000) + ".png");
   tx3.save("/home/lucasw/own/prog/google/trunk/processing/hoc/int/prepross_intensity_" + (counter+10000) + ".png");
   tx4.save("/home/lucasw/own/prog/google/trunk/processing/hoc/hgt/prepross_height_" + (counter+10000) + ".png");
  
  
  /*
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
  
}*/
  
  

  //print ("starting spring creation " + counter + "\n");

if (useSprings) {
   int ind = 0;
   for (int i = 0; i < SZX-1; i++) {
    for (int j = 0; j < SZY-1; j++) {
        
        ///distances to adjacent points
        float l1 = dist(sp[SZX+i][j][0],     sp[SZX+i][j][1],     sp[SZX+i][j][2], 
                        sp[SZX+i+1][j+1][0], sp[SZX+i+1][j+1][1], sp[SZX+i+1][j+1][2]);
        float l2 = dist(sp[SZX+i][j][0],     sp[SZX+i][j][1],     sp[SZX+i][j][2], 
                        sp[SZX+i+1][j][0],   sp[SZX+i+1][j][1],   sp[SZX+i+1][j][2]);
        float l3 = dist(sp[SZX+i][j][0],     sp[SZX+i][j][1],     sp[SZX+i][j][2], 
                        sp[SZX+i][j+1][0],   sp[SZX+i][j+1][1],   sp[SZX+i][j+1][2]);
        
        if (counter == 1) {
          float kd = 1e-1;
          float kv = 1e-2;
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+1, j+1, l1, kd, kv ));
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+1, j,   l2, kd, kv ));
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i,   j+1, l3, kd, kv ));
        
        allSprings = (Spring[]) append(allSprings, new Spring(i, j, i+SZX,   j, 0 , kd/3.0, kv/3.0));
        } else {
          allSprings[ind].len = l1;
          ind +=1;
          allSprings[ind].len = l2;
          ind +=1;
          allSprings[ind].len = l3;
          ind +=2; /// add extra one for skipped over target point
        }
      }}
    
}
  
  //print ("update finished " + counter + "\n");
}
  

  
float oldmx = 0;
float oldmy = 0;

/// straight on
//float my = 316;
//float mx = 286;

float my = 240;
float mx = 151;

void draw() {

  background(0);
  
  
 if (drawScreen) {
  pushMatrix();
  
  if (mousePressed) {
 
    
    mx += (mouseX -oldmx)/3;
    my += (mouseY- oldmy)/3;  
    
  } 
  
  oldmx = mouseX;
  oldmy = mouseY;
  
 
  translate(width/2, height/2); 
  translate(80,40,450-my/1.0);

  float div = 100;
  
  /// autorotate
  mx += div*(PI/2.0)/2000.0; 
  
  rotateY(-(width/div)/2 + mx/div);
 
  pointLight(255, 255, 255, 20, 10, 250);
 //lights();
 
     noStroke();
    //stroke(255);
    
   
    
 textureMode(NORMALIZED);
 
 /*
 beginShape();
texture(tx);
vertex(0, 0, 0, 0);
vertex(width, 0, 1.0, 0);
vertex(width, height, 1.0, 1.0);
vertex(0, height, 0, 1.0);
endShape();
*/


    for (int i = 0; i < SZX-1; i++) {
      beginShape(TRIANGLE_STRIP);
      texture(tx);
    for (int j = 0; j < SZY-1; j++) {
      
      fill(250);
      //fill(f[i][j]);
    //front face
   // beginShape(TRIANGLES);
   
   boolean useNormal = true;
     
    float n1[] = new float[3];
    float n2[]= new float[3];
    float n3[]= new float[3];
    float n4[]= new float[3];
    
     if (useNormal) {
      n1 = getNormal(i,j);
      n2 = getNormal(i,j+1);
      n3 = getNormal(i+1,j);
      n4 = getNormal(i+1,j+1);
     }
     
    float u = (float)i/(float)SZX;
    float v = (float)j/(float)SZY;
    float du = 1.0/(float)SZX;
    float dv = 1.0/(float)SZY;
   
    if (useNormal) normal( n1[0], n1[1], n1[2]);
    vertex( sp[i][j][0],     sp[i][j][1],    sp[i][j][2],   u, v); 
    if (useNormal) normal( n2[0], n2[1], n2[2]);
    vertex( sp[i][j+1][0],   sp[i][j+1][1],  sp[i][j+1][2], u, v+dv);
    if (useNormal) normal( n3[0], n3[1], n3[2]);
    vertex( sp[i+1][j][0],   sp[i+1][j][1],  sp[i+1][j][2], u+du, v);
    if (useNormal) normal( n4[0], n4[1], n4[2]);
    vertex( sp[i+1][j+1][0], sp[i+1][j+1][1],sp[i+1][j+1][2], u+du, v+dv);
    //endShape();
    
    }
     endShape(); 
  }
 
    
  popMatrix();
 }
  
  counter = counter+1;
  update(counter);
  
  
  
  if (useSprings) {
    updateSprings();
    updatePos();
  }
    
    
 // saveFrame("frames/hoc_######.jpg");

}


//////////////////////////////////////////////////////////////


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
