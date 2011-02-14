// drawing scale
final int sc =  3;

final int nx = 201;
final int ny = 91;

float dx;
float dy;
float dt;

class Field {
  float Hx;
float Hy;
float Ez;
float Mm;
float EzC;
float HxC;
float HyC;
float Cv;
}

Field[][] fld = new Field[nx][ny];

// TBD put all of following in class
//%  allocate memory for field arrays */
/*
float[][] Hx = new float[nx][ny-1];
float[][] Hy = new float[nx-1][ny];
float[][] Ez = new float[nx][ny];

/// blocking mass that drives Ez to zero as it approaches 1
float[][] Mm = new float[nx][ny];
float[][] EzC = new float[nx][ny];
float[][] HxC = new float[nx][ny];
float[][] HyC = new float[nx][ny];
float[][] Cv = new float[nx][ny];
*/

/// ABC storage for current 'c' and past 'p' up bottom left right 
float[][] Ez_cl = new float[2][ny];
float[][] Ez_pl = new float[2][ny];
float[][] Ez_cr = new float[2][ny];
float[][] Ez_pr = new float[2][ny];
/// should be rotated [nx][2] but this makes code more consistent
float[][] Ez_cb = new float[2][nx];
float[][] Ez_pb = new float[2][nx];
float[][] Ez_cu = new float[2][nx];
float[][] Ez_pu = new float[2][nx];

//PImage tex;

void setup() {
  size(nx*sc,ny*sc*3);
  
  final float freqq = 1.0e9;
  
  final float c0 = 2.9979e8;
  
 
  // Updating coefficients for space region !
  final float mu0 = 4.0*PI*1.0e-7;        //% permeability of free space
  final float eps0 = 1.0/(c0*c0*mu0);       //% permittivity of free space

  final float muAir  = (1.0)*mu0;            //% permeability of medium
  final float epsAir = (1.0)*eps0;          //% permittivity of medium
  final float muDie  = (1.0)*mu0;            //% permeability of medium
  final float epsDie = (4.0)*eps0;          //% permittivity of medium

  final float cDie = 1/sqrt(muDie*epsDie);
  final float lambda = min(c0,cDie)/freqq;
  dx = lambda/20.0;
  dy = dx;
  
  final float dt0 =(0.95)*dx/c0/sqrt(2.0);  // time step
  final float dtDie =(0.95)*dx/cDie/sqrt(2.0);  // time step
  
  println("dtAir "  + dt0 + ", dtDie " + dtDie);
  println("cAir "  + c0 + ", cDie " + cDie);
  // seems safer to choose the smaller possible timestep
  dt = min(dt0,dtDie);
  

  
  frameRate(30);
  
  background(100,100,100);
  
      for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        
        fld[i][j] = new Field;
        
        float mu = muAir;
        float eps = epsAir;
        float ccur = c0;
        if (i > 100) {
          mu = muDie;
          eps = epsDie;
          ccur = cDie;
        }
        fld[i][j].EzC = dt/eps/dx;
        fld[i][j].HxC = dt/mu/dx;
        fld[i][j].HyC = dt/mu/dy;
        fld[i][j].Cv = ccur;
      }}
  
  //tex = get();
}

float t = 0;
int n = 0;

void keyPressed( ) {
   if (key == 'a') {
     // start source over
     println("restarting src");
      t = 0;
      n = 0;
   } 
   
   if (key == 'r') {
     // clear storage
     t = 0;
     
     fld = new Field[nx][ny];
     /*
     Hx = new float[nx][ny-1];
     Hy = new float[nx-1][ny];
      Ez = new float[nx][ny];
      */
      /// ABC storage
      Ez_cl = new float[2][ny];
      Ez_pl = new float[2][ny];
      Ez_cr = new float[2][ny];
      Ez_pr = new float[2][ny];
      
      Ez_cb = new float[2][nx];
      Ez_pb = new float[2][nx];
      Ez_cu = new float[2][nx]; 
      Ez_pu = new float[2][nx]; 
   }
}

int SX = 45;
int SY = 45;
    
boolean mouseRight = false;

void mouseClicked( ) {
  if ((mouseButton == LEFT)) {
  SX = mouseX/sc;
  SY = mouseY/sc;
      t = 0;
      n = 0;
  }
 
}

void mouseMoved() {
  // TBD this isn't working right
 if ( mouseRight) {
    int x = mouseX/sc;
    int y = mouseY/sc;
    
    fld[x][y].Mm = 1.0 - 0.71*(1.0- fld[x][y].Mm);
  }
}

