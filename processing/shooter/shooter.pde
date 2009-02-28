
 import processing.opengl.*;
 
 import javax.media.opengl.*;

float t = 0.0;

class missile {
  
  float x,y;
  float vx,vy;
  float angle;
  
  int timer = 10;
  boolean active;

  void update() {
  
    if (active) {
    x += vx;
    y += vy;
    
    timer--;
    
    if (timer <=0) {
      
      image(blast,x-15,y-15,30,30);
       for (int i = 0; i < allShips.length; i++) {
         
         if (dist(x,y, allShips[i].x, allShips[i].y )  < 40) {
           allShips[i].crashing = true; 
           
           
         }
       }
      
      active = false;
      x = 0;
      y = 0;
      // explode
    }
    }
  }
  
  void draw() {
    
    if (active) {
    pushMatrix();
    translate(x,y);
    
    rotate(angle);
    
    rect(0,0,10,3);
    
    popMatrix();
    }
    
  }
  
};

class launcher {
  
  float x,y;
  float angle;
  
  int timer;
  
  void update(int targetX, int targetY) {
    angle = atan2(targetY-y, targetX-x);
    
    /*
    if (angle > 2*PI*0.9) {
      
      // angle = 2*PI*0.9; 
    } else if (angle < PI*0.1) {
      
      // angle = PI*0.1; 
    }
    */
    
    timer--;
  }
  
  void draw() {
    
    pushMatrix();
    translate(x,y);
    
    pushMatrix();
    float sc = 3;
      //image(launcherIm2, 0,-10,launcherIm2.width*sc, launcherIm2.height*sc);
    
    rotate(angle);
    
    //rect(0,0,15,3);
    
    
    image(launcherIm, -launcherIm.width*sc/4.0, -launcherIm.height*sc/2.0,launcherIm.width*sc, launcherIm.height*sc);
        popMatrix();
    
    image(launcherIm2, -launcherIm2.width*sc/2.0, -20 ,launcherIm2.width*sc, launcherIm2.height*sc);
    
    popMatrix();
    
    
  }
};

///////////////////////////////////////
class ship {
  
  PImage gfc;
  
  float x,y;
  
  float vx,vy;
  float angle;
  
  boolean active = true;
  
  boolean crashing = false;
  
  ship(String filename) {
    gfc = loadImage(filename);
    
    vx = 4;
  }
  
  void update() {
    
    if (active) {
    
    vx += (noise(x*0.001,y*0.001,t) - 0.5)*0.1;
    vy += (noise(x*0.01, y*0.01,t) - 0.5)*0.1;
    x += vx;
    
    y += vy;
    
    if (crashing) {
       vy += 0.5; 
      
    }
    
    if (vx < 0.7) vx = 0.7;
    
    if (x > (width + gfc.width)) {
      x = -3*gfc.width;
    }
    
    if (!crashing && (y > (height - 90))) {
       
       vy = -abs(vy); 
      
    }
    
    if (y > height) {
      active = false; 
    }
    
    if (y < -2*gfc.height) {
      vy = abs(vy); 
    }
    
    }
  }
  
  void draw() {
   
   if (active) {
    float sc = 5;
    image(gfc,x- gfc.width*sc/2,y - gfc.height*sc/2, gfc.width*sc,gfc.height*sc);
    
    if (crashing) {
      image(blast,x- gfc.width*sc/2,y - gfc.height*sc/2, gfc.width*sc,gfc.height*sc);
    }
   }
  }
  
}

//////////////////////////////////////////////////////////

ship allShips[];

launcher allLaunchers[];

missile allMissiles[];

PImage bgtex;
PImage blast;
PImage launcherIm;
PImage launcherIm2;
float posx; 

void updateBgtex() {
 
  posx += 0.4;
  
 for (int j = 0; j < bgtex.height; j++) {
 for (int i = 0; i < bgtex.width; i++) {
    
    int pixind = j*bgtex.width+i;
    
    if ( j > (bgtex.height -noise( (i+posx*2)*0.1 )*20 ) ) {
       bgtex.pixels[pixind] = color(15,185,15); 
    } else {
    
    float f = noise((i+posx)*0.1, j*0.3, t*0.0);
    if (f > 0.65)
     bgtex.pixels[pixind] = color(255,255,255); 
   else if ( f > 0.6)
    bgtex.pixels[pixind] = color(195,195,255);
   else if ( f > 0.55)
    bgtex.pixels[pixind] = color(155,155,255);
   else
     bgtex.pixels[pixind] = color(100,100,255);
    
    }
    
  }} 
  
  bgtex.updatePixels();
}

void setup() {
  
  frameRate(30);
  size(800,600,OPENGL);
  
  blast = loadImage("blast.png");
  
  launcherIm = loadImage("launcher.png");
  launcherIm2 = loadImage("launcher2.png");
  
  bgtex = createImage((int)(width/15),(int)(height/15),RGB);
  
  allShips = new ship[20];
  
  for (int i = 0; i < allShips.length; i++) {
     allShips[i] = new ship("ship.png");
    
     allShips[i].x = random(0,width);
     allShips[i].y = random(0,height);
     
  }
  
  allLaunchers = new launcher[3];
  allMissiles = new missile[allLaunchers.length];
  
   for (int i = 0; i < allLaunchers.length; i++) {
     allLaunchers[i] = new launcher();
    
     allLaunchers[i].x = random(0,width);
     allLaunchers[i].y = height -5;//random(height-height/10,height);
     
     allLaunchers[i].angle = random(0,2*PI);
       
     allMissiles[i] = new missile();
  }


}


void draw() {
  t+= 0.01;
  //background(100,100,250); 
  updateBgtex();
  image(bgtex,0,0,width,height);
  
  for (int i = 0; i < allShips.length; i++) {
     allShips[i].update();
    allShips[i].draw();
  }
  
  
  
    for (int i = 0; i < allLaunchers.length; i++) {
      
      allLaunchers[i].update(mouseX,mouseY);
      allLaunchers[i].draw();
      
      
      
      if (!allMissiles[i].active && mousePressed) {
        
        allMissiles[i].active = true;
        
        allMissiles[i].x = allLaunchers[i].x;
        allMissiles[i].y = allLaunchers[i].y;
        
        allMissiles[i].angle = allLaunchers[i].angle;
        
        float d = dist(mouseX,mouseY,(int)allLaunchers[i].x, (int)allLaunchers[i].y);
        
        /// missile velocity is 5 pixels/update
        float misV = 8;
        
        allMissiles[i].timer = (int) ( d/misV );
        allMissiles[i].vx = misV*cos(allMissiles[i].angle);
        allMissiles[i].vy = misV*sin(allMissiles[i].angle);
      }
      
        allMissiles[i].update();
      allMissiles[i].draw();
    }
}





