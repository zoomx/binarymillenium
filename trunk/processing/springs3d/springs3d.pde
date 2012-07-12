/*

Lucas Walter
July 2012
GPL 3.0

*/

boolean use_2d = true;

Particle cam;

class Terrain
{
  float ht[];
  Terrain()
  {
    ht = new float[4096];
    
    for (int i = 0; i < ht.length; i++)
    {
      ht[i] = /*-i/2 +*/ 2.5*height/6 + height/30.0*noise(i/5.0) + height/12*noise(i/50.0) + height/6*noise(i/250.0); 
    
    }
  }
  
  float getHeight(float y)
  {
    int yi  = (int)y;
    
    if (yi < 0) yi = 0;
    if (yi > ht.length-1) yi = ht.length-1;
    
    return ht[yi];
  }
  
  void draw(PVector cam_pos)
  {
    int wd = width;
    int ht = height/2;
    for (int i = 1; i < wd; i++)
    {
      stroke(128);
      // center the terrain on the cam_pos
      line(i-1, -cam_pos.y +ht + getHeight(i + cam_pos.x - wd/2-1), 
           i, -cam_pos.y +ht + getHeight(i + cam_pos.x - wd/2));
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
    
    println("Pr " + p);
    
  }
  
  void addForce(PVector new_f)
  {
    // TBD add mass later
    a.add(new_f);
  }
  
  void update() // = new PVector(0,-0.1,0))
  {
    //a.add(new_a);
    v.add(a);
    
    if (use_2d)
      v.z = 0;
    
    p.add(v);   
    
    if (terrain != null) {
    float ht = terrain.getHeight(p.x);
    if (p.y > ht) {
      
      //if (v.y > 10.0) // destroy ground under impact
        //terrain.ht[(int)p.x] = p.y;
        // not working great yet.
      p.y = ht;
      //v.mult(-0.5);
      //if (v.y > 0)
        v.y = -v.y*0.2; //.99;
       
       float depth = abs(p.y -ht);
       if (depth <2.0) depth = 2.0;
       v.x /= depth;
       v.z /= depth;
    }
    }
     
    // make things viscous
    v.mult(0.99);
    
    // need new forces in next time step
    a.mult(0);
  }
  
  void draw()
  {
    float vel = v.mag();
    noStroke();
    fill(255 - vel*50,255,255);
    ellipse(p.x, p.y, 2,2);
    
    //ellipse(p.z, p.y, 2,2);
    
  }
  
  float dist(Particle p2)
  {
    return p.dist(p2.p);
  }
  
  float distManhattan(Particle p2)
  {
    return abs(p.x-p2.p.x) + abs(p.y-p2.p.y) + abs(p.z-p2.p.z);
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
  float Tf; // torsional damping
  
  float dis;
  float x;
  float x_old; // old length
  
  boolean alter_1, alter_2;
 
 // Spring(Particle new_v1, Particle new_v2, float new_K)
   Spring(Particle new_v1, Particle new_v2, 
      float new_K, float new_C, 
      boolean new_alter_1, boolean new_alter_2)
  {
    v1 = new_v1;
    v2 = new_v2;
    K = new_K;
    
    C = new_C; // 0.010;
    Tf = 0.01;
     
    rest = v1.dist(v2);
    
    alter_1 = new_alter_1;
    alter_2 = new_alter_2;
    //println(rest + ": " + v1.p + " ,   " + v2.p + ": " + K);
  } 
  
  /*
  Spring(Particle new_v1, Particle new_v2, float new_K, 
      boolean new_alter_1, boolean new_alter_2)
  {
    alter_1 = new_alter_1;
    alter_2 = new_alter_2;
    
    return Spring.Spring(new_v1, new_v2, new_K);
  }*/
  
  void update()
  {
    dis = v1.dist(v2); 
    x = rest - dis; 
    
    // hard max
    if (x > 2.0 * dis) x = 2.0*dis;
    
    float acc = -K * x;
    
    // diff_o points from v1 TO v2
    PVector diff_o = PVector.sub(v2.p, v1.p);
    diff_o.normalize();
    
    PVector diff = new PVector(0.0,0.0,0.0);
    diff.set(diff_o);
    diff.mult(acc);
    if (alter_1)
      v1.addForce(diff);
    diff.mult(-1.0);
    if (alter_2)
      v2.addForce(diff);
    
    PVector diffC = new PVector(0.0,0.0,0.0);
    diffC.set(diff_o);
    
    float dx = x_old - x;
    if (dx > rest) dx = rest;
    if (dx < -rest) dx = -rest;
    
    diffC.mult(dx*C);
    
    x_old = x;
    if (alter_1)
      v1.addForce(diffC);
    diffC.mult(-1.0);
    if (alter_2)
      v2.addForce(diffC);
    
    // Find tangential velocities
    if (Tf != 0) {
    PVector diff1  = new PVector(0.0,0.0,0.0);
    diff1.set(diff_o);
    
    // find the vector component of velocity that points towards
    // the other particle
    float vdot1 = v1.v.dot(diff1);
    diff1.mult(vdot1);
    PVector vel_tan_1 = PVector.sub(v1.v, diff1);
    
    PVector diff2  = new PVector(0.0,0.0,0.0);
    diff2.set(diff_o);
    
    // find the vector component of velocity that points towards
    // the other particle
    float vdot2 = v2.v.dot(diff2);
    diff2.mult(-vdot2);
    PVector vel_tan_2 = PVector.sub(v2.v, diff2);
    
    PVector avg_tan_vel = PVector.add(vel_tan_1, vel_tan_2);
    avg_tan_vel.div(2);
    
    // now get non-average tangential velocities:
    vel_tan_1.sub(avg_tan_vel);
    vel_tan_2.sub(avg_tan_vel);
    
    // point in opposite directions to opposing the movement
    vel_tan_1.mult(-Tf);
    vel_tan_2.mult(-Tf);
    
    v1.addForce(vel_tan_1);
    v2.addForce(vel_tan_2);
    }
   

 
  }
  
  void draw()
  {
    // transparency is very slow
    
    int  f;
    if (dis > rest) {
      f =  (int)(dis/rest*20.0);
      stroke(128-f, 128-f, 128+f); //, 10);
    } else {
      f =  (int) (rest/dis*20.0);
      stroke(128+f, 128-f,128-f);//,10);
    }
    
    //if (dis > 2.0*rest)
    //if (count == 0)
    //  println(f + ", " + rest + "  " + dis + "   ");

    line(v1.p.x, v1.p.y, v2.p.x, v2.p.y);
    
    //line(v1.p.z, v1.p.y, v2.p.z, v2.p.y);
  }
}

PVector gravity;

class Structure
{
  ArrayList springs;
  ArrayList masses;
   
  PVector axle;
  
  Particle cen;
  
  Structure(int nm)
  {
    springs = new ArrayList();
    masses = new ArrayList();
    int Z_NM = 1;
  
    cen = new Particle(new PVector(0,0,0));
    
    float Cf = 0.02;
  //if (use_2d) Z_NM = 1;
  
  final float SP = 10.0;
  final float Kf = 0.08 * SP/10.0;
  final int NM = nm;
  //final int TNM = NM*NM;
  for (int k = 0; k < Z_NM; k++) {
  for (int i = 0; i < NM; i++) {
     for (int j = 0; j < NM; j++) {
       
       if (sqrt(pow((float)i - NM/2.0,2.0) + pow((float)j - NM/2.0,2.0)) >= NM/2 ) continue;
       
    Particle p = new Particle(new PVector(SP*i, 2*SP + SP*j, k*SP));
    masses.add(p);
    
  }}}
     
     
  for (int i = 0; i < masses.size(); i++) {
    for (int j = 0; j < masses.size(); j++) {
      if (i == j) continue;
      
      Particle p1 = (Particle)masses.get(i);
      Particle p2 = (Particle)masses.get(j);
      
      float dis = p1.distManhattan(p2);
      
      if (dis > SP*3) continue;
      
      float new_Kf = Kf;
      float new_Cf = Cf;
      
      if (dis > SP) {
        //new_Kf = pow(new_Kf, dis/10.0);
        new_Kf /= dis/(0.7*SP);
        new_Cf /= dis/(0.7*SP);
      }
      
      Spring s = new Spring(p1, p2, new_Kf, new_Cf, true,true);
      springs.add(s); 
        
    }}
    
  println("num masses " + masses.size() + ", springs " + springs.size());
  
  
  axle = new PVector(0.0,0.0,1.0); 
  }
  
  
  ///////////////////////////////////////
  void draw()
  {
    pushMatrix();
     for (int i = 0; i < springs.size(); i++) {
    Spring sp = (Spring) springs.get(i);
   // println(i);
    sp.update(); 
  }
  
  cen.p.mult(0);
  
  for (int i = 0; i < masses.size(); i++) {
    Particle pr = (Particle) masses.get(i);
    pr.addForce(gravity); 
    pr.update();
    
    cen.p.add(pr.p);
    
  }
  cen.p.div(masses.size());
  
  cam.update();
  //println(cam.p + "  " + cen.p);
  
  translate(-cam.p.x + width/2, -cam.p.y + height/2);
 
  ////////////////////////////////////////
  for (int i = 0; i < springs.size(); i+=4) {
    Spring sp = (Spring) springs.get(i);
    sp.draw();
  }
  
  for (int i = 0; i < masses.size(); i++) {
    Particle pr = (Particle) masses.get(i);
   pr.draw();
  }
  
    fill(255);
  ellipse(cen.p.x, cen.p.y, 4,4);
   popMatrix();
  }
  
  void addTorque(boolean rotate_clockwise)
  {
    //println (count + " torque " + key); 
     
     for (int i = 0; i < masses.size(); i++) {
       Particle pr = (Particle) masses.get(i);
       PVector rad = PVector.sub(pr.p, cen.p);
       rad.normalize();
       PVector torque = rad.cross(axle);
       
       if (rotate_clockwise)
        torque.mult(0.25);
       else
        torque.mult(-0.25);
       
       pr.addForce(torque);
       
     }
 
     
  } // draw
} // Structure

Structure structure;

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////
Particle p1, p2, p3;//p4;
Spring sp1,sp2,sp3;

void setup() 
{
  size(800, 600);  
  frameRate(20);
  
  gravity = new PVector(0.0, 0.11, 0.0);
  terrain = new Terrain();
  cam = new Particle(new PVector(0,0,0));
  
  if (true) {
    structure = new Structure(7);

    Spring s = new Spring(structure.cen, cam, 0.003, 0.49, false, true);
    s.rest = 0;
    structure.springs.add(s); 
  } else {
    float Cf = 0.4;
    float Kf = 0.5;
     p1 = new Particle(new PVector(width/2,10,0)); 
     p2 = new Particle(new PVector(width/2,40,0)); 
     p3 = new Particle(new PVector(width/2 + 20,10,0)); 
     sp1 = new Spring(p1, p2, Kf, Cf, true, true);
     //sp1.rest = 15;
     
     sp2 = new Spring(p2, p3, Kf, Cf, true, true);
     
     sp3 = new Spring(p1, p3, Kf, Cf, true, true);
   }
}

int count = 0;

/////////////////////////////////////////////////
void draw()
{
  background(0,0,0);
  //fill(0,180);
  //rect(0,0,width,height);
  
  terrain.draw(cam.p);
  
  
  if (true) {
  
structure.draw();
  
  if (keyPressed)
  {
    if ((key == 'j') || (key == 'k')) {
     structure.addTorque( (key=='j' ? true : false));
    
    }
  }
  } else {
    translate(-cam.p.x + width/2,0);//-cam.p.y);
    sp1.update();
     sp2.update();
      sp3.update();
    p1.addForce(gravity);
    p1.update();
    p2.addForce(gravity);
    p2.update();  
    p3.addForce(gravity);
    p3.update(); 
    sp1.draw();
    sp2.draw();
    sp3.draw();
    p1.draw();
    p2.draw();
    p3.draw();
  }
  
  count++;
}
