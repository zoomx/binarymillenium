
int SZ = 500;

float[][] grid = new float[SZ][SZ];

/// for registration
final float div = 3.0;//5.0;
/// for updating the grid
//final float divgrid = 5.0;//5.0

float cur_x;
float cur_y;
float cur_r;

          final float neard = 500;
          final float fard = 8000*0.6;
          final float ffract = (fard-neard)/fard;
          
          
/// cheat and use translations and rotations stored while
/// source image files were generated
final boolean usestoredstate = false;
BufferedReader reader;

/// TBD temp- clear the grid to not accumulate errors
final boolean cleargrid = false;

PImage ima;
PImage imb;
final String base = "../depthvis/frames/height/frame";
PrintWriter output;
PrintWriter outputmse;

void setup() {
  if (usestoredstate) reader = createReader("../depthbuffer/angles.csv");
   
  
  output = createWriter("derivedangles.csv");
  outputmse = createWriter("mse.csv");
  frameRate(20);
  /// start out in the middle of the grid
  cur_x = SZ/2;
  cur_y = SZ/2;//4+SZ/8;
  
  size(SZ,SZ);
  
  cur_r = 0;
  
  if (usestoredstate) cur_r = PI/9;
  
  
}

float last_r = 0;

float register() {



  final int rsteps = 10;
  final float rrange = 1.4/180.0*PI;
  
  final int latsteps = 6;
  final int latrange= 6;
  
  int totnum = 0;
  
  float[][] mse = new float[latsteps*latsteps*rsteps][5];
    // println(mse.length + " ");
 for (int i = 0; i < ima.height; i++) { 
 for (int j = 0; j < ima.width; j++) {
   
   float h = 1.0-getfloat(ima.pixels[i*ima.width+j]);  
   if (h > 0) {
      int y = (int) ( i-(ima.height)*ffract+1);
      int x = (j - ima.width/2);
      
      int mseind = 0;
      
      for (int xind = 0; xind < latsteps; xind++) {
      for (int yind = 0; yind < latsteps; yind++) {
      for (float rind = 0; rind < rsteps; rind++) {
        float xo = div*(xind*latrange/latsteps - latrange/2);
        float yo = div*(yind*latrange/latsteps - latrange/2);
        float r = last_r + rind*rrange/rsteps - rrange/2;
     
        float rx = (int) ((cos(cur_r+r)*(x+xo)-sin(cur_r+r)*(y+yo))/div);
        float ry = (int) ((sin(cur_r+r)*(x+xo)+cos(cur_r+r)*(y+yo))/div);
      
      int nx = (int) (cur_x + rx);
      int ny = (int) (cur_y + ry);
      
        if ((ny < SZ) && (nx < SZ) && (ny >=0) && (nx >= 0)) {
        
          if (grid[ny][nx] > 0) {
           
            float diff = abs(grid[ny][nx]-h);
            
            mse[mseind][0] += diff*diff*h;
            mse[mseind][1] = xo/div;
            mse[mseind][2] = yo/div;
            mse[mseind][3] = r;
            /// count the number of points differenced
            mse[mseind][4]++;
            
            totnum++;
          }
           
        }
        
        mseind++;
        
      }}}
   }
  }}
      
      
  
  /////////////////////////////////////////////////////////////////////  
  /// find minmse
  float minmse = 100000.0;
float minrot = 0.0;
int minxo =0;
int minyo =0;

  int mseind = 0;
  int minmseind = 0;
  
  final float avgmselen = (float)totnum/(float)mse.length;
      
      for (int xind = 0; xind < latsteps; xind++) {
      for (int yind = 0; yind < latsteps; yind++) {
      for (float rind = 0; rind < rsteps; rind++) {
        float xo = xind*latrange/latsteps - latrange/2;
        float yo = yind*latrange/latsteps - latrange/2;
        float r = last_r + rind*rrange/rsteps - rrange/2;
          
          mse[mseind][0] = mse[mseind][0]/mse[mseind][4];
          
          outputmse.print(mse[mseind][3] + ",\t" + mse[mseind][0] + ",\t"); 
        if (mse[mseind][4] > avgmselen) {
        
        if (mse[mseind][0] < minmse) {
          minmse = mse[mseind][0];
          minxo =  (int)mse[mseind][1];
          minyo =  (int)mse[mseind][2];
          minrot = mse[mseind][3];        
          minmseind = mseind;
        }
        }
        
        mseind++;
        
      }}}
        
        outputmse.print("\n");
        outputmse.flush();
    
   output.print(index + ",\t" + mse[minmseind][1] + ",\t" + 0 + ",\t" 
                + mse[minmseind][2] + ",\t" + mse[minmseind][3]*180.0/PI + ",\t" + "\n");
  output.flush();
  
    println(minmseind + ", mse " + mse[minmseind][0] + ", xo " + mse[minmseind][1] + 
            ", yo " + mse[minmseind][2] + ", r " + 180.0*mse[minmseind][3]/PI + 
            ", num " + mse[minmseind][4] + ", " + avgmselen);
 cur_x += minxo;
 cur_y += minyo;
 cur_r += minrot;
 
 last_r = minrot;
 
 return minmse;
  
}

