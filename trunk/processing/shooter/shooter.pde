
 import processing.opengl.*;
 
 import javax.media.opengl.*;

float t = 0.0;

class ship {
  
  PImage gfc;
  
  float x,y;
  
  float vx,vy;
  
  ship(String filename) {
    gfc = loadImage(filename);
    
    vx = 4;
  }
  
  void update() {
    
    vx += (noise(x*0.001,y*0.001,t) - 0.5)*0.1;
    vy += (noise(x*0.01, y*0.01,t) - 0.5)*0.1;
    x += vx;
    
    y += vy;
    
    if (vx < 0.5) vx = 0.5;
    
    if (x > (width + gfc.width)) {
      x = -3*gfc.width;
    }
    
    if (y > (height + 2*gfc.height)) {
       
       vy = -abs(vy); 
      
    }
    
    if (y < -2*gfc.height) {
      vy = abs(vy); 
    }
  }
  
  void draw() {
   
   //scale(100);
   
    image(gfc,x,y, gfc.width*5,gfc.width*5);
  }
  
}

ship allShips[];

void setup() {
  
 
  
  frameRate(30);
  size(600,600,OPENGL);
  
  allShips = new ship[20];
  
  for (int i = 0; i < allShips.length; i++) {
     allShips[i] = new ship("ship.png");
    
     allShips[i].x = random(0,width);
     allShips[i].y = random(0,height);
     
     
  }
  
}


void draw() {
  t+= 0.01;
  background(100,100,250); 
  
  for (int i = 0; i < allShips.length; i++) {
     allShips[i].update();
    allShips[i].draw();
  }
}





