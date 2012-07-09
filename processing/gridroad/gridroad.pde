
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

color sky_col;

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

 int getI() 
 {
   return (int)((xyz.z+BWD/2.0)/BWD );
 }
 
 int getJ() 
 {
   return  (int)((xyz.x+BWD/2.0)/BWD );
 }
 
 void update( ) 
 {
   float y_off = terrain.getElev(getI() ,getJ());
   
   float acc_rate = 0.35;
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
   acc.y -= 1.0;
   
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

//////////////////////////////////////////////////////////////////////////////////////////
///
////////////////////////////////////////////////////////////////////////////////////////

  float dt = 0.1;
    float BWD = 32.0;
  
class Terrain {
  
  // TBD class world

  int NUM; // = 2048;
  float BWD;

  float[][] elev;
  int[][] type;

  Terrain parent;
  Terrain child;
  
  // fraction of 1 where 1 is the top parent
  // and 0 is the bottom child
  float p_dist;
  
  PImage type_image;
  PImage elev_image;
  
  PFont fontA;
  
  Terrain(int new_num, float new_BWD) {

    NUM = new_num;
    BWD = new_BWD;
    
    parent = null;
    
    makeTerrain(); 
    
    if (NUM >= 9) {
      child = new Terrain(this);
    } else {
      child = null;
    }
   
    findPDist(); 
  }
    
  void findPDist() 
  {
    int top_count =0;
    Terrain tmp = parent;
    while (tmp != null) {
      top_count++;
      tmp = tmp.parent;
    }
    
    int bot_count = 0;
    tmp = child;
    while (tmp != null) {
      bot_count++;
      tmp = tmp.child;
    }
    
    p_dist = (float)bot_count/(float)(top_count + bot_count);
    p_dist = 1.0 - (1.0 - p_dist)*(1.0- p_dist);
    println(NUM + " p_dist " + p_dist);
    
  }
  
  void makeTerrain()
  {
    elev_image = loadImage("map_elev.png");
    
    NUM = elev_image.width;
    
    type_image = loadImage("map_type.png");
    
    println("new terrain " + NUM + " " + BWD);
    // TBD error check
    
    elev = new float[NUM][NUM];
    type = new int[NUM][NUM];
  
    float nsc1 = 0.05;
    for (int i = 0; i < NUM; i++) {
    for (int j = 0; j < NUM; j++) {
      color cl = elev_image.pixels[i*NUM+j];
       elev[i][j] = (red(cl) + blue(cl)/256.0 + green(cl)/(256.0*256.0))*BWD/8;
       
       type[i][j] = (int)brightness(type_image.pixels[i*NUM+j]);
       //if (i==0) println(type[i][j]);
    }
    }
  
  }  // makeTerrain
  
  Terrain(Terrain new_parent) {
    parent = new_parent;
    
    NUM = parent.NUM/3;
    BWD = parent.BWD*3;
    
    elev = new float[NUM][NUM];
    type = new int[NUM][NUM];
    
    for (int i = 0; i < NUM; i++) {
    for (int j = 0; j < NUM; j++) {
       float sum = 0; 
       for (int is = -1; is <= 1; is++) {
       for (int js = -1; js <= 1; js++) {
         
         // use maximum
         float cur_elev = parent.getElev(i*3 + is, j*3 + js);
         int cur_type = parent.getType(i*3 + is, j*3 + js);
         if (cur_elev > sum) {
           sum = cur_elev;
           // take the type of the highest location
           // TBD could also do some kind of voting
           type[i][j] = cur_type;
         }
         //sum += parent.getElev(i*3 + is, j*3 + js);
       }}
       
       // simple average
       //sum /= 9;
       
       elev[i][j] = sum;
    }}
    
    if (NUM >= 9) {
      child = new Terrain(this);
    }
    
    findPDist();
  }
  
  int getType(int i_loc, int j_loc) {
    
    if ((i_loc >= 0) && (i_loc < NUM) && (j_loc >= 0) && (j_loc < NUM)) {
      return type[i_loc][j_loc];
    }
    
    return 0;
    
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
    /// the outer boundary to draw
    int i_min, int j_min,
    int i_max, int j_max,
    /// the inner boundary not to draw
    int i_in_min, int j_in_min,
    int i_in_max, int j_in_max)
{

  
  if (child != null) {
    pushMatrix();
    translate(BWD, 0, BWD);
    
    int r_i = 3*((i_loc/3)/3);
    int r_j = 3*((j_loc/3)/3);
    
    child.draw(r_i, r_j, 
         r_i - 18, r_j - 18, 
         r_i + 18, r_j + 18, 
         i_min/3, j_min/3,
         i_max/3, j_max/3
        );
    

    
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

      //if (parent == null) {
        if (type[i][j] == 1) {
          // dirt
          color dirt = color(255,200,0);
          color col = color(
            red(dirt) * p_dist   + red(sky_col) * (1.0 - p_dist),
            green(dirt) * p_dist + green(sky_col) * (1.0 - p_dist),
            blue(dirt) * p_dist  + blue(sky_col) * (1.0 - p_dist)
            );
         // println(red(dirt) * p_dist + "   " + p_dist);
          fill(col);
        } else if (type[i][j] == 2) {
          // snow
          color dirt = color(225,225,225);
          color col = color(
            red(dirt) * p_dist   + red(sky_col) * (1.0 - p_dist),
            green(dirt) * p_dist + green(sky_col) * (1.0 - p_dist),
            blue(dirt) * p_dist  + blue(sky_col) * (1.0 - p_dist)
            );
         // println(red(dirt) * p_dist + "   " + p_dist);
          fill(col);
        } else if (type[i][j] == 3) {
          // road
          color dirt = color(120,120,120);
          color col = color(
            red(dirt) * p_dist   + red(sky_col) * (1.0 - p_dist),
            green(dirt) * p_dist + green(sky_col) * (1.0 - p_dist),
            blue(dirt) * p_dist  + blue(sky_col) * (1.0 - p_dist)
            );
         // println(red(dirt) * p_dist + "   " + p_dist);
          fill(col);
        } else if (type[i][j] == 0) {
         
               // grass
          color dirt = color(10,150,0);;
          color col = color(
            red(dirt) * p_dist   + red(sky_col) * (1.0 - p_dist),
            green(dirt) * p_dist + green(sky_col) * (1.0 - p_dist),
            blue(dirt) * p_dist  + blue(sky_col) * (1.0 - p_dist)
            );
         // println(red(dirt) * p_dist + "   " + p_dist);
          fill(col);
        } 
        
      //}
      
      if ( (parent == null) && (mdist < 3) ) {
        //stroke(0);
        if (type[i][j] == 0) {
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
         
        if ((parent == null) && (mdist < 6)) {
          if (type[i][j] == 0) {
            drawGrass(5, i, j); 
          }
          
        }
        
        //stroke(0);
        //strokeWeight(1);
        noStroke();
        float y_sc = 3;
        translate(0, y_sc*sc * BWD, 0);
        box(sc*BWD, sc*2*y_sc*BWD, sc*BWD);
      
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
  
  sky_col = color(10,100,200);
  frameRate(1.0/dt);
  
  fontA = loadFont("Courier10PitchBT-Roman-36.vlw");
  textFont(fontA, 16);
  
  int NUM = (int)pow(3,6);
  
  player = new Car(new PVector(BWD*NUM/2, BWD*2, BWD*NUM/2));
  
  npcs = new Car[20];
  for (int i = 0; i < npcs.length; i++) {
    npcs[i] = new Car(new PVector(BWD*(NUM/2+i), BWD*2, BWD*NUM/2));
  }
  
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
  
  background(sky_col);//;
  ambientLight(50, 50, 50);
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
  int i_loc = player.getI();
  int j_loc = player.getJ();

  rotateY(-player.rot);
  
  if (!pause) {   
    player.update();
    
    for (int i = 0; i < npcs.length; i++) {
      if ((noise(t/100.0, i*10) > 0.3)) {
        npcs[i].gas = true;
        
        float turn_f = noise(t/1000.0 + 1000, i*10+ npcs.length);
        if (turn_f < 0.3) {
           npcs[i].turn_right = true;
           npcs[i].turn_left = false;
        }
        else if (turn_f > 0.7) {
          npcs[i].turn_left =true;
           npcs[i].turn_right =false;
        }
      }
      npcs[i].update();
    }
  }
  
  //translate(-player.xyz.x, player.xyz.y, -player.xyz.z);
  translate(-player.xyz.x, player.xyz.y, -player.xyz.z);
  
  
  for (int i = 0; i < npcs.length; i++) {
    pushMatrix();
    translate(npcs[i].xyz.x, -npcs[i].xyz.y, npcs[i].xyz.z);
      npcs[i].draw();
      popMatrix();
  }
  //translate(-x*cos(rot) -z*sin(rot),
  //          BWD + y, 
  //           x*sin(rot) -z*cos(rot));
  
 int r_i = 3*(i_loc/3);
 int r_j = 3*(j_loc/3);
 int draw_dist = 21;
 terrain.draw(i_loc, j_loc, 
         r_i - draw_dist, r_j - draw_dist, 
         r_i + draw_dist, r_j + draw_dist, 
         i_loc, j_loc,
         i_loc, j_loc);
    
    
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
