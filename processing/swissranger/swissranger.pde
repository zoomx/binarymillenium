// Binarymillenium October 2008
// GNU GPL

BufferedReader reader;


void setup() {
  
  for (int s = 1; s <= 500; s++) {
  
  if ( s< 10)       reader = createReader("box_translating/BoxTrans2_000" + s + ".dat");
  else if ( s< 100) reader = createReader("box_translating/BoxTrans2_00" + s + ".dat");
  else              reader = createReader("box_translating/BoxTrans2_0" + s + ".dat");

  String raw[] = new String[0]; 

  boolean continuing = true;

  //while(continuing) {
  for (int i = 0; i <144; i++){
      
      String newline = "";
      try {
        newline = reader.readLine();
      } catch(Exception e) {
         continuing = false;
         
      }
       
      if (continuing) raw = append(raw, newline);
    }
       
    processStrings(raw); 

  }
  return;
  
}
    
    
int index =1000;
        
void processStrings(String[] raw) {

  float maxval = 1.0;
  float minval = 1.0;
  
  float vals[][] = new float[144][176];
  
boolean start = false;

    /// preprocess to find out the extent of the data
    for (int i = 0; i < raw.length; i++) {
   
      //String[] lncalib = split(raw[i],' ');
  
      //if (lncalib.length > 1) {
      if (raw[i].charAt(0) == '%') {
       
        if (raw[i].charAt(13) == 'D') {
            start = true;
             //print(raw[i] + "\n");
        }
      }
      
      if (start) {
        
      String[] ln = split(raw[i],'\t');
      for (int j = 0; j < ln.length; j++) {
     
          float z = float(ln[j]);

           if (z > maxval) maxval = z;
          if (z < minval) minval = z;
          
          //print(i + " " + j + ", " + z + "\n");
          if ((i < 144) && (j < 176)) {
           
            vals[i][j] = z;
          }
        }
      }
    }
    
    print(minval + "\t" + maxval + ",\t");
    
    minval = 0.6;
    maxval = 2.1;
    PImage tx = new PImage();
      
    tx.width  = 176;
    tx.height = 144;
    tx.pixels = new color[tx.width*tx.height];
    
    /// preprocess to find out the extent of the data
    for (int i = 0; i < 144; i++) {
    for (int j = 0; j < 176; j++) {
      
      if (vals[i][j] > maxval) vals[i][j] = maxval;
      if (vals[i][j] < minval) vals[i][j] = minval;
      
      float newval = (vals[i][j]- minval)/(maxval-minval);
 
      color newcolor = makecolor(1.0-newval);

      //print(newval + " " + red(newcolor) + " " + green(newcolor) + " " + blue(newcolor) + "\n");
      tx.pixels[i*176+j] = newcolor;
   
    }}
    

   //tx = fillGaps(tx,2);
   tx.updatePixels();
      
    String fullname = "/home/lucasw/gprocessing/swissranger/frames/output" + index + ".png";
    tx.save(fullname);
    index++;
  
}
