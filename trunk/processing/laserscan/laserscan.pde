 
int index = 1;


ArrayList allDepths;  /// array of depthxy arrays
ArrayList baseLines;

void setup() {
  
   frameRate(2);
  
   
  baseLines = new ArrayList();
  allDepths = new ArrayList();



  for (index = 0; index <=9; index++) { 
     PImage bi  = loadImage("fullsize/base/base" + (index+1000) + ".jpg"); 
     PImage di = loadImage("fullsize/misc/misc" + (index+1000) + ".jpg");
     findLaser(bi, di);
  }
   
  index = 0;
    PImage base  = loadImage("fullsize/base/base" + (index+1000) + ".jpg"); 
  size(base.width, base.height);
}

void keyPressed() {
  if (key == 'd') {
   //index = index%6+1;
    index = index+1;
    if (index >8) index = 0;
  }
  if (key == 'a') {
   //index = index%6+1;
    index = index-1;
    if (index < 0) index = 8;
  }
}

boolean findVector(Vector2f vec, ArrayList depths) {
 
  for (int i = 0; i < depths.size(); i++) {
     Vector2f dvec = (Vector2f) depths.get(i);
     if ((vec.x == dvec.x) && (vec.y == dvec.y)) {
       return true; 
     }   
  }  
  return false;
} 

boolean isLaser0(PImage tex, int pixind) 
{
    color col = tex.pixels[pixind];      
  if ((green(col) > 210) && (blue(col) < 210) &&  (red(col) < 170)) return true;
 
 return false; 
}

boolean isLaser(PImage tex, int pixind) {  
  color col = tex.pixels[pixind];      
  
  if ((green(col) > 210) && (blue(col) < 210) &&  (red(col) < 170)) return true;
  
  if ((green(col) > 100) && (green(col) < 120) &&
      (blue(col) > 90)   && (blue(col) < 110) &&
      (red(col) > 65)   && (red(col) < 85))  return true;
  
  if ((green(col) > 130) && (green(col) < 150) &&
      (blue(col) > 110)   && (blue(col) < 130) &&
      (red(col) > 80)   && (red(col) < 100))  return true;
  
  if ((green(col) > 145) && (green(col) < 155) &&
      (blue(col) > 135)   && (blue(col) < 145) &&
      (red(col) > 125)   && (red(col) < 135))  return true;
      
  return false;
}
boolean isLaser2(PImage tex, int pixind) {  
  color col = tex.pixels[pixind];      
  return ((green(col) > 140) && (blue(col) < 250) &&  (red(col) < 250)) ;         
}

void checkAndAdd(ArrayList depthxy2, ArrayList depthxy, int nj, int ni, PImage di)
{
  Vector2f nvec = new Vector2f(nj,ni);
  int pixind = ni*di.width+(nj);
  if ((nj < di.width) && (ni < di.height) && (nj >= 0) && (ni >= 0) &&
      isLaser2(di,pixind) && !findVector( nvec, depthxy)) { 
    depthxy2.add(nvec);  
    //dcount++;
  } 
}


void secondarySearch(PImage di, ArrayList depthxy)
{
   ArrayList depthxy2 = new ArrayList();
   /// secondary search, look for adjacent pixels
  
   for (int k = 0; k < depthxy.size(); k++) {
      Vector2f xy = (Vector2f) depthxy.get(k);
      final int j = (int)xy.x;
      final int i = (int)xy.y;
      
      int pixind,nj,ni;
      Vector2f nvec;

      nj = j+1;
      ni = i;
      checkAndAdd(depthxy2, depthxy, nj, ni, di);
      
      nj = j-1;
      ni = i;
      checkAndAdd(depthxy2, depthxy, nj, ni, di);
      
      nj = j;
      ni = i+1;
      checkAndAdd(depthxy2, depthxy, nj, ni, di);
      
      nj = j;
      ni = i-1;
      checkAndAdd(depthxy2, depthxy, nj, ni, di);
  }
  
   println(depthxy2.size());
   
   for (int k = 0; k < depthxy2.size(); k++) {
       depthxy.add(depthxy2.get(k));
   }  
}

