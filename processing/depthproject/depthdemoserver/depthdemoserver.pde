// binarymillenium 2008
// licensed under the GNU GPL latest version


import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  
import javax.media.opengl.glu.*; 
import processing.net.*;

boolean firstperson = true;
boolean savegrid   = false;
boolean updategrid = true;
boolean savevis = false;
boolean allowmove = false;
boolean showdiff = false;
boolean adddiff = false;


boolean offlinerender = false;
boolean nowsending = false;

Server srv;

PImage tx2,txdiff;

// from depthbuffer
// the original perspective command sets perspective in the
// vertical direction, so it is wider in the horiz dir.
final float angle =  PI*0.5; ///with 640x480, 1.2 seems to work better than 4/3
float fov = degrees(angle); 

final  float mv = -0.5; //-0.1;//-0.025;

color grid3d[][][];
int gridstats[][][];

/// how many times bigger than a single grid to store one view the entire map should be
final float gridmult = 2.0;
final int ghgt = 40;

final float vscale1 = 3.0;
final float voffset = 1.0;

/// derived values
float cameraZ;
float scaleval;
float near;
float far;
float neard;
float fard;

/// the amount to scale the grid to get it back to scale used
/// in depthbuffer
float gridscale;
float honegrid;
float wonegrid;

int index = 10000;

/// opengl coords scaled by scaleval
float cam_x,cam_y,cam_z, cam_rx ,cam_rz;
float cam_vx = 0;
float cam_vz = 0;

BufferedReader reader;


/// these are in grid coordinates and not the same coords as cam_...
float cur_x=0.0, cur_y=0.0, cur_z=0.0, cur_r=0.0;

void setup() {

  
  frameRate(1);
  
  size(640, 640, OPENGL); 


  if (offlinerender) {
  txdiff = createImage(width,height,RGB);

  cameraZ = (height/2.0) / tan(PI * fov / 360.0);
  scaleval = height/2;
  near = scaleval/2; 
  far = scaleval*40;
  neard =  near; 
  fard = far*0.7; 

  /// size of grid that stores one view
  honegrid = 240;
  wonegrid = (int)(honegrid*tan(angle/2)*2); //(h*2.0);
  gridscale = fard/(scaleval*honegrid);


  grid3d    = new color[(int)(gridmult*honegrid)][(int)(gridmult*wonegrid)][ghgt];
  gridstats = new int[(int)(gridmult*honegrid)][(int)(gridmult*wonegrid)][ghgt];

  cur_x = grid3d[0].length/2;
  cur_y = grid3d.length/2;

  if (firstperson) {
    cam_x = -4.3;
    cam_y = 0.0;
    cam_z = -1.3; 
    cam_rx = 0.0;
    cam_rz = PI/9;
  } 
  else {
    cam_x= -0.0;
    cam_y =-0.8;
    cam_z = -1.05;///cam_z = -0.5;

    cam_rx = radians(47.97);
    cam_rz = radians(17.27);
  }

  reader = createReader("../../depthbuffer/angles.csv");
  cur_r = PI/9;

  perspective(angle, float(width)/float(height),near,far);
  //frameRate(1);
  println("server: " + near + " " + far + ", " + wonegrid + " " + honegrid + ", gridscale " + gridscale);


  
  getstoredstate();
  loadgrid();
  
  }
  
  srv = new Server(this, 12345); // Start a simple server on a port
}

