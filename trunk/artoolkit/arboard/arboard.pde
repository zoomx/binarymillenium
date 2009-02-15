float[] marker_info = {};
boolean have_info = false;

void setup() {
String cmd[] = {sketchPath("") + "arlaser", sketchPath("") + "images/test1.jpg", 
                sketchPath("")};
//String cmd[] = {"display", sketchPath("") + "images/test1.jpg"};
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
    
if (false) {
in = new BufferedReader(new InputStreamReader(p.getErrorStream())); 


try {
 while ((cmdout = in.readLine()) != null) {
      println(cmdout);
    }
}
catch(IOException e) {
   e.printStackTrace(); 
}
//println(dataPath(""));

}


for (int i = 0; i < marker_info.length-1; i++) {
  print(marker_info[i] + "\t");
}
print("\n");

size(400,400);

}

void draw() {
  
  if (have_info) {

    fill(255);
    rect(width*marker_info[3], height*marker_info[4],10,10);
  }

}
  
 
