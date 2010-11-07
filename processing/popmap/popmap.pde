PImage mapImage;
Table locationTable;
int rowCount;

float dataMin = MAX_FLOAT;
float dataMax = MIN_FLOAT;

float x_min = MAX_FLOAT;
float y_min = MAX_FLOAT;
float x_max = MIN_FLOAT;
float y_max = MIN_FLOAT;
float xy_div = 1;


void setup() {
  size(1280, 720);
  //mapImage = loadImage("map.png");
  locationTable = new Table("zips_cont.csv");
  rowCount = locationTable.getRowCount();
 
   for (int row = 1; row < locationTable.data.length; row++) {
    //println(locationTable.getFloat(row, 2) + " " + locationTable.getFloat(row, 3) );
    //println(locationTable.data[row].length);
    float x = locationTable.getFloat(row, 3);
    float y = -locationTable.getFloat(row, 2);
    
    if (x > x_max) x_max = x;
    if (y > y_max) y_max = y;
    if (x < x_min) x_min = x;
    if (y < y_min) y_min = y;
  }
  
  println(x_min + " " + x_max + " " + y_min + " "+ y_max);
  
  xy_div = (float)width/(x_max - y_min);
  float y_div = (float)height/(y_max - y_min);
  if (xy_div > y_div) xy_div = y_div;
  
  smooth();
  noStroke();  
  
   fill(random(255.0),random(255.0),random(255.0));
}

int start = 1;
int step = 80;

void draw() {
  if (start == 1 ) background(255);
  //tint(255, 160);
  //image(mapImage, 0, 0);
    
  for (int row = start; (row < start+step) && (row < locationTable.data.length); row++) {
    //String abbrev = dataTable.getRowName(row);
    float x = locationTable.getFloat(row, 3);
    float y = -locationTable.getFloat(row, 2);
    drawData(x, y, row);  
  }
  print('.');
  start = start + step;
  if (start >  locationTable.data.length) {
    println("done");
    fill(random(255.0),random(255.0),random(255.0));
    start = 1;
    //noLoop();
  }
  
}

void drawData(float x, float y, int row) {
  
  float value = locationTable.getFloat(row, 1);  
  //float percent = norm(value, dataMin, dataMax);  
  float percent = 0.5;
  color between = lerpColor(#296F34, #61E2F0, percent); 
  //fill(between);
  //fill(color(i,0,0));
  
  float xp = (x - x_min)*xy_div;
  float yp = (y - y_min)*xy_div;
  ellipse(xp, yp, 1, 1);
}

