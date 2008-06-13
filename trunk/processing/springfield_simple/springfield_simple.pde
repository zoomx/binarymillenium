
/*

binarymillenium 2008

gnu gpl
*/
 
final boolean wrap_edges = false;
final boolean do_gassy = true;
final int SZ = 90;

/// difference between left and right makes it seem like the water is moving
final float k = 0.02;

final float max_vel = 0.3;
final float gravity = 0.00001;

float t;

float field[][];
float field_vel[][];

float f_mask[][];


float x_sc, y_sc;

PImage a;

void setup() {
 
 field = new float[SZ][SZ]; 
 field_vel = new float[SZ][SZ]; 
 f_mask = new float[SZ][SZ];
 

  
 size(640,480,P3D);
 
   a = new PImage();
     a.width = SZ;
     a.height = SZ;
     a.pixels = new color[a.width*a.height];
 
 x_sc = width/SZ;
 y_sc = height/SZ;
 
 frameRate(30);
 
}

void draw() {
 noStroke();
  
       t += 0.002;


 
 
  if(mousePressed) {
    int i = (int) (mouseX/x_sc)%SZ;
    int j = (int) (mouseY/y_sc)%SZ;
  
    if (i < 0) i =0;
    if (j < 0) j =0;  
    
    field_vel[i][j] += 0.007;
    
   
  }
  
  
  float min_field = 1000;
  float max_field = 0;
 
  for (int i = 0; i < SZ; i++) {
  for (int j = 0; j < SZ; j++) {
    
    {
      float div = 10.0;
      float f =   0.01*noise(i/div,j/div,t) + 0.9*noise(i/(4*div),j/(4*div),t); 
 
    float th = 0.4;
    f_mask[i][j] = f*f;//(f > th ? (0.5+0.5*f) : 0.1*f/th);
    }
  
    field[i][j] += field_vel[i][j];

    field_vel[i][j] -= gravity;
       
    if (field[i][j] < f_mask[i][j]) {
        field[i][j] = f_mask[i][j];
       field_vel[i][j] = 0;//-field_vel[i][j]*0.05;
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
      k1 *= 2.0*(field[i][j]-f_mask[i][j]);
      k2 *= 2.0*(field[i][j]-f_mask[i][j]);
    }
    
    
    if (i < SZ-1) {
      k1 += 2.0*(field[i][j]-f_mask[i][j]);
      k2 += 2.0*(field[i+1][j]-f_mask[i+1][j]);
      
      dx = field[i+1][j] - field[i][j];
      field_vel[i][j]   += dx*k1;
      field_vel[i+1][j] -= dx*k2;
    } else if (wrap_edges ) {
      dx = field[0][j] - field[i][j];
      field_vel[i][j] += dx*k1;
      field_vel[0][j] -= dx*k2;
    }
    if (j < SZ-1) {
          k1 += 2.0*(field[i][j]-f_mask[i][j]);
      k2 += 2.0*(field[i][j+1]-f_mask[i][j+1]);
      
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
      int b = (int)( ((field[i][j]-f_mask[i][j]))*255); 
      a.pixels[j*SZ+i] = color(c,c,b);
    } else {
      a.pixels[j*SZ+i] = color(c,c,c);
    }
    
    //rect(i*x_sc,j*y_sc, x_sc,y_sc);
  }}
  
  
  beginShape();
  texture(a);
  vertex(0, 0, 0, 0);
  vertex(width, 0, a.width, 0);
  vertex(width, height, a.width, a.height);
  vertex(0, height, 0, a.height);
  endShape();
  
}
