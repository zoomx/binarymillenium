
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

final float LeftCoefABC = c*dt/dx;
final float RightCoefABC = c*dt/dx;
final float BotCoefABC = c*dt/dy;
final float UpCoefABC = c*dt/dy;


//%  allocate memory for field arrays */
float[][] Hx = new float[nx][ny-1];
float[][] Hy = new float[nx-1][ny];
float[][] Ez = new float[nx][ny];
/// ABC storage
float[][] EzCurLeft = new float[2][ny];
float[][] EzPastLeft = new float[2][ny];
float[][] EzCurRight = new float[2][ny];
float[][] EzPastRight = new float[2][ny];
float[][] EzCurBottom = new float[nx][2];
float[][] EzPastBottom = new float[nx][2];
float[][] EzCurUp = new float[nx][2];

PImage tex;

final int sc = 8;
void setup() {
  size(nx*sc,ny*sc);
  
  frameRate(10);
 
  
  background(100,100,100);
  
  tex = get();
}


float t = 0;
int n = 0;

void keyPressed( ) {
   if (key == 'a') {
     // start source over
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
      EzCurLeft = new float[2][ny];
      EzPastLeft = new float[2][ny];
      EzCurRight = new float[2][ny];
      EzPastRight = new float[2][ny];
      EzCurBottom = new float[nx][2];
      EzPastBottom = new float[nx][2];
      EzCurUp = new float[nx][2]; 
   }
}



void draw() {
  
  //image(tex,-2,-4,width-1, height-1);
  fill(255,0,0,20);
  noStroke();
  rect(0,0,width,height);

  //  update Hx (Eq: 4.5)
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny-1; j++) {
        Hx[i][j] += -hx_coef*(Ez[i][j+1]-Ez[i][j]);
    }}

    //  update Hy (Eq: 4.6)
    for (int i = 0; i < nx-1; i++) {
      for (int j = 0; j < ny; j++) {
        Hy[i][j] += hy_coef*(Ez[i+1][j] - Ez[i][j]);
    }}

    float max_ez = 0;
    float min_ez = 0;
    //  update Ez (Eq: 4.7)
    for (int i = 1; i < nx-1; i++) {
      for (int j = 1; j < ny-1; j++) {
        Ez[i][j] += ez_coef*((Hy[i][j] - Hy[i-1][j]) - (Hx[i][j] - Hx[i][j-1]));
        
        if (Ez[i][j] > max_ez) { max_ez = Ez[i][j]; }
        if (Ez[i][j] < min_ez) { min_ez = Ez[i][j]; }
    }}
    
    float maxm = max_ez;
    if (-min_ez > maxm) maxm = -min_ez;
    
    for (int i = 1; i < nx ; i++) {
      for (int j = 1; j < ny; j++) {
        
        
        // normalized e field
        float val = Ez[i][j]/maxm;
        stroke(0,0,0);
        if (val > 0 ) {
          fill( 0,255*val, 0);
        } else {
          fill( -255*val, 0, 0);
        }
        rect(i*sc,j*sc, sc,sc);
        //point(i,j);
    }}

    println(n + " " + t + ": " + max_ez + " " + min_ez);
    
    //  additive source */
    if (true) { //if (n*dt<=10e-9) {
      Ez[45][45] = cos(t*100);// (10-15*cos(2*PI*1e9*n*dt)+6*cos(4*PI*1e9*n*dt)-cos(6*PI*1e9*n*dt))/32;
    } else {
      Ez[45][45] = 0.0;
    }

  t += dt;
  n++;
   
}
