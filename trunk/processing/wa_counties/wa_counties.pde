	
double x_min =  1e10;
double x_max = -1e10;
double y_min =  1e10;
double y_max = -1e10;

class LL {
  LL(double x, double y) {
    x_lat = x;
    y_long = y;
  }
  
 double x_lat;
 double y_long; 
}

class County {
  County(String nm, int cd) {
    name = nm;
    code = cd; 
    
    latlong = new ArrayList();
  }
  
  String name;
  int code;
  
  ArrayList latlong;
}

ArrayList counties;

int findCountyInd( int cd) {
  for (int i = 0; i < counties.size(); i++) {
    County cur_county = (County )(counties.get(i));
    if ( cur_county.code == cd) {
      return i;
    }
  }
 return -1; 
}

double sc;

void setup() {
  size(800,600);
  
  counties = new ArrayList();
  
  String lines[] = loadStrings(sketchPath("data/counties.txt"));
  //x_long = new float[lines.length-1];
  //y_lat = new float[lines.length-1];
  for (int i = 1; i < lines.length; i++) {
    String[] list = split(lines[i],'\t');
    int code = new Integer(list[5]);
    
    int ind = findCountyInd(code);
    
    County cur_county; 
    if (ind < 0) {
      cur_county = (new County(list[7],code)); 
      counties.add(cur_county);
    } else {
      cur_county = (County)counties.get(ind);
    }
    
    double x_long = new Float(list[1]); 
    double y_lat  = new Float(list[2]); 
    y_lat = -y_lat;
    
    cur_county.latlong.add(new LL(x_long, y_lat));
    
    if (x_long < x_min) x_min = x_long;
    if (x_long > x_max) x_max = x_long;
    if (y_lat < y_min)  y_min = y_lat;
    if (y_lat > y_max)  y_max = y_lat;  
  }
  
  double x_sc = x_max-x_min;
  double y_sc = y_max-y_min;
  
  sc = x_sc;
  if (y_sc > x_sc) sc = y_sc;
   
   // xs[i] = (x_long[i]- x_min)/sc;
   // ys[i] = (y_lat[i] - y_min)/sc;
  
  
  background(255);
}

void draw() {

  stroke(0);
 
   float sc_sc = width;
  
  for (int i = 0; i < counties.size(); i++) {
    fill (255*i/counties.size());
    
    beginShape();

    County cur_county = (County) counties.get(i);
    for (int j = 1; j < cur_county.latlong.size(); j++) {
      LL xy1 = (LL) cur_county.latlong.get(j-1);
      LL xy2 = (LL) cur_county.latlong.get(j);
      vertex(
           (float) ((xy2.x_lat -x_min)/sc)*sc_sc,
           (float) ((xy2.y_long-y_min)/sc)*sc_sc
            );    
    //println(xs[i] + " " + y_lat[i]);
    }
    endShape(CLOSE);
  }
  
  
  noLoop();
}

