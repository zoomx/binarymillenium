final int SZ = 25;

float max_vel = 20.0;
float max_pres = 200.0;

       final float kp = 0.0; //000035;
       final float kv = 0.0;
       final float kavgdp = 0.05;
       final float kdp = 0.5;
       
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
    
    frameRate(25);
  reset();
}

float fadeout(int i, int j)
{
   float retain = 1.0;
   
   final int md = SZ/6;
   if (i < md) retain *= (float)i/md;
   if (j < md) retain *= (float)j/md;
   if ((SZ-i) < md) retain *= (float)(SZ-i)/md;
   if ((SZ-j) < md) retain *= (float)(SZ-j)/md;
   
   retain*= retain;
   //retain*= retain;
   
   return retain;
  
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
      f1[i][j][0] = max_vel/10.0;
      f1[i][j][1] = 0.0;
      
      f1[i][j][2] = max_pres/10.0; 
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
     //float b = (int) (255*(p-min_p)/(max_p-min_p));
     float b = (int) (255*(p/max_pres));
     
      boolean mkij = (mk[i][j] < 0.5);
      a.pixels[j*SZ + i] = mkij ? color(b,b,b) : color(0,200,0) ;  
  
      if ((i > 0) && (j > 0) && (i < SZ-1) && (j < SZ-1)) {
       /// update pressure by adding the sum of all the velocity vectors into a point
       
       float xvl = fw[i-1][j][0];
       float xvr = fw[i+1][j][0];
       float yvl = fw[i-1][j][1];
       float yvr = fw[i+1][j][1];
       
       float xvu = fw[i][j-1][0];
       float xvd = fw[i][j+1][0];
       float yvu = fw[i][j-1][1];
       float yvd = fw[i][j+1][1];
       
       /*
       float xvlu = fw[i-1][j-1][0];
       float xvru = fw[i+1][j-1][0];
       float xvld = fw[i-1][j+1][0];
       float xvrd = fw[i+1][j+1][0];
       
       float yvul = fw[i-1][j-1][1];
       float yvdl = fw[i-1][j+1][1];
       float yvur = fw[i+1][j-1][1];
       float yvdr = fw[i+1][j+1][1];
       */
 
       boolean mkl = (mk[i-1][j] < 0.5);
       boolean mkr = (mk[i+1][j] < 0.5);
       boolean mku = (mk[i][j-1] < 0.5);
       boolean mkd = (mk[i][j+1] < 0.5);
       
       boolean mklu = (mk[i-1][j-1] < 0.5);
       boolean mkrd = (mk[i+1][j+1] < 0.5);
       boolean mkul = (mk[i-1][j-1] < 0.5);
       boolean mkdr = (mk[i+1][j+1] < 0.5);
       
       float pl = fw[i-1][j][2] ;
       float pr = fw[i+1][j][2] ;
       float pu = fw[i][j-1][2] ;
       float pd = fw[i][j+1][2] ;
       
       float plu = fw[i-1][j-1][2] ;
       float prd = fw[i+1][j+1][2] ;
       float pul = fw[i-1][j-1][2] ;
       float pdr = fw[i+1][j+1][2] ;
       
       if (!mkl)  pl = p; ///2 + pl/2;
       if (!mkr)  pr = p;///2 + pr/2;
       if (!mku)  pu = p; ///2 + pu/2;
       if (!mkd)  pd = p;
       
       if (!mklu)  plu = p; ///2 + pl/2;
       if (!mkrd)  prd = p;///2 + pr/2;
       if (!mkul)  pul = p; ///2 + pu/2;
       if (!mkdr)  pdr = p;
       /*
       if (!(mkij && mkl))  pl = p; ///2 + pl/2;
       if (!(mkij && mkr))  pr = p;///2 + pr/2;
       if (!(mkij && mku))  pu = p; ///2 + pu/2;
       if (!(mkij && mkd))  pd = p;
       
       if (!(mkij && mkl))  pl = p; ///2 + pl/2;
       if (!(mkij && mkr))  pr = p;///2 + pr/2;
       if (!(mkij && mku))  pu = p; ///2 + pu/2;
       if (!(mkij && mkd))  pd = p;
       */
       
    
    /*
       float sobel_x = ((xvlu + 2*xvl + xvld) - (xvru + 2*xvr + xvrd))/4;
       float sobel_y = ((yvur + 2*yvu + yvul) - (yvur + 2*yvd + yvul))/4;    
       float sobel = fadeout(i,j)*(sobel_x+sobel_y);
       */
       float avg_dp = (2*(pl + pr + pu + pd) + (plu + prd + pul + pdr)-12*p)*kavgdp*fadeout(i,j);
        
       
       float dp = (xvl*pl + yvu*pl - xvr*pr - yvd*pl)*kdp*fadeout(i,j);
       
   
       if (mkij) {
         fnew[i][j][2] = p + avg_dp + dp;
                             
         if (fnew[i][j][2] < 0) fnew[i][j][2]  = 0;  
         if (fnew[i][j][2] > max_pres) fnew[i][j][2]  = 100.0;    
       } else {  
         fnew[i][j][2] = 0;
       }
  
       

      // float pxdiff = xvl*(pl-p)*kp + xvr*(p-pr)*kp;  
      // float pydiff = yvu*(pu-p)*kp + yvd*(p-pd)*kp; 
       float pxdiff = (pl-pr);  
       float pydiff = (pu-pd); 

      // float avg_x = ((xvlu + 2*xvl + xvld) + 3*xv + (xvru + 2*xvr + xvrd))/11;
       //float avg_y = ((yvur + 2*yvu + yvul) + 3*yv + (yvur + 2*yvd + yvul))/11;
  
       float ptot  = pl + pr + pu + pd;
       
       float new_xv = pl/ptot*xvl + pl/ptot*xvu + pr/ptot*xvr + pl/ptot*xvd;
       float new_yv = pu/ptot*yvu + pd/ptot*yvd + pu/ptot*yvl + pd/ptot*yvr;
  
       fnew[i][j][0] = mkij ? xv /*xv*(1.0-kv) + new_xv*kv + pxdiff*kp*/ : 0.0;
       fnew[i][j][1] = mkij ? yv /*yv*(1.0-kv) + new_yv*kv + pydiff*kp*/ : 0.0; 
    
       //fnew[i][j][0] = mkij ? xv + pxdiff : 0.0;
       //fnew[i][j][1] = mkij ? yv + pydiff : 0.0;
    
       /// zero out velocity if there is no pressure
       /*if (fnew[i][j][2] <= 0.0) {
         fnew[i][j][0] = 0;
         fnew[i][j][1] = 0;
       }
       
       
       float vel_mag = sqrt(fnew[i][j][0]*fnew[i][j][0] + fnew[i][j][1]*fnew[i][j][1]);
       if (vel_mag > max_vel) {
         fnew[i][j][0] *= max_vel/vel_mag;
         fnew[i][j][1] *= max_vel/vel_mag;
       }
       */
     
  } else {
        
    /// keep boundary the same velocity and pressure
    fnew[i][j][2] = p;
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
      
      //print(x + " " + y + "\n");
     
   }
  
  
  /////////
 float ox = -1; //width/SZ/2;
 float oy = -1; //height/SZ/2;
   beginShape();
  texture(a);
  vertex(0, 0,ox ,oy );
  vertex(width, 0, a.width+ox, oy);
  vertex(width, height, a.width+ox, a.height+oy);
  vertex(0, height, ox, a.height+oy);
  endShape(); 
  
  if (true) {
 int ox2 = (width/SZ)/2;
 int oy2 = (height/SZ)/2;
  for (int i = 0; i < SZ; i+=1) {
  for (int j = 0; j < SZ; j+=1) {
    int x = i*width/SZ + ox2;
    int y = j*height/SZ + oy2;
    stroke(color(255,0,0));
    //line(x, y ,x + f1[i][j][2]*f1[i][j][0]*0.04,y+f1[i][j][2]*f1[i][j][1]*0.04);
    line(x, y ,x + f1[i][j][0]*3,y+f1[i][j][1]*3);
    stroke(color(95,0,0));
    //line(x, y ,x + f1[i][j][2]*f1[i][j][0]*0.02,y+f1[i][j][2]*f1[i][j][1]*0.02);
    line(x, y ,x + f1[i][j][0]*1.2,y+f1[i][j][1]*1.2);
  }}
  }
  
  if (keyPressed) {
     if (key == 'r') {
        reset();
     } 
  }
}
