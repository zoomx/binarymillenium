
PImage tx;
PImage bg;

 import processing.opengl.*; 
 
void setup() {
  
      frameRate(15);
    
      size(640,480,OPENGL);
      
    tx = new PImage();
    
    tx.width = 200; //160;
    tx.height =150; //120;
    tx.pixels = new color[tx.width*tx.height];
    
    bg = loadImage("../../artoolkit/laser/images/fl4base.jpg");
    
    BufferedReader reader = createReader("../../artoolkit/laser/hits.csv");
     
      String newline;
  try {
    newline = reader.readLine();
  } catch(Exception e) {
    return;  
  }  
    
 float minz = 0;
 float maxz = 0;
 
 float points[][] = new float[3][700];
 
 float numpoints = 0;
 
 for (int i = 0;  (newline != null) ; i++) {
    String[] thisLine = split(newline, ",");
   
    float x = new Float(thisLine[1]).floatValue();
    float y = new Float(thisLine[2]).floatValue();
    float z = new Float(thisLine[5]).floatValue();
  
   //print(thisLine[0] + "\n");
   
   points[0][i] = x;
   points[1][i] = y;
   points[2][i] = z;
   
  
   
   if (i == 0) {
      minz = z;
      maxz = z;
   }
   
   if (z < minz) minz = z;
   if (z > maxz) maxz = z;
  
   numpoints = i;
 
 try {
    newline = reader.readLine();
  } catch(Exception e) {
    return;  
  }
 }
 
 /// TBD
 minz = 500;
 maxz = 2300;
 
 for (int i = 0;  i <= numpoints ; i++) {
   tx.pixels[(int)(points[0][i]/1600*tx.width) +
            (int)(points[1][i]/1200*tx.height)*tx.width] = 
       color(255*(1.0-(points[2][i]-minz)/(maxz-minz)),255);
 }
    
    
    print("minz maxz: " + minz + " " + maxz + "\n");
    
     tx.updatePixels();
    
    tx = fillGaps(tx,80);
    
    String fullname = "/home/lucasw/own/prog/google/trunk/processing/fillgaps/output.png";
    tx.save(fullname);
    
//exit();
}



void draw() {
  
background(0);

//lights();

rotations();
int sc = bg.width/tx.width;

noStroke();

for (int i = 0; i< tx.width-1; i++) {
    beginShape(QUAD_STRIP);
    texture(bg);
    for (int j = 0; j< tx.height; j++) {
      
       float x1 = i-tx.width/2;
       float x2 = i+1-tx.width/2;
       float y1 = j - tx.height/2;
       float y2 = j - tx.height/2;
       
       float hsc = 255/tx.width*3.0;
       
       vertex(x1*hsc, y1*hsc, brightness(tx.pixels[j*tx.width + i]), i*sc ,j*sc );
       vertex(x2*hsc, y2*hsc, brightness(tx.pixels[j*tx.width + i+1]), i*sc ,j*sc );
    }
  endShape(); 
}


//saveFrame("frames/couch_######.jpg");
}


  //////////////////
  float x_off;
float y_off;
float z_off = 8;

float rX = -3.2;
float rZ = -8.86;
float vX,vZ;


void rotations(){
  
   translate(x_off + width/2, y_off + height/2, z_off); 
   
  rX+=vX;
  rZ+=vZ;
  vX*=.95;
  vZ*=.95;



  if(mousePressed){
    vX+=(mouseY-pmouseY)*.01;
    vZ+=(mouseX-pmouseX)*.01;
    
     //println(rX + " " + vX);
  }

rotateY( radians(- rZ) ); 
  rotateX( radians(-rX) );  
   
}

void keyPressed(){

  
  if(key == 'a'){
    x_off += 10;
  }
  if(key == 'd'){
    x_off -= 8;
  }
  if(key == 'q'){
    y_off += 10;
  }
  if(key == 'z'){
    y_off -= 8;
  }
  if(key == 'w'){
    z_off += 10;
  }
  if(key == 's'){
    z_off -= 8;
  }
  
 print(rX + " " + rZ + ", " + x_off + " " + y_off + " " + z_off + ", " + "\n");
 
}

