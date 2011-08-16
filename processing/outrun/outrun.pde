

void setup()
{
  size(720,480);
  frameRate(5);
  
  background(0);
}

PImage multImg(PImage i1, PImage i2) 
{
  i1.loadPixels();
  i2.loadPixels();
  
  PImage rv = createImage(i1.width, i2.height, RGB);
  
  if ((i1.width != i2.width) || (i1.height != i2.height))  {
    print("imgMult size mismatch");
    return rv; 
  }

  for (int y = 0; y < i1.height; y++) {
    for (int x = 0; x < i1.width; x++) {
      final int ind = y*i1.width+x;
      
      float i1p = red(i1.pixels[ind]);
      float i2p = red(i2.pixels[ind]);
      
      rv.pixels[ind] = color(i1p*i2p/255);
    }
  }
    
  rv.updatePixels();
  return rv;
}

PImage binarize(PImage img, int thresh, int fillc) 
{
img.loadPixels();

PImage bin_img = createImage(img.width, img.height, RGB);

  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      final int ind = y*img.width+x;
      
      if (red(img.pixels[ind]) > thresh) {
        bin_img.pixels[ind] = color(fillc);
      }
    }
  }
    
  bin_img.updatePixels();
  return bin_img;
}

float[][] kernel = { { -1, -1, -1 },
                     { -1,  9, -1 },
                     { -1, -1, -1 } };
                     
PImage edgeDetect(PImage img) 
{
  /*
  float ksum = 0;
  for (int ky = -1; ky <= 1; ky++) {
    for (int kx = -1; kx <= 1; kx++) {
      ksum += kernel[ky+1][kx+1];
  }}*/
  
img.loadPixels();
// Create an opaque image of the same size as the original
PImage edgeImg = createImage(img.width, img.height, RGB);
// Loop through every pixel in the image.
for (int y = 1; y < img.height-1; y++) { // Skip top and bottom edges
  for (int x = 1; x < img.width-1; x++) { // Skip left and right edges
  
    float sum = 0; // Kernel sum for this pixel
    
    for (int ky = -1; ky <= 1; ky++) {
      for (int kx = -1; kx <= 1; kx++) {
        // Calculate the adjacent pixel for this kernel point
        int pos = (y + ky)*img.width + (x + kx);
        // Image is grayscale, red/green/blue are identical
        float val = red(img.pixels[pos]);
        // Multiply adjacent pixels based on the kernel values
        sum += kernel[ky+1][kx+1] * val;
      }
    }
    
    // For this pixel in the new image, set the gray value
    // based on the sum from the kernel
    edgeImg.pixels[y*img.width + x] = color(sum/8);
    //if (sum > 0) {print(sum + "\n");}
    
  }
}
// State that there are changes to edgeImg.pixels[]
edgeImg.updatePixels();
return edgeImg;
}
//image(edgeImg, 100, 0); // Draw the new image

float t = 0;

PImage noiseImage(int w, int h, boolean radial_fade)
{
  
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  
  final int HW = img.width/2;
  final float MAX_R = 0.8 * sqrt(2.0*(HW*HW));
  final float LIM_R = MAX_R/2.0;
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      
      float val = noise(x/15.0,y/8.0, t);
      float val2 = noise(x/50.0,y/30.0, t);
      float val3 = noise(x/2.0,y/2.0, t);
      float tval = (val*0.7 + val2*0.2 + val3*0.1);
      
      if (radial_fade) {
      float r = sqrt( (y-HW)*(y-HW) + (x-HW)*(x-HW));
      
      if (r > MAX_R) {r = MAX_R; }
      if (r > LIM_R) {
        tval *=  1.0 - (r - LIM_R)/(MAX_R - LIM_R);  
      }
      }
      
      tval *= tval;    
      
      img.pixels[y * img.width + x] = color(595*tval);
  }}
  
  img.updatePixels();
  
 return img; 
}

// TBD need to rethink this to generate curves into the distance- the target is always in the center of
// the screen
float roadCurve(float z, int i, int j) 
{
 return (20/z * (noise(z/5.0 + (i + j)/25.0)-0.5));
}


int cnt = 0;

void draw() 
{
  loadPixels();
  
  PImage img = noiseImage(32, 32, true);
  
  PImage bin_img = binarize(img, 56, 255);
  // this doesn't work flexibily enough
  //bin_img.filter(THRESHOLD);
  
  PImage edge_img = edgeDetect(bin_img);
  edge_img = binarize(edge_img, 16, 255);
  img.filter(INVERT);
  PImage fin_img = (multImg(edge_img, img));
  fin_img.filter(POSTERIZE, 8);
  
  fin_img.format = ARGB;
  fin_img.loadPixels();
    for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      final int ind = y*img.width+x;
      
      if (red(fin_img.pixels[ind]) < 6) {
        fin_img.pixels[ind] = color(0, 0);
      }
    }
  }
  fin_img.updatePixels();
 
 PImage road = noiseImage(16, 1, false);
    
 /////////////
 background(0);
 
 //image(img,      0,           0, img.width, img.height);
 //image(bin_img,  img.width,   0, img.width, img.height);
 noSmooth();
 //float sc = 16 * (0.5 + t * 5);
 //image(fin_img, img.width*2, 0, img.width*sc, img.height*sc);
 
 
 
 float z = 100;
 
 float z_final = z;
 for (int ind = 20; ind > 0; ind -= 1) {
   z_final /= 1.5;
 }
 float x_off = width/2 - road.width/(2*z_final) + roadCurve(z_final, cnt, 0);
 
 for (int ind = 20; ind >= 0; ind -= 1) {
   
 //for (float z = 100; z > 0.05; z /= 1.5) {
   float x = width/2 - road.width/(2*z) + roadCurve(z, cnt, ind);
   x -= x_off;
   float y = height/2 + 6/z ;
   image(road, x, y, img.width/z, img.height/z);
   //ind += 1;
   z /= 1.5;
 }
 
 cnt+=1;
 t += 0.008;
}
