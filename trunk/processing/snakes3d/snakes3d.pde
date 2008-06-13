
import processing.opengl.*;
import javax.media.opengl.*; 

final int NUM = 200;

final int LEN = 50;
float snakes[][][] = new float[NUM][LEN][3];

float t;

void setup() {
  
  size(640,480,OPENGL);
  
  for (int i = 0; i< NUM; i++) {
    
    snakes[i][0][0] = (noise(i)-0.5)*10.0;
    snakes[i][0][1] = 0;
    snakes[i][0][2] = (noise(i+100)-0.5)*10.0;
    
    
    
   for (int j = 1; j< LEN; j++) {
     
     float x = snakes[i][j-1][0];
     float y = snakes[i][j-1][1];
     float z = snakes[i][j-1][2];
     
     float f = 20.0;
     float div = f*0.7;
     float divy = 100.0;
     snakes[i][j][0] = x + f*(noise(x/div, y/div, z/div)-0.5);
     snakes[i][j][1] = y - 5.0*noise(y/divy, z/divy, x/divy);
     snakes[i][j][2] = z + f*(noise(z/div, x/div, y/div)-0.5);      

  }}
 
 background(0); 
}

float roty;
float movz;

void draw() {
  t+= 0.001;
  roty += 0.001;
  movz += 0.1;
  //background(0);
  
  /*
   GL gl=((PGraphicsOpenGL)g).beginGL();
  gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
  ((PGraphicsOpenGL)g).endGL(); 
  */
  
 lights(); 
  translate(width/2, height*0.57 , width*0.51 + mouseY/30);
  
  rotateY(roty);
  
  
  for (int i = 0; i< NUM; i++) {
   
    int c = (int)((float)i/NUM*255);
    int g = (int)(255*abs(snakes[i][0][0]/5.0));
    
    stroke(color(g,g,c));
    noFill();
    beginShape();
   for (int j = 0; j< LEN; j++) {
    vertex(snakes[i][j][0], snakes[i][j][1],snakes[i][j][2]);
    
   
     
     
     if (j != 0) {
   
     float x = snakes[i][j-1][0];
     float y = snakes[i][j-1][1];
     float z = snakes[i][j-1][2];
     
     float f = 20.0;
     float div = f*0.7;
     float divy = 100.0;
     snakes[i][j][0] = x + f*(noise(t+x/div, y/div, z/div)-0.5);
     snakes[i][j][1] = y - 5.0*noise(t+y/divy, z/divy, x/divy);
     snakes[i][j][2] = z + f*(noise(t+z/div, x/div, y/div)-0.5);  
       
     } 
     //snakes[i][j][2] -= movz;
    
    
  }
    endShape();
  }
  
}
