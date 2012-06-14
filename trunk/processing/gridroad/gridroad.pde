
/**

*/



float BWD = 50.0;
int NUM = 50;

float[][] elev;//[NUM][NUM];

void setup()
{
  size(800, 600, P3D);
  frameRate(10);
  
  elev = new float[NUM][NUM];
  
  for (int i = 0; i < NUM; i++) {
    for (int j = 0; j < NUM; j++) {
      elev[i][j] = -0.5*(i*j);//(noise(i*0.1,j*0.1)-0.5);
    }
  }
}

float x;
float y;
float z;


void keyPressed()
{
  float sc = 10;
  if (key == 'w') {
    z -= sc*1.21;
  }
  if (key == 's') {
    z += sc*3;
  }  
  if (key == 'a') {
    x -= sc*3.11;
  }
  if (key == 'd') {
    x += sc*3;
  }  
  if (key == 'q') {
    y -= sc*3.11;
  }
  if (key == 'z') {
    y += sc*3;
  }  
}

float y_off;
void draw()
{
  background(0);
  
  directionalLight(255,255,220,0.2,1.0,-0.3);
  
  translate(width/2- NUM*BWD/2, height/2, width/2 - NUM*BWD/2);
  
  int i_loc = (int)((z+BWD/2.0)/BWD + NUM/2);
  int j_loc = (int)((x+BWD/2.0)/BWD + NUM/2);
  
  if ((i_loc >= 0) && (i_loc < NUM) && (j_loc >= 0) && (j_loc <= NUM)) {
   y_off = elev[i_loc][j_loc];
  }
  println(x + ", " + j_loc + ", " + z + ", " + i_loc + ", y " + y + "," +  y_off);
  
  translate(-x, -y + y_off, -z);
  
  //stroke(50);
  
  fill(0,150,0);

  
  noStroke();
  for (int i = 0; i < NUM; i++) {
    pushMatrix();
    for (int j = 0; j < NUM; j++) {
      pushMatrix();
      translate(0, -elev[i][j], 0);
      box(BWD);
      popMatrix();
      translate(BWD,0,0);
    }
    popMatrix();
    translate(0,0,BWD);
    //translate(-10*20, 0, 10);
    
  }
    
}