void getstoredstate() {
  String newline;
  try {
    newline = reader.readLine();
  } 
  catch(Exception e) {
    return;  
  }  

  if (newline !=null) {

    String[] thisLine = split(newline, ",");

    if (false) {
      /// load the changes
      float xo = new Float(thisLine[1]).floatValue();
      float yo = new Float(thisLine[3]).floatValue();
      float ro = radians(new Float(thisLine[4]).floatValue());

      cur_x += xo/-gridscale;
      cur_y += yo/-gridscale;
      cur_r+= ro; 

      if (firstperson) {
        cam_x += xo/scaleval;
        cam_z += yo/scaleval; 
        cam_rz+= ro;   
      } 

    } 
    else {

      /// load the absolute position and rotation
      float xo = new Float(thisLine[5]).floatValue();
      float yo = new Float(thisLine[7]).floatValue();
      float ro = radians(new Float(thisLine[8]).floatValue());

      cur_x = grid3d[0].length/2 - xo/gridscale;
      cur_y = grid3d.length/2    - yo/gridscale;
      cur_r = ro;

      if (firstperson) {
        cam_x =-0.1 + xo;
        cam_z = 0.7 + yo; //1.15+ yo; 
        cam_rz= ro;   
      } 

      //println("new coords " + thisLine[0] + " " + xo + " " + yo + " " + degrees(ro) + ", " + cur_x + " " + cur_y);

    }
  } 
  else {
    noLoop(); 
  }
}



void loadgrid() {
  
  
  BufferedReader gridreader = createReader("grid_final.csv");
  
  int count = 0;
  
  boolean stillreading = true;
  
  while (stillreading) {
    
  String newline;
  try {
    newline = gridreader.readLine();
    
  } 
  catch(Exception e) {
    stillreading = false;
    break;  
  }  
  
  if (newline == null) {
    stillreading = false;
    break;
    
  }
  String[] thisLine = split(newline, ",\t");
  
  int gx = Integer.parseInt(thisLine[0]);
  int gy = Integer.parseInt(thisLine[1]);
  int gz = Integer.parseInt(thisLine[2]);
  int gc = Integer.parseInt(thisLine[3]);
  int col= Integer.parseInt(thisLine[4]);

  if ((gx >= 0) && ( gx < grid3d.length) && ( gy >= 0 ) && (gy < grid3d[gx].length) &&
    (gz >= 0) && ( gz < grid3d[gx][gy].length)) {

      gridstats[gx][gy][gz] = gc;
      grid3d[gx][gy][gz] = (color)col;
      count++;
  }
    
  }
  
  

  
}





void keyPressed() {

   if (key == 'u') {
    nowsending = true;
    println("server: now sending images");
  }  
  
  if (allowmove) {

    if (key =='a' ) cam_x -= mv;
    if (key =='d' ) cam_x += mv;
    if (key =='w' ) cam_z -= mv;
    if (key =='s' ) cam_z += mv;
    if (key =='q' ) cam_y -= mv;
    if (key =='z' ) cam_y += mv;
    if (key =='j') cam_rz += radians(-2);
    if (key =='k') cam_rz += radians(2);

    println(cam_x + " " + cam_y + " " + cam_z + ", " + cam_rx + " " + degrees(cam_rz));
  }

}


