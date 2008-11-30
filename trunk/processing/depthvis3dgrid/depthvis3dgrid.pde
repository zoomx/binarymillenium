// binarymillenium 2008
// licensed under the GNU GPL latest version


import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  
import javax.media.opengl.glu.*; 

boolean firstperson = true;
boolean savegrid = false;
boolean updategrid = true;
boolean savevis = true;

PImage tx,tx2;

// from depthbuffer
// the original perspective command sets perspective in the
// vertical direction, so it is wider in the horiz dir.
final float angle =  PI*0.5; ///with 640x480, 1.2 seems to work better than 4/3
float origh = 640;
float scaleval = origh/2;
float ffract;

final  float mv = -0.025;
  
float griddiv = 2.0;
color grid3d[][][];
int gridstats[][][];
final float gridmult = 3.0;
final int ghgt = 40;

float cameraZ = 0.0;
float near = 0.0;
float far = 0.0;
float fov = degrees(angle); 
float fard = 0.0, fard2 = 0.0;
float neard = 0.0;

final float scaleval2 = 200;

PrintWriter output;

float cam_x,cam_y,cam_z, cam_rx ,cam_rz;
float cam_vx = 0;
float cam_vz = 0;

BufferedReader reader;

int h,w;

float cur_x = 0.0, cur_y = 0.0, cur_z = 0.0, cur_r = 0.0;

void setup() {
  
  if (firstperson) {
     cam_x = 0.0;
     cam_y = 0.0;
     cam_z = 1.15; 
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
   
  h = 480;
  w = (int)(h*tan(angle/2)*2); //(h*2.0);
   
   size(640,640,OPENGL);
   
   
  cameraZ = (height/2.0) / tan(PI * fov / 360.0);
  scaleval = height/2;
 // near = scaleval/2; 
  //far = scaleval*40;
   near = scaleval/20.0; 
  far = scaleval*40;
  
  neard = near;
  fard = scaleval*40*0.7;
  fard2 = far*0.7;
   
      perspective(angle, float(width)/float(height),near,far);
   //frameRate(1);
   println(near + " " + far + ", " + w + " " + h);
   
  
   
   grid3d    = new color[(int)(gridmult*h/griddiv)][(int)(gridmult*w/griddiv)][ghgt];
   gridstats = new int[(int)(gridmult*h/griddiv)][(int)(gridmult*w/griddiv)][ghgt];
   
   
     cur_x = grid3d[0].length/2;
   cur_y = grid3d.length/2;

   
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

          /// 200.0 was a scaling factor in depthbuffer
          /// also the ima.height*ffract pixels / fard opengl units
          final float fconv = h/(fard*griddiv);
         
         /*
          float xo = new Float(thisLine[1]).floatValue();
          float yo = new Float(thisLine[3]).floatValue();
          float ro = radians(new Float(thisLine[4]).floatValue());
          
          cur_x += xo*-fconv;
          cur_y += yo*-fconv;
          cur_r+= ro; 
          
          if (firstperson) {
             cam_x += xo/scaleval2;
             cam_z += yo/scaleval2; 
             cam_rz+= ro;   
         } 
         */
          
          float xo = new Float(thisLine[5]).floatValue();
          float yo = new Float(thisLine[7]).floatValue();
          float ro = radians(new Float(thisLine[8]).floatValue());
          
          cur_x = grid3d[0].length/2 + xo*-fconv;//+width/2;
          cur_y = grid3d.length/2    + yo*-fconv;//+height/2;
          cur_r = ro;
          
         if (firstperson) {
             cam_x = 3.3  + xo;
             cam_z = 3.3 + 1.15 + yo; //1.15+ yo; 
             cam_rz= ro;   
         } 
          
          println(xo + " " + yo + " " + degrees(ro));
       } else {
          noLoop(); 
       }
}

int index = 10000;

boolean dovis = false;
float txscale = 1;

