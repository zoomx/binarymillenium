
void setup() {
    PImage tx = new PImage();
    
    tx.width = 400;
    tx.height = 300;
    tx.pixels = new color[tx.width*tx.height];
    
    BufferedReader reader = createReader("../../arlaser/hits.csv");
     
      String newline;
  try {
    newline = reader.readLine();
  } catch(Exception e) {
    return;  
  }  
    
 float minz = 0;
 float maxz = 0;
 
 float points[][] = new float[3][500];
 
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
 
 for (int i = 0;  i <= numpoints ; i++) {
   tx.pixels[(int)(points[0][i]/1600*tx.width) +
            (int)(points[1][i]/1200*tx.height)*tx.width] = 
       color(255*(1.0-(points[2][i]-minz)/(maxz-minz)),255);
 }
    
    
    print(minz + " " + maxz + "\n");
    
     tx.updatePixels();
    
    tx = fillGaps(tx,38);
    
    String fullname = "/home/lucasw/own/prog/google/trunk/processing/fillgaps/output.png";
    tx.save(fullname);
}

 PImage  fillGaps(PImage tx, int numiterations) {
    PImage rx;
    try{ 
    rx = (PImage) tx.clone();
    } catch (Exception e ) {
        return tx;
    }
    
    int unfillednum =1;
    for (int k = 0; (k < numiterations) &&(unfillednum > 0); k++) {
      unfillednum =0;
      
    /// ignore edges for now
   for (int i = 1; i <tx.width-1; i++) {
    for (int j = 1; j <tx.height-1; j++) {
      
       //int p = i*tx.height + j;
       int p = j*tx.width + i;
       boolean a  = alpha(tx.pixels[p]) > 0;
       
       if (!a) {
         
         /*
       int pl = i*tx.height + j-1;
       int pr = i*tx.height + j+1;
       int pu = (i-1)*tx.height + j;
       int pd = (i+1)*tx.height + j;
       */
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
            
           rx.pixels[p] = color(rval,gval,bval, 255);      
        } else {
         unfillednum++; 
        }
//rx.pixels[p] = color(255,0,0,255);
       } 
    }
   } 
   
   println(unfillednum + " unfilled");
      try{ 
    tx = (PImage) rx.clone();
    } catch (Exception e ) {
        return rx;
    }
    
   
    }
   return rx;
    
  }
