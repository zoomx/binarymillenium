
/**
 Lucas Walter
 
 June 2012
 
 GPL 3.0
*/

//import processing.opengl.*;
import java.util.Stack;

PImage img;  
float y_off;
// camera rotation
float rotx = -PI/2;
boolean pause = false;
HashMap roads;

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
class Car {
  
  boolean ground_contact = false;
  
  // the past locations of the car
  Stack<PVector> cv;
 
 /// these are in world coordinate frame
 PVector xyz;
 PVector xyz_old;
 
 PVector acc;
 PVector vel;
 
 float rot;
 float rot_vel;
 float rot_acc;
 
 /// this is the car coordinate frame
 /// TBD should only be 1 dimensional?
 float wheel_acc;
 float wheel_vel;
 
 /// the angle the steering wheels are at
 float wheel_rot;
 
 float tire_sz;
 
 /// the size of the car
 float SZ;
 
 color col;
 
 boolean gas;
 boolean brake_reverse;
 boolean turn_left;
 boolean turn_right;
 
 Car(PVector init_xyz) 
 { 
   cv = new Stack<PVector>();
 
   xyz = init_xyz;
   xyz_old = init_xyz;
   
   acc = new PVector();
   vel = new PVector();
   
   tire_sz = 0.8;
   
   SZ = 12;
   
   col = color(200,200,200);
   
   gas = false;
   brake_reverse = false;
   turn_left = false;
   turn_right = false;
   
 }

 int getJ() 
 {
   return (int)((xyz.z+BWD/2.0)/BWD );
 }
 
 int getI() 
 {
   return  (int)((xyz.x+BWD/2.0)/BWD );
 }
 
 void update(float y_off) 
 {
   
   float acc_rate = 1.5; //0.15;
   if (gas) {
     wheel_acc += acc_rate; 
   }
   if (brake_reverse) {
     if (wheel_vel > 0) {
       wheel_acc -= acc_rate*2;
     } else { 
       wheel_acc -= acc_rate*0.8;
     } 
   }
   
   if (turn_left) {
      wheel_rot -= 0.1; 
      wheel_acc += acc_rate/4;
   }
   if (turn_right) {
      wheel_rot += 0.1; 
       wheel_acc += acc_rate/4;
   }
   
   // gravity
   //acc.y -= 1.0;
   
   wheel_vel += wheel_acc;
   
   /// TBD this needs to be recomputed every time step, need a car_z_acc
   acc.z -= wheel_vel * cos(rot + wheel_rot);
   acc.x -= wheel_vel * sin(rot + wheel_rot);
   
   rot += wheel_rot * wheel_vel * 0.1;
  
   vel.add( acc );
   xyz.add( vel );
 
   rot_vel += rot_acc;
   rot += rot_vel;
   
    // simple ground collision, no other collisions yet
    if (xyz.y < y_off) { 
      ground_contact = true;
      xyz.y = y_off; 
      // bounce TBD this should used diff vel.y rather than this no longer valid vel.y
      vel.y = -vel.y*0.6; 
    } else {
      ground_contact = false; 
    } 
   
   //println(y_off + " wa" + wheel_acc + " " + wheel_vel + " wr" + wheel_rot + " r" + rot + ", " + getI() + " " + getJ() + " " + (xyz) + " v" + (vel) + " a" + (acc));
   
   // TBD or set to zero
   wheel_acc *= 0.1;
   wheel_vel *= 0.85;
   wheel_rot *= 0.85;
   
   acc.mult( 0.1 );
   rot_acc *=  0.1;
   
   /// TBD friction could be a function of how aligned the wheels are 
   /// with the current direction of travel (use atan2(vel.y, vel.x) ) 
   vel.mult( 0.95 );
   rot_vel *= 0.95;
    
    //int loc = getI()*NUM + getJ();
    boolean is_road =false;// roads.containsKey(loc);
  
    if (ground_contact) {
      if (is_road) {
        vel.x *= 0.65;
        vel.z *= 0.8; 
        rot_vel *= 0.56;
      } else {
        vel.x *= 0.6;
        vel.z *= 0.6; 
        rot_vel *= 0.46;
      } 
    } 
    
    
  } // update
 
