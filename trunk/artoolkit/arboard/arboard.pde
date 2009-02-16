

class MarkerInfo {
  float cf;
  int id;
  float area;
  float x;
  float y;
  float x1;
  float y1;
  
}

MarkerInfo[] markerInfos = new MarkerInfo[0];
boolean have_info = false;

void setup() {
  
 getImage();

size(400,400);

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
  
  fill(0,10);
  rect(0,0,width,height);
  
  getImage();
  noStroke();
  
  if (have_info) {

    
    for (int i = 0; i < markerInfos.length; i++) {
      if (markerInfos[i].cf > 0.4) { 
      fill(255, markerInfos[i].cf*255,255,markerInfos[i].cf*255);      
      rect(width*markerInfos[i].x, height*markerInfos[i].y,10,10);
      }
    }
  }

}
  
 
