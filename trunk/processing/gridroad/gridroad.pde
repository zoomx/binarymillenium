
/**
 Lucas Walter
 
 June 2012
 
 GPL 3.0
*/

//import processing.opengl.*;

import java.util.Stack;

Stack<Float> cx = new Stack<Float>();
Stack<Float> cy = new Stack<Float>();
Stack<Float> cz = new Stack<Float>();

float BWD = 100.0;
int NUM = 1500;

float dt = 0.1;

float[][] elev;//[NUM][NUM];

PImage img;  


float x = BWD*NUM/2;
float y;
float z = BWD*3*NUM/4;
float rot;

HashMap roads;


void makeRoads()
{
  roads = new HashMap();
  
  int i_loc = (int)((z+BWD/2.0)/BWD );
  int j_loc = (int)((x+BWD/2.0)/BWD );
  
  for (int i = 0; i < NUM*(NUM/50+1); i++) {
    int loc = i_loc*NUM + j_loc;
  
    roads.put(loc, true);
  
    int choice = (int) ( noise(i_loc, j_loc)*4 );
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

void setup()
{
  //size(800, 800, OPENGL);
  size(600, 400, P3D);
  frameRate(1.0/dt);
  
  makeRoads();
  
  elev = new float[NUM][NUM];
  
  float nsc1 = 0.05;
  for (int i = 0; i < NUM; i++) {
    for (int j = 0; j < NUM; j++) {
      //elev[i][j] = -0.2*(i*j);
      float hills = (noise(100+i*nsc1,10+j*nsc1)-0.5);
      if (hills < 0.0) hills = 0;
      hills *= 10*BWD;
      elev[i][j] = 1*BWD*(noise(i*nsc1,j*nsc1)-0.5) + hills - 5*BWD;
    }
  }
  
  img = createImage(10, 10, RGB);
  img.loadPixels();
  for (int i = 0; i < img.width; i++) {
    for (int j = 0; j < img.height; j++) {
      img.pixels[i * img.height + j] = color(12, 120 + 80 * noise(i/10.0,j/10.0), 11); 
  }}
  
  img.updatePixels();

 
}


float y_off;

float yvel;
float xvel, zvel;
float rot_vel;

float rotx = -PI/8;
boolean ground_contact = false;
boolean pause= false;

void keyPressed()
{
  float sc = BWD/170.0;
  
  if (ground_contact) {
  if (key == 'w') {
    zvel -= sc*1;
  }
  if (key == 's') {
    zvel += sc*0.5;
  }  
  if (key == 'a') {
    xvel -= sc*0.25;
  }
  if (key == 'd') {
    xvel += sc*0.25;
  }  
  if (key == 'q') {
    yvel += sc*15;
  }
  if (key == 'z') {
    yvel -= sc*15;
  }  
  }
  
  if (key== 'j') {
     rot_vel += 0.04; 
  }
  
  if (key == 'l') {
     rot_vel -= 0.04; 
  }
  
  if (key == 'p') {
     pause = !pause; 
  }
  
  if (key == 'i') {
     rotx += 0.1; 
     
     if (rotx > PI/2) { rotx = PI/2; }
  }
  
  if (key == 'k'){
     rotx -= 0.1; 
     
     if (rotx < -PI/2) { rotx = -PI/2; }
  }
}

void drawCar(float SZ)
{
  strokeWeight(10);
  stroke(0);
  
  pushMatrix();
  //translate(0,BWD*0.5, 0 );
  translate(0,-SZ/8, 0 );
  
  fill(200);
  pushMatrix();
  box(SZ/2.5, SZ/8, SZ/2);
  translate(0,-SZ/8, 0 );
  box(SZ/2.5, SZ/8, SZ/5);
  popMatrix();
 
 // draw four wheels
  fill(10);
  translate(0,SZ/10, SZ*0.23 );
  
  noStroke();
  
  // back wheels
  float tire_sz = SZ/16;
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
}

int  count = 0;
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
  float car_sz = 15;
  translate(0, car_sz/2, 0);//car_sz*2 );
  
  rotateX(rotx);
    
  drawCar(car_sz);
  


  // get current position on map
  int i_loc = (int)((z+BWD/2.0)/BWD );
  int j_loc = (int)((x+BWD/2.0)/BWD );

  
  y_off = 0;
  
  /*
  i_loc %= NUM;
  j_loc %= NUM;
  
  if (j_loc < 0) j_loc+= NUM;
  if (i_loc < 0) i_loc+= NUM;
  */
  
  //println(i_loc + " " + j_loc);

  
  if ((i_loc >= 0) && (i_loc < NUM) && (j_loc >= 0) && (j_loc < NUM)) {
   y_off = elev[i_loc][j_loc];
  }
  
  //println(x + ", x=" + j_loc + ", " + z + ", z=" + i_loc + ", y " + y + "," +  y_off);

  rotateY(-rot);
  
  
  if (!pause) {
  yvel *= 0.95;
  yvel -= 1.1;
  y += yvel;
  
  if (y < y_off) { 
    ground_contact = true;
    y = y_off; 
    yvel = 0; 
  } else {
    ground_contact = false; 
  }
  
  
  if (ground_contact) {
    xvel *= 0.6;
    zvel *= 0.6; 
    rot_vel *= 0.46;
  } else {
    xvel *= 0.95;
    zvel *= 0.95; 
    rot_vel *= 0.95;
  }
  
  x +=  xvel * cos(rot) + zvel * sin(rot);
  z += -xvel * sin(rot) + zvel * cos(rot);
  rot += rot_vel;
  }
  
  translate(-x, y, -z);

  //translate(-x*cos(rot) -z*sin(rot),
  //          BWD + y, 
  //           x*sin(rot) -z*cos(rot));
  
  
 
 drawTerrain(i_loc, j_loc);


// trails
if (false) {
  if ((cx.size() == 0 ) || (count %5 == 0)) {
  cx.push(x);
  cy.push(y);
  cz.push(z);
  }
 
  if (cx.size() > 100) {
    cx.pop();
    cy.pop();
    cz.pop();
  }
  

  //println(cx.size() + " " + cx.get(0));
  
    stroke(255,200,0);
    strokeWeight(10);
    
    int i =  0;
    for (i = 0; i < cx.size()-1; i++) {
      //println( str(cx.get(i)) + ' ' +  str(cy.get(i)) + ' ' + str(cz.get(i)) );
      line(cx.get(i) ,  -cy.get(i), cz.get(i), 
           cx.get(i+1), -cy.get(i+1),cz.get(i+1));
    }
    
    line(x,-y,z, cx.get(i), -cy.get(i), cz.get(i));
}
    
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

float t = 0;

//////////////////////////////////////////////
void drawGrass(int num, int i, int j)
{
   strokeWeight(3);
   stroke(24,125,10);
   
   float dx = 3.5*(noise(0.2*t + i/100.0)-0.5);
   float dz = 3.5*(noise(0.2*t + j/100.0)-0.5);
      
   for (int ind = 0; ind < num*2; ind++) {
      float x = 1.6 * BWD * (noise(i + ind)-0.5);
      float z = 1.6 * BWD * (noise(j + ind)-0.5);
          
      // TBD wind blowing effect here
      line(x , 0, z, x + dx, -2, z + dz);
   }
   
  fill(45,135,3);
  noStroke();
  for (float ind = 0; ind < 100.0; ind+= 1.0) {
    float x = 1.6*(float)BWD*(noise(0.1*i + ind + t/2000.0)-0.5);
    float z = 1.6*(float)BWD*(noise(0.1*j + ind + t/2000.0)-0.5);
    
    pushMatrix();
    translate(x,ind/100.0,z);    
    box(BWD/80);
    popMatrix();
  }
  noStroke(); 
}
////////////////////////////////////////////
void drawTerrain(int i_loc, int j_loc)
{
  
    
  fill(0,150,0);
   //stroke(50);

  int DRAW_NUM = 800;
  pushMatrix();
  noStroke();
  for (int i = i_loc- DRAW_NUM; i < i_loc + DRAW_NUM; i++) {
    //pushMatrix();
    for (int j = j_loc - DRAW_NUM; j < j_loc + DRAW_NUM; j++) {
      
      int loc = i*NUM + j;
      
      boolean is_road = roads.containsKey(loc);
      
      /*int j2 = j;
      int i2 = i;
      
      if (j2 < 0) j2+= NUM;
      if (i2 < 0) i2+= NUM;
      
      j2 = j2 % NUM;
      i2 = i2 % NUM;
      //if ((j2 < 0) || (i2 < 0)) {println(j2 + " " + i2);}
      translate(j*BWD, -elev[i2][j2], i*BWD);
      */
      
      if ((i < 0) || (j < 0) || (i >= NUM) || (j >= NUM)) {
        continue;  
      }
      
      float mdist = abs(i - i_loc) + abs(j - j_loc);
      
      
      float sc = 1.0;
      
      if (mdist > 400) {
        continue; 
      } 
      
      if (mdist > 100) {
        if (mdist % 64 != 0) {
          continue; 
        } 
        
        sc = 16;
        
      }
      if (mdist > 25) {
        if ( (mdist) % 8 != 0) {
        continue; 
        } 
        sc = 4;
      }
      if (mdist > 15) {
        if (mdist % 2 != 0) {
        continue; 
        }
        sc = 2;
      }
      
      pushMatrix();
       translate(j*BWD, -elev[i][j], i*BWD);

       
      if ( mdist < 3 ) {
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
        
        
        if (mdist < 6) {
          if (is_road) {
            fill(135);
          } else {
            fill(0,135,0);
            drawGrass(5, i, j); 
          }
          
        }
        
        translate(0,sc * BWD/2, 0);
        box(sc*BWD);
      
      }

      popMatrix();
      //translate(BWD,0,0);
    }
    //popMatrix();
    //translate(0,0,BWD);
    //translate(-10*20, 0, 10);
    
  }
  popMatrix();
}
