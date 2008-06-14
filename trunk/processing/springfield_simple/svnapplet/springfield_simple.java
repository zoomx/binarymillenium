import processing.core.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class springfield_simple extends PApplet {/**
 
binarymillenium 2008
<br><br>
gnu gpl
<br><br>
    't' - take a larger timestep<br>
    'g' - toggle between yellow gas and normal mode<br>
    'e' - decrease granularity<br>
    'd' - increase granulariy<br>
    'i' - increase velocity<br>
    'j' - decrease move velocity<br>
    'r' - reset<br>
    'm' - flatten<br>
    
*/
 
final boolean wrap_edges = false;
boolean do_gassy = false;
final int SZ = 80;

/// difference between left and right makes it seem like the water is moving
final float k = 0.02f;

final float max_vel = 0.3f;
final float gravity = 0.000005f;

float div = SZ/10; //12.0;

float f_mask_mod = 1.0f;

float t;

float field[][];
float field_vel[][];

float f_mask[][];


float x_sc, y_sc;

PImage a;

   

public void setup() {
 
 field     = new float[SZ][SZ]; 
 field_vel = new float[SZ][SZ]; 
 f_mask    = new float[SZ][SZ];
 

  
 size(640,480,P3D);
 
   a = new PImage();
     a.width = SZ;
     a.height = SZ;
     a.pixels = new int[a.width*a.height];
 
 x_sc = width/SZ;
 y_sc = height/SZ;
 
 frameRate(19);
 
}


float movex = 0;
float movey = 0;
float movevel = 0.2f;

public void draw() {
 noStroke();
  
       t += 0.005f;
  movex += noise(t*6)*movevel;
 movey += (noise(10000+t*6)-0.5f)*movevel*2;
 
 
  if(mousePressed) {
    int i = (int) (mouseX/x_sc)%SZ;
    int j = (int) (mouseY/y_sc)%SZ;
  
    if (i < 0) i =0;
    if (j < 0) j =0;  
    
    field_vel[i][j] += 0.057f;
  }
  
  
  float min_field = 1000;
  float max_field = 0;
 
  for (int i = 0; i < SZ; i++) {
  for (int j = 0; j < SZ; j++) {
    
    {
      
      float f =   0.1f*noise((i+movex*2)/div,(j+movey)/div,t) +
                  0.2f*noise((i+movex*6)/(2*div),(j+movey*6)/(2*div),t)+ 
                  0.7f*noise((i+movex)/(4*div),(j+movey)/(4*div),t); 
 
    float th = 0.4f;
    
    f -= 0.08f;
    f *= 1.1f;
    
    f *= f;
    f *= f_mask_mod;
    if (f < 0) f = 0;
    f_mask[i][j] = f;//(f > th ? (0.5+0.5*f) : 0.1*f/th);
    }
  
    field[i][j] += field_vel[i][j];

    field_vel[i][j] -= gravity;
       
    if (field[i][j] < f_mask[i][j]) {
        field[i][j] = f_mask[i][j];
       field_vel[i][j] = -field_vel[i][j]*0.05f;
    }
        //if (field[i][j] > 1.0) {
        //field_vel[i][j] = -field_vel[i][j]*0.4;
     //   field[i][j] = 1.0;
    //}

    
    //field_vel[i][j] *= 0.999;
    //field[i][j] *= 0.999;
    
    if (field[i][j] > max_field) max_field = field[i][j];
    if (field[i][j] < min_field) min_field = field[i][j];
  
    
    float dx;    
     float k1   = k;
     float k2 = k;
     
    if (do_gassy) {
      k1 *= 2.0f*(field[i][j]-f_mask[i][j]);
      k2 *= 2.0f*(field[i][j]-f_mask[i][j]);
    }
    
    
    if (i < SZ-1) {
      k1 += 2.0f*(field[i][j]-f_mask[i][j]);
      k2 += 2.0f*(field[i+1][j]-f_mask[i+1][j]);
      
      dx = field[i+1][j] - field[i][j];
      field_vel[i][j]   += dx*k1;
      field_vel[i+1][j] -= dx*k2;
    } else if (wrap_edges ) {
      dx = field[0][j] - field[i][j];
      field_vel[i][j] += dx*k1;
      field_vel[0][j] -= dx*k2;
    }
    if (j < SZ-1) {
          k1 += 2.0f*(field[i][j]-f_mask[i][j]);
      k2 += 2.0f*(field[i][j+1]-f_mask[i][j+1]);
      
      dx = field[i][j+1] - field[i][j];
      field_vel[i][j]  += dx*k1;
      field_vel[i][j+1]-= dx*k2;
    } else if (wrap_edges ) {
      dx = field[i][0] - field[i][j];
      field_vel[i][j] += dx*k1;
      field_vel[i][0] -= dx*k2;      
    }
    
    
    
    
    if ( field_vel[i][j] > max_vel) field_vel[i][j] = max_vel;
    if ( field_vel[i][j] <-max_vel) field_vel[i][j] =-max_vel;
  }} 
  
  ///////////////////////////////////////////////////////
  for (int i = 0; i < SZ; i++) {
  for (int j = 0; j < SZ; j++) {
    int c = (int)( (field[i][j]-min_field)/(max_field-min_field)*255);
    if (c > 255) c = 255;
    if (c < 0) c = 0;
    
    int g = (int)(f_mask[i][j]*255);
       if (g > 255) g = 255;
    if (g < 0) g = 0;
    
    
    //if (f_mask[i][j] < 0.0) b = 0;
    
    if (do_gassy) {
      int b = (int)( 2.0f*((field[i][j]-f_mask[i][j]))*255);
     
      
      a.pixels[j*SZ+i] = color(b+c,b+c,5*b);
      //a.pixels[j*SZ+i] = color(5*b+c/4,5*b+c/4,5*b);
    } else {
      a.pixels[j*SZ+i] = color(c,c,c);
    }
    
    //rect(i*x_sc,j*y_sc, x_sc,y_sc);
  }}
  
  
    
  if(keyPressed) { 
    if(key == 't') {
      t += 0.1f;     
    }
    
    if(key == 'g') {
       do_gassy = !do_gassy;
    }
     
    if(key == 'e') {
      div *= 1.5f;
    }
    if(key == 'd') {
      div /= 1.5f;
    }
    
    if (k == 'i') {
      movevel *= 2;
    } 
    if (k == 'j') {
      movevel /= 1.5f;
    }
    
    if (key == 'r') {
       // reset
       t = 0.0f; 
       div = SZ/10;
       
       field     = new float[SZ][SZ]; 
       field_vel = new float[SZ][SZ]; 
       f_mask    = new float[SZ][SZ];
    }
    if (key == 'm') {
      f_mask_mod = (f_mask_mod < 0.5f) ? 1.0f : 0.0f;
    }
    
  }
  
  
  
  beginShape();
  texture(a);
  vertex(0, 0, 0, 0);
  vertex(width, 0, a.width, 0);
  vertex(width, height, a.width, a.height);
  vertex(0, height, 0, a.height);
  endShape();
  
}

  static public void main(String args[]) {     PApplet.main(new String[] { "springfield_simple" });  }}