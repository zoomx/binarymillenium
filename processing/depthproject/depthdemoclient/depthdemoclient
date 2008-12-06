// binarymillenium 2008
// licensed under the GNU GPL latest version


import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  
import javax.media.opengl.glu.*; 

boolean firstperson = true;
boolean savegrid   = false;
boolean updategrid = false;
boolean savevis = false;
boolean allowmove = true;

PImage tx,tx2,txdiff;

// from depthbuffer
// the original perspective command sets perspective in the
// vertical direction, so it is wider in the horiz dir.
final float angle =  PI*0.5; ///with 640x480, 1.2 seems to work better than 4/3
float fov = degrees(angle); 

final  float mv = -0.1;//-0.025;
  
color grid3d[][][];
int gridstats[][][];

/// how many times bigger than a single grid to store one view the entire map should be
final float gridmult = 2.0;
final int ghgt = 80;

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

PrintWriter output;
BufferedReader reader;

/// these are in grid coordinates and not the same coords as cam_...
float cur_x=0.0, cur_y=0.0, cur_z=0.0, cur_r=0.0;

void setup() {
  
  size(640, 640, OPENGL); 
  
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
  } else {
    cam_x= -0.0;
    cam_y =-0.8;
    cam_z = -1.05;///cam_z = -0.5;

    cam_rx = radians(47.97);
    cam_rz = radians(17.27);
  }
  
   reader = createReader("../depthbuffer/angles.csv");
   cur_r = PI/9;
   
   perspective(angle, float(width)/float(height),near,far);
   //frameRate(1);
   println(near + " " + far + ", " + wonegrid + " " + honegrid + ", gridscale " + gridscale);
   
   getstoredstate();
   makegrid();
}

void getstoredstate() {
   String newline;
       try {
          newline = reader.readLine();
       } catch(Exception e) {
          return;  
       }  
     
       if (newline !=null) {
         
          String[] thisLine = split(newline, ",");
      
         /*
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
         */
          
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
          
          println("new coords " + thisLine[0] + " " + xo + " " + yo + " " + degrees(ro) + ", " + cur_x + " " + cur_y);
       } else {
          noLoop(); 
       }
}



void makegrid() {
  tx  = loadImage("../depthbuffer/frames/depth/depth" + index + ".png");
  tx2 = loadImage("../depthbuffer/frames/vis/vis"     + index + ".png");
  
  for (int i = 0; i < tx.height; i++) {
    float zf = -0.5*((float)(i - tx.height/2)/(float)(tx.height/2));
    //print("zf " + zf);
  for (int j = 0; j < tx.width; j++) {

    int txpixind = i*tx.width + j;
    color c  = tx.pixels[txpixind];
    color nc = tx2.pixels[txpixind];
    
    if (c != color(0)) {
    float d = getfloat(c);  //1.0 -  red(c)/255.0;
    
    /// add the 'missing' depth that is inbetween 
    d = (d + neard/fard)/(1.0+neard/fard);
    
    float xf = (float)j/(float)tx.width-0.5;
    
    float zc = 0.5 + d*zf;
    
    // the ffract is wrong give that d is scale above, but it looks less skewed
    float yc = -(d * honegrid); //*ffract*0.8);
    float xc = (d * xf * wonegrid);   // (2*atan(angle/2)*height)
    
    zc*= vscale1;
    zc -= voffset;
    if (zc > 1.0) zc = 1.0;
    if (zc < 0.0) zc = 0.0;
    
    float rx = cos(cur_r)*xc - sin(cur_r)*yc;
    float ry = sin(cur_r)*xc + cos(cur_r)*yc;
     
    int gz = (int)(zc*(ghgt-1));
    int gx = (int)(cur_y+ry);
    int gy = (int)(cur_x+rx);
    
    if ((gx >= 0) && ( gx < grid3d.length) && ( gy >= 0) && (gy < grid3d[gx].length) &&
        (gz >= 0) && ( gz < grid3d[gx][gy].length)) {
    int gcount = gridstats[gx][gy][gz];
    color gc   = grid3d[gx][gy][gz];
  
      /// blend new color with old colors
      grid3d[gx][gy][gz]= color( 
            (int)((float)red(gc)*gcount/(float)(gcount+1)   + (float)red(nc)/(float)(gcount+1)),
            (int)((float)green(gc)*gcount/(float)(gcount+1) + (float)green(nc)/(float)(gcount+1)),
            (int)((float)blue(gc)*gcount/(float)(gcount+1)  + (float)blue(nc)/(float)(gcount+1))
                                );

    
     //println(gx + " " + gy + " " + gz + " " + red( grid3d[gx][gy][gz]));
     
    gridstats[gx][gy][gz]++;
    }
    
    /// TBD - need to clear out grid locations between the seen point and the viewer
    }
    
    }}
    
    
    if (false) {
    int gz = ghgt/2;
    int gx = (int)(cur_y);
    int gy = (int)(cur_x);
    /// white cube where viewer is
    if ((gx >= 0) && ( gx < grid3d.length) && ( gy >= 0) && (gy < grid3d[gx].length) &&
        (gz >= 0) && ( gz < grid3d[gx][gy].length)) {
      
      grid3d[gx][gy][gz] = color(255);
    }
}
    
    println("finished " + index);
  }





