/**
 * k-means palette discovery algorithm
 * binarymillenium
 * GNU GPL
 * May 2008 
 *
 */
 

PImage in,out;  // Declare variable "a" of type PImage

boolean doSobel = true;;
final int maxKnum = 20;
int knum = 10;
float space_weight = 1.4;//0.3;
  String name = "test.jpg";

color cols[] = new color[maxKnum];
int col_center[][] = new int[maxKnum][2];


int counter = 0;

  float new_cols[][] = new float[maxKnum][3];
  int new_cols_num[] = new int[maxKnum];
  
  float new_col_center_x[] = new float[maxKnum];
  float new_col_center_y[] = new float[maxKnum];
/////////////

void keyPressed() {
 if (key == 'q') {
   space_weight *= 1.19;
  println("space weight " + space_weight); 
 }
 if (key == 'a') {
   space_weight *= 0.85;
    println("space weight " + space_weight); 
 }
 
 if (key == 's') {
   saveFrame("output.png");
 }
 
 if (key == 'j') {
   knum++;
   if (knum >= maxKnum) knum = maxKnum-1;
   makeNewCenter(knum-1);
   println("knum " + knum);
 }
 if (key == 'k') {
   knum--;
   if (knum < 2) knum = 2;
   println("knum " + knum);
 }
 
 if (key == 'e') {
   doSobel = !doSobel; 
 }
}
///////////

float color_dist(color c1, color c2) {

  float col_dist =  dist(red(c1),green(c1),blue(c1), 
                         red(c2),green(c2),blue(c2));
 
  return col_dist;
  
}

////////

/// color and spatial distance 
float color_space_dist(color c1, color c2, int x1, int y1, int x2, int y2) {
 
  /// used to normalize color distance
  float nom_cdist = color_dist(color(255,255,255), color(0,0,0));
 float col_dist = color_dist(c1,c2)/nom_cdist;

  float nom_sdist = dist(0,0,in.width,in.height);

float space_dist = dist(x1,y1, x2,y2)/nom_sdist; 


// may want to weight these to give color or space more importance over the other
return dist(0,0, col_dist, space_weight*space_dist); 
  
}

////////


void find_means() {
  
  for (int j = 0; j < in.height; j++) {
  for (int i = 0; i < in.width;  i++) {
    
      int pixind = j*in.width + i;

      
       
   ///////////////
   float dist_closest = sqrt(255*255*3); 
   int ind_closest = 0;
   
   
   for (int k = 0; k< knum; k++) {
     
      //float col_dist = color_dist(in.pixels[pixind],cols[k]);
      float col_dist = color_space_dist(in.pixels[pixind],cols[k], i,j, col_center[k][0], col_center[k][1]);
      
      if (col_dist < dist_closest) {
         ind_closest = k;
         dist_closest = col_dist; 
      }
      
   }
   
   out.pixels[pixind] = cols[ind_closest];
   
   out.updatePixels();// = true;
   
   
      /////////////
 
      new_cols[ind_closest][0] += (red(in.pixels[pixind]));
      new_cols[ind_closest][1] += (green(in.pixels[pixind]));
      new_cols[ind_closest][2] += (blue(in.pixels[pixind]));
      
      new_col_center_x[ind_closest] += i;
      new_col_center_y[ind_closest] += j;
      
      new_cols_num[ind_closest]++;
   
   
   
   
  }
  }
  
  
  int num_changed = 0;
    for (int k = 0; k< knum; k++) {
      
      float new_r = new_cols[k][0]/new_cols_num[k];
      float new_g = new_cols[k][1]/new_cols_num[k];
      float new_b = new_cols[k][2]/new_cols_num[k];
      
      float new_x = new_col_center_x[k]/new_cols_num[k];
      float new_y = new_col_center_y[k]/new_cols_num[k];    
      
      /*
      if ( (int(new_r) != int(red(cols[k]))) || (int(new_g) != int(green(cols[k]))) || (int(new_b) != int(blue(cols[k])))   ) {
            num_changed++;
            }
            */
      
       cols[k] = color( int(new_r), int(new_g), int(new_b));
       
       col_center[k][0] = int(new_x);
       col_center[k][1] = int(new_y);
              
              
       new_cols[k][0] = 0;
       new_cols[k][1] = 0;
       new_cols[k][2] = 0;
       new_col_center_x[k] = 0;
       new_col_center_y[k] = 0;
       new_cols_num[k] = 0;
       
              /*          
     print(k + ", " + red(cols[k]) + " " + green(cols[k]) + " " + blue(cols[k]) + 
               ",    " + float(new_cols_num[k])/(in.width*in.height) +"\n");
               */
    }
    
    /*
    if (num_changed == 0) {
        print("done\n");
        noLoop();
       
    }
    */
  
}

