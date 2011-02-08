
float[] pas;
float[] fut;
float[] now;

float x,dx,c;
int nx;
float dt, ctdx2;

float prop =  0.93;//sqrt(0.5);
float f = 1.0;

final int nx_sc = 4;
float maxDt;
float maxDtMult = 25;

PImage tex;

void setup() {
  size(320,nx_sc*60);
  
  frameRate(10);
  
  nx = width/nx_sc;
  pas = new float[nx];
  fut = new float[nx];
  now = new float[nx];

  
  dx = 0.125;
  x = nx*dx;
  
  // wave speed 
  c = 1.0;
  
  dt = dx/c*prop;
 
  ctdx2 = (c*dt/dx)*(c*dt/dx);
  
  maxDt = dt*maxDtMult;
 
  println("ctdx2 = " + ctdx2);
  
  background(100,100,100);
  
  tex = get();
}


float t = 0;

void keyPressed( ) {
   if (key == 'a') {
      t = 0;

   } 
   
   if (key == 'r') {
           
        pas = new float[nx];
  fut = new float[nx];
  now = new float[nx];
  
   }
}



void draw() {
  
  image(tex,-2,-4,width-1, height-1);
  fill(100,100,190,20);
  noStroke();
  rect(0,0,width,height);
 
  t += dt;
  /*
   Wave equation
   
   \partial^2 u / \partial t^2 =  c^2  laplacian u
   
   u / dt^2 =  c^2 u/dx^2   
   
   ( (u(T+dt) - u(T))/dt - (u(T) - u(T-dt))/dt )/dt = c^2 ((u(x+1) - u(x))/dx - (u(x) - u(x-1))/dx)/dx
   
   ( u(T+dt) - 2*u(T) + u(T-dt) )/dt^2 = c^2 ( u(x+1) - 2*u(x) + u(x-1) ) /dx^2
   
   u(T+dt) = (dt^2 * c^2 / dx^2) * ( u(x+1) - 2*u(x) + u(x-1) ) + 2 u(t) - u(T-dt)
       
   u(T+dt) = (dt^2 * c^2 / dx^2) * ( u(x+1,t) + u(x-1,t) ) + 2*(1 - (dt^2 * c^2 / dx^2)) u(x,t) - u(x,T-dt)    
   
   u(T+dt) = prop^2*(u(x+1,t) + u(x-1,t)) + 2*(1 - prop^2)*u(x,t) - u(x,T-dt)    
 
  */
  
  final  float sc = height*0.5;
  
  for (int i = 1; i < nx-1; i++) {
    //fut[i] = ctdx2*(now[i+1] - 2*now[i] + now[i-1]) + 2 * now[i] - pas[i]; 
    fut[i] = ctdx2*(now[i+1] + now[i-1]) + 2 * (1 - ctdx2) * now[i] - pas[i]; 
  }

  // these absorbers assume the direction of the wave- need to decompose
  // wave equation into left and right hand travel directions?
  // that doesn't really make sense, every value can be thought of as a point source
  // which will propagate forward and backward, so on the edge the 
  
  // u(t+dt) = dt c (u(x+0.5) - u(x-0.5))/dx - u(t) )
  
  // the right hand wave is du/dx = -(1/c)*du/dt
  // du/dx = -du/dt
  // fut[i+1] - fut[i] = - (fut[i] - now[i]) 
  // -> fut[i+1] = now[i] 
  
  if (false ) {
   // right hand boundary condition
  fut[nx-1] =  ctdx2*now[nx-2] + 2*(1 - ctdx2)*now[nx-1] + (ctdx2-1)*pas[nx-1]; //f*now[nx-2];
  // left hand boundary condition
  fut[0] = ctdx2*(now[1] + pas[0]) + 2 * (1 - ctdx2) * now[0] - pas[0];  //f*now[1]; 
  } else if (true) {
    // right hand boundary condition
    fut[nx-1] = f*now[nx-2];
    // left hand boundary condition
    fut[0] = f*now[1]; 
  }
  
  // the source signal
  final int src_x = nx/3;
  if ( t < maxDt ) {
    float env = -0.5*cos(t/maxDt*2*PI) + 0.5;
    float val = 0.5;// /*(1-t/maxDt) */cos(t/dt*PI);
    /// tbd shouldn't it be +=?
    fut[src_x] = val*env; //env*noise(t/2.0,t/3.0);
    //if (t + dt > maxDt) println("done sourcing signal");
  } 

  for (int i = 0; i < fut.length; i++) {
    pas[i] = now[i];
    now[i] = fut[i];   
  }
  
  for (int i = 0; i < fut.length; i++) { 
    if (fut[i] > 0) {
      fill(128.0+255.0*fut[i],0,0,200);
      stroke(155,155,200,200);
    } else {
      fill(105,10,100.0+255.0*fut[i],200);
      stroke(95,55,210,200);
    }
    
    if ((i == nx-1) || (i == 0)) {
      fill(0,10,155.0*fut[i],200);
    }
    
    if ((i == src_x) && (t < maxDt)) {
      fill(0,200,155.0*fut[i],200);
    }
    
    rect((float)(nx_sc*i), height/2.0, nx_sc,  - fut[i]*sc);
  }
  
  tex = get();
  
  for (int i = 0; i < fut.length; i++) { 
    if (fut[i] > 0) {
      fill(128.0+355.0*fut[i],0,0,200);
      stroke(255,255,200,200);
    } else {
      fill(105,10,100.0+355.0*fut[i],200);
      stroke(95,55,255,200);
    }
    
    if ((i == nx-1) || (i == 0)) {
      fill(0,10,255.0*fut[i],200);
    }
    
    if ((i == src_x) && (t < maxDt)) {
      fill(0,2550,155.0*fut[i],200);
    }
    
    rect((float)(nx_sc*i), height/2.0, nx_sc,  - fut[i]*sc);
  }
   
}
