

float field1[][][];

float field2[][][];

/// ping-pong between the two fields
boolean which_field;

final int LEN = 40;

float x_scale, y_scale;

void setup() {

  frameRate(10);
  
   field1 = new float[LEN][LEN][2];
   field2 = new float[LEN][LEN][2];  
   
    size(400,400);
    
    x_scale = width/LEN;
    y_scale = height/LEN;
  
    
}

int old_mouseX;
int old_mouseY;

void draw() {
 


      
      if (which_field) {
         update_field(field1,field2);
      } else {
         update_field(field2, field1); 
      }
  

    which_field = !which_field;
  
}

void update_field(float field[][][], float new_field[][][]) {
  

  ////
  /// create disturbances based on mouse position and propagate them
  for (int i = 0; i< LEN; i++) {
  for (int j = 0; j< LEN; j++) {
      
        
  float vx = field[i][j][0] - new_field[i][j][0];
  float vy = field[i][j][1] - new_field[i][j][1];
  
  float magv = sqrt(vx*vx + vy*vy);
  
  /// decay old value
  float f = 0.45;
  new_field[i][j][0] = field[i][j][0]*f;// - vx*f;
  new_field[i][j][1] = field[i][j][1]*f;// - vy*f;
  
  }}
  
  for (int i = 0; i< LEN; i++) {
  for (int j = 0; j< LEN; j++) {
    
    float d = atan2(field[i][j][1], field[i][j][0]);
    
    
    float f  = 0.4;
    if (i > 0) { 
      if (field[i][j][0] > 0) {
        //new_field[i-1][j][0] += field[i][j][0] * cos(d)*f; 
      } else {
        new_field[i-1][j][0] += field[i][j][0] * abs(cos(d))*f;
        new_field[i-1][j][1] += field[i][j][1] * abs(cos(d))*f;
      }
    }
 
    if (i < LEN - 1) { 
      if (field[i][j][0] > 0) {
        new_field[i+1][j][0] += field[i][j][0] * abs(cos(d))*f; 
        new_field[i+1][j][1] += field[i][j][1] * abs(cos(d))*f;
      } else {
        //new_field[i+1][j][0] += field[i][j][0] * cos(d)*f; 
      }
    } 
   
   ///
    if (j > 0) { 
      if (field[i][j][1] > 0) {
        //new_field[i-1][j][0] += field[i][j][0] * cos(d)*f; 
      } else {
        new_field[i][j-1][0] += field[i][j][0] * abs(sin(d))*f;
        new_field[i][j-1][1] += field[i][j][1] * abs(sin(d))*f;
      }
    }
 
    if (j < LEN - 1) { 
      if (field[i][j][1] > 0) {
        new_field[i][j+1][0] += field[i][j][0] * abs(sin(d))*f;
        new_field[i][j+1][1] += field[i][j][1] * abs(sin(d))*f; 
      } else {
        //new_field[i+1][j][0] += field[i][j][0] * cos(d)*f; 
      }
    } 
   
   
   
  }}
  
  int mx = (int)(mouseX/x_scale) % LEN;
  int my = (int)(mouseY/y_scale) % LEN;

  float vx = (mouseX - old_mouseX)/x_scale;
  float vy = (mouseY - old_mouseY)/y_scale;


  new_field[mx][my][0] += vx;
  new_field[mx][my][1] += vy;

  old_mouseX = mouseX;
  old_mouseY = mouseY;
  ///  
//print(mx + " " + my + ", " + vx + " " + vy + "\n");
  ///  
  
  draw_field(new_field);
}

void draw_field(float field[][][]) {
  
   background(0);
   
   for (int i = 0; i< LEN; i++) {
   for (int j = 0; j< LEN; j++) {
     
      if (field[i][j][0] > x_scale) field[i][j][0] = x_scale;
      if (field[i][j][1] > y_scale) field[i][j][1] = y_scale;
      if (field[i][j][0] < -x_scale) field[i][j][0] = -x_scale;
      if (field[i][j][1] < -y_scale) field[i][j][1] = -y_scale;
      
      int x = (int)(i*x_scale);
      int y = (int)(j*y_scale);
      stroke(color(255,0,0));
      line(x,y, x + field[i][j][0], y+field[i][j][1]);
     
   
  }}  
}
