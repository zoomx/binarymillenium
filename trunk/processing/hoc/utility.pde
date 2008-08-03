
/// (c) 2008 binarymillenium
/// GNU GPL


import processing.opengl.*;

///

/// the spring points, also stores the target points (which aren't updated)
float[][][] sp = new float[SZX*2][SZY][6];


/// these all assume input float arrays of size 3 
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


////


float minx = -30; //-70;
float maxx = 205; //230;

float miny = -50;//-110;
float maxy = 300; //300;

float minz = -1100;
float maxz = 360;

float mini = 100;
float maxi = 0;



/// input a array of strings that are in point cloud form and convert to textures  
PImage[] cloudToBin(String[] raw , int SZX, int SZY)
{
  PImage tx[] = new PImage[4];

  float p1[][] = new float[raw.length][4];

  for (int i = 0; i < tx.length; i++) {   
    tx[i] = new PImage();
    tx[i].width = SZX;
    tx[i].height = SZY;
    tx[i].pixels = new color[tx[i].width*tx[i].height]; 
  }

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

  /// go through again to assign data to bins
  for (int i = 0; i < raw.length; i++) {
    /// get rid of the /2 *2 to get rid of the doubling up effect
    int x_ind = 0; 
    int y_ind = 0;

    if (doublePoints) {
      y_ind = int((p1[i][1]-miny)/(maxy-miny)*(SZY/2))*2;
      x_ind = int((p1[i][0]-minx)/(maxx-minx)*(SZX/2))*2;

    } 
    else {
      y_ind = int((p1[i][1]-miny)/(maxy-miny)*(SZY));
      x_ind = int((p1[i][0]-minx)/(maxx-minx)*(SZX));
    }

    if ((x_ind >= 0) && (x_ind < SZX) && (y_ind >= 0) && (y_ind < SZY)) {

      float  z = p1[i][2]+150;
      if (z < 0) z = 0;
      if (z > 140) z = 140;

      /// TBD don't use sp now
      if ((i>0) && (abs(p1[i][2]- p1[i-1][2]) < 4)) {
        sp[x_ind+SZX][y_ind][2] = z;
      } 

      float intensity = p1[i][3]/2;

      int pix_ind = y_ind*SZX + x_ind;
      tx[0].pixels[pix_ind] =  color(  brightness(tx[0].pixels[pix_ind])/2 + intensity/2 );      

      int c = int(z/140.0*255.0*255.0);

      /// saves all the data with 16-bit precision, but doesn't look like much
      tx[1].pixels[pix_ind] = color(c/255,c%255,intensity);
      tx[2].pixels[pix_ind] = color(intensity,intensity, intensity,(c>0) ? 255 : 0);
      tx[3].pixels[pix_ind] = color(c/255,c/255,c/255, (c>0) ? 255 : 0);

    }     
  }

  for (int i =0; i < tx.length; i++ ){
    tx[i].updatePixels();
  }


  String base = "/home/lucasw/own/prog/google/trunk/processing/hoc/";
  //tx[1].save("/home/lucasw/own/prog/google/trunk/processing/hoc/all/prepross_all_" + (counter+10000) + ".png");
  tx[2].save(base + "int/prepross_intensity_" + (counter+10000) + ".png");
  tx[3].save(base + "hoc/hgt/prepross_height_" + (counter+10000) + ".png");


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

  return tx;

}

///////////////////////////////
//// more app specific



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

    }
  }

}

