/**
 * Sine. 
 * 
 * Smoothly scaling size with the sin() function. 
 * 
 * Updated 21 August 2002
 */
 
float spin = 0.0; 
float diameter = 84.0; 
float angle;

float angle_rot; 
int rad_points = 90;

float dt = 1.0/20.0;

class target {
 float x,y;
 float vx,vy;
 
   float acc_max = 100;


float clip(float val, float maxval)
{
 if (val > 0) val = min(val, maxval);
 if (val < 0) val = max(val, -maxval);
  
  return val;
}


void accel(float accx, float accy) 
{
  

    accx = clip(accx, acc_max);
    accy = clip(accy, acc_max);

 
  vx += accx*dt;
  vy += accy*dt;

  x += vx*dt;
  y += vy*dt;
  
  if (x < 0) x = width;
  if (y < 0) y = height;
  if (x > width) x = 0;
  if (y > height) y = 0;
  //x %= width;
 // y %= height;
 
}
  
}

class vehicle extends target {
 
  
  
  float kp = 0.05;
  float kd = 10.0;
  float ki;
  
  float old_ex, old_ey;
  
  void follow(target tgt) 
  {
    float ex = tgt.x - x;
    float ey = tgt.y - y;
    
    float dex = ex-old_ex;
    float dey = ey- old_ey;
    
    accel(ex*kp + dex*kd , ey*kp + dey*kd); 
 
    old_ex = ex;
    old_ey = ey;   
  }
   
}  
   
vehicle chaser;
target tgt;

void setup() 
{
  size(400, 400);
  noStroke();
  smooth();
  
  tgt = new target();
  tgt.x = width/2;
  tgt.y = height/2;
  chaser = new vehicle();
  chaser.acc_max = 300.0;
  
  frameRate(1/dt);
}

int i;
void draw() 
{ 
 // background(153);
 
 i += 1;
 if (i == 10) {
   i = 0;
  fill(50,50,50,1);
  rect(0,0,width,height);
 }
 
  float m = 250;
  
  chaser.follow(tgt);
  tgt.accel(random(-m,m), random(-m,m));

  fill(255,250,250,220);
  stroke(0,0,0,50);

  rect(tgt.x-5, tgt.y-5, 10, 10);
  
  
    fill(50,250,250,250);
  stroke(100,100,100,30);
  rect(chaser.x-5, chaser.y-5, 10, 10);
  

}

