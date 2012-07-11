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
    p = new PVector(new_p.x, new_p.y, new_p.z);
    v = new PVector();
    a = new PVector();
    
  }
  
  void addForce(PVector new_f)
  {
    // TBD add mass later
    a.add(new_f);
  }
  
  void update(PVector new_a) // = new PVector(0,-0.1,0))
  {
    a.add(new_a);
    v.add(a);
    p.add(v);
    
    a.mult(0);
  }
  
  void draw()
  {
    fill(0,255,0);
    point(p.x,p.y);
    
  }
  
  float dist(Particle p2)
  {
    return p.dist(p2.p);
  }
  
  /*
  static PVector sub(Particle p1, Particle p2)
  {
    return PVector.sub(p1,p2); 
  }
  */  
}

class Spring 
{
   
  Particle v1, v2;
  
  float rest;
  float K;
 
  Spring(Particle new_v1, Particle new_v2, float new_K)
  {
    v1 = new_v1;
    v2 = new_v2;
    K = new_K;
     
    rest = v1.dist(v2);
  } 
  
  void update()
  {
    float dis = v1.dist(v2);
    
    float x = rest - dis; 
    float acc = -K * x;
    
    PVector diff = PVector.sub(v2.p, v1.p);
    diff.normalize();
    diff.mult(acc);
    
    //v1_a.add(diff);
    v1.addForce(diff);
    
    diff.mult(-1.0);
    v2.addForce(diff);
    
  }
  
  void draw()
  {
    stroke(255);
    line(v1.p.x, v1.p.y, v2.p.x, v2.p.y);
  }
}

ArrayList springs;
ArrayList masses;

void setup() 
{
  size(400,400);  
  
  springs = new ArrayList();
  masses = new ArrayList();
  
  for (int i = 0; i < 10; i++) {
    Particle p = new Particle(new PVector(width/2.0 + 10.0*i, 20.0,0.0));
    masses.add(p);
    
    if (i > 0) {
      Spring s = new Spring((Particle)masses.get(i-1),p, 0.05);
      springs.add(s); 
    }
  }
  
  
}

void draw()
{
  background(0);
  
  for (int i = 0; i < springs.size(); i++) {
    Spring sp = (Spring) springs.get(i);
   // println(i);
    sp.update(); 
  }
  
  PVector gravity = new PVector(0.0, 0.1, 0.0);
  
  for (int i = 1; i < masses.size(); i++) {
    Particle pr = (Particle) masses.get(i);
    pr.update(gravity); 
    
    pr.draw();
  }
  
   for (int i = 0; i < springs.size(); i++) {
    Spring sp = (Spring) springs.get(i);
    sp.draw(); 
  }
  
  

}
