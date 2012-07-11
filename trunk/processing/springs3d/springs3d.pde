/*

Lucas Walter
July 2012
GPL 3.0

*/

class Terrain
{
  float ht[];
  Terrain()
  {
    ht = new float[width];
    
    for (int i = 0; i < ht.length; i++)
    {
      ht[i] = 2.5*height/4 + height/4*noise(i/50.0) + height/5*noise(i/250.0); 
    }
  }
  
  float getHeight(float y)
  {
    int yi  = (int)y;
    
    if (yi < 0) yi = 0;
    if (yi > ht.length-1) yi = ht.length-1;
    
    return ht[yi];
  }
  
  void draw()
  {
    for (int i = 1; i < ht.length; i++)
    {
      stroke(128);
      line(i-1,ht[i-1], i, ht[i]);
    } 
  }
  
}

Terrain terrain;

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
    
    
    float ht = terrain.getHeight(p.x);
    if (p.y > ht) {
     p.y = ht;
     v.y = -v.y*0.7;
     
     v.x *= 0.5;
     v.z *= 0.5;
    }
    
    
    
    v.mult(0.99);
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

/*
class AngleSpring 
{
   
  Particle ps, p1, p2;
  
  float rest;
  float K; // spring constant
  float C; // damping constant
  
  float x_old; // old length
 
  AngleSpring(Particle new_v1, Particle new_v2, float new_K)
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
    //stroke(255);
    //line(v1.p.x, v1.p.y, v2.p.x, v2.p.y);
  }
}
*/

ArrayList springs;
ArrayList masses;

void setup() 
{
  size(400,400);  
  
  springs = new ArrayList();
  masses = new ArrayList();
  terrain = new Terrain();
  
  final float Kf = 0.06;
  
  boolean use_diagonals = true;
  int double_up_num = 4;  // at least 1
  
  final int NM = 9;
  //final int TNM = NM*NM;
  for (int k = 0; k < 3; k++) {
  for (int i = 0; i < NM; i++) {
     for (int j = 0; j < NM; j++) {
       
       final int ind = k*NM*NM + i*NM + j;
       
    Particle p = new Particle(new PVector(width/2.0 + 10.0*i, 20.0 + 10.0*j, 0.0));
    masses.add(p);
    
    for (int d = 1; d <= double_up_num; d++) {
    if (j > d-1) {
      Spring s = new Spring((Particle)masses.get(ind - d), p, Kf/(float)d);
      springs.add(s); 
    }
    
    if (i > d-1) {
      Spring s = new Spring((Particle)masses.get(ind - (d)*NM), p, Kf/(float)d);
      springs.add(s); 
    }
    // diagonal 1
    if (use_diagonals) {
    if ((i > d-1) && (j > d-1)) {
      Spring s = new Spring((Particle)masses.get(ind - (d)*NM - (d)), p, Kf);
      springs.add(s); 
    }
    
    // diagonal 2
    if ((i > d-1) && (j > d-1)) {
      Spring s = new Spring(
        (Particle)masses.get(ind - d*NM), 
        (Particle)masses.get(ind - d), 
        Kf);
      springs.add(s); 
    }
    }
    
    
    if (k >  d-1) {
      // straight across
      {
      Spring s = new Spring((Particle)masses.get(ind - d*NM*NM), p, Kf);
      springs.add(s); 
      }
      
      if (use_diagonals) {
      // column diagonals
      if (j >  d-1) {
        Spring s = new Spring((Particle)masses.get(ind - d*NM*NM - d), p, Kf);
        springs.add(s); 
      }
      if (j < NM- d-1) {
        Spring s = new Spring((Particle)masses.get(ind - d*NM*NM + d), p, Kf);
        springs.add(s); 
      }
      
      // row diagonals
      if (i >  d-1) {
        Spring s = new Spring((Particle)masses.get(ind - d*NM - d*NM*NM), p, Kf);
        springs.add(s); 
      }
      if (i < NM- d-1) {
        Spring s = new Spring((Particle)masses.get(ind + d*NM - d*NM*NM), p, Kf);
        springs.add(s); 
      }
      
      // diagonal diagonal
      if ((i >  d-1) && (j >  d-1)) {
        Spring s = new Spring((Particle)masses.get(ind - d*NM - d*NM*NM - d), p, Kf);
        springs.add(s); 
      }
      
      if ((i  < NM- d-1) && (j  < NM- d-1)) {
        Spring s = new Spring((Particle)masses.get(ind + d*NM - d*NM*NM + d), p, Kf);
        springs.add(s); 
      }
      // TBD two more possible here
      } // if false
    }// k>0
    
    } // double_up_num
    
     
  }}
  }
  
  
}

void draw()
{
  background(0);
  
  terrain.draw();
  
  for (int i = 0; i < springs.size(); i++) {
    Spring sp = (Spring) springs.get(i);
   // println(i);
    sp.update(); 
  }
  
  PVector gravity = new PVector(0.0, 0.11, 0.0);
  
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
