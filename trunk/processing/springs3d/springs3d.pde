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
    
    //v.z = 0;
    
    p.add(v);
    
    if (p.y > height) {
     p.y = height;
     v.y = -v.y*0.8;
    }
    
    
    
    v.mult(0.995);
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
  float K; // spring constant
  float C; // damping constant
  
  float x_old; // old length
 
  Spring(Particle new_v1, Particle new_v2, float new_K)
  {
    v1 = new_v1;
    v2 = new_v2;
    K = new_K;
    
    C = 0.010;
     
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
    v1.addForce(diff);
    
    PVector diffC = PVector.sub(v2.p, v1.p);
    diffC.normalize();
    diffC.mult((x_old - x)*C);
    x_old = x;
    v1.addForce(diffC);
    
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
  
  final float Kf = 0.06;
  
  final int NM = 5;
  //final int TNM = NM*NM;
  for (int k = 0; k < 3; k++) {
  for (int i = 0; i < NM; i++) {
     for (int j = 0; j < NM; j++) {
       
       final int ind = k*NM*NM + i*NM + j;
       
    Particle p = new Particle(new PVector(width/2.0 + 10.0*i, 20.0 + 10.0*j, 0.0));
    masses.add(p);
    
    if (j > 0) {
      Spring s = new Spring((Particle)masses.get(ind - 1), p, Kf);
      springs.add(s); 
    }
    
    if (i > 0) {
      Spring s = new Spring((Particle)masses.get(ind - NM), p, Kf);
      springs.add(s); 
    }
    
    // diagonal 1
    if ((i > 0) && (j > 0)) {
      Spring s = new Spring((Particle)masses.get(ind - NM - 1), p, Kf);
      springs.add(s); 
    }
    
    // diagonal 2
    if ((i > 0) && (j > 0)) {
      Spring s = new Spring(
        (Particle)masses.get(ind - NM), 
        (Particle)masses.get(ind - 1), 
        Kf);
      springs.add(s); 
    }
    
    if (k > 0) {
      // straight across
      {
      Spring s = new Spring((Particle)masses.get(ind - NM*NM), p, Kf);
      springs.add(s); 
      }
      
      // column diagonals
      if (j > 0) {
        Spring s = new Spring((Particle)masses.get(ind - NM*NM - 1), p, Kf);
        springs.add(s); 
      }
      if (j < NM-1) {
        Spring s = new Spring((Particle)masses.get(ind - NM*NM + 1), p, Kf);
        springs.add(s); 
      }
      
      // row diagonals
      if (i > 0) {
        Spring s = new Spring((Particle)masses.get(ind - NM - NM*NM), p, Kf);
        springs.add(s); 
      }
      if (i < NM-1) {
        Spring s = new Spring((Particle)masses.get(ind + NM - NM*NM), p, Kf);
        springs.add(s); 
      }
      
      // diagonal diagonal
      if ((i > 0) && (j > 0)) {
        Spring s = new Spring((Particle)masses.get(ind - NM - NM*NM- 1), p, Kf);
        springs.add(s); 
      }
      
      if ((i  < NM-1) && (j  < NM-1)) {
        Spring s = new Spring((Particle)masses.get(ind + NM - NM*NM + 1), p, Kf);
        springs.add(s); 
      }
      // TBD two more possible here
    }
  }}
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
  
  PVector gravity = new PVector(0.0, 0.04, 0.0);
  
  for (int i = 0; i < masses.size(); i++) {
    Particle pr = (Particle) masses.get(i);
    pr.update(gravity); 
    
    pr.draw();
  }
  
   for (int i = 0; i < springs.size(); i++) {
    Spring sp = (Spring) springs.get(i);
    sp.draw(); 
  }
  
  

}
