/**
* optical flow 
*
* binarymillenium
* June 2008
*
* Licensed under the latest version of the GNU GPL
*
*/

PImage a;

color old_pixels[];

    
     // weight the center pixel most heavily, make this a gaussian later
    float weight(int i,int j) {
      /*
        float div = (flow_point.s/2);
        float x = (i - div)/div;
        float y = (j - div)/div;
        
        return 1.0-sqrt(x*x + y*y);
        */
        
        return 1.0;
        
        
    }

class flow_point {
    float x;
    float y;
    
    static final int s = 12;
    
    PImage pixel_block;
    PImage old_pixel_block;
    
    PImage diff_x;
    PImage diff_y;
    PImage diff_t;

    
    flow_point(float x, float y) {
      this.x = x;
      this.y = y;
      
      pixel_block = new PImage();
      pixel_block.width = s;
      pixel_block.height = s;
      pixel_block.pixels = new color[s*s];
      
      old_pixel_block = new PImage();
      old_pixel_block.width = s;
      old_pixel_block.height = s;
      old_pixel_block.pixels = new color[s*s];
      
      diff_x = new PImage();
      diff_x.width = s;
      diff_x.height = s;
      diff_x.pixels = new color[s*s];
      
      diff_y = new PImage();
      diff_y.width = s;
      diff_y.height = s;
      diff_y.pixels = new color[s*s];
      
      diff_t = new PImage();
      diff_t.width = s;
      diff_t.height = s;
      diff_t.pixels = new color[s*s];
      
      der_x = new float[s*s];
      der_y = new float[s*s];
      der_t = new float[s*s];
     
    } 
    
    float[] der_x;
    float[] der_y;
    float[] der_t;
    

    
    void draw() {
      
      float max_dx = 0;
      float max_dy = 0;
      float max_dt = 0;
      
      float min_dx = 0;
      float min_dy = 0;
      float min_dt = 0;
    
        for (int i = 0; i < diff_x.pixels.length; i++) {
            if (der_x[i] > max_dx) {max_dx = der_x[i];}
            if (der_y[i] > max_dx) {max_dy = der_y[i];}
            if (der_t[i] > max_dx) {max_dt = der_t[i];}
            
            if (der_x[i] < min_dx) {min_dx = der_x[i];}
            if (der_y[i] < min_dx) {min_dy = der_y[i];}
            if (der_t[i] < min_dx) {min_dt = der_t[i];}
            
        }
          
       for  (int i = 0; i < diff_x.pixels.length; i++) {
         
         color cdx;
         color cdy;
         color cdt;
         
           if (der_x[i] > 0) {
             int d = (int)(255*der_x[i]/max_dx);
             cdx = color(d, 0,0);
           } else {
             int d = (int)(255*der_x[i]/min_dx);
             cdx = color(0, d,0);
           }
           
           if (der_y[i] > 0) {
             int d = (int)(255*der_y[i]/max_dy);
             cdy = color(d, 0,0);
           } else {
             int d = (int)(255*der_y[i]/min_dy);
             cdy = color(0, d,0);
           }
           
           if (der_t[i] > 0) {
             int d = (int)(255*der_t[i]/max_dt);
             cdt = color(d, 0,0);
           } else {
             int d = (int)(255*der_t[i]/min_dt);
             
             cdt = color(0, d,0);
           }
          
           diff_x.pixels[i] = cdx;
           diff_y.pixels[i] = cdy; 
           diff_t.pixels[i] = cdt; 
        }
      
         /// this will screw with the optical flow, since in the next step these markers may not be covered up
         fill(color(255,0,0,10));
        rect(x , y, s,s);
        
        
       
        image(pixel_block,0, s, s, s);
        image(diff_x,s, s, s, s);
        image(diff_y,0, 2*s, s, s);
        image(diff_t,s, 0, s, s);
        image(old_pixel_block,0, 0, s, s);
        
     
    }
    
};

flow_point fp[];
/////////////////////////////////////////////////////////////////////////


