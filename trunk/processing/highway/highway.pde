float world_y = 500; //1080;
float world_x = 400; //1920;

int NUM_CARS = (int) (world_x*0.1);
float ymax = 1.0;
float xmax = ymax*0.2;
// y acceleration
float acc = 0.02;
float xacc = (acc - 1.0)/4.0; 
float xaccstep = 0.004;
float yaccstep = 0.005;
float ydec = 0.14; //0.88; 
int pix_thresh = 10;


// x and y are relative to the angle

// zero angle is facing straight down in +y
// turning right is a negative angle, left is a positive angle
// +x is to the left of the car, -x to the right
float testPixel(float cx, float cy, float rx, float ry, float angle) 
{
  // cos sin   x
  // -sin cos  y
  float x = cx + cos(angle)*rx + sin(angle)*ry;
  float y = cy - sin(angle)*rx + cos(angle)*ry;
  
  int yt = (int(y))%(int(world_y));
  int pix_ind = yt * (int(world_x)) + (int(x));
  
  while (pix_ind >= world_x * world_y) {
    pix_ind -= world_x * world_y; 
  }
  while (pix_ind < 0) {
    pix_ind += world_x * world_y; 
  }
  color val = pixels[pix_ind];
  
  if (red(val) > pix_thresh) {
    return  ((float)(red(val) - pix_thresh)/((255.0-pix_thresh)));
  }
  return 0.0;
}

class Car {
  float x;
  float y;
  // radial velocity
  float xvel;
  // forward velocity
  float yvel;
  
  float angle;
  float wd;
  float ht;
  
  Car(float x, float y) {
    this.x = x;
    this.y = y; 
    wd = 8;
    ht = 16;
    
    angle = 0;
    
    yvel = 0; //1.0;
  }
  
  void update() {
    x += sin(angle)*yvel;
    y += cos(angle)*yvel; 
    
    angle += xvel ;
   
    float fr = 0;
    // zero angle is facing straight down in +y
    // turning right is a negative angle, left is a positive angle
    // +x is to the left of the car, -x to the right
    
    ////////////
    fr = (testPixel(x,y, - wd, ht, angle)) ;
    yvel *= 1.0 - fr * ydec;
    xvel += fr * xaccstep ;
      
    fr = (testPixel(x,y, - wd*2, ht*2, angle)) ;
    yvel *= 1.0 - fr * ydec * 0.5;
    xvel += fr * xaccstep * 0.7;  
    
    fr = (testPixel(x,y, - wd*2, 0, angle)) ;
    xvel += fr * xaccstep * yvel/ymax * 0.5;  
    
    ///////////////////
    fr = (testPixel(x,y, wd, ht, angle));
    yvel *= 1.0 - fr*ydec; 
    xvel -= fr * xaccstep ;
    
    fr = (testPixel(x,y, wd*2, ht*2, angle));
    yvel *= 1.0 - fr*ydec * 0.5; 
    xvel -= fr * xaccstep  * 0.7;
  
    fr = (testPixel(x,y, wd*2, 0, angle));
    xvel -= fr * xaccstep * 0.5;
  
    ////////////////
    fr = (testPixel(x,y, 0 ,  ht*2, angle));
    yvel *= 1.0 - fr*ydec;
    
    fr = (testPixel(x,y, 0,  ht, angle));
    yvel *= 1.0 - fr*ydec;
    
    
    {
      yvel *= 1.0 + acc;
      yvel += yaccstep;
    }
    

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
    
  
    if (yvel > ymax) {
       yvel = ymax; 
    }
    if (yvel < -ymax) {
       yvel = -ymax; 
    }
    
    if (xvel > xmax) {
       xvel = xmax; 
    }
    if (xvel < -xmax) {
       xvel = -xmax; 
    }
    
    yvel *= 0.999; 
    xvel *= 0.99;
    xvel *= yvel/ymax;
  }
  
  void draw(float offx, float offy) {
     fill(60, 175, 10,20);
    noStroke();
    //rect(offx+x-wd,offy+y-ht, wd*2,ht*2); 
    fill(225, 255,225,125);
    stroke(128,15);
    
    float ca = cos(angle);
    float sa = sin(angle);
    //float dx =  wd/2*ca + ht/2*sa;
    //float dy = -wd/2*sa + ht/2*ca;
    quad(x + wd/2*ca + ht/2*sa, y -wd/2*sa + ht/2*ca,
         x + wd/2*ca - ht/2*sa, y -wd/2*sa - ht/2*ca,
         x - wd/2*ca - ht/2*sa, y +wd/2*sa - ht/2*ca,
         x - wd/2*ca + ht/2*sa, y +wd/2*sa + ht/2*ca);
    //rect(offx+x-wd/2,offy+y-ht/2, wd,ht); 
    
  }
};



ArrayList cars;

void setup() {
   size(int(world_x),int(world_y));
  
  background(0);
  
  cars = new ArrayList();
 
  for (int i = 0; i < NUM_CARS; i++) {
      cars.add(new Car(random(world_x), random(world_y)));
  }
}

void update() {
    for (int i = cars.size()-1; i >= 0; i--) {
      Car car = (Car) cars.get(i);
      car.update();
    }
}

void draw() {
  fill(0, 0, 10, 15);
  rect(0,0,width,height);
  loadPixels();
  
   update();
   
    for (int i = cars.size()-1; i >= 0; i--) { 
    // An ArrayList doesn't know what it is storing so we have to cast the object coming out
    Car car = (Car) cars.get(i);
    
    car.draw(0,0);
    }
  
  //saveFrame("highwayr#####.png"); 
}
