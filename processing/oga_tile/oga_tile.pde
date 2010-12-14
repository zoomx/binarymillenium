/*
binarymillenium 
 November 2010
 GNU GPL v3 
*/


PImage tiles[];
PImage dec[];
PImage elev[];
PImage slope[];

PImage[] loadTiles(String path) {
  File dir = new File(path); 
  PImage tiles[];
  tiles = new PImage[dir.list().length];
  for (int i = 0; i < dir.list().length; i++) {
    println( dir.list()[i]);
    try {
    tiles[i] = loadImage(path + "/" + dir.list()[i]);
    } catch (Exception e) {
       tiles[i] = null; 
    }
  }
  return tiles;
}

void setup() {
  size(48*16,48*9);
  //tiles = loadImage("iso-64x64-outside.png");
  
  String path;
   
  tiles = loadTiles(dataPath("tiles"));
  dec   = loadTiles(dataPath("dec"));
  elev  = loadTiles(dataPath("elev"));
  slope  = loadTiles(dataPath("slope"));
  
  //println("dec size " + dir.list().length);
  //noLoop();
  frameRate(8);
}

int ew_mv_size = 32;
int ns_mv_size = 0;

void keyPressed() 
{
  int maxmv = 32;
  
  if (key == 'a') {
    ew_mv_size -= 32;
    
    if (ew_mv_size > maxmv) ew_mv_size = maxmv;
  } 
  if (key == 'd') {
    ew_mv_size += 32;
    
    if (ew_mv_size < -maxmv) ew_mv_size = -maxmv;
  } 
  
  if (key == 'w') {
    ns_mv_size += 16;
    
    if (ns_mv_size > maxmv) ns_mv_size = maxmv;
  } 
  if (key == 's') {
    ns_mv_size -= 16;
    
    if (ns_mv_size < -maxmv) ns_mv_size = -maxmv;
  } 
  
  
}


float t = 0.0;
int xoff = 0;
int yoff = 0;
int dec_ind_max = 0;
int dec_ind_min = 100000;

final int MAX_HEIGHT=8;
int getElevation(int x_noise,int y_noise)
{
   float frac = 3.0;
        
      
   int elevation = (int) (MAX_HEIGHT*noise( x_noise/frac+2000, y_noise/frac,t));
   
   elevation -=4;
   
   if (elevation <0) elevation = 0;
   
   return elevation;
      
}


void draw() {
  background(0);
  
  //t += 0.00001;
  xoff += ew_mv_size;
  yoff -= ns_mv_size;
  
  ew_mv_size =0;
  ns_mv_size =0;
  
  int x_part = xoff % 32;
  int x_rnd  = xoff/32;
  
  int y_part = yoff % 16;
  int y_rnd  = yoff/16;
  //println(x_part);
  

  for (int i = 7; i>= -7/*-2; i < width/32+1*/; i--) {
    // diagonal down to right
    for (int j = -7; j <=7; j++) {
      float x =  j*32 - x_part;
      float y = -i*32 + y_part;
           
      float x_rot = x   - y/2 + width/2 + i*16 -32;
      float y_rot = x/2 + y   + height/2 + i*16 -16*3;
      
      int x_noise = (i + x_rnd);
      int y_noise = (j + y_rnd);
      
      
      //////////////////////////////////////
      // get a random flat tile for base
      float frac = 9.0;  
     // random(tiles.length); 
      int tile_ind = 1+ (int) ((tiles.length-1) * 3.0*noise( x_noise/frac, y_noise/frac,t))%(tiles.length-1);
     
      if (tiles[tile_ind] != null) {
        image(tiles[tile_ind], x_rot, y_rot);
      }
      
      if (true) {
      ///////////////////////////////////////
      // raise the elevation
      int elevation = getElevation(x_noise,y_noise);
       
      int elev_factor = 32;
      // draw elev tiles upwards
      for (int k = 0; k < elevation; k++) {
        
        float nval =  3.0*noise( x_noise/frac,y_noise/frac, k/frac + t);
        int ind = (int) (elev.length * nval) % elev.length;
        if (elev[ind] != null) {
          image(elev[ind], x_rot, y_rot - k*elev_factor);
        }
      }
      
      boolean is_slope = false;
      
      /// put a slope if neighboring tiles are elevated differently
      if        (getElevation(x_noise+1,y_noise) > elevation) {
         image(slope[2], x_rot, y_rot - elevation*elev_factor );
         is_slope = true;
      } else if (getElevation(x_noise, y_noise-1) > elevation) {
         image(slope[3], x_rot, y_rot - elevation*elev_factor );
         is_slope = true;
      }  else if (getElevation(x_noise-1,y_noise) > elevation) {
         image(slope[7], x_rot, y_rot - elevation*elev_factor );
         is_slope = true;
      } else if (getElevation(x_noise, y_noise+1) > elevation) {
         image(slope[6], x_rot, y_rot - elevation*elev_factor );
         is_slope = true;
      } 
      
        else if (getElevation(x_noise+1,y_noise-1) > elevation) {
        /// directly above
         image(slope[1], x_rot, y_rot - elevation*elev_factor );
         is_slope = true;
      } else if (getElevation(x_noise+1,y_noise+1) > elevation) {
        ///
         image(slope[4], x_rot, y_rot - elevation*elev_factor );
         is_slope = true;
      } else if (getElevation(x_noise-1,y_noise-1) > elevation) {
        ///
         image(slope[5], x_rot, y_rot - elevation*elev_factor );
         is_slope = true;
      } 
      
      else
      //////////////////////////
      /// now put a tree on it
      if ((!is_slope) && (noise( 500 + x_noise/frac, y_noise/frac,t) > 0.55)) {
        frac = 11.0;
        
        float nval =  3.0*noise( 100 + x_noise/frac,y_noise/frac,t);
        int ind = 1+ (int) ((dec.length-1) * nval) % (dec.length-1);
        if (dec[ind] != null) {
          image(dec[ind], x_rot, y_rot - (elevation-2)*elev_factor - dec[ind].height);
        }
        
        if (ind > dec_ind_max){ 
          dec_ind_max = ind; 
          println(dec.length + " max " + ind + " " + nval); 
        }
        if (ind < dec_ind_min){ 
          dec_ind_min = ind; 
          println(dec.length + "  min " + ind + " " + nval); 
        }
      }
      
      } // extra terrain
      
    }  // i loop
  } // j loop
  
}
