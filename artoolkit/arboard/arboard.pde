
boolean use_saved = true;

 boolean use_texture = false;
 boolean tree_like = true;
boolean use_lateral =false;
boolean all_lateral = false;

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

final int numParticles = 800;

float t = 0.0;
 float div = 30.0;

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
 
  final float mv = 40.0;
  
  static final float max_counter = 150;
  
  ///////////////////////////////////
  void draw() {
    stroke(c);
      fill(c);
      
     // line(x,y,old_x,old_y);
     
     rect(x,y,sz,sz);
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
     c = color(255,255,255,60);
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



MarkerInfo[] markerInfos = new MarkerInfo[0];

final int numMarkers = 3;
MarkerInfo[] dbInfos = new MarkerInfo[numMarkers];


particle[] particles = new particle[numParticles];

boolean have_info = false;

void setup() {
  
  size(1280,720);
  
  for (int i = 0; i< dbInfos.length; i++) {
    
 
    
    dbInfos[i] = new MarkerInfo();
  }
  
  for (int i = 0; i< particles.length; i++) {
     particles[i] = new particle();  

    particles[i].x = width/2;
    particles[i].y = height/2; 
     //ps[i].counter = (int)random(particle.max_counter);
  }
  
 getImage();


background(0);

}

////////////////////////////////////////////////////

void printOutput(Process p) {
   
 BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream())); 
 String cmdout;
 
 if (true) {
 try {
 while ((cmdout = in.readLine()) != null) {
      println(cmdout);
    }
  }
catch(IOException e) {
   e.printStackTrace(); 
  }
 }
    
if (true) {
in = new BufferedReader(new InputStreamReader(p.getErrorStream())); 


try {
 while ((cmdout = in.readLine()) != null) {
      println(cmdout);
    }
}
catch(IOException e) {
   e.printStackTrace(); 
}
  
}

}

////////////////////////////////////////////////////////////

int ind = 1000;
void getImage() {
 /* String cmdCurl[] = {"curl", "http://192.168.1.57/now.jpg > " + 
                                sketchPath("") +"images/test.jpg"};
 Process p = exec(cmdCurl);
 
 printOutput(p);
 */
 
 
 Process p;
 if (use_saved) {
   ind++;
   String cmd[] = {sketchPath("") + "run2.sh", sketchPath(""), "" +ind};
   
   if (ind == 200) noLoop();
   p = exec(cmd);
 } else { 
   String cmd[] = {sketchPath("") + "run.sh", sketchPath("")};
    p = exec(cmd);
 }

BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream())); 

String cmdout;

markerInfos = new MarkerInfo[0];

try {
 while ((cmdout = in.readLine()) != null) {
      float[] temp = float(split(cmdout, ','));
      if (temp.length == 8) {
        
        MarkerInfo tempmi = new MarkerInfo();
        
        tempmi.area = temp[0];
        tempmi.id = int(temp[1]);
        tempmi.cf = temp[2];
        tempmi.x  = temp[3];
        tempmi.y  = temp[4];
        tempmi.x1 = temp[5];
        
        markerInfos = (MarkerInfo[])append(markerInfos, tempmi);
         
        have_info = true;
      }
    }
}
catch(IOException e) {
   e.printStackTrace(); 
}
    
if (true) {
  in = new BufferedReader(new InputStreamReader(p.getErrorStream())); 

  try {
    while ((cmdout = in.readLine()) != null) {
      println(cmdout);
    }
  }
  catch(IOException e) {
    e.printStackTrace(); 
  }
}


for (int i = 0; i < markerInfos.length-1; i++) {
  //print(marker_info[i] + "\t");
}
//print("\n");

}

/////////////////////////////////


int newCounter = 0;

void draw() {
  
  fill(0,55);
  rect(0,0,width,height);
  
  newCounter++;
  if (newCounter > 5) {
    
  getImage();
  newCounter = 0;
  }
  //noStroke();
  
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
  
  
  for (int i = 1; i < dbInfos.length; i++) {
    
     for (int j = 1; j < dbInfos.length; j++) {
         
        if (dbInfos[i].count == 0) {
          if (dbInfos[j].count == 0) {
            /// restart a bunch of particles
            for (int k = 0; k < numParticles/15; k++) {
               float f = random(0.0,1.0);
               
               //f *= f;
           
               float newx = dbInfos[i].x + (dbInfos[j].x - dbInfos[i].x)*f ;
               float newy = dbInfos[i].y + (dbInfos[j].y - dbInfos[i].y)*f;
               
               int randParticleInd = int(random(0,numParticles-1));
               float range = 30.0;
               particles[randParticleInd].x = newx*width + random(-range,range);
               particles[randParticleInd].y = newy*height  + random(-range,range);
               
               if (i == 1) {
                  if (random(0.0,1.0) > 0.3) particles[randParticleInd].c = color(255,0,0,70);
                  else particles[randParticleInd].c = color(0,0,0,90);
                 
               } else {
                 if (random(0.0,1.0) > 0.3)
                  particles[randParticleInd].c = color(255,255,255,70);
                  else particles[randParticleInd].c = color(0,0,0,90);
                 
               }
               
               particles[randParticleInd].sz = (1.0-f)*(1.0-f)*(1.0-f) * 13;
               particles[randParticleInd].lateral = !particles[randParticleInd].lateral;
               particles[randParticleInd].rev = !particles[randParticleInd].rev;
               
            }
          }
        } else {
           dbInfos[i].count++;    
          
        }
        
   
     }
     
     
    /*
      if (dbInfos[i].count == 0) {
         particles[i].vx = 200.0*(dbInfos[i].x - dbInfos[i].oldx)/dbInfos[i].oldCount; 
         particles[i].vy = 200.0*(dbInfos[i].y - dbInfos[i].oldy)/dbInfos[i].oldCount; 
      } else {
        dbInfos[i].count++;
      } 
     
    // strokeWidth(3);
     stroke((float)i/(float)dbInfos.length*255,150,150);
     
     line(particles[i].x, particles[i].y,
     particles[i].x+ particles[i].vx, particles[i].y + particles[i].vy);
    
     
     particles[i].x += particles[i].vx;
     particles[i].y += particles[i].vy;
    
    if (particles[i].x > width) {
        particles[i].x -= width;
        //particles[i].vx = -abs(particles[i].vx*0.8); 
    }
    if (particles[i].y > height) {
      particles[i].y -= height;
      //particles[i].vy = -abs(particles[i].vy*0.8); 
    }
    
    if (particles[i].x < 0) particles[i].vx = abs(particles[i].vx*0.8); 
    if (particles[i].y < 0) particles[i].vy = abs(particles[i].vy*0.8); 
    
    println(i + ", " + particles[i].x + " " + particles[i].y);
    
    */
  }
  
  
  
  for (int i = 0; i< numParticles; i++) {
     particles[i].update();
     particles[i].draw();
     particles[i].update();
      particles[i].draw();
     particles[i].update();
     particles[i].draw();
     particles[i].update();
      particles[i].draw();
      
   //ps[i].test_respawn();

 
 
  }
  
  
    
  for (int i = 1; i < dbInfos.length; i++) {
  fill(255,20);
         //rect(dbInfos[i].x*width, dbInfos[i].y*height, 10,10);
        println(i + "  " + dbInfos[i].x + " " + dbInfos[i].y );
  }
    
  saveFrame("splotch#####.png");

}
  
 
