// binarymillenium 2008
// licensed under the GNU GPL latest version

import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;  
import javax.media.opengl.glu.*; 

String base = "C:/Documents and Settings/lucasw/My Documents/own/processing/depthdiff/";

int index = 10000;

PImage tx,tx2,txvis, txdiff, txdiff2;

void setup() {
  size(1280, 960);
}

void draw() {
  
  tx = loadImage("../depthbuffer/frames/vis/vis" + index + ".png");
  tx2 = loadImage("../depthvis3dgrid/frames/grid3d_" + (index+1) + ".png");
  
  txdiff = createImage(tx.width, tx.height, RGB); 
  //txdiff2= createImage(tx.width, tx.height, RGB); 

loadPixels();
  
  for (int i = 0; i < tx.height; i++) {
  for (int j = 0; j < tx.width; j++) { 
  
      int pixind = i*tx.width+j;
      color visc = tx.pixels[pixind];
      color vish = tx2.pixels[pixind];       
      int r = 128 + (int)((red(visc)  - red(vish))/2);
      int g = 128 + (int)((green(visc)- green(vish))/2);
      int b = 128 + (int)((blue(visc) - blue(vish))/2);
                                      
       txdiff.pixels[pixind] = color(r,g,b);
       
       txdiff2.pixels[pixind] = color( (128 + (red(visc) - red(vish))     - 2*(r-128)),
                                       (128 + (green(visc) - green(vish)) - 2*(g-128)),
                                       (128 + (blue(visc) - blue(vish))   - 2*(b-128)) );
       ///TBD need to compute how much data out of width*height*32-bits are lost to the divide by two.
       
       pixels[i*width+j]              = tx.pixels[pixind];
       pixels[i*width+j+width/2]      = tx2.pixels[pixind];
      
  }}
  
  for (int i = 0; i < tx.height; i++) {
  for (int j = 0; j < tx.width; j++) { 
     pixels[(i+height-txdiff.height)*width + j ]            = txdiff.pixels[i*tx.width+j];
     //pixels[(i+height-txdiff.height)*width + j + width/2] = txdiff2.pixels[i*tx.width+j];
  }}
  updatePixels();
  
  //if (savedata) {
    
    txdiff.save( base + "frames/diff/diff" + (index) + ".png");
    //txdiff2.save(base + "frames/diff/rdiff" + (index) + ".png");
  //}

  index+=1;
  
  
  }
