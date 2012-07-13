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
    
    float sc = 500;
    for (int i = 0; i < ht.length; i++)
    {
      float f = (float) i;
      ht[i] = /*-i/2 +*/ 2.5*sc/6 + sc/60.0*noise(f/5.0) + 
      sc/10.0*noise(f/50.0) + sc/8.0*noise(f/250.0) + sc*noise(f/2000.0);
    
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
  
  ArrayList vels;

  // permanent springs attached to this particle
  int spring_count;
  
  color c;
 
  Particle(PVector new_p, color col)
  {
    p = new PVector(new_p.x, new_p.y, new_p.z);
    v = new PVector();
    a = new PVector();
    
    c = col;
    
    spring_count = 0;
    
    // store old vels for filtering
    vels = new ArrayList();
    
    //println("Pr " + p); 
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
    
    if (false) {
    
    vels.add(v);
    
    // compare the sum of vector magnitudes to the magnitude of vector sums
    // if it is high then reduce velocity
    float vel_mag_sum = 0;
    PVector vel_sum = new PVector(0.0,0.0,0.0);
    for (int i = 0; i < vels.size(); i++) {
      PVector vo = (PVector)vels.get(i);
      vel_sum.add(vo);
      vel_mag_sum += vo.mag();
    }
    
    float vel_sum_mag = vel_sum.mag();
    
    if (vel_mag_sum > 0) {
      float vel_mag_ratio = vel_sum_mag/vel_mag_sum; 
      
      float th = 0.9;
      
      if (vel_mag_ratio < th) {
        v.mult(vel_mag_ratio/th); 
        println(vel_mag_ratio + "   " + vel_sum_mag + "  " + vel_mag_sum+ "   " + v);
      }
      //;
    }
    
    if (vels.size() > 40) vels.remove(0);
    }
    
    /// clip vel at certain speed
    if (false) {
    float vmag= v.mag();
    float max_vel = 25.0;
    if (vmag > max_vel) {
       v.normalize();
       v.mult(max_vel); 
    }
    }
    
    
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
        v.y = -v.y*0.9; //.99;
       
       float depth = abs(p.y -ht);
       if (depth <4.0) depth = 4.0;
       v.x /= depth*depth;
       v.z /= depth*depth;
       
       //println(v.x + "   " + v.z);
    }
    }
     
    // make things viscous
    v.mult(0.999);
    
    // need new forces in next time step
    a.mult(0);
  }
  
  void draw()
  {
    float vel = v.mag();
    noStroke();
    fill(c);
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


//////////////////////////////////////////////////////////////////////////////////
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
  
  color c;
 
 // Spring(Particle new_v1, Particle new_v2, float new_K)
   Spring(Particle new_v1, Particle new_v2, 
      float new_K, float new_C, 
      boolean new_alter_1, boolean new_alter_2,
      color col)
  {
    c = col;
    v1 = new_v1;
    v2 = new_v2;
    
    v1.spring_count++;
    v2.spring_count++;
    
    K = new_K;
    
    C = new_C; // 0.010;
    Tf = 0.015;
     
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
    //if (x > 2.0 * dis) x = 2.0*dis;
    
    float acc = -K * x;
    
    // diff_o points from v1 TO v2
     PVector diff_o = PVector.sub(v2.p, v1.p);
    diff_o.normalize();

    // dead zone
    if (!((x < rest/10.0) && (x > -rest/10.0)))
    {

    float avg_count = (float)(v1.spring_count + v2.spring_count)/2.0;
    
    PVector diff = new PVector(0.0,0.0,0.0);
    diff.set(diff_o);
    diff.mult(acc/avg_count);
    if (alter_1)
      v1.addForce(diff);
    diff.mult(-1.0);
    if (alter_2)
      v2.addForce(diff);
    }
    
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
    
    
    //////////////////////////////////////////////
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
    
    stroke(c);
    /*
    int  f;
    if (dis > rest) {
      f =  (int)(dis/rest*20.0);
      stroke(128-f, 128-f, 128+f); //, 10);
    } else {
      f =  (int) (rest/dis*20.0);
      stroke(128+f, 128-f,128-f);//,10);
    }
    */
    
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
  
  ArrayList cen;
  
  float Cf;
  float Kf;
  float SP;
  float spring_dist;
  
  Structure(int NM_x, int NM_y, 
  float new_SP, PVector offset, 
  boolean make_circle, color col,
  float new_Kf, float new_Cf, float new_spring_dist)
  {
    springs = new ArrayList();
    masses = new ArrayList();
    cen = new ArrayList();
    int Z_NM = 2;

    
    //if (use_2d) Z_NM = 1;
    SP = new_SP;// 10.0;
    Kf = new_Kf; //0.01;// * SP/10.0;
    Cf = new_Cf; //0.09;s
    spring_dist = new_spring_dist;

  for (int k = 0; k < Z_NM; k++) {
  if (make_circle) {
    for (int r = 0; r < NM_x/2; r++) {
     for (int a =  0; a < NM_y; a+= (NM_x/2-r)) {
       float rad = r *SP;
       float angle = (float)a*2.0*PI/(float)NM_y;
       Particle p = new Particle(new PVector(rad * cos(angle), rad*sin(angle), k*SP),col);
       p.p.add(offset);

       masses.add(p);
       
        if (r ==0) {
         cen.add(p);
         break;
       }
     }}
  } else {
  //final int TNM = NM*NM;

  for (int i = -NM_x/2; i < NM_x/2; i++) {
     for (int j =  -NM_y/2; j < NM_y/2; j++) {
       
    Particle p = new Particle(new PVector(SP*i, SP*j, k*SP), col);
    
    p.p.add(offset);
    
    if ((i ==0) && (j==0)) cen.add(p);
    
    masses.add(p);
    
     }}
    
  } // make rectangle
  
  }// k
     
     
  for (int i = 0; i < masses.size(); i++) {
    for (int j = 0; j < masses.size(); j++) {
      if (i == j) continue;
      
      Particle p1 = (Particle)masses.get(i);
      Particle p2 = (Particle)masses.get(j);
      
      float dis = p1.distManhattan(p2);
      
      if (dis > spring_dist /*SP*3*/) continue;
      
      float new_Kf2 = Kf;
      float new_Cf2 = Cf;
      
      if (dis > SP) {
        //new_Kf = pow(new_Kf, dis/10.0);
        new_Kf2 /= dis/(0.6*SP);
        new_Cf2 /= dis/(0.6*SP);
      }
      
      Spring s = new Spring(p1, p2, new_Kf, new_Cf, true, true,col);
      springs.add(s); 
        
    }}
    
  println("num masses " + masses.size() + ", springs " + springs.size());
  
  
  axle = new PVector(0.0,0.0,1.0); 
  }
  
  
  ///////////////////////////////////////
  void update()
  {
    
     for (int i = 0; i < springs.size(); i++) {
    Spring sp = (Spring) springs.get(i);
   // println(i);
    sp.update(); 
    }
  
  //cen.p.mult(0);
  
    for (int i = 0; i < masses.size(); i++) {
    Particle pr = (Particle) masses.get(i);
    pr.addForce(gravity); 
    pr.update();
    
    //cen.p.add(pr.p);
    
    }
  }
  //cen.p.div(masses.size());
  
   void draw() {
  //println(cam.p + "  " + cen.p);
  pushMatrix();
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
  
  
   for (int i = 0; i < cen.size(); i++) {
     fill(255,10);
    Particle pr = (Particle) cen.get(i);
    ellipse(pr.p.x, pr.p.y, 4,4);
  }

  
   popMatrix();
  }
  
  void addTorque(boolean rotate_clockwise, Particle cn, float range)
  {
    float tq = 0.6;
    //println (count + " torque " + key); 
     //Particle cn = (Particle) cen.get(0);
     
     for (int i = 0; i < masses.size(); i++) {
       Particle pr = (Particle) masses.get(i);
       PVector rad = PVector.sub(pr.p, cn.p);
       
       if (rad.mag() > range) continue;
       
       rad.normalize();
       PVector torque = rad.cross(axle);
       
       if (rotate_clockwise)
        torque.mult(tq);
       else
        torque.mult(-tq);
       
       pr.addForce(torque);
       
     }
 
     
  } // addTorque
  
  void connectCen(Structure s2, float max_dist)
  {
   
    for (int i = 0; i < s2.masses.size(); i++) {
      for (int j = 0; j < cen.size(); j++) {
      Particle pr = (Particle) s2.masses.get(i);
      Particle cn = (Particle) cen.get(j);
      
      float dis = cn.distManhattan(pr);
      
      float new_Kf = Kf*4;
      float new_Cf = Cf;
      
      if (dis < max_dist) {
        if (dis > s2.SP) {
        //new_Kf = pow(new_Kf, dis/10.0);
        new_Kf /= dis/(0.7*s2.SP);
        new_Cf /= dis/(0.7*s2.SP);
        }
      
        Spring s = new Spring(cn, pr, new_Kf, new_Cf, true, true, color(64,64,128));
        s2.springs.add(s); 
      }
    }}
  }
} // Structure

Structure wheel1, wheel2, body;

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
Spring cam_spring;

float wheel_rad;

void setup() 
{
  size(600, 600);  
  frameRate(20);
  
  gravity = new PVector(0.0, 0.11, 0.0);
  terrain = new Terrain();
  cam = new Particle(new PVector(0,0,0), color(255));
  
  strokeWeight(1.5);
  
  if (true) {
    // distance between springs
    float SP = 25.0;
    float spring_dist = SP*3.0;
    float Kf = 1.95;
    float Cf = 0.005;
    int wheel_diameter = 9;
    int wheel_circ = 19;
    
    wheel_rad = SP*wheel_diameter/2.0;
    
    color c1 = color(64,64,64);
    wheel1 = new Structure(wheel_diameter,wheel_circ, SP, 
                        new PVector(-200,200,0) , 
                        true , c1,
                         Kf, Cf, 
                         spring_dist);
                         
    wheel2 = new Structure(wheel_diameter,wheel_circ, SP, 
                        new PVector(0,200,0) , 
                        true, c1,
                         Kf, Cf, 
                         spring_dist);
    
    SP *= 1.7;
    spring_dist = SP*2.1;
    
    color c2 = color(128,64,64);
    body   = new Structure(8,5, SP, 
                        new PVector(-100,150,0) , 
                        false, c2,
                        Kf, Cf, 
                        spring_dist);
    
    wheel1.connectCen(body,wheel_rad*2);
    wheel2.connectCen(body,wheel_rad*2);

    cam_spring = new Spring((Particle)wheel1.cen.get(0), cam, 
          0.14, 0.29, 
          false, true, color(255));
    cam_spring.rest = 0;
    //wheel1.springs.add(s); 
  } else {
    float Cf = 0.4;
    float Kf = 0.5;
    color c = color(255);
     p1 = new Particle(new PVector(width/2,10,0),c); 
     p2 = new Particle(new PVector(width/2,40,0),c); 
     p3 = new Particle(new PVector(width/2 + 20,10,0),c); 
     sp1 = new Spring(p1, p2, Kf, Cf, true, true,c);
     //sp1.rest = 15;
     
     sp2 = new Spring(p2, p3, Kf, Cf, true, true,c);
     
     sp3 = new Spring(p1, p3, Kf, Cf, true, true,c );
   }
}

int count = 0;
boolean pause = false;

/////////////////////////////////////////////////
void draw()
{
  background(0,0,0);
  //fill(0,180);
  //rect(0,0,width,height);
  
  terrain.draw(cam.p);
  
  
  if (true) {
  
    if (!pause) {
         body.update();
wheel1.update();
wheel2.update();

    }
    body.draw();
wheel1.draw();
wheel2.draw();

cam_spring.update();
 cam.update();
  
  boolean dir = false;
  boolean drive = false;
  
  if (keyPressed)
  {
    if ((key == 'j') || (key == 'k')) {
      dir = (key=='j' ? true : false);
     drive = true;
    }
    
    if (key == 'p') {
      pause= !pause;
      println("paused " + pause);
    }
    
    if (key == 'q') {
     // jump
     PVector jump = new PVector(0,-5,0);
      for (int i = 0; i < body.masses.size(); i++) {
        Particle pr = (Particle) body.masses.get(i);
        pr.addForce(jump);
      } 
      jump.mult(0.5);
      for (int i = 0; i < wheel1.masses.size(); i++) {
        Particle pr = (Particle) wheel1.masses.get(i);
        pr.addForce(jump);
      } 
       for (int i = 0; i < wheel2.masses.size(); i++) {
        Particle pr = (Particle) wheel2.masses.get(i);
        pr.addForce(jump);
      } 
    }
  }
  
  if (drive){ 
   Particle cn = (Particle)wheel1.cen.get(0);
     wheel1.addTorque( dir, cn, wheel_rad*1.2);
     body.addTorque( !dir, cn, wheel_rad/2.0);
     
     Particle cn2 = (Particle)wheel2.cen.get(0);
     wheel2.addTorque( dir, cn2, wheel_rad*1.2);
     body.addTorque( !dir, cn2, wheel_rad/2.0);  
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
  
  //saveFrame("springs-#####.png");
}
