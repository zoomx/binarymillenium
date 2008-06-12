
/// TBD make a texture and draw the colors onto that to get free
/// interpolation when it is scaled up
final int SZ = 80;
float field[][];
float field_vel[][];

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
  
  
  for (int i = 0; i < SZ; i++) {
  for (int j = 0; j < SZ; j++) {
    int c = (int)(field[i][j]*255);
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

 
 
  if(mousePressed) {
    int i = (int) (mouseX/x_sc)%SZ;
    int j = (int) (mouseY/y_sc)%SZ;  
    
    field_vel[i][j] += 0.013;
    
   
  }
 
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
    
    field_vel[i][j] *= 0.9999;
    
    float dx;
    final float k = 0.01;
    
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
    
    
    final float max_vel = 0.05;
    if ( field_vel[i][j] > max_vel)  field_vel[i][j] = max_vel;
    if ( field_vel[i][j] < -max_vel)  field_vel[i][j] = -max_vel;
  }} 
  
}