void updategrid()
{
  /// having found the minmse, save the values into the grid
 
 if (cleargrid) grid = new float[SZ][SZ];
 
 for (int i = 0; i < ima.height; i++) { 
    for (int j = 0; j < ima.width; j++) {
      
      int y = (int) ( i-(ima.height)*ffract+1);// -1 - i);
      int x = (j - ima.width/2);
      
      int rx = (int) ((cos(cur_r)*x-sin(cur_r)*y)/div);
      int ry = (int) ((sin(cur_r)*x+cos(cur_r)*y)/div);
      
      int nx = (int) (cur_x + rx);
      int ny = (int) (cur_y + ry);
      
      if ((ny < SZ) && (nx < SZ) && (ny >=0) && (nx >= 0)) {
        
          float h = 1.0-getfloat(ima.pixels[i*ima.width+j]);  
        
          //if (h > grid[ny][nx]) 
          if (h > 0) {
            grid[ny][nx] = h;       
          }
            
          if ((x == 0) && (y == 0)) {
            grid[ny][nx] = 1.0;  
          }
      }
  }}
  
}

void getstoredstate() {
   String newline;
       try {
          newline = reader.readLine();
       } catch(Exception e) {
          return;  
       }  
     
       if (newline !=null) {
         
         String[] thisLine = split(newline, ",");


          /// 200.0 was a scaling factor in depthbuffer
          /// also the ima.height*ffract pixels / fard opengl units
          final float fconv = ima.height*ffract/fard*2.0;
         
          float xo = new Float(thisLine[1]).floatValue()*-fconv;
          float yo = new Float(thisLine[3]).floatValue()*-fconv;
          float ro = new Float(thisLine[4]).floatValue()*PI/180.0;
          
          cur_x += xo;
          cur_y += yo;
          cur_r+= ro; 
          
          println(xo + " " + yo + " " + ro*180.0/PI);
       } else {
          noLoop(); 
       }
}

 int index = 100001;
       
void draw() {
  
  ima = loadImage(base + str(index).substring(1) + ".png");
  
  float minmse = 0.0; 
  
  if (!usestoredstate) {
     if (index > 100001) minmse = register();
  } else {
     getstoredstate();
  }
  
 
  updategrid();
  //println(minmse + ", " + cur_x + " " + cur_y + ", " + cur_r/PI*180.0);
   
  index++; 
 
  loadPixels();
 for (int i = 0; i < SZ; i++) { 
    for (int j = 0; j < SZ; j++) {
     
      int pixind = i*SZ+j;
     pixels[pixind] = makecolor(grid[i][j]);      
      
      grid[i][j] *= 0.9;  
 }}
 updatePixels();
 
 
 //saveFrame("frames/registered#####.png");
 //noLoop();
}
