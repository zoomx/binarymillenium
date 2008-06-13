
/// TBD make a texture and draw the colors onto that to get free
/// interpolation when it is scaled up
final int SZ = 70;
float field[][];
float field_vel[][];

final float k = 0.08;
final float max_vel = 0.15;

float x_sc, y_sc;

PImage a;

void setup() {
 field = new float[SZ][SZ]; 
 field_vel = new float[SZ][SZ]; 
  
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
  
  


 
 
  if(mousePressed) {
    int i = (int) (mouseX/x_sc)%SZ;
    int j = (int) (mouseY/y_sc)%SZ;
  
    if (i < 0) i =0;
    if (j < 0) j =0;  
    
    field_vel[i][j] += 0.013;
    
   
  }
  
  
  float min_field = 1000;
  float max_field = 0;
 
  for (int i = 0; i < SZ; i++) {
  for (int j = 0; j < SZ; j++) {

  
    field[i][j] += field_vel[i][j];

    if (field[i][j] > 1.0) {
        field_vel[i][j] = -field_vel[i][j]*0.4;
        field[i][j] = 1.0;
    }
    if (field[i][j] < 0.0) {
        field[i][j] = 0.0;
        field_vel[i][j] = -field_vel[i][j]*0.4;
    }
    
    field_vel[i][j] *= 0.998;
    field[i][j] *= 0.998;
    
    if (field[i][j] > max_field) max_field = field[i][j];
    if (field[i][j] < min_field) min_field = field[i][j];
    
    float dx;
 
    
    if (i < SZ-1) {
      dx = field[i+1][j] - field[i][j];
      field_vel[i][j] += dx*k;
      field_vel[i+1][j] -= dx*k;
    } else {
      dx = field[0][j] - field[i][j];
      field_vel[i][j] += dx*k;
      field_vel[0][j] -= dx*k;
    }
    if (j < SZ-1) {
      dx = field[i][j+1] - field[i][j];
      field_vel[i][j] += dx*k;
      field_vel[i][j+1] -= dx*k;
    } else {
      dx = field[i][0] - field[i][j];
      field_vel[i][j] += dx*k;
      field_vel[i][0] -= dx*k;      
    }
    
    

    if ( field_vel[i][j] > max_vel)  field_vel[i][j] = max_vel;
    if ( field_vel[i][j] < -max_vel)  field_vel[i][j] = -max_vel;
  }} 
  
  
    for (int i = 0; i < SZ; i++) {
  for (int j = 0; j < SZ; j++) {
    int c = (int)( (field[i][j]-min_field)/(max_field-min_field)*255);
    if (c > 255) c = 255;
    if (c < 0) c = 0;
    
    a.pixels[j*SZ+i] = color(c,c,c);
    
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
