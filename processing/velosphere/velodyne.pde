/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 * binarymillenium 2008
 * binarymillenium.com
 * GNU GPL
 *
 * Load csv point cloud files and convert to png height map files
 *//////////////////////////////////////////////////////////////

import processing.opengl.*;
//import java.util.*

final int SZ = 10;

final int len = int(12*32*2604); //33333*2;




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

PC rv;
BufferedReader reader;

CloudConverter converter;

void setup(){
 

  String base = "C:/Users/lucasw/own/prog/velodyne/frames/";
  converter = new CloudConverter(base);

  while(true) {
    update();
  }
}


void update() {
  //println(counter + " " + counter%SZ);
  if (counter%SZ == 0) {
    // 30
    /*if (counter/SZ > 1) 
      {exit(); 
    return; // counter = 0;
      }*/

    reader = createReader("../velodyne/output" + counter/SZ + ".csv");
    rv = new PC(len);

    loadPoints(len);


    println(counter/SZ);
  }
  counter++;
}


int counter = 0;

void loadPoints(int len) {

  //byte b[] = loadBytes("../../velodyne/output" + counter +".bin");

  //rv.points = new float[1][b.length/16 * 3];
  //rv.colors = new float[1][b.length/16 * 4]; 


  //for (int i = 0; i < b.length/16; i++) {



  for (int j = 0; j < SZ; j++) {

    String raw[] = new String[0]; 

    for (int i = 0; i < len/SZ; i++) {



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
    converter.toGrid(280,280,  false);
  }




  return;
}