void setup() {
  
  frameRate(5);
  
  size(600,600,P3D);
  
  old_pixels = new color[width*height];
  
  
  /// create high contrast texture
  //randomSeed(0);
  //noiseSeed(0);
  //loadPixels();
  
    final float div = 2.0;
    final float div2 = 35.0;
     final float div3 = 65.0;
    
    a = new PImage();
     a.width = 400;
     a.height = 400;
     a.pixels = new color[a.width*a.height];
     
     for (int i = 0; i < a.width; i++) {
       for (int j = 0; j < a.height; j++) {
         
         float val = (0.3*noise(i/div,j/div) + 
                            0.5*noise(i/div2,j/div2) + 
                            0.5*cos(PI*noise(i/div3,j/div3)) + 
                            0.5*cos(PI*noise(i/10.0,j/10.0)) +
                            0.3*cos(PI*noise(i/25.0,j/55.0)));
         
         val*=val;
         if (val > 1.0) val = 1.0;

         
         int c = (int)(255*val);
        // float trans = noise(i/div,j/div);
        
        //trans *= trans*trans*trans*0.5;
      
         a.pixels[i*a.height +j] = color(c,c,c);//,(int)(255*trans));
         
     }}
  

  /// setup initial optical flow points
  fp = new flow_point[1];
  
  for (int i = 0; i < fp.length; i++) {
    fp[i] = new flow_point(width/2,height/2  );//random(width-flow_point.s-1),random(height-flow_point.s-1));
  }
  
  colorMode(RGB); //,255,255,255,100);
  
  //smooth();
  background(0);
  
}

////////////////////////////////////////////////////////////////////
/// send a pixel block in and compute the partial derivative of it
float[] i_x(color[][] pixel_block) {

  float der_x[] = new float[0]; 
  
  for (int i = 0; i < pixel_block.length-1; i++) {
  for (int j = 0; j < pixel_block[i].length; j++) {
    
    float diff = brightness(pixel_block[i][j]) -  brightness(pixel_block[i+1][j]);

                              
    der_x = append(der_x,  diff*weight(i,j));
  }} 
  
  // add row of zeros to make der_x same size as source pixel blocks
  for (int j = 0; j < pixel_block.length; j++) {
    der_x = append(der_x, 0);
  }
  
  
  return der_x;
}

/// send a pixel block in and compute the partial derivative of it
float[] i_y(color[][] pixel_block) {
  
  float der_y[] = new float[0]; 
  

  for (int i = 0; i < pixel_block.length; i++) {
  for (int j = 0; j < pixel_block[i].length-1; j++) {
    
    float diff = (float)brightness(pixel_block[i][j]) - (float)brightness(pixel_block[i][j+1]);
        
    der_y = append(der_y, diff*weight(i,j));
    
  }
  
  // add column of zeros to make der_x same size as source pixel blocks
  der_y = append(der_y, 0);
  //print("\n");
} 
  
  return der_y;
}

/// send a pixel block in and compute the partial derivative of it
float[] i_t(color[][] pixel_block,color[][] old_pixel_block) {
  
  float der_y[] = new float[0]; 
  

  for (int i = 0; i < pixel_block.length; i++) {
  for (int j = 0; j < pixel_block[i].length; j++) {
    
    float diff = brightness(pixel_block[i][j]) -  brightness(old_pixel_block[i][j]);
                              
    der_y = append(der_y, diff*weight(i,j)  );
  }} 
  
  return der_y;
}