///////

void setup() {
in = loadImage(name); // Load the images into the program
  
size(in.width, in.height);

  
  colorMode(RGB, 255);
  
  frameRate(10);

 out = loadImage(name);

print( in.height + " " + in.width + " " + in.width*in.height +"\r\n");

randomSeed(minute() + second());
/// initial random guess at colors
/// could choose completely random colors, but taking some inside the image ought to converge faster
/// (though likelihood of getting two of the same color may be increased)
for (int i = 0; i < knum; i++) {
  
  /*
  /// this doesn't work too well for uniformly colored pictures as knum is increased,
  /// most of the colors will be further away and not get any pixels assigned to them.
  int r = int(random(255));
  int g = int(random(255));
  int b = int(random(255));
  
  print(i + ", " + r + " " + g + " " + b + ", "); 
  
  
  cols[i] = color(r,g,b);
  
  print(red(cols[i]) + " " + green(cols[i]) + " " +blue(cols[i]) + "\n");
 */
  makeNewCenter(i);

  
}

}


void makeNewCenter(int i) {
    int x,y;
  int picsize = in.width*in.height;
  
  if (true) {
    x = int(random(in.width));
    y = int(random(in.height));
  } else {
    /// uniformly spaced sample points (not really)
    int ind =  int(float(i)/knum * picsize); 

    x = ind%in.width;
    y=  int(ind/in.width);
     
  }
  
  print(x + " " + y + ", ");
  cols[i] = in.pixels[y*in.width+x];
  col_center[i][0] = x;
  col_center[i][1] = y;
}

int count = 0;

void draw() {

  /// image() caches the image , so need to set modified to true to redraw it
  image(out, 0, 0); // Displays the image from point (0,0)
  //image(a, in.width, 0);
  
  find_means();
  if (doSobel) findEdges();
  
  //if (count == 5) { 
    //noLoop();
  //  saveFrame("output.png");
  //}
  count++;

}

void findEdges() {
 loadPixels();
 
 float sobel_x, sobel_y;

  for (int i = 1; i < height -1; i++) {
  for (int j = 1; j < width -1; j++) {
    float pl = brightness(out.pixels[i*width+j-1]);
    float pr = brightness(out.pixels[i*width+j+1]);
    float pu = brightness(out.pixels[(i-1)*width+j]);
    float pd = brightness(out.pixels[(i+1)*width+j]);
    
    float plu = brightness(out.pixels[(i-1)*width+j-1]);
    float pld = brightness(out.pixels[(i+1)*width+j-1]);
    float pru = brightness(out.pixels[(i-1)*width+j+1]);
    float prd = brightness(out.pixels[(i+1)*width+j+1]);
     
    sobel_x = (0.5*pr + 0.25*(pru + prd)) - (0.5*pl + 0.25*(plu + pld));
    sobel_y = -(0.5*pd + 0.25*(pld + prd)) + (0.5*pu + 0.25*(pru + plu));
    float sobel = sqrt(sobel_x*sobel_x + sobel_y*sobel_y);
    
    if (sobel > 0.9) pixels[i*width+j] = color(0);
  }}  
  updatePixels();
}
