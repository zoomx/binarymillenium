/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 * binarymillenium 2008
 * binarymillenium.com
 * GNU GPL
 *
 * Load csv point cloud files and convert to png height map files
 *//////////////////////////////////////////////////////////////

import processing.opengl.*;
//import java.util.*

boolean converttogrid = false;

int counter = 0;

CloudConverter converter;

void setup(){

  String base = "C:/Users/lucasw/own/prog/velodyne/frames/";
  converter = new CloudConverter(base);

  size(800,600);
}

void draw() {
   update(); 
}

void update() {
  
  BufferedReader reader;
  
  
  println("counter " + counter);
    
    String file = "C:/Users/lucasw/own/prog/googlecode/trunk/processing/velodyne/unit_46_sample_capture_velodyne_" + str(counter) + ".csv";
  
   //
          reader = createReader(file);

    
    counter++;
    //rv = new PC(len);

    loadPoints(reader );
}

void loadPoints(BufferedReader reader) {

  //byte b[] = loadBytes("../../velodyne/output" + counter +".bin");

  //rv.points = new float[1][b.length/16 * 3];
  //rv.colors = new float[1][b.length/16 * 4]; 

  //for (int i = 0; i < b.length/16; i++) {
String newline = null;
     try {
     newline = reader.readLine();
   } catch (IOException e) {
      println("ioexception");
   }
   
    String raw[] = new String[0]; 

    while (newline != null) {  

      raw = append(raw, newline);
      
      try {
        newline = reader.readLine();
      } 
      catch(Exception e) {
        break;  
      }
    }

    converter.processStrings(raw, false); // (counter == 0) && (j==0));
    
    if (converttogrid)
      converter.toGrid(width,height,  false);
  

  return;
}