void mousePressed() {
 if ((mouseButton == RIGHT)) {
    mouseRight = true;
    println("mouseRight");
  }
}
void mouseReleased() {
  if (mouseButton == RIGHT) {
     mouseRight = false; 
      println("mouseRight off");
  }
}

void draw() {



  
  //image(tex,-2,-4,width-1, height-1);
  fill(255,0,0,20);
  noStroke();
  rect(0,0,width,height);

    float max_ez = -1e9;
    float min_ez = 1e9;
  
    /// combined for loops should be faster
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        
        if (j < ny -1) {
          //  update Hx (Eq: 4.5)
          fld[i][j].Hx += -fld[i][j].HxC*(fld[i][j+1].Ez-fld[i][j].Ez);
        }
        
        if (i < nx-1) {
          //  update Hy (Eq: 4.6)
          fld[i][j].Hy += fld[i][j].HyC*(fld[i+1][j].Ez - fld[i][j].Ez);
        }
        
        if ((i > 0) && (j > 0) && (i < nx-1) && (j < ny-1)) {
          //  update Ez (Eq: 4.7)
          //if (EzC[i][j] == EzC[i-1][j]) {
            fld[i][j].Ez += fld[i][j].EzC*((fld[i][j].Hy - fld[i-1][j].Hy) - 
                                           (fld[i][j].Hx - fld[i][j-1].Hx));
          //} else {
          //  Ez[i][j] = Ez[i-1][j]; 
          //}
 
        
          fld[i][j].Ez *= (1.0-fld[i][j].Mm);
        
          if (fld[i][j].Ez > max_ez) { max_ez = fld[i][j].Ez; }
          if (fld[i][j].Ez < min_ez) { min_ez = fld[i][j].Ez; }
        }
    }}

    
    //  additive source */
    if (n*dt<=2e-9) {
      fld[SX][SY].Ez += (10-15*cos(2*PI*1e9*n*dt)+6*cos(4*PI*1e9*n*dt)-cos(6*PI*1e9*n*dt))/32;
    
    } else {
      //Ez[SX][SY] = 0.0;
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    /// ABC left right
    for (int j = 1; j < ny-1; j++) {
      {
        final float c = fld[0][j].Cv;
        final float cdtpdx = (c*dt + dx);
        final float fx_order1 = (c*dt-dx)/cdtpdx;
        final float fx_order2 = 2*dx/cdtpdx;
        final float fx_order3 = (c*dt)*(c*dt)*dx / (2*(dy*dy)*cdtpdx);
      
        //-----------------------/2nd-order Taflove ABC at x = 0.
        fld[0][j].Ez = -Ez_pl[1][j] 
            + fx_order1 * (fld[1][j].Ez  +   Ez_pl[0][j]) 
            + fx_order2 * (Ez_cl[0][j]   +   Ez_cl[1][j]) 
            + fx_order3 * (Ez_cl[0][j+1] - 2*Ez_cl[0][j] + Ez_cl[0][j-1] 
                        +  Ez_cl[1][j+1] - 2*Ez_cl[1][j] + Ez_cl[1][j-1]);
      }
       
      {   
        final float c = fld[nx-1][j].Cv; 
        final float cdtpdx = (c*dt + dx);
        final float fx_order1 = (c*dt-dx)/cdtpdx;
        final float fx_order2 = 2*dx/cdtpdx;
        final float fx_order3 = (c*dt)*(c*dt)*dx / (2*(dy*dy)*cdtpdx);        
        fld[nx-1][j].Ez = -Ez_pr[1][j] 
            + fx_order1 * (fld[nx-2][j].Ez +   Ez_pr[0][j]) 
            + fx_order2 * (Ez_cr[0][j]     +   Ez_cr[1][j]) 
            + fx_order3 * (Ez_cr[0][j+1] - 2*Ez_cr[0][j] + Ez_cr[0][j-1] 
                        +  Ez_cr[1][j+1] - 2*Ez_cr[1][j] + Ez_cr[1][j-1]);
      }
    }
 

    if (false) {
    for (int j = 1; j < nx-1; j++) {
      {
        final float c = fld[j][0].Cv;
        /// ABC up
        float cdtpdy = (c*dt + dy);
        float fy_order1 = (c*dt-dy)/cdtpdy;
        float fy_order2 = 2*dy/cdtpdy;
        float fy_order3 = (c*dt)*(c*dt)*dy / (2*(dx*dx)*cdtpdy);
        
        //-----------------------/2nd-order Taflove ABC at y = 0.
        // coordinates loook inconsistent because we want to make the matrices
        // the same indexing in both dimensions
        fld[j][0].Ez = -Ez_pu[1][j] 
            + fy_order1 * (fld[j][1].Ez  +   Ez_pu[0][j]) 
            + fy_order2 * (Ez_cu[0][j]   +   Ez_cu[1][j]) 
            + fy_order3 * (Ez_cu[0][j+1] - 2*Ez_cu[0][j] + Ez_cu[0][j-1] 
                        +  Ez_cu[1][j+1] - 2*Ez_cu[1][j] + Ez_cu[1][j-1]);
      }            
      {     
        final float c = fld[j][ny-1].Cv;
        /// ABC bottom
        float cdtpdy = (c*dt + dy);
        float fy_order1 = (c*dt-dy)/cdtpdy;
        float fy_order2 = 2*dy/cdtpdy;
        float fy_order3 = (c*dt)*(c*dt)*dy / (2*(dx*dx)*cdtpdy);         
        fld[j][ny-1].Ez = -Ez_pb[1][j] 
            + fy_order1 * (fld[j][ny-2].Ez +   Ez_pb[0][j]) 
            + fy_order2 * (Ez_cb[0][j]     +   Ez_cb[1][j]) 
            + fy_order3 * (Ez_cb[0][j+1] - 2*Ez_cb[0][j] + Ez_cb[0][j-1] 
                        +  Ez_cb[1][j+1] - 2*Ez_cb[1][j] + Ez_cb[1][j-1]);
      }                
    } // j loop
    }
    
    /// ABC update
    for (int j = 0; j < ny; j++) {
      for (int ind = 0; ind < 2; ind++) {
        Ez_pl[ind][j] = Ez_cl[ind][j];
        // it seems like the current boundary value is 1 dt in the past
        // by the time this value is used
        Ez_cl[ind][j] = fld[ind][j].Ez;
        
        Ez_pr[ind][j] = Ez_cr[ind][j];
        Ez_cr[ind][j] = fld[nx-ind-1][j].Ez;
      }
    }
    for (int j = 0; j < nx; j++) {
      for (int ind = 0; ind < 2; ind++) {
        Ez_pu[ind][j] = Ez_cu[ind][j];
        // it seems like the current boundary value is 1 dt in the past
        // by the time this value is used
        Ez_cu[ind][j] = fld[j][ind].Ez;
        
        Ez_pb[ind][j] = Ez_cb[ind][j];
        Ez_cb[ind][j] = fld[j][ny-ind-1].Ez;
      }
    }
      
    ////////////////////////////////////////////////////////////////////////////////
    /// Drawing stuff
    float maxm = max_ez;
    if (-min_ez > maxm) maxm = -min_ez;
    
    final int csc = 6000;
    final int csc2 = 28000;
    
    for (int i = 0; i < nx ; i++) {
      for (int j = 0; j < ny; j++) {
        
       { 
        //if (!Mm[i][j]) {
        int mval = (int)( 255*( fld[i][j].Mm));
        // normalized e field
        float val = (fld[i][j].Ez);
        float lval = log(1+abs(val));
        ///maxm;
        stroke(0,0,0);
        
        if (val > 0 ) {
          fill( 0,csc*lval, mval); //csc2*lval);
        } else {
          fill( csc*lval, 0, mval); //csc2*lval);
        }
        //} else {
        //   fill(255,255,0); 
        //}
        rect(i*sc,j*sc, sc,sc);
        //point(i,j);
      }
      
      // Magnetic field X
      if (j< ny-1) {
        float val = fld[0][0].EzC*(fld[i][j].Hx);
        float lval = log(1+abs(val));
        ///maxm;
        stroke(0,0,0);
        
        if (val > 0 ) {
          fill( 0,0,csc*lval); //csc2*lval);
        } else {
          fill(0, csc*lval, 0); //csc2*lval);
        }
        //} else {
        //   fill(255,255,0); 
        //}
        rect(i*sc,j*sc + 1*height/3, sc,sc);
      }
      
      // Magnetic field Y
      if(i<nx-1){
        float val = fld[0][0].EzC*(fld[i][j].Hy);
        float lval = log(1+abs(val));
        ///maxm;
        stroke(0,0,0);
        
        if (val > 0 ) {
          fill(0, 0,csc*lval); //csc2*lval);
        } else {
          fill( 0,csc*lval, 0); //csc2*lval);
        }
        //} else {
        //   fill(255,255,0); 
        //}
        rect(i*sc,j*sc + 2*height/3, sc,sc);
      }
    }}

    //println(n + "\t" + t + ":\t" + (max_ez) + "\t" + (min_ez) + ",\tsrc " + 
    //println((int)(csc*log(1+abs(Ez[SX][SY]))));
    /////////////

  t += dt;
  n++;
   
}
