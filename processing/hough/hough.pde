/**
 * hough transform for line detection
 * binarymillenium
 * GNU GPL
 * May 2008 
 *
 */
 

PImage a,b;  // Declare variable "a" of type PImage

  String name = "test4.png";
 float max_red =0.0;

float thetamax = PI/2;
float thetamin = -PI/2;

float rtheta[][][];

 int min_hw;

////////
////////


void find_means(int k_start, int k_num) {
  
  /*
   if (k_start == 0) {
      for (int r = k_start; k< k_num; k++) {
       for (int k = 0; k< k_num; k++) {
           rtheta[r][k][0] = red(a.pixels[pixind]);
         rtheta[r][k][1] = green(a.pixels[pixind]);
         rtheta[r][k][2] = blue(a.pixels[pixind]);
    }
    
   }*/
   
  
  
  for (int y = 0; y < min_hw; y++) {
  for (int x = 0; x < min_hw;  x++) {
    int pixind = y*min_hw + x;
         
    for (int k = k_start; k< min(k_start+k_num,min_hw); k++) {
       float theta = thetamin + (float)k/(float)min_hw * (thetamax-thetamin);
    
       /// r is going to range from -min_hw*sqrt(2) to + min_hw*sqrt(2) at most, 
       int r = min_hw/2 + (int)((x*cos(theta) + y*sin(theta))/(2*sqrt(2.0))); 
       
       r %= min_hw;
       
       
        
         rtheta[r][k][0] += red(a.pixels[pixind]);
         if ( rtheta[r][k][0] > max_red) {
           max_red = rtheta[r][k][0];
           
          
         }
         
         rtheta[r][k][1] += green(a.pixels[pixind]);
         rtheta[r][k][2] += blue(a.pixels[pixind]);
         
         //print(r + ", " + k + "\n");
         
    }
  }
  }
  
 //for (int k = 0; k < min_hw; k++) {
   for (int k = 0; k< min(k_start+k_num,min_hw); k++) {
  for (int r = 0; r < min_hw;  r++) {
    int pixind = k*b.width + r;
        
    int new_r = (int)(255*( rtheta[r][k][0]/max_red ));
    int new_g = (int)(255*( rtheta[r][k][1]/max_red ));
    int new_b = (int)(255*( rtheta[r][k][2]/max_red ));
    
    b.pixels[pixind] = color(new_r, new_g, new_b);
    
     //print(r + ", " + k + ", " + rtheta[r][k][0] + ", " +  red(color(new_r, new_g, new_b))  + "\n");
  }
 }
  
  b.modified= true;

  
   }
///////

void setup() {
  
  colorMode(RGB, 255);
  
  //frameRate(4);
  

  a = loadImage(name); // Load the images into the program

size(a.width, a.height);

 b = loadImage(name);

print( a.height + " " + a.width + " " + a.width*a.height +"\r\n");

min_hw = min(a.height, a.width);

rtheta = new float[min_hw][ min_hw][3];

randomSeed(minute() + second());
/// initial random guess at colors
/// could choose completely random colors, but taking some inside the image ought to converge faster
/// (though likelihood of getting two of the same color may be increased)


 for (int k = 0; k < min_hw; k++) {
  for (int r = 0; r < min_hw;  r++) {
    int pixind = k*b.width + r;
   
    b.pixels[pixind] = color(0, 0, 0);
  }
 }


}



int counter = 0;

void draw() {

  /// image() caches the image , so need to set modified to true to redraw it
  image(b, 0, 0); // Displays the image from point (0,0)
  //image(a, a.width, 0);

  int step = 1;
  counter+= step;
  
  if (counter < min_hw) {
    find_means(counter, step);
    //print( counter + ", max_red " + max_red);
  } else {
noLoop();
  }


}