/////////////

 PImage  fillGaps(PImage tx, int numiterations) {
   PImage rx;

   try{ 
          rx = (PImage) tx.clone();
       } catch (Exception e ) {
          return tx;
       }
    
    int unfillednum =1;
    for (int k = 0; (k < numiterations) &&(unfillednum > 0); k++) {
      
      
       try { 
          tx = (PImage) rx.clone();
       } catch (Exception e ) {
          return rx;
       }
      
       unfillednum =0;
      
       /// ignore edges for now
       for (int i = 1; i <tx.width-1; i++) {
         for (int j = 1; j <tx.height-1; j++) {
      
         //int p = i*tx.height + j;
         int p = j*tx.width + i;
         boolean a  = alpha(tx.pixels[p]) > 0;
       
         if (!a) {
         
         int pl = j*tx.width + i-1;
       int pr = j*tx.width + i+1;
       int pu = (j-1)*tx.width + i;
       int pd = (j+1)*tx.width + i;
       
       float rvl = red(tx.pixels[pl]);
       float rvr = red(tx.pixels[pr]);
       float rvu = red(tx.pixels[pu]);
       float rvd = red(tx.pixels[pd]);
       
       float gvl = green(tx.pixels[pl]);
       float gvr = green(tx.pixels[pr]);
       float gvu = green(tx.pixels[pu]);
       float gvd = green(tx.pixels[pd]);
       
       float bvl = blue(tx.pixels[pl]);
       float bvr = blue(tx.pixels[pr]);
       float bvu = blue(tx.pixels[pu]);
       float bvd = blue(tx.pixels[pd]);
          
       boolean al = alpha(tx.pixels[pl]) > 0;
       boolean ar = alpha(tx.pixels[pr]) > 0;
       boolean au = alpha(tx.pixels[pu]) > 0;
       boolean ad = alpha(tx.pixels[pd]) > 0;
       
       float rsum = 0;
       float gsum = 0;
       float bsum = 0;
       
       int sumnum = 0;
       if (al) { 
         rsum += rvl; 
         gsum += gvl;
         bsum += bvl;
         sumnum++; 
       }
       if (ar) {  
         rsum += rvr; 
         gsum += gvr;
         bsum += bvr;
         sumnum++; 
       }
       if (au) { 
         rsum += rvu; 
         gsum += gvu;
         bsum += bvu;
         sumnum++; 
       }
       if (ad) { 

         rsum += rvd; 
         gsum += gvd;
         bsum += bvd;
         sumnum++;  
       }
    
        if (sumnum > 0) {
            float rval = rsum/(float)sumnum;
            float gval = gsum/(float)sumnum;
            float bval = bsum/(float)sumnum;
             
            color newColor = color(rval,gval,bval, 255); 
           
           
           if (ar && !al) {
              int d = nearestLeft(tx, p);
              newColor = interp(newColor, tx, p, d,d, rval, gval, bval); 
           } else if (!ar && al) {
              int d = nearestRight(tx, p);
              newColor = interp(newColor, tx, p, d,d, rval, gval, bval); 
           } 
           
             
           if (au && !ad) {
              int d = nearestDown(tx, p);
              newColor = interp(newColor, tx, p, d,d/tx.width, rval, gval, bval); 
           } else if (!au && ad) {
             int d = nearestUp(tx, p);
             newColor = interp(newColor, tx, p, d, d/tx.width,rval, gval, bval); 
           }  
           
            
           rx.pixels[p] = newColor;      
        } else {
          
         unfillednum++; 
        }
       } 
    }
   } 
   
    println(k + " " + unfillednum + " unfilled");  
   
    }
    
    tx.updatePixels();
   return tx;
    
  }
  
  
  
int maxinterp = 30;

int nearestLeft(PImage tx, int index) {
  for (int i = 0; (i < maxinterp) && (i < index%tx.width) ; i++) {
     
    if  (alpha(tx.pixels[index-i]) > 0) return -i;
  } 
  return 0;
}

int nearestRight(PImage tx, int index) {
  for (int i = 0; (i < maxinterp) && (i < tx.width-index%tx.width) ; i++) {
     
    if  (alpha(tx.pixels[index+i]) > 0) return i;
  } 
  return 0;
}

int nearestUp(PImage tx, int index) {
  for (int i = 0; (i < maxinterp) && (index-i*tx.width > 0) ; i++ ) {
     
    if  (alpha(tx.pixels[index-i*tx.width]) > 0) return -i*tx.width;
  } 
  return 0;
}

int nearestDown(PImage tx, int index) {
  for (int i = 0; (i < maxinterp) && (index + i*tx.width < tx.width*tx.height) ; i++ ) {
     
    if  (alpha(tx.pixels[index+i*tx.width]) > 0) return i*tx.width;
  } 
  return 0;
}


color interp(color newColor, PImage tx, int p, int d,int real_d, float rval, float gval, float bval)
{
  if (d != 0) {         
//print("p " + p + ", d " + d + "\n");    
                float rlval = red(    tx.pixels[p + d]);
                float glval = green(  tx.pixels[p + d]);
                float blval = blue(   tx.pixels[p + d]);
                
                //print(real_d + " " + rlval + ", " + rval + " ");
                
                float fct = 0.5;
                
                float df = float(abs(real_d));
                 rval =  df/(df+fct)*rval + fct/(df + fct)*rlval;
                 gval =  df/(df+fct)*gval + fct/(df + fct)*glval;
                 bval =  df/(df+fct)*bval + fct/(df + fct)*blval;
                 //print(rval + "\n");
                 
                 newColor = color(rval,gval,bval, 255); 
  }   
              
  return newColor;
}
