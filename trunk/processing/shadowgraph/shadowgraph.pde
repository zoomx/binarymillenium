final int SZ = 40;

/// xy vector flow field, plus pressure
float f1[][][];
float f2[][][];

// the mask that has blocking objects 
float mk[][];

PImage a;

float min_x;
float max_x;
float min_y;
float max_y;
float min_p;
float max_p;

void setup() {
    size(640,480,P3D);
    
    frameRate(15);
  reset();
}

void reset() {
     f1 = new float[SZ][SZ][3];
     f2 = new float[SZ][SZ][3];
     mk = new float[SZ][SZ];
     
      a = new PImage();
     a.width = SZ;
     a.height = SZ;
     a.pixels = new color[a.width*a.height];
     
   // the left most line is a constant velocity and should not
   // be changed
   for (int i = 0; i < SZ; i++) {
   for (int j = 0; j < SZ; j++) {
      f1[i][j][0] = -1.0;
      f1[i][j][1] = -0.4;
      
      f1[i][j][2] = 50.0; 
   }}
}

float[][][] update_f(float[][][] fw, float[][][] fnew) {
  float new_min_x = 100.0;
  float new_max_x = 0;
  float new_min_y = 100.0;
  float new_max_y = 0;
  float new_min_p = 100.0;
  float new_max_p = 0;  
  
  for (int i = 0; i < SZ; i++) {
  for (int j = 0; j < SZ; j++) { 
     float xv = fw[i][j][0];
     float yv = fw[i][j][1];  
     float p  = fw[i][j][2];  
    
     if (xv > new_max_x) new_max_x = xv;
     if (xv < new_min_x) new_min_x = xv;
     if (yv > new_max_y) new_max_y = yv;
     if (yv < new_min_y) new_min_y = yv;
     if (p > new_max_p) new_max_p = p;
     if (p < new_min_p) new_min_p = p;
     
    
     
     
     float r = (int) (255*(xv-min_x)/(max_x-min_x));
     float g = (int) (255*(yv-min_y)/(max_y-min_y));
     float b = (int) (255*(p-min_p)/(max_p-min_p));
     
      boolean mkij = (mk[i][j] < 0.5);
      a.pixels[j*SZ + i] = mkij ? color(b,b,b) : color(0,200,0) ;  
  
       /// update pressure by adding the sum of all the velocity vectors into a point
       
       float xvl = (i > 0)   ? fw[i-1][j][0] : fw[i+1][j][1];
       float xvr = (i < SZ-1)? fw[i+1][j][0] : xvl;
       float yvu = (j > 0)   ? fw[i][j-1][1] : fw[i][j+1][1];
       float yvd = (j < SZ-1)? fw[i][j+1][1] : yvu;
       
       boolean mkl = (i > 0)   ? (mk[i-1][j] < 0.5) : true;
       boolean mkr = (i < SZ-1)? (mk[i+1][j] < 0.5) : true;
       boolean mku = (j > 0)   ? (mk[i][j-1] < 0.5) : true;
       boolean mkd = (j < SZ-1)? (mk[i][j+1] < 0.5) : true;
       
       float pl  = (mkij && mkl) && (i > 0)   ? fw[i-1][j][2] : p;
       float pr  = (mkij && mkr) && (i <SZ-1) ? fw[i+1][j][2] : p;
       float pu  = (mkij && mku) && (j > 0)   ? fw[i][j-1][2] : p;
       float pd  = (mkij && mkd) && (j <SZ-1) ? fw[i][j+1][2] : p;
       
       if (mkij) {
         fnew[i][j][2] = p + yvu - yvd + xvl - xvr;
         if (fnew[i][j][2] < 0) fnew[i][j][2]  = 0;  
         if (fnew[i][j][2] > 100.0) fnew[i][j][2]  = 100.0;    
       } else {  
         fnew[i][j][2] = 0;
       }
       
       final float kp = 0.002;
       final float kv = 0.05;
       float pxdiff = (pl-p)*kp + (p-pr)*kp;  
       float pydiff = (pu-p)*kp + (p-pd)*kp;  
       float xvdiff = (xvl-xv)*kv + (xv-xvr)*kv;
       float yvdiff = (yvu-yv)*kv + (yv-yvd)*kv;
       
       /// keep boundary the same velocity
       if ((i > 0) && (j > 0) && (i < SZ-1) && (j < SZ-1)) {
         fnew[i][j][0] = mkij ? xv  /*xvdiff ; pxdiff*/ : 0.0;
         fnew[i][j][1] = mkij ? yv : 0.0;// + /*yvdiff;// +*/ pydiff;
       } else {
         fnew[i][j][0] = xv;
         fnew[i][j][1] = yv;
       }
     
     
  }
  } 
  
  /// could do a simple filter here
  max_x = new_max_x;
  min_x = new_min_x;
  max_y = new_max_y;
  min_y = new_min_y;
  max_p = new_max_p;
  min_p = new_min_p;
  
  return fnew;
}

boolean toggle = true;

void draw() {

  
   if (toggle) { 
       f2 = update_f(f1,f2);
   } else { 
       f1 = update_f(f2,f1);
   }
   toggle = !toggle; 
   
   if (mousePressed) {
      int x = (int)(mouseX/(width/SZ)); 
      int y = (int)(mouseY/(height/SZ)); 
      
      x = (abs(x)%SZ);
      y = (abs(y)%SZ);
      
      mk[x][y] = 1.0; //1.0-mk[x][y];
      
      print(x + " " + y + "\n");
     
   }
  
  
  /////////
   beginShape();
  texture(a);
  vertex(0, 0, 0, 0);
  vertex(width, 0, a.width, 0);
  vertex(width, height, a.width, a.height);
  vertex(0, height, 0, a.height);
  endShape(); 
  
  for (int i = 0; i < SZ; i+=1) {
  for (int j = 0; j < SZ; j+=1) {
    int x = i*width/SZ;
    int y = j*height/SZ;
    stroke(color(255,0,0));
    line(x, y ,x + f1[i][j][0]*6.0,y+f1[i][j][1]*6.0);
  }}
  
  if (keyPressed) {
     if (key == 'r') {
        reset();
     } 
  }
}
