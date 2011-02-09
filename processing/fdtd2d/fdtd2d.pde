final int sc =  6;

final int nx = 91;
final int ny = 91;

final float c = 2.9979e8;
final float freqq = 1.0e9;
final float lambda = c/freqq;

final float dx = lambda/20.0;
final float dy = dx;

final float dt =(0.95)*dx/c/sqrt(2.0);  // time step
final float nt = round(24.0e-9/dt);    // total number of time steps
final float nT = 5000;

// Updating coefficients for space region !
final float mu0 = 4.0*PI*1.0e-7;        //% permeability of free space
final float eps0 = 1.0/(c*c*mu0);       //% permittivity of free space

final float mu = (1.0)*mu0;            //% permeability of medium
final float eps = (1.0)*eps0;          //% permittivity of medium
final float hx_coef = dt/mu/dy;         //% update coeficient for Hy
final float hy_coef = dt/mu/dx;         //% update coeficient for Hy
final float ez_coef = dt/eps/dx;        //% update coeficient for Ez

final float lrABC = c*dt/dx;

final float BotCoefABC = c*dt/dy;
final float UpCoefABC = c*dt/dy;


//%  allocate memory for field arrays */
float[][] Hx = new float[nx][ny-1];
float[][] Hy = new float[nx-1][ny];
float[][] Ez = new float[nx][ny];

/// blocking mass
float[][] Mm = new float[nx][ny];
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

PImage tex;

void setup() {
  size(nx*sc,ny*sc);
  
  print("hx_coef " + hx_coef + ", hy_coef " + hy_coef);
  frameRate(30);
  
  background(100,100,100);
  
  tex = get();
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
     Hx = new float[nx][ny-1];
     Hy = new float[nx-1][ny];
      Ez = new float[nx][ny];
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
    
    Mm[x][y] = 1.0 - 0.71*(1.0- Mm[x][y]);
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
          Hx[i][j] += -hx_coef*(Ez[i][j+1]-Ez[i][j]);
        }
        
        if (i < nx-1) {
          //  update Hy (Eq: 4.6)
          Hy[i][j] += hy_coef*(Ez[i+1][j] - Ez[i][j]);
        }
        
        if ((i > 0) && (j > 0) && (i < nx-1) && (j < ny-1)) {
          //  update Ez (Eq: 4.7)
          Ez[i][j] += ez_coef*((Hy[i][j] - Hy[i-1][j]) - (Hx[i][j] - Hx[i][j-1]));
        //}
        
          Ez[i][j] *= (1.0-Mm[i][j]);
        
          if (Ez[i][j] > max_ez) { max_ez = Ez[i][j]; }
          if (Ez[i][j] < min_ez) { min_ez = Ez[i][j]; }
        }
    }}

    
    //  additive source */
    if (n*dt<=2e-9) {
      Ez[SX][SY] += (10-15*cos(2*PI*1e9*n*dt)+6*cos(4*PI*1e9*n*dt)-cos(6*PI*1e9*n*dt))/32;
    
    } else {
      //Ez[SX][SY] = 0.0;
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    /// ABC left right
    
    float cdtpdx = (c*dt + dx);
    float fx_order1 = (c*dt-dx)/cdtpdx;
    float fx_order2 = 2*dx/cdtpdx;
    float fx_order3 = (c*dt)*(c*dt)*dx / (2*(dy*dy)*cdtpdx);
    
    for (int j = 1; j < ny-1; j++) {
        //-----------------------/2nd-order Taflove ABC at x = 0.
        Ez[0][j] = -Ez_pl[1][j] 
            + fx_order1 * (Ez[1][j]      +   Ez_pl[0][j]) 
            + fx_order2 * (Ez_cl[0][j]   +   Ez_cl[1][j]) 
            + fx_order3 * (Ez_cl[0][j+1] - 2*Ez_cl[0][j] + Ez_cl[0][j-1] 
                        +  Ez_cl[1][j+1] - 2*Ez_cl[1][j] + Ez_cl[1][j-1]);
                        
        Ez[nx-1][j] = -Ez_pr[1][j] 
            + fx_order1 * (Ez[nx-2][j]   +   Ez_pr[0][j]) 
            + fx_order2 * (Ez_cr[0][j]   +   Ez_cr[1][j]) 
            + fx_order3 * (Ez_cr[0][j+1] - 2*Ez_cr[0][j] + Ez_cr[0][j-1] 
                        +  Ez_cr[1][j+1] - 2*Ez_cr[1][j] + Ez_cr[1][j-1]);
    }
    
    /// ABC update
    for (int j = 0; j < ny; j++) {
      for (int ind = 0; ind < 2; ind++) {
        Ez_pl[ind][j] = Ez_cl[ind][j];
        // it seems like the current boundary value is 1 dt in the past
        // by the time this value is used
        Ez_cl[ind][j] = Ez[ind][j];
        
        Ez_pr[ind][j] = Ez_cr[ind][j];
        Ez_cr[ind][j] = Ez[nx-ind-1][j];
      }
    }
    
    /// ABC up/bottom
    float cdtpdy = (c*dt + dy);
    float fy_order1 = (c*dt-dy)/cdtpdy;
    float fy_order2 = 2*dy/cdtpdy;
    float fy_order3 = (c*dt)*(c*dt)*dy / (2*(dx*dx)*cdtpdy);
    
    for (int j = 1; j < nx-1; j++) {
        //-----------------------/2nd-order Taflove ABC at y = 0.
        // coordinates loook inconsistent because we want to make the matrices
        // the same indexing in both dimensions
        Ez[j][0] = -Ez_pu[1][j] 
            + fy_order1 * (Ez[j][1]      +   Ez_pu[0][j]) 
            + fy_order2 * (Ez_cu[0][j]   +   Ez_cu[1][j]) 
            + fy_order3 * (Ez_cu[0][j+1] - 2*Ez_cu[0][j] + Ez_cu[0][j-1] 
                        +  Ez_cu[1][j+1] - 2*Ez_cu[1][j] + Ez_cu[1][j-1]);
                   
                        
        Ez[j][ny-1] = -Ez_pb[1][j] 
            + fy_order1 * (Ez[j][ny-2]   +   Ez_pb[0][j]) 
            + fy_order2 * (Ez_cb[0][j]   +   Ez_cb[1][j]) 
            + fy_order3 * (Ez_cb[0][j+1] - 2*Ez_cb[0][j] + Ez_cb[0][j-1] 
                        +  Ez_cb[1][j+1] - 2*Ez_cb[1][j] + Ez_cb[1][j-1]);
                        
    }
    
        /// ABC update
    for (int j = 0; j < nx; j++) {
      for (int ind = 0; ind < 2; ind++) {
        Ez_pu[ind][j] = Ez_cu[ind][j];
        // it seems like the current boundary value is 1 dt in the past
        // by the time this value is used
        Ez_cu[ind][j] = Ez[j][ind];
        
        Ez_pb[ind][j] = Ez_cb[ind][j];
        Ez_cb[ind][j] = Ez[j][ny-ind-1];
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
        
        
        //if (!Mm[i][j]) {
        int mval = (int)( 255*( Mm[i][j]));
        // normalized e field
        float val = (Ez[i][j]);
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
    }}

    //println(n + "\t" + t + ":\t" + (max_ez) + "\t" + (min_ez) + ",\tsrc " + 
    //println((int)(csc*log(1+abs(Ez[SX][SY]))));
    /////////////

  t += dt;
  n++;
   
}
