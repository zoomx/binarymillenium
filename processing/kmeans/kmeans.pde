/**
 * k-means palette discovery algorithm
 * binarymillenium
 * GNU GPL
 * May 2008 
 *
 */
 

PImage a,b;  // Declare variable "a" of type PImage


int knum = 10;
float space_weight = 0.3;
  String name = "test.jpg";

color cols[] = new color[knum];
int col_center[][] = new int[knum][2];


int counter = 0;

  float new_cols[][] = new float[knum][3];
  int new_cols_num[] = new int[knum];
  
  float new_col_center_x[] = new float[knum];
  float new_col_center_y[] = new float[knum];
  
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

  float nom_sdist = dist(0,0,a.width,a.height);

float space_dist = dist(x1,y1, x2,y2)/nom_sdist; 


// may want to weight these to give color or space more importance over the other
return dist(0,0, col_dist, space_weight*space_dist); 
  
}

////////


void find_means() {
  
  for (int j = 0; j < a.height; j++) {
  for (int i = 0; i < a.width;  i++) {
    
      int pixind = j*a.width + i;

      
       
   ///////////////
   float dist_closest = sqrt(255*255*3); 
   int ind_closest = 0;
   
   
   for (int k = 0; k< knum; k++) {
     
      //float col_dist = color_dist(a.pixels[pixind],cols[k]);
      float col_dist = color_space_dist(a.pixels[pixind],cols[k], i,j, col_center[k][0], col_center[k][1]);
      
      if (col_dist < dist_closest) {
         ind_closest = k;
         dist_closest = col_dist; 
      }
      
   }
   
   b.pixels[pixind] = cols[ind_closest];
   
   b.modified = true;
   
   
      /////////////
 
      new_cols[ind_closest][0] += (red(a.pixels[pixind]));
      new_cols[ind_closest][1] += (green(a.pixels[pixind]));
      new_cols[ind_closest][2] += (blue(a.pixels[pixind]));
      
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
               ",    " + float(new_cols_num[k])/(a.width*a.height) +"\n");
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
  
  colorMode(RGB, 255);
  
  frameRate(4);
  

  a = loadImage(name); // Load the images into the program

size(a.width*2, a.height);

 b = loadImage(name);

print( a.height + " " + a.width + " " + a.width*a.height +"\r\n");

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
  
  int x,y;
  int picsize = a.width*a.height;
  
  if (false) {
    x = int(random(a.width));
    y = int(random(a.height));
  } else {
    /// uniformly spaced sample points (not really)
    int ind =  int(float(i)/knum * picsize); 

    x = ind%a.width;
    y=  int(ind/a.width);
     print(x + " " + y + ", ");
  }
  
  cols[i] = a.pixels[y*a.width+x];
  col_center[i][0] = x;
  col_center[i][1] = y;
  
}

}




void draw() {

/// image() caches the image , so need to set modified to true to redraw it
image(b, 0, 0); // Displays the image from point (0,0)
image(a, a.width, 0);


  

find_means();


}