/// return Vx Vy of 
float[] optical_flow(flow_point tfp) {
  
  float[][] a_mat = new float[2][2];
  
  float[] b_vec = new float[2];
  
  
  int [][] new_pix = new int[flow_point.s][flow_point.s];
  int [][] old_pix = new int[flow_point.s][flow_point.s];
  
  for (int j = 0; j < flow_point.s; j++) {
  for (int k = 0; k < flow_point.s; k++) {
    new_pix[j][k] = tfp.pixel_block.pixels[j*flow_point.s + k];
    old_pix[j][k] = tfp.old_pixel_block.pixels[j*flow_point.s + k];  
  }}  
  
  tfp.der_y = i_y(new_pix);
  tfp.der_x = i_x(new_pix);
  tfp.der_t = i_t(new_pix, old_pix);
  
  /// the pixel_block should be square, ignore anything but largest square inside it
  //print("der ");
    for (int i = 0; i < min(tfp.der_y.length,tfp.der_x.length, tfp.der_t.length); i++) {
    //    print(der_x[i] + " " + der_y[i] + " " + der_t[i] + ", ");
      
        a_mat[0][0] += tfp.der_x[i] * tfp.der_x[i];
        a_mat[0][1] += tfp.der_x[i] * tfp.der_y[i];
        a_mat[1][0] += tfp.der_x[i] * tfp.der_y[i];
        a_mat[1][1] += tfp.der_y[i] * tfp.der_y[i];
        
        b_vec[0] += tfp.der_x[i]*tfp.der_t[i];
        b_vec[1] += tfp.der_y[i]*tfp.der_t[i];
      }
     // print("\n");
     // print("\n");
      
      float vel_vec[] = new float[2];
      
      /// invert a_mat
      float[][] inv_a_mat = new float[2][2];
      
      /// if this is zero this is probably a bad point- just move around manually or don't 
      /// move at all until something happens with it.
      float det_div = a_mat[0][0]*a_mat[1][1] - a_mat[1][0]*a_mat[0][1];
      
      if (det_div != 0.0) {
      float det_a = 1/det_div;
      
      
      inv_a_mat[0][0] = det_a * a_mat[1][1];
      inv_a_mat[0][1] = det_a * inv_a_mat[1][0];
      inv_a_mat[1][0] = det_a * inv_a_mat[1][1];
      inv_a_mat[1][1] = det_a * a_mat[0][0];
        
      /// multiply inv_a_mat * b_vec to get vel_vec;
      
      vel_vec[0] = inv_a_mat[0][0] * b_vec[0] + inv_a_mat[1][0] * b_vec[1]; 
      vel_vec[1] = inv_a_mat[0][1] * b_vec[0] + inv_a_mat[1][1] * b_vec[1];     
      
      //print("det_a " + det_a + ", " + vel_vec[0] + " " + vel_vec[1] + ", ");
      } 
  
    return vel_vec;
}
////////////////////////////////////////////////////////////////////////////////


float t;
void draw() {
  
  background(0);
  
  //t-= 2.0;
  t+= 0.01;

  
  float ofs[] = new float[8];
  for (int i = 0; i< ofs.length; i++) {
    ofs[i] = 300.0*(noise(t,i/10.0)-0.5);
  }

// temp
//ofs[1] = 0;
ofs[3] = ofs[1];
ofs[5] = ofs[1];
ofs[7] = ofs[1];

//ofs[0] = t;
ofs[2] = ofs[0];
ofs[4] = ofs[0];
ofs[6] = ofs[0];

beginShape();
texture(a);

/*
vertex(0, 0, 0+ofs[0], ofs[1]);
vertex(width, 0, a.width+ofs[2], 0+ofs[3]);
vertex(width, height, a.width + ofs[4], a.height+ofs[5]);
vertex(0, height, 0+ofs[6], a.height+ofs[7]);
*/
vertex( 0+ofs[0], ofs[1], 0, 0);
vertex(width+ofs[2], 0+ofs[3], a.width,0);
vertex(width + ofs[4], height+ofs[5], a.width, a.height);
vertex( 0+ofs[6], height+ofs[7], 0, a.height);
endShape();

  
  
  /// do optical flow, copy areas of screen in to little buffers to be processed
  loadPixels();
  

  
  for (int i = 0; i < fp.length; i++) {
    //arraycopy( fp[i].pixel_block.pixels, fp[i].old_pixel_block.pixels );
    
    
    for (int j = 0; j < flow_point.s; j++) {
      for (int k = 0; k < flow_point.s; k++) {
        
        int pix_ind = (int)(fp[i].y + j)*width  + (int)(fp[i].x + k);
        fp[i].pixel_block.pixels[j*flow_point.s + k] = pixels[pix_ind];
        
         fp[i].old_pixel_block.pixels[j*flow_point.s + k] = old_pixels[pix_ind];
       
  }}
    
    float[] vxy = optical_flow(fp[i]);
    
    /// so far this seems to be handling negative motions by scaling down the 
    /// vxy - 0.6* value that would be seen in opposite direction
    //if (vxy
    fp[i].x += vxy[1];
    fp[i].y += vxy[0];
    
    /// this movement will invalidate what's in the old_pixel
    
    print(vxy[0] + " " + vxy[1] + "\n");
    
    
    if (fp[i].x >= width - flow_point.s - 1 ) fp[i].x = width -flow_point.s - 1;
    if (fp[i].x < 0) fp[i].x = 0;
    if (fp[i].y >= height - flow_point.s - 1 ) fp[i].y = height -flow_point.s -1;    
    if (fp[i].y < 0) fp[i].y = 0;  
    
    
  }
  //print("\n");
    
    /// need to keep a buffer of the entire screen around
    arraycopy(pixels, old_pixels );
    
    /// draw points to indicate flow point locations.
  for (int i = 0; i < fp.length; i++) {
    fp[i].draw();

  }
  
  
}
