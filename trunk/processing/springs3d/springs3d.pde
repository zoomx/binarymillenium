/*

Lucas Walter
July 2012
GPL 3.0

*/

class Particle
{
  PVector p;
  PVector v;
  PVector a;
  
  Particle(PVector new_p)
  {
    p = new_p;
  }
  
  void update(PVector new_a)
  {
    v.add(new_a);
    p.add(v);
    
    a.mult(0);
  }
  
  void draw()
  {
    fill(0,255,0);
    point(p.x,p.y);
    
  }
  
}
class Spring 
{
   
  PVector v1, v2;
  
  // spring velocities
  PVector v1_v, v2_v;
  
  float rest;
  float K;
 
  Spring(PVector new_v1, PVector new_v2, float new_K)
  {
    v1 = new_v1;
    v2 = new_v2;
    K = new_K;
     
    rest = v1.dist(v2);
    
    v1_v = new PVector(0,0,0);
    v2_v = new PVector(0,0,0);
     
  } 
  
  void update()
  {
    float dis = v1.dist(v2);
    
    float x = rest - dis;
    
    // spring accelerations 
    // init with gravity
    PVector v1_a = new PVector(0,0,0);
    PVector v2_a = new PVector(0,0.1,0);
    
    float acc = -K * x;
    
    PVector diff = PVector.sub(v2, v1);
    diff.normalize();
    diff.mult(acc);
    
    //v1_a.add(diff);
    v2_a.sub(diff);
    
    // v1 is fixed
    //v1_v.add(v1_a);
    v2_v.add(v2_a);
    
    // TBD a simple particle class could handle this
    v1.add(v1_v);
    v2.add(v2_v);
  }
  
  void draw()
  {
    stroke(255);
    line(v1.x, v1.y, v2.x, v2.y);
  }
}

Spring s1;

void setup() 
{
  size(400,400);  
  
  s1 = new Spring(new PVector(width/2.0,10.0,0.0), new PVector(width/2 + 10.0,10.0,0.0), 0.01);
  
}

void draw()
{
  background(0);
  s1.update();
  s1.draw();
}
