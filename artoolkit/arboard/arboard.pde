

float[] marker_info = {};
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

try {
 while ((cmdout = in.readLine()) != null) {
      float[] temp = float(split(cmdout, ','));
      if (temp.length == 8) {
        marker_info = temp; 
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


for (int i = 0; i < marker_info.length-1; i++) {
  //print(marker_info[i] + "\t");
}
//print("\n");

}

/////////////////////////////////



void draw() {
  
  getImage();
  
  if (have_info) {

    fill(255);
    rect(width*marker_info[3], height*marker_info[4],10,10);
  }

}
  
 