void findLaser(PImage bi, PImage di) {
   int bcount = 0;
   int dcount = 0;
  
   int xmin = width;
   int xmax = 0;
   int ymin = height;
   int ymax = 0;
  
   ArrayList depthxy = new ArrayList();
  
   for (int i = 0; i < bi.height; i++) {
   for (int j = 0; j < bi.width; j++)  {
     
      int pixind = i*bi.width+j;
      
      if (isLaser0(bi,pixind)) {
        bcount++;
        
        if (j < xmin) {
           xmin = j;
           ymin = i; 
        }
        if (j > xmax) {
           xmax = j;
           ymax = i; 
        }
      } 
      
      if (isLaser(di,pixind)) {
        
        depthxy.add(new Vector2f((float)j,(float)i));  
        dcount++;
      }
           
   }}
   
    println(index + " " + bcount + " " + dcount);
    
   secondarySearch(di, depthxy);
   secondarySearch(di, depthxy);
  
   baseLines.add(new Vector2f(xmin,ymin));
   baseLines.add(new Vector2f(xmax,ymax));
   
   allDepths.add(depthxy);
      
  
}

void draw() {
  background(0);
 
  PImage base  = loadImage("fullsize/base/base" + (index+1000) + ".jpg"); 
  PImage depth = loadImage("fullsize/misc/misc" + (index+1000) + ".jpg");
  
  ArrayList depthxy = (ArrayList) allDepths.get(index);
  
  Vector2f lmin = (Vector2f) baseLines.get((index)*2);
  Vector2f lmax = (Vector2f) baseLines.get((index)*2+1);  
  
  
  image(depth,0,0);
  
   stroke(255);
   line(lmin.x,lmin.y,lmax.x,lmax.y);
   
   /// guess at projection of normal line from surface
   float normx = -20;
   float normy = -1;
   
   for (int i = 0; i < depthxy.size(); i++) {
      Vector2f xy = (Vector2f) depthxy.get(i);
      float x = xy.x;
      float y = xy.y;
  
      stroke(250,0,250);
      rect(x,y,1,1);
      
      Vector2f intersectpoint = segIntersection(lmin.x,lmin.y,lmax.x,lmax.y,  x, y, x+normx*100, y+normy*100);
      
      if ((intersectpoint != null) && (dist(x,y,intersectpoint.x,intersectpoint.y) > 20.0)) {
        stroke(255,50,20);
         //line(x,y,intersectpoint.x,intersectpoint.y);
      }
   }

}

class Vector2f
{
 float x;
float y;

 Vector2f(int nx,int ny) {
    x = (float)nx;
    y = (float)ny;
  }
  
  Vector2f(float nx,float ny) {
    x = nx;
    y = ny;
  }
}

/**
detecting-line-to-line-intersection taken from http://processinghacks.com/hacks:detecting-line-to-line-intersection
@author Ryan Alexander
*/
Vector2f lineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
{
  float bx = x2 - x1;
  float by = y2 - y1;
  float dx = x4 - x3;
  float dy = y4 - y3;
 
  float b_dot_d_perp = bx*dy - by*dx;
 
  if(b_dot_d_perp == 0) return null;
 
  float cx = x3-x1;
  float cy = y3-y1;
 
  float t = (cx*dy - cy*dx) / b_dot_d_perp;
 
  return new Vector2f(x1+t*bx, y1+t*by);
}
 
// Line Segment Intersection
Vector2f segIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
{
  float bx = x2 - x1;
  float by = y2 - y1;
  float dx = x4 - x3;
  float dy = y4 - y3;
 
  float b_dot_d_perp = bx * dy - by * dx;
 
  if(b_dot_d_perp == 0) return null;
 
  float cx = x3 - x1;
  float cy = y3 - y1;
 
  float t = (cx * dy - cy * dx) / b_dot_d_perp;
  if(t < 0 || t > 1) return null;
 
  float u = (cx * by - cy * bx) / b_dot_d_perp;
  if(u < 0 || u > 1) return null;
 
  return new Vector2f(x1+t*bx, y1+t*by);
}