  void draw()
  { 
  // draw four wheels
  fill(10);
  pushMatrix();
  
  // the tires dangle if in mid-air
  if (ground_contact) {
    translate(0, -tire_sz * 0.94, 0);
  } else {
     translate(0, -tire_sz * 1.1, 0);
  }
  
  pushMatrix();
  translate(0, 0, SZ*0.23 );
  
  noStroke();
  
  // back wheels
  //float tire_sz = SZ/16;
  translate(-SZ/5,0 , 0 );
  sphere(tire_sz);
  translate(SZ/2.5,0 , 0 );
  sphere(tire_sz);
  
  // forward wheel
  fill(50);
  translate(0,0 , -SZ*0.46);
  sphere(tire_sz);
  fill(50);
  translate(-SZ/2.5,0 , 0 );
  sphere(tire_sz);
  popMatrix();
  
  ///////////////////
  /// draw the body
  strokeWeight(10);
  stroke(0);
  
  pushMatrix();
  //translate(0,BWD*0.5, 0 );
  translate(0,-tire_sz*0.97 - SZ/8, 0 );
  
  fill(col);
  
  box(SZ/2.5, SZ/8, SZ/2);
  translate(0,-SZ/8, 0 );
  box(SZ/2.5, SZ/8, SZ/5);
  popMatrix();
 
 popMatrix();
 
 
 // trails
  if (false) {
  if ((cv.size() == 0 ) || (count %5 == 0)) {
    cv.push(xyz);
  }
  if (cv.size() > 100) {
    cv.pop();
  }
  
  //println(cx.size() + " " + cx.get(0));
    stroke(255,200,0);
    strokeWeight(10);
    
    int i =  0;
    for (i = 0; i < cv.size()-1; i++) {
      //println( str(cx.get(i)) + ' ' +  str(cy.get(i)) + ' ' + str(cz.get(i)) );
     // line(cv.get(i) ,  -cy.get(i), cz.get(i), 
     //      cx.get(i+1), -cy.get(i+1),cz.get(i+1));
    }
    
    //line(xyz.x, -xyz.y, xyz.z, cx.get(i), -cy.get(i), cz.get(i));
  }
 
}

}
///////////////////////////////////////////////////////////////////////////////////

Car player;
Car[] npcs;

void makeRoads(int i_loc, int j_loc, int NUM)
{
  roads = new HashMap();
  
  // TBD put in world object
  for (int i = 0; i < NUM*(NUM/50+1); i++) {
    int loc = i_loc*NUM + j_loc;
  
    roads.put(loc, true);
  
    int choice = (int) ( noise(i_loc/10.0, j_loc/10.0)*4 );
    if (choice == 3) {
      i_loc += 1;
    } else if (choice == 2) {
      j_loc += 1;
    } else if (choice == 1) {
      i_loc -= 1;
    } else  {
      j_loc -= 1;
    }
  }
  
}

//////////////////////////////////////////////////////////////////////////////////////////
///
////////////////////////////////////////////////////////////////////////////////////////

  float dt = 0.1;
    float BWD = 128.0;
  
class Terrain {
  
  // TBD class world

  int NUM; // = 2048;
  float BWD;

  float[][] elev;//[NUM][NUM];

  Terrain parent;
  Terrain child;
  
  PFont fontA;

  
  Terrain(int new_num, float new_BWD) {
    println("new terrain " + new_num + " " + new_BWD);
    NUM = new_num;
    BWD = new_BWD;
    
    parent = null;
    
    makeTerrain(); 
    
    if (NUM >= 9) {
      child = new Terrain(this);
    }
  }
  
  void makeTerrain()
  {
    elev = new float[NUM][NUM];
  
    float nsc1 = 0.05;
    for (int i = 0; i < NUM; i++) {
    for (int j = 0; j < NUM; j++) {
      //elev[i][j] = -0.2*(i*j);
      float hills = (noise(100+i*nsc1,10+j*nsc1)-0.5);
      if (hills < 0.0) hills = 0;
      hills *= 10*BWD;
      elev[i][j] = 1*BWD*(noise(i*nsc1,j*nsc1)-0.5) + hills - 5*BWD;
      
      elev[i][j]=0;
    }
    }
  
  }  // makeTerrain
  
  Terrain(Terrain new_parent) {
    parent = new_parent;
    
    NUM = parent.NUM/3;
    BWD = parent.BWD*3;
    
    elev = new float[NUM][NUM];
    
    for (int i = 0; i < NUM; i++) {
    for (int j = 0; j < NUM; j++) {
       float sum = 0; 
       for (int is = -1; is <= 1; is++) {
       for (int js = -1; js <= 1; js++) {
         sum += parent.getElev(i*3 + is, j*3 + js);
       }}
       
       sum /= 9;
       
       elev[i][j] = sum;
    }}
    
    if (NUM >= 9) {
      child = new Terrain(this);
    }
  }
  
