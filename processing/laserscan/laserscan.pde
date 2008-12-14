
PImage base, depth, viz;
 
int index = 1;

ArrayList depthxy;

void setup() {
  
  depthxy = new ArrayList();
  
   base = loadImage("fullsize/base/base" + (index+1000) + ".jpg"); 
   viz = createImage(base.width, base.height,RGB);
   size(base.width, base.height);
}

void draw() {
  background(0);
  
   base  = loadImage("fullsize/base/base" + (index+1000) + ".jpg"); 
   depth = loadImage("fullsize/misc/misc" + (index+1000) + ".jpg");

viz.loadPixels();
  int bcount = 0;
  int dcount = 0;
  
  int xmin = width;
  int xmax = 0;
  int ymin = height;
  int ymax = 0;
  
   for (int i = 0; i < base.height; i++) {
   for (int j = 0; j < base.width; j++) {
     
      int pixind = i*base.width+j;
      
      color col = base.pixels[pixind];
      if ((green(col) > 200) &&
          (blue(col) < 210) && 
          (red(col) < 170)
          )    {
        viz.pixels[pixind] = color(0,0,255);
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
      
      col = depth.pixels[pixind]; 
      if ((green(col) > 200) &&
          (blue(col) < 210) && 
          (red(col) < 170)
          )    {
        viz.pixels[pixind] = color(0,255,0);
        
        depthxy.add(new Vector2f((float)j,(float)i));
        
        dcount++;
      } 
     
   }}
   

   viz.updatePixels();
   
   
   println(index + " " + bcount + " " + dcount);
   
    //index = index%6+1;
    index = index+1;
    if (index >8) noLoop();
  
   image(viz,0,0); 
   
   stroke(255);
   line(xmin,ymin,xmax,ymax);
   
   /// guess at projection of normal line from surface
   float normx = -20;
   float normy = -1;
   
   for (int i = 0; i < depthxy.size(); i++) {
      Vector2f xy = (Vector2f) depthxy.get(i);
      float x = xy.x;
      float y = xy.y;
  
      
      Vector2f intersectpoint = segIntersection(xmin,ymin,xmax,ymax,  x, y, x+normx*100, y+normy*100);
      
      if ((intersectpoint != null) && (dist(x,y,intersectpoint.x,intersectpoint.y) > 20.0)) {
        stroke(255,50,20);
        line(x,y,intersectpoint.x,intersectpoint.y);
      }
   }
}

class Vector2f
{
 float x;
float y;

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