void draw() {
  
  if (offlinerender) {
  pushMatrix();
  translate(width/2,height/2,cameraZ);

  if (false) {
    if (mousePressed) {
      cam_vx += (mouseY-pmouseY)*0.01; 
      cam_vz += (mouseX-pmouseX)*0.01;
    }
    cam_rx += cam_vx;
    cam_rz += cam_vz;

    cam_vx *= 0.9;
    cam_vz *= 0.9;
  }


  background(0);

  scale(scaleval);

  rotateX(-cam_rx);
  rotateY( cam_rz);
  translate(cam_x,cam_y,cam_z);

  final float vscale =   (3.0*160.0)/(vscale1*ghgt);
  
  
  if (true) {
    for (int i = 0; i < grid3d.length; i++) {
   // for (int i = grid3d.length/4; i < 3*grid3d.length/4; i++) {
      float z = gridscale*(float)(i-grid3d.length/2);

      for (int j = 0; j < grid3d[i].length; j++) {
        //for (int j = grid3d[i].length/4; j < 3*grid3d[i].length/4; j++) {
        float x = gridscale*(float)(j-grid3d[i].length/2);

        //for (int k = 0; k < grid3d[i][j].length; k++) {
          for (int k = 3*grid3d[i][j].length/8; k < grid3d[i][j].length; k++) {
          float y = -0.1- vscale*gridscale*(float)(k-grid3d[i][j].length/2); //1.0/(float)ghgt* (float)grid3d.length/2.0*3.0/4.0;

          if (brightness(gridstats[i][j][k]) > 10) {
            pushMatrix();
            translate(x,y,z);
            noStroke();
            fill(grid3d[i][j][k]);

            //println(x + ",\t" + y + ",\t" + z + ",\t" + brightness(grid3d[i][j][k]) + ",\t" + gridstats[i][j][k]);
            // noLoop();
            //fill(255);
            box(gridscale,gridscale*vscale,gridscale);
            //rect(-gridscale,gridscale,-gridscale,gridscale);
            //sphere(istep);
            popMatrix();
          }
        }
      }
    }

  }

  popMatrix();

  if (savevis) saveFrame("frames/grid3d_" + index + ".png");

  //  /float mse = 0.0;
  
  if (showdiff) {
  
  
 tx2 = loadImage("../../depthbuffer/frames/vis/vis" + index + ".png");
 // tx2 = loadImage("vis_320/vis" + index + ".jpg");
 

  loadPixels();
  for (int i = 0; i< height; i++) {
    for (int j = 0; j < width; j++) {

      int pixind = i*tx2.width+j;
      color vish = pixels[pixind];
      color visc = tx2.pixels[pixind];  

      int rdiff = (int)((red(visc)  -   red(vish))/2);
      int gdiff = (int)((green(visc)- green(vish))/2);
      int bdiff = (int)((blue(visc) -  blue(vish))/2);

      //mse += rdiff*rdiff;

      int r = 128 + rdiff;
      int g = 128 + gdiff;
      int b = 128 + bdiff;

      pixels[pixind] = color(r,g,b);

    }
  }
  updatePixels();

  //mse /= width*height*255;
  //println("mse = " + mse);

  if (savevis) saveFrame("frames/diff/diffgrid_" + index + ".png");
  
  ////////////////////////////////////////////////////////////
  } else if (adddiff) {
    
    //tx2 = loadImage("../../depthvis3dgrid/frames/diff/diffgrid_" + index + ".png");
     tx2 = loadImage("frames/diff/diffgrid_" + index + ".png");
     
      loadPixels();
  for (int i = 0; i< height; i++) {
    for (int j = 0; j < width; j++) {

      int pixind = i*tx2.width+j;
      color vish = pixels[pixind];
      color visc = tx2.pixels[pixind];  

      

      int rdiff = (int)((red(visc)  - 128)*2);
      int gdiff = (int)((green(visc)- 128)*2);
      int bdiff = (int)((blue(visc) - 128)*2);


      //mse += rdiff*rdiff;

      int r = (int)red(vish)+ rdiff;
      int g = (int)green(vish)+gdiff;
      int b = (int)blue(vish)+ bdiff;
      
     //  if (i == 0) println(rdiff + " " + gdiff + " " + bdiff + ", " + 
     //                (int)red(visc) + ", " + (int)green(visc) + ", " + (int)blue(visc));

      pixels[pixind] = color(r,g,b);

    }
  }
  updatePixels();
  
  }
  
   if (updategrid) { 
      index++;
      getstoredstate();
     
    }
    
  } else {
  
  //String filename = "C:/Documents and Settings/lucasw/My Documents/own/processing/depthproject/depthdemoserver/frames_320/diff/diffgrid_" + index + ".png";
  String filename = "C:/Users/lucasw/own/prog/googlecode/trunk/processing/depthproject/depthdemoserver/frames_640/diff/diffgrid_" + index + ".png";
  PImage dg = loadImage(filename);
  image(dg,0,0);
  
  if (nowsending) {
    sendimage( filename);
    index++;
    
    nowsending = false;
   
  }  
  }
  
}

