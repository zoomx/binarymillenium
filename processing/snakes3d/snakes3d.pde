
import processing.opengl.*;
import javax.media.opengl.*; 

final int NUM = 20;

//final int LEN = 50;
float snakes[][] = new float[NUM][3];

float t;

void setup() {
  
  size(640,480,OPENGL);
  
  for (int i = 0; i< NUM; i++) {
    
    float f = 50.0;
    snakes[i][0] = random(-f,f);
    snakes[i][1] = random(-f,f);
    snakes[i][2] = random(-f,f);
    
    
    
   //for (int j = 1; j< LEN; j++) {
     
   
     /*
     
     float x = snakes[i][j-1][0];
     float y = snakes[i][j-1][1];
     float z = snakes[i][j-1][2];
     
     float f = 20.0;
     float div = f*0.7;
     float divy = 100.0;
     snakes[i][j][0] = x + f*(noise(x/div, y/div, z/div)-0.5);
     snakes[i][j][1] = y - 5.0*noise(y/divy, z/divy, x/divy);
     snakes[i][j][2] = z + f*(noise(z/div, x/div, y/div)-0.5);    */  

  }//}
 
 background(0); 
}

float roty;
float movz;

void draw() {
  t+= 0.001;
  roty += 0.01;
  movz -= 0.1;
  //background(0);
  
  /*
   GL gl=((PGraphicsOpenGL)g).beginGL();
  gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
  ((PGraphicsOpenGL)g).endGL(); 
  */
  
 lights(); 
  translate(width/2, height*0.5, width*0.46);// + mouseY/30);
  
  rotateY(roty);
  
  
  for (int i = 0; i< NUM; i++) {
   
    int c = (int)((float)i/NUM*255);
    int g = (int)(255*abs(snakes[i][0]/5.0));
    
     fill(color(g,g,c));
     
     noStroke();
     pushMatrix();
     translate(snakes[i][0], snakes[i][1],snakes[i][2]);
     sphere(1);
     popMatrix();
     
     float x = snakes[i][0];
     float y = snakes[i][1];
     float z = snakes[i][2];
 
          float f = 2.0;
     float div = 10.0;
     float divy = 100.0;
     snakes[i][0] = x + f*(noise(t+x/div, y/div, z/div)-0.5);
     snakes[i][1] = y + f*(noise(t+y/divy, z/divy, x/divy)-0.3);
     snakes[i][2] = z + f*(noise(t+z/div, x/div, y/div)-0.5);
  
  }
  
}