  float getElev(int i_loc, int j_loc) {
    
    if ((i_loc >= 0) && (i_loc < NUM) && (j_loc >= 0) && (j_loc < NUM)) {
      return elev[i_loc][j_loc];
    }
    
    return 0;
    
  }

////////////////////////////////////////////
void draw(
    int i_loc, int j_loc,
    int i_min, int j_min,
    int i_max, int j_max,
    int i_in_min, int j_in_min,
    int i_in_max, int j_in_max)
{

  
  if (child != null) {
    pushMatrix();
    translate(BWD, 0, BWD);
    
    int i_sc = (i_max-i_min)/3;
    int j_sc = (j_max-j_min)/3;
    
    //child.draw(i_loc/3, j_loc/3, i_min);
    popMatrix();
  }
  
  fill(0,150,0);
   //stroke(50);

  pushMatrix();
  noStroke();
  for (int i = i_min; i < i_max; i += 1) {
    //pushMatrix();
    if (i >= NUM) break;
    if (i < 0) continue;
    
    for (int j = j_min; j < j_max; j += 1) {
      
      if (j >= NUM) break;
      if (j < 0) continue;
      
      if ((i >= i_in_min) && (i < i_in_max) &&
          (j >= j_in_min) && (j < j_in_max)) {
      
        continue;     
      }
      
      
      
        int mdist = abs( i - i_loc) + abs( j - j_loc);  

        drawSection(i, j, mdist);  
  
    }

  }
  popMatrix();
}

  void drawSection(int i, int j, int mdist)
  {
    float sc = 1.0;
    int loc = i*NUM + j;
    boolean is_road = false;//roads.containsKey(loc);
      
    pushMatrix();
    translate(j*BWD, -elev[i][j], i*BWD);
      
       //stroke(0);
       /*
        pushMatrix();
        rotateX(-PI/2);
        fill(0);
         text(str(i) + "," + str(j), 0, 0, -BWD/2);
         popMatrix();
         */
   
      if ( (parent == null) && (mdist < 3) ) {
        //stroke(0);
        if (is_road) {
          fill(150);
        } else {
          fill(0,150,0);
          // draw grass
          drawGrass(50,  i,  j);
        }
        drawTriFan(BWD);
        
        if (true) {
        pushMatrix();
        rotateX(PI/2);
        translate(0, BWD/2,-BWD*0.499);
        drawTriFan(BWD);
        translate(0, -BWD,0);
        drawTriFan(BWD);
        popMatrix();
      }
        pushMatrix();
        rotateZ(PI/2);
        translate(BWD*0.499,-BWD*0.5,0);
        drawTriFan(BWD);
        translate(0, BWD,0);
        drawTriFan(BWD);
        popMatrix();   
       
      } else {
        if (is_road) {
          fill(130);
        } else {
          fill(0,130,0);
        }
         
        if ((parent == null) && (mdist < 6)) {
          if (is_road) {
            fill(135);
          } else {
            fill(0,135,0);
            drawGrass(5, i, j); 
          }
          
        }
        
        stroke(0);
        strokeWeight(1);
        translate(0,sc * BWD/2, 0);
        box(sc*BWD*0.9);
      
      } 
      popMatrix();
  } // drawSection
/////////////////////////////////////////////////////

  
} // Terrain

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

Terrain terrain;

PFont fontA;

void setup()
{
  size(600, 600, P3D);
  //size(1280, 720, P3D);
  
  frameRate(1.0/dt);
  
  fontA = loadFont("Courier10PitchBT-Roman-36.vlw");
  textFont(fontA, 16);
  
  int NUM = (int)pow(3,4);
  
  player = new Car(new PVector(BWD*NUM/2, BWD*20, BWD*NUM/2));
  
  //makeRoads( player.getI(), player.getJ() );
  
  terrain = new Terrain(NUM,BWD);

  if (false) {
    img = createImage(10, 10, RGB);
    img.loadPixels();
    for (int i = 0; i < img.width; i++) {
      for (int j = 0; j < img.height; j++) {
        img.pixels[i * img.height + j] = color(12, 120 + 80 * noise(i/10.0,j/10.0), 11); 
    }}
  
    img.updatePixels();
  }
}
/////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int  count = 0;
float t;

