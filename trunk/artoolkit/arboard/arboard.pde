

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
 
float x;
float y;

float vx;
float vy;

float ax;
float ay;
}

MarkerInfo[] markerInfos = new MarkerInfo[0];

final int numMarkers = 3;
MarkerInfo[] dbInfos = new MarkerInfo[numMarkers];
particle[] particles = new particle[numMarkers];

boolean have_info = false;

void setup() {
  
  size(400,400);
  
  for (int i = 0; i< dbInfos.length; i++) {
    
    particles[i] = new particle();
    particles[i].x = width/2;
    particles[i].y = height/2;  
    
    dbInfos[i] = new MarkerInfo();
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

void getImage() {
 /* String cmdCurl[] = {"curl", "http://192.168.1.57/now.jpg > " + 
                                sketchPath("") +"images/test.jpg"};
 Process p = exec(cmdCurl);
 
 printOutput(p);
 */
 
 String cmd[] = {sketchPath("") + "run.sh", sketchPath("")};
 Process p = exec(cmd);


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



void draw() {
  
  fill(0,1);
  rect(0,0,width,height);
  
  getImage();
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
  
  for (int i = 0; i < dbInfos.length; i++) {
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
  }
  

}
  
 
