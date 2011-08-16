

void setup()
{
  size(720,480);
  frameRate(5);
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

PImage noiseImage(int w, int h )
{
  
  PImage img = createImage(w, h, RGB);
  img.loadPixels();
  
  final int HW = img.width/2;
  final float MAX_R = 0.8 * sqrt(2.0*(HW*HW));
  final float LIM_R = MAX_R/2.0;
  
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      
      float val = noise(x/19.0,y/12.0, t);
      float val2 = noise(x/50.0,y/30.0, t);
      float val3 = noise(x/2.0,y/2.0, t);
      float tval = (val*0.5+val2*0.2 + val3*0.3);
      
      float r = sqrt( (y-HW)*(y-HW) + (x-HW)*(x-HW));
      
      if (r > MAX_R) {r = MAX_R; }
      if (r > LIM_R) {
        tval *=  1.0 - (r - LIM_R)/(MAX_R - LIM_R);  
      }
      tval *= tval;
      
      
      img.pixels[y*img.width+x] = color(595*tval);
  }}
  
  img.updatePixels();
  
 return img; 
}

void draw() 
{
  loadPixels();
  
  PImage img = noiseImage(32, 32);
  
  PImage bin_img = binarize(img, 56, 255);
  // this doesn't work flexibily enough
  //bin_img.filter(THRESHOLD);
  
  PImage edge_img = edgeDetect(bin_img);
  edge_img = binarize(edge_img, 16, 255);
  PImage fin_img = (multImg(edge_img, img));
  fin_img.filter(POSTERIZE, 8);
    
 image(img,      0,           0, img.width, img.height);
 image(bin_img,  img.width,   0, img.width, img.height);
 noSmooth();
 final int SC = 16;
 image(fin_img, img.width*2, 0, img.width*SC, img.height*SC);
 
 t+= 0.008;
}
