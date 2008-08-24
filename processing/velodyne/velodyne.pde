/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 * binarymillenium 2008
 * binarymillenium.com
 * GNU GPL
 *
 * Load csv point cloud files and convert to png height map files
 *//////////////////////////////////////////////////////////////

import processing.opengl.*;
//import java.util.*

final int SZ = 10; //10;
int counter = 0;

final int len = int((12*32*2604)/SZ); //33333*2;


class PC {

  int index;
  float[][] points;
  float[][] colors;

  PC(int len) {
    index = 0;
    points = new float[SZ][len/SZ * 3];
    colors = new float[SZ][len/SZ * 4]; 
  }
}

//PC rv;


CloudConverter converter;

void setup(){

  String base = "C:/Users/lucasw/own/prog/velodyne/frames/";
  converter = new CloudConverter(base);

  size(1280,720);
}

void draw() {
   update(); 
}

void update() {
  
  BufferedReader reader;
  
  counter++;
  println(counter);

    reader = createReader("data/2_two/vel2_" + counter + ".csv");
    //rv = new PC(len);

    loadPoints(len,reader );

  
}



void loadPoints(int len, BufferedReader reader) {

  //byte b[] = loadBytes("../../velodyne/output" + counter +".bin");

  //rv.points = new float[1][b.length/16 * 3];
  //rv.colors = new float[1][b.length/16 * 4]; 

  //for (int i = 0; i < b.length/16; i++) {

  for (int j = 0; j < SZ; j++) {

    String raw[] = new String[0]; 

    for (int i = 0; i < len; i++) {

      String newline;
      try {
        newline = reader.readLine();
      } 
      catch(Exception e) {
        return;  
      }

      raw = append(raw, newline);

    }

    converter.processStrings(raw, false); // (counter == 0) && (j==0));
    converter.toGrid(width,height,  false);
  }

  return;
}


