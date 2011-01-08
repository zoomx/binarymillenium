	
float x_long[]; 
float y_lat[];  

float xs[]; 
float ys[];  

float x_min =  1e10;
float x_max = -1e10;
float y_min =  1e10;
float y_max = -1e10;

void setup() {
  size(800,600);
  
  String lines[] = loadStrings(sketchPath("data/counties.txt"));
  x_long = new float[lines.length-1];
  y_lat = new float[lines.length-1];
  for (int i = 1; i < lines.length; i++) {
    String[] list = split(lines[i],'\t');
    x_long[i-1] = new Float(list[1]); 
    y_lat[i-1]  = new Float(list[2]); 
    y_lat[i-1] = -y_lat[i-1] ;
    
    if (x_long[i-1] < x_min) x_min = x_long[i-1];
    if (x_long[i-1] > x_max) x_max = x_long[i-1];
    if (y_lat[i-1] < y_min) y_min = y_lat[i-1];
    if (y_lat[i-1] > y_max) y_max = y_lat[i-1];  
  }
  
  float x_sc = x_max-x_min;
  float y_sc = y_max-y_min;
  
  float sc = x_sc;
   if (y_sc > x_sc) sc = y_sc;
   
  xs = new float[lines.length-1];
  ys = new float[lines.length-1];
  
  for (int i = 0; i < x_long.length; i++) {
    xs[i] = (x_long[i]- x_min)/sc;
    ys[i] = (y_lat[i] - y_min)/sc;
  }
}

void draw() {

  stroke(128);
 
   float sc_sc = width;
  
  for (int i = 1; i < xs.length; i++) {
    line(xs[i-1]*sc_sc,ys[i-1]*sc_sc, xs[i]*sc_sc, ys[i]*sc_sc);    
    //println(xs[i] + " " + y_lat[i]);
  }
  
  
  noLoop();
}

