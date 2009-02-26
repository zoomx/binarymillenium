
import processing.net.*;

boolean use_saved = true;

 boolean use_texture = false;
 boolean tree_like = true;
boolean use_lateral =false;
boolean all_lateral = false;



final int COUNT_DIV = 10;
int ind = 1000;
 float range = 5.0;


final int numParticles = 20;

float t = 0.0;
 float div = 30.0;

class MarkerInfo {
  float cf;
  int id;
  float area;
  float x;
  float y;
  float x1;
  float y1;
  
  float oldx;
  float oldy;
  
  /// ticks since last update
  int count;
  int oldCount;
}


class particle {
  
  boolean rev = false;
   
  float sz = 10;
  float x;
  float y;  
  
  float old_x;
  float old_y;
  
  int counter;
  
  boolean lateral;
  
  color c;
  
  float x_seed;
 
  final float mv = 10.0;
  
  static final float max_counter = 150;
  
  ///////////////////////////////////
  void draw() {
    
   // if (lateral) {
     if (sz >25) {
      stroke(0,50); } else {
      stroke(c);
      } 
   // else {
   //   stroke(255);
   // }
      fill(c);
      
     rect(x,y,sz,sz);
   // line(x,y,old_x,old_y);
  //  rect(x,y,abs( x-old_x), abs(y-old_y));
    
   // int randp = int(noise(x,y,t)*numParticles-1);// int(random(0,numParticles-1));
    
   // line(x,y,particles[randp].x,particles[randp].y);
     
     
   //rect(x,y,2,2);  
  }
  
  void update() {
    
    
    
    counter++;
    
    if (false) {
    if (counter > max_counter) {
      /*if (tree_like) {
        final float ext = width/2;
        x+= random(-ext,ext);
        y+= random(-ext,ext);
        counter = 0;
      } else */{
        new_pos();
      }
        
    }
    
    }
    
    old_x = x;
    old_y = y;

    float r = rev ? -1.0 : 1.0;
     float a = r*mv*(noise(x/div,y/div,t) - 0.5);
     float b = r*mv*(noise(width + x/div,y/div,t) - 0.5);   
    x += lateral ? a : -b;
    y += lateral ? b : a;
  }
  
  void new_pos() {
   
        //if (random(1) > 0.5) lateral = true;
        if (use_lateral) lateral = !lateral;
       else {
       if (all_lateral) lateral = true;
        else lateral = false;
       }
        counter = 0;
          
          
         if (tree_like) {
           /*
            x = random(width); //x_seed +random(width/20);
             y = height; 
             */
             x = random(width);
             y = random(height);
           
         } else {
           int sel = (int)(random(4)%4);    
         
       
          if (sel == 0) {
             x = random(width);
             y = 0;    
          } else if (sel == 1) {
             x = random(width);
             y = height;    
          } else if (sel == 2) {
             x = 0;
             y = random(height);
          } else if (sel == 3) {
            x = width;
            y = random(height);
          }
          
         }
          
          old_x = x;
          old_y = y;
          
               float c1 = x/width*255;
      float g = y/height*255;
      float b = random(255);
      //if (random(1) > 0.9)c1 = 0;
      
     // c = color(c1,g,lateral? b : 255-b, 45+random(35));
     c = color(0,0,0,0);
      if (use_texture)  c = color(c1,g,b,10+random(90));
         
  }
  
  particle() {
    
    x_seed = width/4 + random(width/2);
     new_pos();
     
 
  }
  
  void test_respawn() {
    final float f = 0.1;
    if ((x > width*(1.0+f))  || (x < -width*f) || 
        (y > height*(1.0+f)) || (y < -height*f) ) {
          
          new_pos();

        }  
  }
  
};
/////////////////////////////////////////////////

MarkerInfo[] markerInfos = new MarkerInfo[0];

final int numMarkers = 4;
MarkerInfo[] dbInfos = new MarkerInfo[numMarkers];


particle[] particles = new particle[numParticles];

boolean have_info = false;

Client cli;

void setup() {
  
  cli = new Client(this, "127.0.0.1", 5601);
  
  //size(1280,720);
  size(400,400);
  
  for (int i = 0; i< dbInfos.length; i++) {
    
 
    
    dbInfos[i] = new MarkerInfo();
  }
  
  for (int i = 0; i< particles.length; i++) {
     particles[i] = new particle();  

    particles[i].x = width/2;
    particles[i].y = height/2; 
     //ps[i].counter = (int)random(particle.max_counter);
  }
  



background(255);

}