void keyPressed() {

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


void writegrid() {
  output = createWriter("grid_" + index + ".csv");
  
  for (int i = 0; i < grid3d.length; i++) {
    float z = gridscale*(float)(i-grid3d.length/2);
    
    for (int j = 0; j < grid3d[i].length; j++) {
       float x = gridscale*(float)(j-grid3d[i].length/2);
       
       for (int k = 0; k < grid3d[i][j].length; k++) {
         
         if (brightness(gridstats[i][j][k]) > 0) {
           output.println(i + ",\t" + j + ",\t" + k + ",\t" + gridstats[i][j][k] + ",\t" + grid3d[i][j][k]);
         }
 }
  output.flush();
  }}
   
  
   output.close();
}

void draw() {
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
    float z = gridscale*(float)(i-grid3d.length/2);
    
    for (int j = 0; j < grid3d[i].length; j++) {
       float x = gridscale*(float)(j-grid3d[i].length/2);
       
       for (int k = 0; k < grid3d[i][j].length; k++) {
         float y = -0.1- vscale*gridscale*(float)(k-grid3d[i][j].length/2); //1.0/(float)ghgt* (float)grid3d.length/2.0*3.0/4.0;
         
         if (brightness(gridstats[i][j][k]) > 0) {
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
  }}}
  
  }
  
  popMatrix();
  
  if (savevis) saveFrame("frames/grid3d_" + index + ".png");
  
  float mse = 0.0;
  
  loadPixels();
  for (int i = 0; i< height; i++) {
  for (int j = 0; j < width; j++) {
    
    int pixind = i*tx.width+j;
      color vish = pixels[pixind];
      color visc = tx2.pixels[pixind];  
      
      int rdiff = (int)((red(visc)  -   red(vish))/2);
      int gdiff = (int)((green(visc)- green(vish))/2);
      int bdiff = (int)((blue(visc) -  blue(vish))/2);
      
      mse += rdiff*rdiff;
      
      int r = 128 + rdiff;
      int g = 128 + gdiff;
      int b = 128 + bdiff;
                                      
      pixels[pixind] = color(r,g,b);
                               
  }}
  updatePixels();
  
  mse /= width*height*255;
  println("mse = " + mse);
  
  if (savevis) saveFrame("frames/diff/diffgrid_" + index + ".png");
  //else saveFrame("frames/hgt#####.png");
//noLoop();

  if (savegrid) writegrid();
  if (updategrid) { 
    index++;
    getstoredstate();
    makegrid();
  }
}