void draw()
{
  t += dt;
  count += 1;
  
  background(10,90,200);
  ambientLight(50, 50, 200);
  directionalLight(255,255,220,0.2,1.0,-0.3);
  
  // TBD where does BWD*13 come from?
  translate(width/2, height/2, height*.81 );
  
  // how far behind the car the camera should be
  
  translate(0, player.SZ/2, 0);//car_sz*2 );
  
  rotateX(rotx);
    
  pushMatrix();
  rotateY(player.wheel_rot);
  player.draw();
  popMatrix();
  
  // get current position on map
  int j_loc = player.getI();
  int i_loc = player.getJ();

  y_off = terrain.getElev(i_loc,j_loc);

  rotateY(-player.rot);
  
  if (!pause) {   
    player.update(y_off);
  }
  
  //translate(-player.xyz.x, player.xyz.y, -player.xyz.z);
  translate(-player.xyz.x, player.xyz.y, -player.xyz.z);
  
  //translate(-x*cos(rot) -z*sin(rot),
  //          BWD + y, 
  //           x*sin(rot) -z*cos(rot));
  
 terrain.draw(i_loc, j_loc, i_loc - 10, j_loc - 10, i_loc+10, j_loc+10, i_loc, j_loc, i_loc, j_loc);
    
    
  //saveFrame("line-####.png");
}


//////////////////////////////////////////////
void drawGrass(int num, int i, int j)
{
   strokeWeight(3);
   stroke(24,125,10);
   
   float dx = 3.5*(noise(0.2*t + i/100.0)-0.5);
   float dz = 3.5*(noise(0.2*t + j/100.0 + 1000)-0.5);
      
   for (int ind = 0; ind < num*2; ind++) {
      float x = 1.6 * BWD * (noise(i + ind)-0.5);
      float z = 1.6 * BWD * (noise(j + ind + 200)-0.5);
          
      // TBD wind blowing effect here
      line(x , 0, z, x + dx, -2, z + dz);
   }
   
  fill(45,135,3);
  noStroke();
  for (float ind = 0; ind < 100.0; ind+= 1.0) {
    float x = 1.6*(float)BWD*(noise(0.1*i + ind + t/2000.0)-0.5);
    float z = 1.6*(float)BWD*(noise(0.1*j + ind + t/2000.0 + 500)-0.5);
    
    pushMatrix();
    translate(x,ind/100.0,z);    
    box(BWD/80);
    popMatrix();
  }
  noStroke(); 
}

void drawTriFan(float sz)
{
  textureMode(NORMALIZED);
  beginShape(TRIANGLE_FAN);
  //stroke(0);
 // texture(img);
      vertex( 0,    0,  0);//,    0.50, 0.50);
      vertex( sz/2, 0,  0);//,    1.00, 0.50); 
      vertex( sz/2, 0,  sz/2);//, 1.00, 1.00); 
      vertex(0,     0,  sz/2);//, 0.50, 1.00); 
      vertex(-sz/2, 0,  sz/2);//, 0,    1.00); 
      vertex(-sz/2, 0,  0);//,    0,    0.50); 
      vertex(-sz/2, 0, -sz/2);//, 0,    0); 
      vertex( 0,    0, -sz/2);//, 0.50, 0); 
      vertex( sz/2, 0, -sz/2);//, 1.00, 0);
      vertex( sz/2, 0,  0);//,    1.00, 0.50); 
      endShape();
}


void keyReleased()
{
  if (key == 'w') {
    player.gas = false;
  }
  if (key == 's') {
     player.brake_reverse = false;
  }  
  if (key == 'a') {
    
  }
  if (key == 'd') {
    
  }  
  if (key == 'q') {
    
  }
  if (key == 'z') {
   
  }  
  
  if (key== 'j') {
     player.turn_right = false;
  }
  
  if (key == 'l') {
     player.turn_left = false;
  }
}

void keyPressed()
{
  float sc = BWD/50.0;
  
 // if (ground_contact) {
  if (key == 'w') {
    player.gas = true;

  }
  if (key == 's') {  
    player.brake_reverse = true;
  }  
  if (key == 'a') {
   
  }
  if (key == 'd') {
   
  }  
  if (key == 'q') {
    player.acc.y += 10;
   
  }
  if (key == 'z') {
    player.acc.y -= 10;
  }  
 // }
  
  if (key== 'j') {
     player.turn_right = true; 
  }
  
  if (key == 'l') {
     player.turn_left = true;
  }
  
  if (key == 'p') {
     pause = !pause; 
  }
  
  ///////////////////////////
  if (key == 'i') {
     rotx += 0.1; 
     
     if (rotx > PI/2) { rotx = PI/2; }
  }
  
  if (key == 'k'){
     rotx -= 0.1; 
     
     if (rotx < -PI/2) { rotx = -PI/2; }
  }
  
  if (key == 'b') {
    player.tire_sz *= 0.9;
    if (player.tire_sz< 0.3) {
      player.tire_sz = 0.3;
    } 
  }
  if (key == 'n') {
    player.tire_sz *= 1.1; 
  }
}

///////////////