////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


int newCounter = 0;

void draw() {
  
    int num = cli.available();
  if (num > 0) {
    println("client: num " + num);
  }
  
  //background(0);
  fill(255,150);
  rect(0,0,width,height);
  
  newCounter++;
  if (newCounter > COUNT_DIV) {
    

  newCounter = 0;
  }
  

  //noStroke();
  
  for (int i = 0; i < dbInfos.length; i++) {
   dbInfos[i].count++;
  }
  
  if (have_info) {

    
    for (int i = 0; i < markerInfos.length; i++) {
      
          
       
      if (markerInfos[i].cf > 0.4 ){// && markerInfos[i].id >= 0 ) { 
        
        int newId = markerInfos[i].id;
        if ((newId >= 0) && (newId < numMarkers)) {
          
          /// TBD deep copy?
          dbInfos[newId].oldx = dbInfos[newId].x;
          dbInfos[newId].oldy = dbInfos[newId].y;  
          
          dbInfos[newId].x = markerInfos[i].x; 
          dbInfos[newId].y = markerInfos[i].y;
          
          dbInfos[newId].x1 = markerInfos[i].x1; 
          dbInfos[newId].y1 = markerInfos[i].y1;
          
          if (dbInfos[newId].count > 0) 
            dbInfos[newId].oldCount = dbInfos[newId].count;
          else 
            dbInfos[newId].oldCount = 1;
            
          dbInfos[newId].count = 0;
        }
        /*
        fill(markerInfos[i].id/3.0*255, markerInfos[i].cf*255,255,128+markerInfos[i].cf*127);      
        rect(width*markerInfos[i].x, height*markerInfos[i].y,10,10);
        */
      }
    }
  }
  
  
  t+= 0.001;
  
  
  
  for (int i = 0; i < dbInfos.length; i++) {
    
     float angle = atan2(dbInfos[i].x1-dbInfos[i].x,
                         dbInfos[i].y1-dbInfos[i].y);
     angle = (angle+PI)/(2*PI);
     //println(angle);
               
               
     for (int j = 0; j < dbInfos.length; j++) {
         
        if (dbInfos[i].count == 0) {
          if (dbInfos[j].count == 0) {
            /// restart a bunch of particles
            for (int k = 0; k < numParticles/15; k++) {
               float f = random(0.0,1.0);
               
               //f *= f;
           
               float newx = dbInfos[i].x + (dbInfos[j].x - dbInfos[i].x)*f;
               float newy = dbInfos[i].y + (dbInfos[j].y - dbInfos[i].y)*f;
               
               int randParticleInd = int(random(0,numParticles-1));
              
               particles[randParticleInd].x = newx*width  + random(-range,range);
               particles[randParticleInd].y = newy*height + random(-range,range);
               
               float cf = (float)i/(float)dbInfos.length;
               
               
 
               
               if (random(0.0,1.0) > 0.1)
                 particles[randParticleInd].c = color(cf*255, (1.0-cf)*255, 255*angle,30);
               else 
                 particles[randParticleInd].c = color(0,0,0,30);
                 
               
               
               particles[randParticleInd].sz = (1.0-f)*(1.0-f)*(1.0-f) * 30;
               particles[randParticleInd].lateral = !particles[randParticleInd].lateral;
               particles[randParticleInd].rev = !particles[randParticleInd].rev;
               
            }
          }
        } 
        
   
     }
     
     
 
  }
  
if (true) {
  for (int i = 0; i< numParticles; i++) {
     particles[i].update();
     particles[i].draw();
   /*  particles[i].update();
      particles[i].draw();
     particles[i].update();
     particles[i].draw();
     particles[i].update();
      particles[i].draw();*/
      
   //ps[i].test_respawn(); 
  }
  }
  
  
   
   if (false) {
  for (int i = 1; i < dbInfos.length; i++) {
        fill(255,20);
        if (dbInfos[i].count == 0) {
          fill(255,0,0);
        } else {
           fill(0,255,0); 
        }
        //rect(dbInfos[i].x*width, (dbInfos[i].y)*height, 10,10);
        //rect(dbInfos[i].x, (dbInfos[i].y), 10,10);
       // println(i + "  " + dbInfos[i].x + " " + dbInfos[i].y );
  }
   }
  
    
    

    
 // saveFrame("frames/splotch#####.png");

}
  
 
