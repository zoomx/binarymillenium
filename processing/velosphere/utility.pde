
/// (c) 2008 binarymillenium
/// GNU GPL

 
import processing.opengl.*;

///

class CloudConverter {

  String base;

  int index = 0;

  CloudConverter(String base) {
    this.base = base;
    
  }
  
 PImage  fillGaps(PImage tx, int numiterations) {
    PImage rx;
    try{ 
    rx = (PImage) tx.clone();
    } catch (Exception e ) {
        return tx;
    }
    
    int unfillednum =1;
    for (int k = 0; (k < numiterations) &&(unfillednum > 0); k++) {
      unfillednum =0;
      
    /// ignore edges for now
   for (int i = 1; i <tx.width-1; i++) {
    for (int j = 1; j <tx.height-1; j++) {
      
       //int p = i*tx.height + j;
       int p = j*tx.width + i;
       boolean a  = alpha(tx.pixels[p]) > 0;
       
       if (!a) {
         
         /*
       int pl = i*tx.height + j-1;
       int pr = i*tx.height + j+1;
       int pu = (i-1)*tx.height + j;
       int pd = (i+1)*tx.height + j;
       */
       int pl = j*tx.width + i-1;
       int pr = j*tx.width + i+1;
       int pu = (j-1)*tx.width + i;
       int pd = (j+1)*tx.width + i;
       
       float rvl = red(tx.pixels[pl]);
       float rvr = red(tx.pixels[pr]);
       float rvu = red(tx.pixels[pu]);
       float rvd = red(tx.pixels[pd]);
       
       float gvl = green(tx.pixels[pl]);
       float gvr = green(tx.pixels[pr]);
       float gvu = green(tx.pixels[pu]);
       float gvd = green(tx.pixels[pd]);
       
       float bvl = blue(tx.pixels[pl]);
       float bvr = blue(tx.pixels[pr]);
       float bvu = blue(tx.pixels[pu]);
       float bvd = blue(tx.pixels[pd]);
          
       boolean al = alpha(tx.pixels[pl]) > 0;
       boolean ar = alpha(tx.pixels[pr]) > 0;
       boolean au = alpha(tx.pixels[pu]) > 0;
       boolean ad = alpha(tx.pixels[pd]) > 0;
       
       float rsum = 0;
       float gsum = 0;
       float bsum = 0;
       
       int sumnum = 0;
       if (al) { 
         rsum += rvl; 
         gsum += gvl;
         bsum += bvl;
         sumnum++; 
       }
       if (ar) {  
         rsum += rvr; 
         gsum += gvr;
         bsum += bvr;
         sumnum++; 
       }
       if (au) { 
         rsum += rvu; 
         gsum += gvu;
         bsum += bvu;
         sumnum++; 
       }
       if (ad) { 

         rsum += rvd; 
         gsum += gvd;
         bsum += bvd;
         sumnum++;  
       }

        if (sumnum > 0) {
            float rval = rsum/(float)sumnum;
            float gval = gsum/(float)sumnum;
            float bval = bsum/(float)sumnum;
            
           rx.pixels[p] = color(rval,gval,bval, 255);      
        } else {
         unfillednum++; 
        }
//rx.pixels[p] = color(255,0,0,255);
       } 
    }
   } 
   
   println(unfillednum + " unfilled");
      try{ 
    tx = (PImage) rx.clone();
    } catch (Exception e ) {
        return rx;
    }
    
   
    }
   return rx;
    
  }


  float finc = 0;

  void processStrings(String[] raw) {
  
    finc += 0.01;
    
    PImage tx = new PImage();
    
    tx.width = 1280;
    tx.height = 64;
    tx.pixels = new color[tx.width*tx.height];

    int offset = (int)( tx.width/2 + (tx.width-1)*(noise(finc)-0.5));
    
    println("index: " + index + ", " + offset);
    
    /// preprocess to find out the extent of the data
    for (int i = 0; i < raw.length; i++) {


      
      String[] ln = split(raw[i],',');
      for (int j = 0; j < ln.length; j++) {
     
        float z = float(ln[j]);
        
        
        //print( j + ", " + z + "\n");
      
        if ((j < tx.height) && (i < tx.width) ) {
          int pixind = tx.width*(63-j);
          pixind += (i + offset)%tx.width;
           
          //print( j + ", " + z + "\n");
          
          float minval = 100.0;
          float maxval = 30000.0;
          if (z > minval) {
            
            if (z > maxval) z = maxval;
            if (z < minval) z = minval;
                
            float powval = 0.8;
            float val = (pow(z,powval)-pow(minval,powval))/pow(maxval,powval);  
            
        
            /*
            int val;
             val = int( (log(z)-log(200))/(log(16000.0)-log(200))*255.0);
             //val = int( (z/20000.0)*255.0);
            if (val > 255) val = 255;
            if (val < 0) val = 0;
            */
            tx.pixels[pixind] = makecolor(1.0-val);
            //color(255 - val,255);
          } else {
           tx.pixels[pixind] = color(0,0,0,0);
          } 
        }

    }
    }


   tx = fillGaps(tx,2);
   tx.updatePixels();
    
    
    
     println("index: " + index);
     
     String fullname = base + "hgt_" + outbase + (index+10000) + ".png";
    tx.save(fullname);
    index++;
  
    
  }

}


/// the spring points, also stores the target points (which aren't updated)
float[][][] sp; // = new float[SZX*2][SZY][6];


/// these all assume input float arrays of size 3 
float[] minus(float a[], float b[]) {
  float r[] = new float[3];

  r[0] = a[0] - b[0];
  r[1] = a[1] - b[1];
  r[2] = a[2] - b[2];

  return r;
}

/*
float[] crossProduct(int i, int j, int i1, int j1, int i2, int j2) {
 
 float a[] = minus(sp[i1][j1], sp[i][j]);
 float b[] = minus(sp[i2][j2], sp[i][j]);
 
 return crossProduct(a,b);
 
 }
 */

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

float [] normalize(float r[]) {

  float l = dist(0,0,0,r[0],r[1],r[2]);

  if (l == 0) return r;

  r[0] /= l;
  r[1] /= l;
  r[2] /= l;

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


///////////////////////////////
//// more app specific



Spring allSprings[] = new Spring[0];

void updateSprings() {

  for (int i =0; i < allSprings.length; i++) {
    allSprings[i].updateVel();
  } 

}

void updatePos(int SZX, int SZY) {

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