void makegrid() {
  tx  = loadImage("../depthbuffer/frames/depth/depth" + index + ".png");
  tx2 = loadImage("../depthbuffer/frames/vis/vis"     + index + ".png");
  
  txscale = griddiv*fard2/(10.0*tx.height*scaleval2);
    
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
    d = (d + neard/fard2)/(1.0+neard/fard2);
    
    float xf = (float)j/(float)tx.width-0.5;
    
    float zc = 0.5 + d*zf;
    
    // the ffract is wrong give that d is scale above, but it looks less skewed
    int yc = (int)((1.0-d) * h); //*ffract*0.8);
    int xc = (int)(w/2 + d * xf * w);   // (2*atan(angle/2)*height)
    
    int pixind = yc*w + xc;
    if (pixind >= w*h) pixind = w*h-1;
    if (pixind < 0) pixind = 0;
    
    
    zc*= 3.0;
    zc -= 1.0;
    if (zc > 1.0) zc = 1.0;
    if (zc < 0.0) zc = 0.0;
    
    int rx = (int) ((cos(cur_r)*(xc-w/2) - sin(cur_r)*(yc-h))/griddiv);
    int ry = (int) ((sin(cur_r)*(xc-w/2) + cos(cur_r)*(yc-h))/griddiv);
    
    
    int gz = (int)(zc*(ghgt-1));
    int gx = (int)((float)(cur_y+ry));
    int gy = (int)((float)(cur_x+rx));
    
    
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
    
    /// white cube where viewer is
    int gz = ghgt/2;
    int gx = (int)(cur_y);
    int gy = (int)(cur_x);
    grid3d[gx][gy][gz] = color(255);
    
    println("finished " + index);
  }




void keyPressed() {

  
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


void writegrid() {
  output = createWriter("grid_" + index + ".csv");
  
  for (int i = 0; i < grid3d.length; i++) {
    float z = txscale*(float)(i-grid3d.length/2);
    
    for (int j = 0; j < grid3d[i].length; j++) {
       float x = txscale*(float)(j-grid3d[i].length/2);
       
       for (int k = 0; k < grid3d[i][j].length; k++) {
         
         if (brightness(grid3d[i][j][k]) > 20) {
           output.println(i + ",\t" + j + ",\t" + k + ",\t" + gridstats[i][j][k] + ",\t" + grid3d[i][j][k]);
         }
 }
  output.flush();
  }}
   
  
   output.close();
}

void draw() {
  
  float cameraZ = (height/2.0) / tan(PI * fov / 360.0);
  translate(width/2,height/2,cameraZ);
  

  if (mousePressed) {
   cam_vx += (mouseY-pmouseY)*0.01; 
   cam_vz += (mouseX-pmouseX)*0.01;
  }
  cam_rx += cam_vx;
  cam_rz += cam_vz;
  
  cam_vx *= 0.9;
  cam_vz *= 0.9;
  

  
  background(0);

  scale(scaleval2);
  
  translate(cam_x,cam_y,cam_z);
  rotateX(-cam_rx);
  rotateY( cam_rz);


  final float vscale = 160.0/ghgt;
  
  for (int i = 0; i < grid3d.length; i++) {
    float z = txscale*(float)(i-grid3d.length/2);
    
    for (int j = 0; j < grid3d[i].length; j++) {
       float x = txscale*(float)(j-grid3d[i].length/2);
       
       for (int k = 0; k < grid3d[i][j].length; k++) {
         float y = -vscale*txscale*(float)(k-grid3d[i][j].length/2); //1.0/(float)ghgt* (float)grid3d.length/2.0*3.0/4.0;
         
         if (brightness(grid3d[i][j][k]) > 20) {
         pushMatrix();
         translate(x,y,z);
         noStroke();
         fill(grid3d[i][j][k]);
         
         //println(x + " " + z + " " + y);
         
         //point(0,0);
         //fill(255);
         box(txscale,txscale*vscale,txscale);
         //rect(-txscale,txscale,-txscale,txscale);
         //sphere(istep);
         popMatrix();
         }
  }}}
  
 
  //print('.');
  //if (dovis)  
  if (savevis) saveFrame("frames/grid3d_" + index + ".png");
  //else saveFrame("frames/hgt#####.png");
//noLoop();

  if (savegrid) writegrid();
  if (updategrid) { 
    index++;
    getstoredstate();
   makegrid();
  }
}
