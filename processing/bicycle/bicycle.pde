// Lucas Walter 2012
// GNU GPL 3.0
int NUM_CARS=1;
float world_y = 500; //500; //1080;
float world_x = 500; // 400; //1920;

void drawRotatedRect(float x, float y, float wd, float ht, float angle, float x_off, float y_off, float angle2)
{
  pushMatrix();
  translate(x,y);
  rotate(-angle);
  translate(x_off,y_off);
  rotate(-angle2);
  rect(-wd/2, -ht/2, wd, ht);
  
  popMatrix();
  return;
  /*
  float ca2 = cos(angle2);
  float sa2 = sin(angle2);
  float dx =  x_off*ca2 + y_off*sa2;
  float dy = -x_off*sa2 + y_off*ca2;
  
    float ca = cos(angle);
    float sa = sin(angle);

    quad(x + ( wd/2)*ca + ht/2*sa + dx, y + (-wd/2)*sa + ht/2*ca + dy,
         x + ( wd/2)*ca - ht/2*sa + dx, y + (-wd/2)*sa - ht/2*ca + dy,
         x + (-wd/2)*ca - ht/2*sa + dx, y + ( wd/2)*sa - ht/2*ca + dy,
         x + (-wd/2)*ca + ht/2*sa + dx, y + ( wd/2)*sa + ht/2*ca + dy);
    */
}

class Car {
  float x;
  float y;
  float orientation;
  
  float steering_angle;
  float forward_vel;
  
  float xc;
  float yc;
  
  int wd;
  int ht;
  //float old_x;
  //float old_y;
  
  float steer_noise_offset;
  
  Car(float x, float y) {
    this.x = x;
    this.y = y; 
    wd = 36;
    ht = 64;
    
    orientation = 0;
    
    steering_angle = 0;
    
    steer_noise_offset = 0;
  }
  
  void move(float steering_delta, float forward_acc) 
  {
    steering_angle += steering_delta;
    
    forward_vel += forward_acc;
    
    if (forward_vel > ht/13.0) {forward_vel = ht/13.0;}
    if (forward_vel < 0) { forward_vel = 0; }
    
    if (steering_angle > PI/4) {
      steering_angle = PI/4;
      steer_noise_offset = random(10000); 
    }
    if (steering_angle < -PI/4) { 
      steering_angle = -PI/4; 
      steer_noise_offset = random(10000);
    }
        
    float xp = x + forward_vel * cos(-orientation);
    float yp = y + forward_vel * sin(-orientation);
    float orientationp = orientation;
       
    xc = x;
    yc = y;
    
    if (abs(steering_angle) > 0.15) {
            float r = ht/tan(steering_angle);
        
            xc = x - r * cos (-orientation - PI/2.0);
            yc = y - r * sin (-orientation - PI/2.0);
        
            float psi = forward_vel/r;
        
            xp = xc + r * cos(-orientation - PI/2.0 + psi);
            yp = yc + r * sin(-orientation - PI/2.0 + psi);
            
            orientationp = orientation + psi;
            
            orientationp %= 2*PI;        
            
            // TBD the xc, yc above are in wrong direction but motion comes out okay
            xc = x + r * cos (-orientation - PI/2.0);
            yc = y + r * sin (-orientation - PI/2.0);
      }
      
      x = xp;
      y = yp;
      orientation = orientationp;
      
    if (y >= world_y) {
      y -= world_y; 
    }
    if (y < 0) {
      y += world_y; 
    }
    
    if (x >= world_x) {
      x -= world_x; 
    }
    if (x < 0) {
      x += world_x; 
    }
      
                 
  }
  
  void draw() {
    
    
    fill(255, 175, 10,150);
//    noStroke();
    stroke(0,15);
    
    drawRotatedRect(x,y, ht,wd, orientation,0,0,0);

    // draw tires    
    fill(225, 255,225,255);
    stroke(0,25);
    
    // rear tires
    drawRotatedRect(x,y, ht/4, wd/4, orientation , -ht/2, -wd/2, 0);    
    drawRotatedRect(x,y, ht/4, wd/4, orientation , -ht/2,  wd/2, 0); 
    
    // steering tires
    drawRotatedRect(x,y, ht/4, wd/4, orientation , ht/2, -wd/2, steering_angle);    
    drawRotatedRect(x,y, ht/4, wd/4, orientation , ht/2,  wd/2, steering_angle);    
    
    stroke(255,100,0);
    ellipse(xc,yc, 3,3);
    stroke(205,0,30);
    line(x,y, xc,yc);
    //rect(offx+x-wd/2,offy+y-ht/2, wd,ht); 
  }
  
};

ArrayList cars;

void setup() {
   size(int(world_x),int(world_y));
  
  background(0);
  
  cars = new ArrayList();
 
  for (int i = 0; i < NUM_CARS; i++) {
      cars.add(new Car( world_x/4.0 + random(world_x/2.0), world_y/4.0 + random(world_y/2.0)));
  }
  
  frameRate(25);
}

float t = 0;

void update() {
  t+= 0.001;
    for (int i = cars.size()-1; i >= 0; i--) {
      Car car = (Car) cars.get(i);
      
      float steer_acc = noise(t*25.0 + i * 10.0 + car.steer_noise_offset) -0.3;
      float forward_acc = noise(t + i * 100.0 +10000) - 0.5;
      //println(i + " " + steer_acc + " " + forward_acc);
      steer_acc /= 2.0;
      forward_acc /= 5.0;
      car.move(steer_acc, forward_acc);
    }
}

void draw() {
  fill(0, 0, 10, 4);
  rect(0,0,width,height);
  loadPixels();
  
   update();
   
    for (int i = cars.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so we have to cast the object coming out
    Car car = (Car) cars.get(i);
    
    car.draw();
    }
  
  //saveFrame("highwayr#####.png"); 
}


